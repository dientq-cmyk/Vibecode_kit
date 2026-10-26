# Bảo mật, phân quyền, audit log

> Bổ sung cho mục "Application Security" của SmartOSC_Coding_Guide (luôn áp dụng). 3 hệ đều là hệ thống tài chính
> — dữ liệu khách hàng, hoá đơn, thanh toán, dòng tiền đều là **dữ liệu nhạy cảm**.

## Roles & data scope

Mỗi hệ tự định nghĩa role trong CLAUDE.md của dự án, theo khung 2 chiều: **giao diện nào** + **thấy data nào** +
**được sửa gì**. Role là enum cố định trong `packages/shared` + Prisma, không thêm role qua UI.

*Ví dụ từ BMS:*

| Role | Data scope | Quyền sửa |
|---|---|---|
| `sale` | Chỉ data của mình | Data của mình |
| `market_lead` | Của mình + các sale báo cáo cho mình (bảng hierarchy 1-n) | Data của mình |
| `accounting` | Toàn bộ data phân hệ kế toán | Toàn bộ |
| `finance` / `hod` | Toàn bộ | Chỉ đọc |
| `admin` | Toàn bộ + chức năng admin | Toàn bộ |

Brainstorm tính năng mới phải hỏi rõ: ai đăng nhập, role nào, ai xem / sửa được data nào. Thiếu câu trả lời thì
dừng hỏi, **không đoán luật phân quyền**.

## RBAC default-deny

- Quyền lưu trong DB: bảng `permissions` (mã dạng `module:action[:scope]`, vd `customer:create`) + bảng nối
  `role_permissions`. Admin chỉnh quyền từng role trên màn **Access Control**.
- **Guard toàn cục, mặc định chặn:** route không khai quyền → 403. Không có route nào "quên khai là mở".
- **2 tầng:** (1) **module access** — vào được phân hệ (`@Permissions('module:x:access')` ở class controller);
  (2) **action + read-scope** — làm được gì (`@Permissions('<resource>:<action>')` ở method). Có action mà không có
  module access ⇒ vô hiệu. *(chốt ở BMS 2026-06-05)*
- Route public dùng `@Public()`; cross-cutting cho mọi user đã đăng nhập dùng `@AnyAuthenticated()`. Endpoint nhạy
  cảm (rbac, user, settings) giữ thêm `@Roles(ADMIN)` cứng — phòng thủ nhiều lớp.
- Mọi route chạm data được bảo vệ kiểm **cả hai**: đã đăng nhập **và** được phép với **đúng bản ghi này** (sở hữu /
  scope). Không tin userId / role gửi từ client.
- 🔴 **Không tự ý thêm / sửa / gỡ quyền hay module.** Trước khi build tính năng liên quan đến quyền → hỏi PO, đợi chốt.
- Gỡ module / tính năng → **retire mã quyền tương ứng** (xoá khỏi seed + migration dọn `role_permissions`), không để
  "module ma" trên bảng.

## Quyền mới phải lên bảng Access Control

Thêm `@Permissions('x:y')` mới (hoặc route mới dùng mã chưa có trên bảng) → **khai luôn trong cùng đợt** ở file định
nghĩa bảng quyền (*BMS: `apps/api/src/permissions/matrix.shape.ts` — `RESOURCE_ACTION_CODE_MAP` +
`MATRIX_RESOURCES`/`MATRIX_MODULES` + `actionLabels`, và `ROLE_CEILING` nếu route có `@Roles(...)`*). **Không được để
quyền chỉ sống trong seed.** *(chốt ở BMS 2026-10-24)*

- Quyền liên quan Admin / Settings (user, rbac, app settings, audit…) → hỏi PO trước khi quyết đưa lên bảng hay để
  Admin-only.
- Phải có **test chặn**: mã không nằm trên bảng, không Admin-only, không nằm trong danh sách miễn (kèm lý do) → test
  đỏ. *BMS: `matrix-coverage.spec.ts`.*
- Mã quyền mới phải có **migration SQL** (`ON CONFLICT DO NOTHING`, grant cả ADMIN) — không chỉ seed. Container
  production chạy `migrate deploy` nhưng **không chạy seed** → thiếu row quyền.

## Kiểm quyền bằng tài khoản thật

