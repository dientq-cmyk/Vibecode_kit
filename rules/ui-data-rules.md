# Luật UI & hiển thị dữ liệu

> Nạp tự động khi làm việc trong `apps/web/` (import từ `apps/web/CLAUDE.md` của dự án). Design system riêng
> (font, màu, layout shell) mỗi hệ tự ghi trong `apps/web/CLAUDE.md` của mình.

## Hiển thị số, tiền, ngày

- **UI sản phẩm viết tiếng Anh.** Không emoji trong UI sản phẩm.
- 🔴 **Không bao giờ dùng ký hiệu tiền tệ** (`₫ $ £ ¥ A$ S$ ฿ ₩ €`…) ở bất kỳ đâu: list, form, preview, PDF, email,
  dashboard. Luôn **mã 3 chữ đứng trước số**: `VND 1,250,000` · `USD 12,500.00` · `JPY 1,200,000`.
  *Lý do: nhiều đồng tiền cùng dùng `$` (USD/SGD/AUD/HKD) — kế toán review dễ nhầm.*
- 🔴 **Không viết tắt số tiền** (`1.2M`, `850K`) ở **mọi nơi, kể cả dashboard**. Hiển thị đủ, có dấu phân cách hàng
  nghìn. Số lẻ: 0 cho `VND` `JPY` `KRW`; 2 cho `USD` `AUD` `EUR` `SGD` `GBP` `THB`…
  Một hàm format dùng chung toàn app (vd `formatAmount(amount, currency)`), không tự viết lại ở từng trang.
  *Lệch đã biết ở BMS — không lấy làm mẫu: ô tổng của Sale dashboard đang hiện dạng `$1.89M` (thiết kế prototype cũ).
  Hệ mới không làm vậy; muốn ngoại lệ thì PO phải chốt và ghi vào CLAUDE.md của dự án.*
- Số tiền luôn có class `.num` (tabular figures, căn phải).
- Ô trống hiển thị `—` (em-dash). Không để trống, không ghi `N/A`.
- Ngày trong bảng: `15 Mar 2026`; trong input / filter: `2026-03-15`.

## Hiển thị tên, không hiển thị code / id

Mọi label, option, dòng bảng, trang chi tiết, toast hiển thị **`name`** của đối tượng — không hiện UUID, slug, mã
nội bộ. *(chốt ở BMS 2026-05-27)*

- Cần hiện mã cho admin tham khảo → mẫu 2 dòng: tên đậm ở trên, mã nhỏ màu nhạt ở dưới.
- **Ngoại lệ:** mã tiền tệ 3 chữ; mã nghiệp vụ người dùng thật sự đọc (số hoá đơn, số hợp đồng, mã yêu cầu); tab
  "System" chỉ-đọc dành cho admin debug.
- Sai đã gặp: option combobox `{ label: id }`; toast "Updated entity CORP" thay vì tên đầy đủ.

## Tái dùng component

Trước khi tạo button / dropdown / modal / drawer / badge / pill / card / table: **tìm component đã có** trong
`components/ui/` và `components/<feature>/`. Có thì dùng lại; chưa có thì tạo ở `components/ui/` (chung) hoặc
`components/<feature>/` (theo nghiệp vụ), props rõ ràng — **không** inline style trùng chức năng trong từng trang.
Trong câu trả lời ghi rõ "đã kiểm, dùng lại X" hoặc "không có, tạo mới Y ở đường dẫn Z". *(chốt ở BMS 2026-05-27)*

## Dropdown / Combobox

- **Mọi dropdown dùng một component `<Combobox>` chung**, không dùng `<select>` thuần. *(chốt ở BMS 2026-05-21)*
- Luôn có ô tìm kiếm. Mỗi lần render tối đa 20 option.
- List lớn (khách hàng, dự án, user, hợp đồng, hoá đơn, giao dịch ngân hàng): **tìm phía server** — debounce 250ms,
  gọi `?search=&limit=20&page=1`. List nhỏ (tiền tệ, thuế suất, phòng ban): lọc phía client.
- 🔴 **Combobox tìm phía server phải chèn sẵn option đang chọn** vào đầu `options` nếu nó không có trong trang kết quả
  hiện tại. Không làm thì sau khi gõ tìm kiếm khác / refetch / mở form sửa, **nhãn biến mất** dù value vẫn còn.
  Giữ label của value đã chọn (state lúc chọn, hoặc gọi `/resource/:id`). *(chốt ở BMS 2026-05-30, lỗi lặp 2 lần)*
- Chọn đối tượng cha → dropdown con phải refetch theo cha (vd chọn Customer → Project lọc `?customerId=`). Xem
  `backend-rules.md` mục lọc chéo.

## Autofill

- Dữ liệu đã có ở đối tượng gốc (khách hàng / dự án / hợp đồng) → **tự điền**, không bắt người dùng chọn lại. Chỉ hiện
  dropdown khi thật sự cần cho phép ghi đè. Bỏ chọn đối tượng gốc → **reset** mọi field đã tự điền từ nó.
- **Đọc schema trước khi autofill** để lấy đúng nguồn (*ví dụ từ BMS: tiền tệ lấy từ `project.wo_currency`, không từ
  `contract.currency`*).
