# Finance AI Kit — luật chung cho AI (BMS / PMS / TMS)

> File này là **điểm vào cho AI**. Dự án nạp nó bằng dòng `@docs/ai-kit/CLAUDE.md` ở đầu `CLAUDE.md` của dự án.
> Phiên bản kit: xem `KIT_VERSION.md`.

## Thứ tự ưu tiên luật

Khi các luật mâu thuẫn, áp dụng theo thứ tự (cao → thấp):

1. **`CLAUDE.md` của dự án** (và `apps/api|web/CLAUDE.md`) — chỉ khi nó **ghi rõ** là ghi đè luật kit.
2. **Luật của kit** — các file trong `rules/`.
3. **`smartosc/SmartOSC_Coding_Guide.md`** — chuẩn chung của SmartOSC.

Chỗ kit cố ý làm khác guide SmartOSC (NestJS, pnpm…) được liệt kê ở `rules/stack-architecture.md` › "Khác biệt so
với SmartOSC_Coding_Guide". Ngoài các chỗ đó, guide SmartOSC áp dụng đầy đủ. Thứ tự import bên dưới **không** quyết
định ưu tiên — thứ tự ở trên mới quyết định.

Mâu thuẫn mà không rõ bên nào thắng → dừng lại hỏi người dùng.

## Nạp

@smartosc/SmartOSC_Coding_Guide.md
@rules/ways-of-working.md
@rules/stack-architecture.md
@rules/security-rbac-audit.md
@rules/lessons-learned.md

## Không nạp ở đây (nạp theo thư mục)

- `rules/ui-data-rules.md` — nạp từ `apps/web/CLAUDE.md` của dự án.
- `rules/backend-rules.md` — nạp từ `apps/api/CLAUDE.md` của dự án.
- `smartosc/README.md` — Quick Start cài máy, dành cho **người**. Chỉ đọc khi người dùng hỏi về cài đặt / quy trình
  deploy SmartOSC.
- `README.md` của kit — dành cho người.

Làm việc ở root mà task đụng UI hoặc BE → tự đọc file rules tương ứng trước khi sửa.