Typecheck / build / test xanh **không** chứng minh quyền đúng và UI hiện. Trước khi báo xong một tính năng có quyền:

1. Query read-only xác nhận row quyền có thật trong DB.
2. Restart API, đăng xuất rồi đăng nhập lại (BE và FE đều cache quyền; FE fail-closed nên thiếu mã là ẩn nút).
3. Đi bảng kiểm với ít nhất 3 tài khoản khác role (BMS: ADMIN / ACCOUNTING / FINANCE): thấy tab, thấy nút, gọi API
   ra 200 / 403 đúng, bảng Access Control hiện đúng nhãn, bật / tắt quyền có tác dụng.
4. Lên staging: kiểm pipeline + version trước, rồi lặp lại bảng kiểm.

Nguyên nhân đã gặp ở BMS: mã chỉ có trong seed; migration chưa chạy lên DB dev; quên thêm tab cho route mới; thiếu
nhãn action nên bảng hiện chữ thô; pipeline staging chưa deploy.

## Audit log

*(chốt ở BMS 2026-06-05)*

1. **Mọi thay đổi quyền** (sửa role-permission, bật/tắt module, đổi read-scope, gán/gỡ hierarchy) bắt buộc ghi audit
   (ai, khi nào, role nào, trước / sau). Không ngoại lệ.
2. **Mọi hành động ghi / đổi trạng thái nhạy cảm** (create / edit / delete / approve / issue / cancel / reconcile /
   khoá user / đổi settings / chạy sync…) phải ghi audit.
3. 🔴 **Ra function / endpoint mới → bắt buộc hỏi "có cần ghi Audit Log không?"** trước khi coi là xong. Ghi / đổi
   trạng thái → mặc định **có**; chỉ đọc thuần → hỏi PO xác nhận bỏ qua. Không tự ý bỏ audit.
4. Tối thiểu mỗi entry: actor (userId + role), mã hành động, đối tượng (entity + id), thời điểm, diff / metadata khi
   đổi dữ liệu.
5. Có audit tự động ở tầng DB (extension Prisma) thì **không ghi tay trùng**; giá trị bí mật trong diff phải che.

## Secret & dữ liệu nhạy cảm

- Không log và không trả trong response: mật khẩu, token (OAuth, API key AI, token hệ thống kế toán / ngân hàng),
  mật khẩu SMTP. Endpoint ghi setting bí mật chỉ trả `{ ok, key }`, không trả giá trị.
- Log định danh user bằng **user ID nội bộ**, không bằng email / SĐT.
- Ticket / tài liệu bàn giao chỉ ghi **tên** biến môi trường, không ghi giá trị.
- HTML chèn dữ liệu người dùng (email template, preview) phải escape — xem `backend-rules.md` và `ui-data-rules.md`.

## AI chatbot không vượt quyền

Tính năng hỏi-đáp dữ liệu bằng AI **không được trả lời vượt quyền** của người đang hỏi.

- **Cấm** sinh SQL từ ngôn ngữ tự nhiên rồi chạy thẳng — nó đi vòng qua toàn bộ RBAC, model không biết read-scope.
- Dùng **tool-calling**: mỗi tool là một hàm service đã có kiểm quyền; **bind user context bằng closure** (userId /
  role / scope đóng vào tool lúc tạo, không nhận từ tham số model sinh ra — model không được chọn mình là ai).
- Câu hỏi nằm ngoài các tool → trả lời "không có quyền / không hỗ trợ", không tự chế query.

## Hệ thống bên ngoài thật: AI chỉ được đọc

Với hệ thống ngoài đang chạy thật (phần mềm kế toán, ngân hàng, cổng thanh toán, ERP): AI chỉ được gọi **đọc (GET)**
để đối chiếu. **Cấm** POST / PUT / DELETE — kể cả "thử một bản ghi" — trên tổ chức / tài khoản thật.

- Luồng ghi xây theo tài liệu / OpenAPI của bên đó, kiểm bằng unit test với client giả (mock fetch).
- Giao checklist để PO tự chạy thử sau khi build.
- *Ví dụ từ BMS: Xero (4 tổ chức AU/SG/JP/KR là sổ kế toán thật) — PO chốt 2026-10-18.* Với PMS (thanh toán) luật
  này càng quan trọng: lệnh ghi nhầm là chuyển tiền thật.
