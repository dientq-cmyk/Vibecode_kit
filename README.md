# Finance AI Kit

Bộ knowledge base chung để làm việc với AI (Claude Code) cho 3 hệ thống tài chính nội bộ SmartOSC.
Phiên bản: xem `KIT_VERSION.md`.

## Thứ tự đọc

1. **`smartosc/README.md`** — Quick Start chính thức của SmartOSC: xin quyền, cài máy, cài Claude Code + Superpowers,
   quy trình build → deploy. Người mới đọc file này trước.
2. **File này** — kit là gì, AI đã biết gì, gắn kit vào dự án thế nào.
3. Lướt **`rules/`** khi cần chi tiết một luật.

## Kit là gì

| Hệ thống | Làm gì |
|---|---|
| **BMS** — Billing Management System | Hợp đồng, yêu cầu xuất hoá đơn, hoá đơn, thanh toán nhận về, công nợ. Đang chạy. |
| **PMS** — Payment | Thanh toán. Sắp xây. |
| **TMS** — Treasury | Quản lý dòng tiền. Sắp xây. |

3 hệ dùng chung một bộ framework (Next.js + NestJS + Prisma + PostgreSQL) để sau này gọi API lẫn nhau và gộp thành
một platform. Kit gom lại những gì AI đã được dạy qua 6 tháng làm BMS, bỏ phần riêng của BMS, để PMS / TMS không phải
dạy lại từ đầu.

```
finance-ai-kit/
├── README.md              ← bạn đang đọc (cho người)
├── CLAUDE.md              ← điểm vào cho AI
├── KIT_VERSION.md         ← phiên bản kit + changelog
├── install.sh             ← cài / cập nhật kit vào dự án bằng một lệnh
├── smartosc/              ← 2 tài liệu chính thức SmartOSC, nguyên văn (+ VERSION.md)
├── rules/                 ← luật chung, tiếng Việt
└── templates/             ← CLAUDE.md mẫu cho dự án mới
```

## AI đã biết gì

Khi dự án đã gắn kit, AI tự tuân theo các luật dưới đây — bạn không cần nhắc lại.

| Luật | Chi tiết ở |
|---|---|
| Toàn bộ chuẩn SmartOSC: bảo mật, license, Docker, commit, không push `main` | `smartosc/SmartOSC_Coding_Guide.md` |
| Quy trình superpowers theo loại việc: brainstorm → plan → TDD → verify → MR | `rules/ways-of-working.md` |
| Không tự merge MR; không commit / push khi chưa được bảo | `rules/ways-of-working.md` |
| Không sửa file `.env` — chỉ chỉ ra dòng nào cần sửa | `rules/ways-of-working.md` |
| Kiểm trạng thái (git, DB, file…) bằng lệnh trước khi khẳng định | `rules/ways-of-working.md` |
| Thấy rủi ro thì nói + đưa phương án + recommend; viết dễ đọc để PO quyết | `rules/ways-of-working.md` |
| Stack chung + chỗ khác guide SmartOSC; FE / BE tách hẳn; quy ước API tối thiểu | `rules/stack-architecture.md` |
| Phân quyền mặc định chặn, 2 tầng; quyền mới phải lên bảng Access Control | `rules/security-rbac-audit.md` |
| Audit log cho mọi hành động nhạy cảm | `rules/security-rbac-audit.md` |
| Chatbot AI không vượt quyền; hệ thống ngoài thật thì AI chỉ được đọc | `rules/security-rbac-audit.md` |
| Không ký hiệu tiền tệ — luôn `VND 1,250,000`; hiện tên không hiện mã | `rules/ui-data-rules.md` |
| Combobox, autofill, field email, form nháp, HTML an toàn | `rules/ui-data-rules.md` |
| Đọc schema trước; snapshot dữ liệu lịch sử; query DTO; kiểm DI đúng cách | `rules/backend-rules.md` |
| Các lỗi đã gặp ở BMS và luật rút ra | `rules/lessons-learned.md` |

## Khi nào AI sẽ dừng lại hỏi bạn

- Trước khi **đổi schema DB**, đổi DTO, hoặc khi spec không khớp code / schema.
- Trước khi **chạy migration**, lệnh không hoàn tác được, ghi đè / xoá dữ liệu, chọn DB local hay remote.
- Trước khi **thêm / sửa / gỡ quyền** hoặc module.
- Khi ra **endpoint mới**: "có cần ghi Audit Log không?".
- Trước khi **commit, push, mở MR** — và nó không bao giờ tự merge.
- Khi cần **sửa `.env`** — nó chỉ chỉ ra dòng nào, bạn tự sửa.
- Khi bạn hỏi cách dựng DB / server — nó đưa lệnh để bạn tự chạy.
- Trước khi ghi một **luật mới** vào CLAUDE.md hoặc kit.
- Khi cần **đổi giao diện đang chạy** trong lúc làm tính năng mới.

