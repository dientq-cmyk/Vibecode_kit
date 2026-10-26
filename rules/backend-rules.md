# Luật backend (NestJS + Prisma)

> Nạp tự động khi làm việc trong `apps/api/` (import từ `apps/api/CLAUDE.md` của dự án). Chi tiết riêng từng hệ
> (DB host, module, integration) ghi trong `apps/api/CLAUDE.md` của dự án.

## Schema & dữ liệu

- 🔴 **Đọc schema trước** mọi task đụng data / API / form / query. Mỗi dự án giữ một bản đồ toàn cảnh
  (`docs/.../schema.dbml`) + `apps/api/prisma/schema.prisma`. Lệch nhau → **`schema.prisma` thắng** (là nguồn thực
  thi), nhưng đọc `schema.dbml` trước để hiểu quan hệ. Mục đích: viết query đúng đường FK (*ví dụ từ BMS: Project →
  Contract → Customer, không có FK Project → Customer*), dùng đúng tên cột / nullable / kiểu khi thêm field vào DTO.
- 🔴 **Đổi schema phải hỏi trước** (xem `ways-of-working.md`). Sau khi được chốt và đã sửa `schema.prisma` + migration
  → **cập nhật `schema.dbml` cùng đợt**, và ghi rõ trong câu trả lời đã cập nhật gì. *(chốt ở BMS 2026-05-30)*
- Migration chỉ qua Prisma (`migrate dev` ở local, `migrate deploy` ở server). Không viết tay file SQL ngoài luồng
  Prisma, trừ migration dữ liệu có chủ đích (vd grant quyền `ON CONFLICT DO NOTHING`).
- DB dùng chung cho nhiều người → chạy migration là việc **phải hỏi trước**.

## List endpoint & query DTO

- Mọi list endpoint trả `{ data: [], total, page, limit }`.
- `ValidationPipe({ whitelist: true, forbidNonWhitelisted: true })` → query param không khai trong DTO bị 400.
  **Mỗi resource một Query DTO** extend DTO list chung (`page` / `limit` / `search` / `status`, `limit` có `@Max(100)`),
  thêm filter riêng trong đó. *(chốt ở BMS 2026-05-21)*

  ```ts
  // ❌ @Query() pagination: PaginationDto, @Query("customerId") customerId?: string
  // ✅
  export class ProjectsQueryDto extends ListQueryDto {
    @IsOptional() @IsUUID() customerId?: string;
  }
  @Get() findAll(@CurrentUser() u, @Query() query: ProjectsQueryDto) { ... }
  ```
- **Lọc chéo theo quan hệ:** list của đối tượng phụ thuộc phải nhận filter theo đối tượng cha, resolve qua đúng đường
  FK (vd `GET /projects?customerId=` đi qua `contract.customerId`). FE chọn cha → refetch con theo cha.

## Dữ liệu lịch sử: snapshot & sổ cái

Hệ thống tài chính phải giữ đúng dữ liệu tại thời điểm chứng từ được duyệt / phát hành.

- **Snapshot khi chốt:** chứng từ có FK tới đối tượng hay đổi (khách hàng, dự án…) → khi chuyển sang trạng thái chốt
  (Approved), service tự đọc dữ liệu hiện tại và ghi vào cột JSON `*_snapshot`, rồi khoá chứng từ. Trước khi chốt:
  đọc live qua JOIN; từ lúc chốt: đọc từ snapshot. FK chỉ dùng để lọc / điều hướng, **không** để render PDF / email /
  trang chi tiết.
- **Sổ cái tự chứa:** bản ghi cuối cùng (vd hoá đơn đã phát hành) là **bất biến, tự chứa** — mọi nghiệp vụ sau đó
  (công nợ, phân bổ doanh thu, báo cáo) đọc từ chính nó, không join lại bảng master, không đọc lại chứng từ nguồn.
  Data copy từ đối tượng khác nằm trong JSON snapshot (kèm id); data của chính bản ghi nằm ở cột scalar; mỗi dữ kiện
  một chỗ. Báo cáo nhóm / lọc dùng view chiếu JSON ra cột. *(chốt ở BMS 2026-06-06)*
- Người phụ trách / phòng ban / mốc thanh toán đóng băng tại thời điểm phát hành — đổi người phụ trách sau đó không
  làm trôi doanh thu lịch sử.

## RBAC ở controller

Controller mới **bắt buộc** khai `@Permissions('module:x:access')` ở class (guard default-deny chặn nếu thiếu) + mã
action ở method. Chi tiết: `security-rbac-audit.md`.

## Bảo mật ở BE

- 🔴 **Escape mọi giá trị dữ liệu** chèn vào HTML email / template trước khi vào template literal (`escapeHtml`). Markup
  cố định của template thì không escape. Thêm field mới vào template = thêm một dòng escape. Có test khẳng định `<`
  `&` `"` được escape. *(chốt ở BMS 2026-09-23)*
- **Settings chỉ nhận key đã khai báo:** endpoint ghi setting chỉ nhận key nằm trong một bảng luật (mỗi key một luật
  kiểm); key lạ → 400. Ghi setting chỉ trả `{ ok, key }`, không trả giá trị. *(chốt ở BMS 2026-10-12)*
- Upload file: giới hạn kích thước + danh sách mime cho phép + throttle cho endpoint tốn tiền (AI).
- Hệ thống ngoài: dùng stub / mock khi chưa setup thật, không chặn tính năng khác. Với hệ thống thật: AI chỉ GET (xem
  `security-rbac-audit.md`).

## Kiểm DI của NestJS

🔴 **Không kiểm DI của NestJS bằng vitest.** Vitest chạy qua esbuild, không sinh decorator metadata → `@Injectable()`
không có `@Inject()` tường minh resolve thành `undefined` và Nest báo "can't resolve dependencies" **giả**, trong khi
app thật chạy bình thường. *(chốt ở BMS 2026-09-23)*

Cách kiểm đúng: `pnpm --filter api exec nest build` → chạy node bootstrap
`NestFactory.createApplicationContext(AppModule)` trên `dist/src/app.module.js` → in `DI_OK`. Hoặc `pnpm --filter api
start` thật.

Liên quan: API chỉ `import type` từ shared — xem `stack-architecture.md`.

## Queue

Redis + BullMQ chỉ cho việc chậm (email, PDF, import file lớn). CRUD thường không đưa vào queue.

## Lint api

API **không** bật `--max-warnings 0` khi còn nợ lint có chủ đích (*BMS: `no-floating-promises`, `no-unsafe-argument`
đang để warn*). CI chạy lint tuần tự `pnpm -r --workspace-concurrency=1 run lint:ci` — 2 eslint type-aware chạy song
song với `--max-old-space-size=4096` mỗi process dễ bị OOM-kill (exit 137, log chỉ có `Killed`).

## Quy tắc chung

- Không log secret ra response (API key AI, mật khẩu SMTP, token hệ thống kế toán / ngân hàng).
- Không business logic ở FE; FE không query DB.
- Logic thuần trong service tách thành hàm helper có unit test (*ví dụ từ BMS: dashboard tính từ helper thuần của
  module công nợ, không gọi endpoint của màn khác → sửa màn kia không làm vỡ dashboard*).
