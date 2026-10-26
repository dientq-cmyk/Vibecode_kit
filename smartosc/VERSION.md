# Tài liệu SmartOSC trong kit — phiên bản

Hai file trong folder này là **bản nguyên văn** của tài liệu chính thức SmartOSC. **Không sửa nội dung.**
Chỗ nào BMS/PMS/TMS làm khác guide thì ghi ở `../rules/stack-architecture.md` (mục "Khác biệt so với
SmartOSC_Coding_Guide"), không ghi vào đây.

| File trong kit | Tài liệu gốc | Phiên bản | SmartOSC cập nhật | Ngày lấy về kit |
|---|---|---|---|---|
| `SmartOSC_Coding_Guide.md` | Knowledge base for AI Assistants | 1.3 | 2026-10-19 | 2026-10-26 |
| `README.md` | Vibe Coding at SmartOSC — Quick Start Guide | 1.4 | 2026-10-19 | 2026-10-26 |

Nguồn: https://git02.smartosc.com/ai-projects/smartosc-vibe-coding-guide (cần mạng nội bộ / VPN).

## Cập nhật khi SmartOSC ra bản mới

1. Tải bản raw mới từ git02 (`/-/raw/main/SmartOSC_Coding_Guide.md`, `/-/raw/main/README.md`).
2. Ghi đè **nguyên văn** vào 2 file trong folder này.
3. Sửa bảng trên (phiên bản + 2 cột ngày).
4. Rà `../rules/stack-architecture.md` mục "Khác biệt so với SmartOSC_Coding_Guide" — guide mới có thể đã
   thay đổi chỗ mình đang ghi đè.
5. Tăng số patch trong `../KIT_VERSION.md` và ghi 1 dòng changelog.
6. Chép kit mới vào `docs/ai-kit/` của từng dự án (xem `../README.md`).
