# Stack & kiến trúc chung

> BMS / PMS / TMS dùng **cùng một bộ framework** để sau này gọi API lẫn nhau và gộp vào một platform mà không
> phải viết lại. Stack dưới đây là stack BMS đang chạy production (2026-10).

## Stack bắt buộc

| Layer | Công nghệ |
|---|---|
| Frontend | Next.js 16 (App Router, RSC), React 19, Tailwind CSS 4 |
| UI primitives | shadcn/ui (Radix + CVA), icon lucide-react (stroke 2px, không emoji) |
| Table | `tanstack/react-table` v8 (+ `tanstack/react-virtual` khi list dài) |
| Data fetching | TanStack Query |
| Backend | NestJS 11, TypeScript strict |
| ORM | Prisma 6 |
| Database | PostgreSQL 15 — mỗi hệ một schema/DB riêng |
| Shared types | `packages/shared` — Zod schema + TS type thuần |
| Monorepo | pnpm workspaces (`apps/api`, `apps/web`, `packages/shared`) |
| Auth | JWT trong cookie httpOnly do BE set (thư viện `jose`), mật khẩu `bcryptjs` |
| Unit test | Vitest |
| Chạy local / deploy | Docker Compose — **một file `docker-compose.yml` ở root** chứa app + mọi dependency |
| CI/CD | GitLab CI (`.gitlab-ci.yml`), registry GitLab |

## Khi cần mới thêm

| Công nghệ | Dùng khi |
|---|---|
| Redis 7 + BullMQ | Việc chậm chạy nền: gửi email, tạo PDF, import file lớn (hàng nghìn dòng). Không dùng cho CRUD thường. |
| Recharts | Biểu đồ dashboard |
| MSW (Mock Service Worker) | FE cần làm trước khi BE có endpoint — xoá mock khi BE xong |
| LangChain JS + OpenAI / Claude API | Tính năng AI (xem `security-rbac-audit.md` — chatbot không được vượt quyền) |
| Trích xuất tài liệu (OCR) | Đọc PDF/ảnh hợp đồng. *Ví dụ từ BMS: chạy trong process NestJS, giới hạn 10MB + mime pdf/png/jpeg/webp, throttle vì mỗi lần gọi tốn tiền AI.* |
| Playwright | Test e2e |
| Keycloak SSO | **Hướng đích**, chưa bắt buộc: để 3 hệ dùng chung một lần đăng nhập khi gộp platform. *BMS: code đã có, đang chờ client Keycloak.* Hệ mới giữ BE làm chủ session cookie để cắm SSO sau không phải đổi FE. |

Thêm thư viện mới → nói license trước khi thêm (luật license trong SmartOSC_Coding_Guide).

## Khác biệt so với SmartOSC_Coding_Guide

Guide cho phép: *"If the user has already chosen a different stack, follow their choice."* Các điểm 3 hệ làm khác
default của guide, và cách vẫn giữ đúng tinh thần guide:

| Guide nói | Kit làm | Lý do / cách giữ tinh thần |
|---|---|---|
| Backend Express hoặc Fastify | **NestJS** | Module + DI + guard/decorator hợp với RBAC nhiều tầng và hệ thống lớn. Middleware an ninh vẫn bắt buộc: `helmet()`, `app.enableCors({ origin: <whitelist từ CORS_ORIGINS>, credentials: true })`, rate limit đăng nhập bằng `@nestjs/throttler`. |
| Package manager npm | **pnpm** workspaces | Monorepo FE + BE + shared. Thay `npm ci` bằng `pnpm install --frozen-lockfile`; thay `npm audit --audit-level=high` bằng `pnpm audit --audit-level high`; commit `pnpm-lock.yaml` thay `package-lock.json`. License check vẫn chạy `license-checker-rseidelsohn`. |
| Frontend React hoặc HTML/JS | **Next.js** (React) | Vẫn là React; FE build độc lập với BE. |
| Code trong `src/` | `apps/api/src`, `apps/web/app` | Cấu trúc monorepo. |
| `Dockerfile` ở root dự án | Mỗi app một Dockerfile: `apps/api/Dockerfile`, `apps/web/Dockerfile` | FE / BE build và deploy tách rời. `docker-compose.yml` vẫn **một file ở root**; Dockerfile vẫn multi-stage, non-root, pin base image. |
| CI/CD deploy branch: `main` only | Dự án có thể cho nhánh tích hợp (vd `develop`) tự deploy **staging**; **production** vẫn chỉ deploy từ `main` | Kiểm thử trên staging trước khi cắt lên production. Luồng nhánh cụ thể ghi trong CLAUDE.md của dự án (xem `ways-of-working.md` › Khuyến nghị). |

