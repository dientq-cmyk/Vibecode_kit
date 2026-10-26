# Cách làm việc với AI

> Áp dụng cho mọi dự án dùng kit (BMS / PMS / TMS). Luật trong file này **thêm vào** SmartOSC_Coding_Guide,
> không thay thế. Mục **Bắt buộc** là luật; mục **Khuyến nghị** là thói quen đã chạy tốt ở BMS, dự án có thể bỏ.
> Nguồn: CLAUDE.md BMS §12, §12.5 + memory làm việc của PO BMS (2026-05 → 2026-10).

## Quy trình theo loại việc

Luôn dùng skill superpowers tương ứng. **Không bỏ bước brainstorm / plan.** Luôn nêu plan + danh sách file sẽ
tạo/sửa **trước** khi bắt đầu sửa.

| Loại việc | Chuỗi skill | Ghi chú |
|---|---|---|
| Làm tính năng mới | `brainstorming` → `writing-plans` → `test-driven-development` → `executing-plans` (hoặc `subagent-driven-development`) | Brainstorm phải hỏi: ai đăng nhập, role nào, ai xem/sửa data nào, data nào nhạy cảm, ảnh/icon/font lấy từ đâu. Plan phải có mục **Security** và **Licensing**. |
| Sửa bug | `systematic-debugging` | Tái hiện trước → tìm nguyên nhân gốc → chỉ sửa cái cần. Không đụng code không liên quan. |
| Xong việc, xin review | `verification-before-completion` → `/security-review` → kiểm license → `finishing-a-development-branch` → `requesting-code-review` | Không bao giờ push thẳng `main`. |
| Nhận review | `receiving-code-review` | Kiểm lại finding trước khi sửa, không gật đầu cho có. |
| Chạy local | `docker compose up --build` → mở `http://localhost:<PORT>` | |
| Lên production | Rà production-readiness → chạy toàn bộ test (còn fail thì dừng) → viết DevOps handoff note (env var **chỉ ghi TÊN**) → ticket Jira portal 600 sau khi merge | Xem `smartosc/README.md` Step 3. |

### Thứ tự build một tính năng (FE + BE cùng lúc)

Làm xong từng tính năng cả FE lẫn BE rồi mới sang tính năng khác. Không build hết FE rồi mới làm BE.

1. Zod schema trong `packages/shared/`.
2. Prisma model + migration (BE) — **hỏi trước**, xem mục Bắt buộc.
3. NestJS controller + service + test (BE).
4. MSW mock handler cho FE (để FE không phải chờ BE).
5. Next.js page + component + test (FE).
6. Xoá MSW mock, nối BE thật.
7. Commit + MR.

## Bắt buộc

### Git & MR
- **AI không bao giờ merge MR.** AI chỉ commit, push nhánh feature, mở MR rồi đưa link và dừng. Không gọi API merge,
  không bật "merge when pipeline succeeds". *Lý do: merge là điểm không quay lại của review; ở BMS đã từng tự merge
  một lần và phải dọn.*
- **Không commit / push / mở MR khi chưa được bảo rõ** ("commit đi", "mở MR"). Sửa file trong working tree thì cứ làm.
  Làm xong thì báo "chưa commit" + tóm tắt file đã đổi. *Lý do: người dùng muốn tự xem diff trước khi nó thành lịch
  sử; push còn kích CI.*
- Repo ở GitLab git02 → là **MR**, không phải PR.

### Secret & môi trường
- **Không Edit/Write bất kỳ file `.env` nào** (`.env`, `.env.local`, `.env.staging`…), kể cả khi người dùng đã nói đúng
  giá trị. Cần đổi thì viết rõ "dòng nào → thành gì" để người dùng tự sửa. Đọc để hiểu cấu hình thì được nhưng
  không in giá trị ra. Áp dụng cả `.env` trên server và GitLab CI/CD Variables. *Lý do: `.env` chứa secret thật,
  không nằm trong git — sửa sai là mất.*

### Hỏi trước khi làm
- **Việc thực thi chưa chắc thì phải hỏi:** chạy migration, lệnh không revert được, chọn DB local hay remote, ghi đè
  / xoá data, đổi cấu hình server. Mô tả việc định làm + hệ quả + 2–3 phương án, đợi chốt. *Lý do: execute đoán sai
  là hỏng thật; viết code đoán sai thì sửa được.*
- **Hướng dẫn chứ không tự chạy hạ tầng.** Người dùng hỏi "làm sao dựng DB / nạp dump / setup server" → trả lời bằng
  các bước đánh số kèm lệnh để **người dùng tự chạy**. Người dùng chọn phương án ≠ cho phép AI thực thi. Việc chỉ đọc
  (đếm dòng, so schema) thì vẫn được làm.
- **Spec / mockup không khớp code hoặc schema → dừng lại hỏi.** Không tự thêm/sửa/xoá cột DB, không nhét data vào
  field sai nghĩa (vd dồn ngày kết thúc hợp đồng vào `notes`), không tạo cột "tạm" (`extra`, `meta_x`, JSON lách),
  không tự đoán ý rồi hack. Đưa 2–3 phương án, đợi chốt. Nếu người dùng chọn phương án sai kỹ thuật thì cảnh báo rõ
  trước khi làm. Áp dụng cho: đổi schema, sửa logic service BE, đổi DTO, đổi cách form lưu xuống BE. *(chốt
  2026-05-26)*
- **Endpoint / function mới → hỏi "có cần ghi Audit Log không?"** trước khi coi là xong. Xem
  `security-rbac-audit.md`.
