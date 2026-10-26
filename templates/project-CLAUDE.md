@docs/ai-kit/CLAUDE.md

# <Tên hệ thống> — CLAUDE.md

> AI đọc file này trước mọi task. Luật chung ở `docs/ai-kit/` (đã nạp ở dòng 1). File này chỉ ghi phần **riêng của
> dự án**. Muốn ghi đè một luật của kit thì ghi rõ ở mục "Ghi đè luật kit".

## 1. Project overview

- **Sản phẩm:** TBD — hệ thống làm gì, cho ai (team nào dùng).
- **Repo:** monorepo pnpm — `apps/api` (NestJS), `apps/web` (Next.js), `packages/shared` (Zod + type).
- **Phương châm:** làm xong từng tính năng cả FE + BE rồi mới sang tính năng khác.

## 2. Roles & data scope

TBD — bảng role (enum trong `packages/shared/src/roles.ts` + Prisma): role · giao diện · thấy data nào · được sửa gì.
Khung: `docs/ai-kit/rules/security-rbac-audit.md` › Roles & data scope.

## 3. Schema reference

- Bản đồ toàn cảnh: `docs/<...>/schema.dbml` — TBD.
- Nguồn thực thi: `apps/api/prisma/schema.prisma`. Lệch nhau → `schema.prisma` thắng.
- 🔴 Task đụng data / API / form / query → đọc `schema.dbml` trước.

## 4. Luồng nhánh & release

TBD — nhánh đích của MR (`develop` hay `main`), khi nào lên `main`, khi nào push tag. Mặc định nếu chưa ghi: theo
SmartOSC guide (feature branch → MR → không push thẳng `main`).

## 5. Integrations

TBD — hệ thống ngoài (kế toán, ngân hàng, cổng thanh toán, hệ thống nội bộ khác). Ghi rõ hệ nào là **thật** (AI chỉ
được đọc).

## 6. Phase status

| Mảng | Status | Ghi chú |
|---|---|---|
| TBD | ⏳ | |

## 7. Ghi đè luật kit

TBD — để trống nếu không ghi đè. Mỗi dòng: luật nào trong kit · dự án làm khác thế nào · lý do · ngày chốt.

## 8. File references

| Khi cần | Đọc file |
|---|---|
| Backend chi tiết | `apps/api/CLAUDE.md` |
| Frontend / design system | `apps/web/CLAUDE.md` |
| Schema đầy đủ | TBD |
| Spec / plan | `docs/superpowers/specs/`, `docs/superpowers/plans/` |