Mọi điểm còn lại của guide (dev/prod tách, `/health`, Docker non-root, multi-stage, không publish cổng DB, secret
chỉ ở `.env` / GitLab CI-CD Variables…) **giữ nguyên**.

## FE/BE tách riêng

FE và BE là **2 service độc lập hoàn toàn**, chỉ nói chuyện qua REST API + cookie. Cùng monorepo nhưng build và
deploy tách rời. *(chốt ở BMS 2026-05-22)*

| Điểm | Luật |
|---|---|
| Port | API = 4000, Web = 3000, mỗi cái một container. |
| Shared code | **Chỉ** qua `packages/shared` (Zod + type thuần). Không share business logic, không share Prisma client. |
| Database | **Chỉ BE** truy cập. FE không có `DATABASE_URL`, không có Prisma client. |
| Secret | Chỉ ở `.env` của BE. FE chỉ có biến `NEXT_PUBLIC_*` (an toàn để lộ ra trình duyệt). |
| Auth | Cookie httpOnly do BE `Set-Cookie`. FE gọi với `credentials: include`. **Không** lưu token trong localStorage. |
| Routing | FE gọi `/api/v1/*` → Next.js rewrite proxy sang `API_INTERNAL_URL`. |
| Deploy | API restart không kéo web sập (web vẫn serve UI, chỉ fetch lỗi). `pnpm --filter web build` chạy được khi chưa có BE. |

**Cấm:**
- Import file từ `apps/api/src/*` vào `apps/web/*`.
- Gọi service BE trực tiếp từ React component (Server Action dính chặt vào BE).
- FE đọc `DATABASE_URL`, `REDIS_PASSWORD`, API key…; tồn tại file `apps/web/lib/prisma.ts`.
- BE trả về field bí mật (`passwordHash`, token OAuth, mật khẩu SMTP…).
- FE chứa business logic — FE chỉ điều phối UI. FE không query DB.

Kiểm nhanh: xoá thử `apps/web/node_modules/@prisma` rồi `pnpm typecheck && pnpm build` trong `apps/web` — phải pass.

## Quy ước API tối thiểu

Đủ để 3 hệ gọi nhau được về sau. Không thiết kế thêm khi chưa có nhu cầu tích hợp cụ thể.

- Prefix `/api/v1`. Đổi API theo kiểu làm hỏng bên gọi → lên `v2`, giữ `v1` một thời gian.
- Mọi list endpoint trả `{ data: [], total, page, limit }`; `limit` có trần (BMS: 100).
- Tiền: luôn đi kèm **mã tiền tệ 3 chữ** (`VND`, `USD`…), không ký hiệu.
- Ngày giờ: ISO 8601 (`2026-03-15`, `2026-03-15T08:30:00Z`).
- Mỗi hệ một database/schema riêng. **Không hệ nào đọc DB của hệ khác** — muốn dữ liệu thì gọi API.
- Để sau (khi bắt đầu tích hợp): token service-to-service, idempotency key cho lệnh tạo/thanh toán, OpenAPI spec,
  `requestId` xuyên hệ.

## Shared package

- Constant / type dùng ở cả FE và BE (role, status…) đặt trong `packages/shared/src/*.ts` — là nguồn gốc duy nhất.
  FE **import từ shared**, không hardcode chuỗi status / role.
- Thêm role / status mới: (1) sửa `packages/shared` → (2) sửa enum Prisma + migration (**hỏi trước**) →
  (3) để TypeScript báo lỗi những chỗ FE còn thiếu rồi sửa theo.
- 🔴 **API chỉ được `import type` từ shared.** `packages/shared` chỉ có file `.ts`, không build ra JS. Next.js tự
  biên dịch nên web dùng được giá trị; Node chạy API thì **không** → import một hàm / hằng / enum làm API sập lúc khởi
  động (`ERR_MODULE_NOT_FOUND`). Test, `tsc`, eslint đều **không** bắt được lỗi này. *(chốt ở BMS 2026-10-01)*
  - API cần cùng luật với FE → để **bản sao trong API** + test so khớp với bản shared trên một bộ mẫu.
  - Kiểm: `grep -rn "from '@<scope>/shared'" apps/api/src | grep -v "import type\|\.spec\."` phải rỗng, rồi
    `nest build` + chạy bootstrap trên `dist` (xem `backend-rules.md`).