- 🔴 **Tra không khớp thì cảnh báo, không để trống im lặng.** Nguồn (hệ thống ngoài) có giá trị nhưng hệ mình không
  map được → cảnh báo đỏ ngay tại ô + hiện **giá trị thô từ nguồn** ("Source: "Division 5" — no match, pick
  manually"), bắt chọn lại; cảnh báo tự tắt khi chọn hợp lệ. Nguồn rỗng → để trống, không cảnh báo.
  *(chốt ở BMS 2026-05-30)*

## Field email

- Field nhập email (một hay nhiều) dùng **một component multi-select email chung**: nhiều chip, Enter / dấu phẩy, gợi ý
  dropdown tìm phía server, validate từng email. Không dùng `<input type="email">` đơn.
- Email **nội bộ công ty** → gợi ý từ danh bạ nhân viên (email + họ tên). Email **phía khách** → gợi ý từ liên hệ của
  khách hoặc gõ tự do; không gợi ý nhân viên.
- Đặt tên field email cho rõ **của ai** (nội bộ hay của khách). *Sai đã gặp ở BMS: field email nội bộ đặt nhãn
  "Customer email" → cả team hiểu nhầm.*
- Lưu nhiều email vào cột chuỗi → BE chuẩn hoá (tách dấu phẩy → trim → validate → bỏ trùng → nối lại); DTO dùng
  `@IsString` + chuẩn hoá ở service, không `@IsEmail` đơn.

## HTML từ BE / DB

🔴 Thân thư HTML và mọi HTML đến từ BE / DB chỉ hiển thị qua **iframe `sandbox=""` + `srcDoc`** (một component chung,
vd `<EmailHtmlFrame>`). **Cấm `dangerouslySetInnerHTML`** với nội dung từ BE / DB, kể cả khi BE ghi "đã làm sạch".
Kiểm: `grep -rn dangerouslySetInnerHTML apps/web --include=*.tsx` → 0 kết quả trong code. *(chốt ở BMS 2026-09-23 sau
lỗ XSS thật: tên khách chứa mã độc chạy trong phiên của kế toán.)*

## Form nháp (`draft ?? server`)

Khi form sửa dùng nháp chồng lên dữ liệu server, **nháp phải là `Partial<FormState>` theo từng field**, không phải cả
object — `form = { ...serverForm, ...draft }`; `setForm` chỉ ghi vào nháp những field thật sự đổi. *(chốt ở BMS
2026-08-12)*

- Nháp cả-object → người dùng sửa 1 ô là mọi ô khác đóng băng ở giá trị lúc đó; lưu xong có thể **ghi đè / xoá mất
  dữ liệu** (đã mất danh sách liên hệ của khách ở BMS).
- Drawer / modal không unmount → **reset nháp ở mọi lối thoát**: Cancel, backdrop, ESC, lưu thành công, Approve /
  Reject.
- **Xoá nháp sau khi refetch xong**, không trước: `onSuccess: async () => { await invalidate(); clearDraft(); }`.
- Giá trị suy ra lúc render phải truyền tới **mọi chỗ** dùng (UI, validate, payload), không chỉ một nửa.

## Layout & render

- Mọi bảng có wrapper `overflow-x-auto`. Mọi nút chỉ có icon có `aria-label`.
- `"use client"` chỉ khi thật sự cần (form, tương tác, hooks).
- **Đổi text / thêm icon / đổi width → xem render thật.** `tsc` không bắt được chữ bị cắt. Bảng `table-layout: fixed`
  thì nới width cột khi đổi label; `white-space: nowrap` phải chừa sẵn width; kiểm cả sidebar thu gọn và màn hẹp.
- **Có design handoff thì bám đúng**: layout, spacing, token, đủ state (default / hover / loading / empty / error).
  Handoff thiếu state hoặc mâu thuẫn component có sẵn → hỏi, không tự chế.
- **Làm tính năng mới chỉ THÊM**, không đổi giao diện / hành vi các trang và component dùng chung đang chạy. Buộc phải
  đụng → hỏi trước. *(chốt ở BMS 2026-06-03)*

## Logic thuần tách khỏi page

Form / page lớn **không** nhồi validation, build payload, suy autofill, mapping vào component. Logic thuần (không
React / fetch / DOM) tách ra `apps/web/lib/<feature>/*.ts` + unit test Vitest; page chỉ điều phối UI. Quy trình: viết
test mô tả hành vi hiện tại (RED) → port logic (GREEN) → nối page sang lib → `typecheck` + `build`. *(chốt ở BMS
2026-06-02; mẫu chuẩn BMS: `lib/contract-form/` + 74 test.)*

## Lint web

`lint:ci` của `apps/web` là **`eslint . --max-warnings 0`**. `eslint-config-next` để nhiều rule quan trọng ở mức
**warn** (`react-hooks/exhaustive-deps`, toàn bộ `jsx-a11y`…) → `eslint .` trần exit 0 khi còn warning = không có
gate thật. Trước khi bật cho package mới, chạy local xác nhận đang thật sự 0 warning. *(chốt ở BMS 2026-08-12)*
