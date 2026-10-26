# Bài học đã gặp (anti-pattern)

> Những lỗi **đã thật sự xảy ra** ở BMS và đã phải sửa. Mỗi mục: chuyện gì xảy ra → luật rút ra → luật nằm ở đâu
> trong kit. Gặp lỗi mới có thể lặp lại → đề xuất thêm mục ở đây (hỏi PO trước — xem `ways-of-working.md`).

### 2026-05-26 — Nhét dữ liệu vào field sai nghĩa
- **Chuyện gì xảy ra:** schema thiếu cột ngày kết thúc hợp đồng → AI tự dồn giá trị vào `notes`. PO phát hiện sau.
- **Luật rút ra:** spec không khớp schema thì dừng, đưa 2–3 phương án, đợi chốt. Không cột "tạm", không JSON lách.
- **Ở đâu:** `ways-of-working.md` › Hỏi trước khi làm.

### 2026-05-30 — Combobox mất nhãn sau khi tìm kiếm
- **Chuyện gì xảy ra:** sau khi chọn Contract / Customer rồi gõ tìm kiếm khác, ô hiện placeholder dù value vẫn còn —
  vì option đã chọn không còn trong trang kết quả. Lặp lại 2 lần ở 2 form.
- **Luật rút ra:** combobox tìm phía server phải chèn sẵn option đang chọn vào `options`.
- **Ở đâu:** `ui-data-rules.md` › Dropdown / Combobox.

### 2026-05-30 — Autofill không khớp để trống im lặng
- **Chuyện gì xảy ra:** dữ liệu từ hệ thống ngoài không map được → field để trống, người dùng tưởng nguồn không có.
- **Luật rút ra:** cảnh báo đỏ tại ô + hiện giá trị thô từ nguồn.
- **Ở đâu:** `ui-data-rules.md` › Autofill.

### 2026-08-12 — Nháp cả-object làm mất dữ liệu
- **Chuyện gì xảy ra:** form sửa khách hàng dùng nháp cả object; người dùng gõ trước khi chi tiết tải xong → danh sách
  liên hệ đóng băng 1 phần tử → lưu thay cả collection → **mất các liên hệ còn lại**.
- **Luật rút ra:** nháp `Partial<FormState>` theo từng field; reset ở mọi lối thoát; xoá nháp sau refetch.
- **Ở đâu:** `ui-data-rules.md` › Form nháp.

### 2026-08-12 — Comment mô tả sai một merge gate
- **Chuyện gì xảy ra:** comment trong `eslint.config.mjs` khẳng định "giữ mức error nên vi phạm mới bị chặn" — sai, vì
  `react-hooks` và `jsx-a11y` ở mức warn mà `eslint .` exit 0 khi còn warning. Nợ lint tích lại âm thầm.
- **Luật rút ra:** web lint `--max-warnings 0`. Comment mô tả sai một gate còn tệ hơn không có comment.
- **Ở đâu:** `ui-data-rules.md` › Lint web.

### 2026-08 — ESLint chạy song song bị OOM-kill
- **Chuyện gì xảy ra:** `pnpm -r run lint` chạy song song, mỗi process 4GB heap → CI chết exit 137, log chỉ có
  `Killed`.
- **Luật rút ra:** CI lint chạy tuần tự `--workspace-concurrency=1`.
- **Ở đâu:** `backend-rules.md` › Lint api.

### 2026-08-20 — Mã quyền chỉ có trong seed
- **Chuyện gì xảy ra:** thêm mã quyền vào seed; container production chạy `migrate deploy` nhưng không chạy seed →
  staging thiếu quyền, nút không hiện.
- **Luật rút ra:** mã quyền mới phải có migration SQL + test chặn; kiểm bằng 3 tài khoản thật.
- **Ở đâu:** `security-rbac-audit.md` › Quyền mới / Kiểm quyền bằng tài khoản thật.

### 2026-09-22 — Lỗ XSS qua email HTML
- **Chuyện gì xảy ra:** template email chèn tên khách thô; FE hiện `bodyHtml` bằng `dangerouslySetInnerHTML` → tên
  khách chứa `<img onerror=…>` là mã chạy trong phiên của kế toán / admin khi mở Outbox.
- **Luật rút ra:** BE escape mọi giá trị dữ liệu; FE chỉ hiện HTML qua iframe sandbox.
- **Ở đâu:** `backend-rules.md` › Bảo mật ở BE; `ui-data-rules.md` › HTML từ BE / DB.

### 2026-09-23 — DI "hỏng" giả trong vitest
- **Chuyện gì xảy ra:** smoke test compile AppModule bằng vitest báo không resolve được dependency, trong khi app thật
  chạy bình thường.
- **Luật rút ra:** kiểm DI bằng `nest build` + bootstrap trên `dist`.
- **Ở đâu:** `backend-rules.md` › Kiểm DI của NestJS.

### 2026-10-01 — API import giá trị từ shared → sập khi khởi động
- **Chuyện gì xảy ra:** API import một hàm từ `packages/shared` → 2,886 test xanh, lint / typecheck sạch, nhưng
  `nest start` sập ngay (`ERR_MODULE_NOT_FOUND`) — shared chỉ có `.ts`, Node không nạp được.
- **Luật rút ra:** API chỉ `import type` từ shared; cần cùng luật thì để bản sao trong API + test so khớp.
- **Ở đâu:** `stack-architecture.md` › Shared package.

### 2026-10-20 — AI tự tạo DB trên server chung
- **Chuyện gì xảy ra:** PO hỏi cách dựng DB và chọn phương án "DB trắng mới" → AI tự tạo DB trên server dùng chung.
  PO chặn: "bạn phải chỉ tôi làm chứ".
- **Luật rút ra:** chọn phương án ≠ cho phép thực thi; việc hạ tầng thì đưa lệnh để người dùng tự chạy.
- **Ở đâu:** `ways-of-working.md` › Hỏi trước khi làm.

### 2026-10-23 — 17 quyền có hiệu lực nhưng không hiện trên bảng Access Control
- **Chuyện gì xảy ra:** các mã như `invoice_request:submit`, `master_invoice:cancel` chạy ở BE nhưng không có trên
  bảng → Accounting không submit được hoá đơn mà Admin không có chỗ nào để cấp.
- **Luật rút ra:** quyền mới phải khai lên bảng Access Control cùng đợt + test chặn.
- **Ở đâu:** `security-rbac-audit.md` › Quyền mới phải lên bảng Access Control.

### 2026-10-24 — Biến môi trường có chữ thường bị lọc mất im lặng
- **Chuyện gì xảy ra:** biến CI khai tên có chữ thường; bộ lọc của kênh deploy chỉ nhận `A-Z 0-9 _` → biến không tới
  staging, không có lỗi nào, tính năng báo "not configured".
- **Luật rút ra:** tên biến môi trường toàn chữ hoa ở mọi nơi.
- **Ở đâu:** `ways-of-working.md` › Khuyến nghị.

### Từng vấp — khẳng định trạng thái theo trí nhớ
- **Chuyện gì xảy ra:** định xếp MR lên một nhánh feature, nhưng nhánh đó đã bị xoá sau khi merge — chỉ lộ ra lúc push.
  Một lần khác kết luận git server chết vì lệnh `timeout` không tồn tại trên macOS.
- **Luật rút ra:** kiểm trạng thái ngay trong lượt trả lời; đọc kỹ lỗi trước khi kết luận.
- **Ở đâu:** `ways-of-working.md` › Trung thực về trạng thái.