## Gắn kit vào dự án

Mở terminal ở **root repo dự án**, chạy một lệnh:

```bash
curl -fsSL https://raw.githubusercontent.com/dientq-cmyk/Vibecode_kit/main/install.sh | bash
```

Script tự làm:
- Chép kit vào **`docs/ai-kit/`**.
- `CLAUDE.md` ở root: chưa có thì tạo từ template; có rồi thì chèn dòng `@docs/ai-kit/CLAUDE.md` lên đầu.
- Nếu có `apps/api` / `apps/web`: làm tương tự cho `apps/api/CLAUDE.md` (`@../../docs/ai-kit/rules/backend-rules.md`)
  và `apps/web/CLAUDE.md` (`@../../docs/ai-kit/rules/ui-data-rules.md`).
- Không commit. Bạn xem `git diff` rồi commit: `docs(ai-kit): add finance ai kit`.

Cài một phiên bản cố định: thêm `KIT_REF=<tag>` trước `bash`, vd `... | KIT_REF=v1.0.1 bash`.

Không dùng được `curl`? Clone kit về chỗ khác rồi chạy `bash <đường-dẫn-kit>/install.sh` ở root dự án.

Lần đầu mở dự án, Claude Code có thể hỏi bạn có cho phép nạp các file import không — chọn cho phép. Kiểm tra AI đã
nạp kit: gõ `/memory` trong Claude Code, danh sách phải có các file trong `docs/ai-kit/`.

## Khởi tạo dự án mới (PMS / TMS)

1. Tạo repo theo `smartosc/README.md` Step 1–2 (xin repo qua Jira, clone).
2. Chạy lệnh cài ở mục trên — script tạo `CLAUDE.md` ở root từ template.
3. Khi đã có `apps/api` và `apps/web` (sau khi scaffold monorepo), chạy lại lệnh cài để tạo `apps/api/CLAUDE.md` và
   `apps/web/CLAUDE.md` từ template.
4. Mở Claude Code, chạy `/superpowers:brainstorming` để mô tả hệ thống. Điền các mục `TBD` trong 3 file CLAUDE.md
   theo kết quả brainstorm (role, schema, design system…).

## Tool cần có

| Tool | Bắt buộc? | Cài thế nào |
|---|---|---|
| Git, Docker (+ Compose), VS Code, Node.js | Có | Ticket IT — `smartosc/README.md` Step 1.2 |
| Claude Code (tài khoản Pro do IT cấp) | Có | `smartosc/README.md` Step 1.3 |
| Superpowers plugin | Có | `smartosc/README.md` Step 1.3 |
| pnpm | Có | `npm install -g pnpm` (hoặc `corepack enable`) — kit dùng pnpm thay npm, xem `rules/stack-architecture.md` |
| CodeGraph | Tuỳ chọn | Index code để AI tìm nhanh hơn grep. Chỉ có tác dụng khi repo có thư mục `.codegraph/`. |

## Câu lệnh hay dùng

| Muốn | Gõ |
|---|---|
| Làm tính năng mới | `/superpowers:brainstorming` rồi mô tả tính năng |
| Sửa bug | `/superpowers:systematic-debugging` + "Bug: [thấy gì] thay vì [đáng lẽ]. Không đụng code không liên quan." |
| Kiểm trước khi xong | `/superpowers:verification-before-completion` |
| Rà bảo mật nhánh | `/security-review` |
| Kết thúc nhánh / mở MR | `/superpowers:finishing-a-development-branch` → `/superpowers:requesting-code-review` |
| Xử lý comment review | `/superpowers:receiving-code-review` + dán comment |
| Xem AI đã nạp luật nào | `/memory` |
| Hỏi code ở đâu / chạy thế nào (repo có CodeGraph) | "Dùng codegraph tìm …" — hoặc shell `codegraph explore "<tên symbol / câu hỏi>"` |
| Chạy app ở máy | `docker compose up --build` |

Prompt kiểm license, rà production-readiness, handoff DevOps: xem `smartosc/README.md` (Before finishing / Step 3).

## Cập nhật kit

- **Bản gốc** của kit do PO giữ. Sửa ở bản gốc, tăng số trong `KIT_VERSION.md`, ghi changelog.
- Mỗi dự án: chạy lại lệnh cài (chép đè `docs/ai-kit/` bằng bản mới, không đụng nội dung CLAUDE.md của dự án), so
  `KIT_VERSION.md`, commit `docs(ai-kit): update to x.y.z`.
- SmartOSC ra guide mới: làm theo `smartosc/VERSION.md`.
- Gặp lỗi lặp lại ở bất kỳ dự án nào mà đáng thành luật chung → đề xuất thêm vào `rules/lessons-learned.md` và file
  rules liên quan ở bản gốc.