- **Gặp lỗi lặp lại thì đề xuất ghi vào CLAUDE.md — nhưng hỏi trước.** Sửa xong một lỗi về tooling / pattern có thể
  lặp lại → đề xuất nội dung luật cho người dùng; được đồng ý mới ghi, kèm ngày + anti-pattern cụ thể. Luật dùng chung
  cho cả 3 dự án thì đề xuất đưa vào kit. *(chốt 2026-05-30)*

### Trung thực về trạng thái
- **Kiểm trước khi khẳng định.** Mọi câu "đã X / chưa X" về git, MR, DB, container, file, service phải có lệnh kiểm
  **ngay trong lượt trả lời đó**. Không dựa vào kết quả lượt trước hay trí nhớ. Báo cáo của subagent cũng phải kiểm
  lại finding quan trọng trước khi sửa code theo. *Lý do: trạng thái đổi giữa các lượt — ở BMS từng định xếp MR lên
  một nhánh đã bị xoá sau merge.*
- Test fail thì nói fail kèm output; bước nào bỏ qua thì nói bỏ qua.

### Phản biện & cách viết cho người dùng
- **Thấy rủi ro thì nói, kèm recommend.** Mô tả vấn đề, đưa 2–3 phương án có trade-off, đặt phương án mình recommend
  lên đầu và nói lý do. Người dùng vẫn chọn hướng khác thì cảnh báo một lần rồi làm theo.
- **Viết để người dùng quyết được.** Người dùng thường là PO, không phải người đọc diff:
  - Nói **hậu quả**, không nói cơ chế: *khi nào nổ · lúc đó ai thấy gì · vì sao giờ chưa thấy · sửa mất bao lâu*.
  - Một ý một câu, câu ngắn. Các bước người dùng phải làm thì đánh số, mỗi bước bắt đầu bằng động từ.
  - Tách "tôi đã làm gì" khỏi "bạn cần làm gì".
  - Chi tiết kỹ thuật (tên hàm, file:dòng) để ở báo cáo đầy đủ, không nhét vào phần cần quyết.
  - Không áp dụng cho nội dung gửi agent hoặc ghi vào file — ở đó thuật ngữ chính xác là đúng.
- **Người dùng gửi ảnh thì bám đúng ảnh.** Không rõ ảnh thuộc module / môi trường nào (local, staging, production)
  thì hỏi, đừng đoán.

## Commit & nhánh

Mức bắt buộc = SmartOSC_Coding_Guide:
- Mỗi tính năng / bug một nhánh: `feat/<tên>`, `fix/<tên>`.
- Commit `type(scope): mô tả` — imperative, chữ thường, không dấu chấm cuối, < 72 ký tự.
  Type: `feat` `fix` `docs` `style` `refactor` `test` `chore` `ci` `revert`.
- Mọi thay đổi đi qua MR. **Không push thẳng / force-push `main`.**
- `git status` trước mỗi `git add` — thấy `.env`, `*.key`, `*.pem` thì dừng.

## Khuyến nghị

Thói quen đã chạy tốt ở BMS. Dự án / người dùng khác có thể bỏ hoặc đổi trong CLAUDE.md của dự án.

- **Trả lời bằng tiếng Việt.** Thuật ngữ kỹ thuật, tên field, tên status giữ tiếng Anh. UI sản phẩm vẫn English.
  *Lý do: câu trả lời từng trôi dần sang tiếng Anh giữa hội thoại.*
- **Dùng CodeGraph trước grep** nếu repo đã index (có thư mục `.codegraph/`). Nếu `.codegraph/` không nằm ở root repo
  (vd nằm trong `invoice_v3/`) thì mỗi lần gọi phải truyền `projectPath` trỏ đúng chỗ. Không có index thì bỏ qua —
  index là quyết định của người dùng.
- **Việc lớn thì tách nhiều agent nhỏ theo mối quan tâm** (vd review FE: một agent lo hành vi + tích hợp, một agent
  lo quy ước UI + a11y), nói rõ trong prompt "agent khác lo mảng X, bạn chỉ lo Y". Lỗi `529 Overloaded` là server
  quá tải — tách agent không chữa được, chờ rồi retry.
- **Mô tả MR dài đi qua REST API.** `git push -o merge_request.description=...` không nhận xuống dòng → MR chỉ có 1–2
  câu. Cách làm: ghi mô tả ra file → push tạo MR chỉ với `create` / `target` / `title` → PUT mô tả qua
  `/api/v4/projects/<id>/merge_requests/<iid>` bằng `--data-urlencode "description@file"`. Token lấy theo cách IT đã cấu
  hình trên máy; **không bao giờ in token ra**. macOS không có lệnh `timeout`.
- **Tên biến môi trường TOÀN CHỮ HOA** (`A-Z 0-9 _`), giống nhau ở code, `.env.example`, hướng dẫn. Kênh CI có thể lọc
  bỏ im lặng biến có chữ thường. *Ví dụ từ BMS: biến GitLab khai `APP_<TÊN>`, job deploy cắt tiền tố rồi ghi xuống
  server; một biến có chữ thường đã không tới được staging mà không có lỗi nào.*
- **Luồng nhánh.** *Ví dụ từ BMS (PO chốt 2026-08-13):* nhánh feature rẽ từ `develop`; mọi MR nhắm `develop` (deploy
  staging tự động); chỉ lên `main` khi PO tự quyết hệ thống đã ổn — AI không tự đề xuất merge `develop → main`; bump
  version thì làm bình thường nhưng **hoãn push tag `vX.Y.Z`** tới đợt lên `main` (push tag kích pipeline release).
  PMS / TMS chốt luồng riêng và ghi vào CLAUDE.md của dự án.
