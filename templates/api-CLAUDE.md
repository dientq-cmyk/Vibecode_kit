@../../docs/ai-kit/rules/backend-rules.md

# <Tên hệ thống> — Backend rules (apps/api)

> Claude Code tự nạp file này khi làm việc trong `apps/api/`. Luật BE chung đã nạp ở dòng 1. File này chỉ ghi phần
> riêng của dự án. 🔴 Đọc kèm `schema.dbml` trước mọi task đụng data / API / query.

## Database

- Engine: PostgreSQL 15, schema `TBD`.
- Kết nối: qua `DATABASE_URL` trong `.env` (không ghi host / mật khẩu vào file này). Local hay remote: TBD.
- Migration: `prisma migrate dev` (local) / `prisma migrate deploy` (server). Chạy migration lên DB dùng chung → hỏi
  trước.

## RBAC

- Danh sách module + mã quyền: TBD.
- File định nghĩa bảng Access Control: TBD (mọi `@Permissions` mới phải khai ở đây cùng đợt).
- Test chặn quyền chưa lên bảng: TBD.

## Integrations

| Hệ thống | Mục đích | Thật hay mock | Ghi chú |
|---|---|---|---|
| TBD | | | |

## Queue / background jobs

TBD — có dùng Redis + BullMQ không, job nào.

## Luật riêng của dự án

TBD — luật BE đã chốt riêng cho hệ này (kèm ngày chốt + lý do).
