# BÁO CÁO ĐỒ ÁN ỨNG DỤNG ĐẶT LỊCH SPA

> **Hướng dẫn sử dụng:** Các nội dung đặt trong dấu `[ ... ]` là phần cần bổ sung hoặc chỉnh sửa trước khi nộp báo cáo.

## 1. Thông tin chung

| Nội dung | Thông tin |
| --- | --- |
| Tên đề tài | Xây dựng ứng dụng đặt lịch dịch vụ spa |
| Môn học | [Tên môn học] |
| Giảng viên hướng dẫn | [Họ và tên giảng viên] |
| Sinh viên thực hiện | [Họ và tên sinh viên] |
| Mã số sinh viên | [Mã số sinh viên] |
| Lớp | [Tên lớp] |
| Thời gian thực hiện | [Từ tháng/năm đến tháng/năm] |

## 2. Giới thiệu đề tài

### 2.1. Lý do chọn đề tài

[Trình bày thực trạng đặt lịch spa theo phương thức truyền thống, những khó khăn của khách hàng và cơ sở spa, sau đó nêu lý do cần xây dựng ứng dụng.]

Ví dụ: Nhu cầu chăm sóc sức khỏe và làm đẹp ngày càng tăng, tuy nhiên việc đặt lịch qua điện thoại hoặc tin nhắn có thể gây nhầm lẫn, trùng lịch và khó quản lý. Vì vậy, đề tài xây dựng một hệ thống đặt lịch spa nhằm giúp khách hàng tìm kiếm dịch vụ, chủ động chọn thời gian và theo dõi lịch hẹn; đồng thời hỗ trợ quản trị viên quản lý hoạt động của spa hiệu quả hơn.

### 2.2. Mục tiêu

- Xây dựng ứng dụng đa nền tảng bằng Flutter với giao diện thân thiện.
- Cho phép người dùng đăng ký, đăng nhập và đăng nhập bằng Google.
- Hiển thị, tìm kiếm và lọc dịch vụ theo danh mục.
- Cho phép khách hàng xem chi tiết dịch vụ và đặt lịch.
- Hỗ trợ khách hàng theo dõi lịch hẹn và cập nhật hồ sơ cá nhân.
- Hỗ trợ quản trị viên quản lý dịch vụ, danh mục, khách hàng và lịch đặt.
- Xây dựng REST API có xác thực, phân quyền và kiểm tra dữ liệu đầu vào.

### 2.3. Phạm vi đề tài

Hệ thống gồm hai nhóm người dùng chính:

- **Khách hàng:** đăng ký, đăng nhập, xem dịch vụ, tìm kiếm, đặt lịch, theo dõi lịch hẹn và quản lý hồ sơ.
- **Quản trị viên:** theo dõi tổng quan, quản lý dịch vụ, danh mục, khách hàng, lịch đặt và cấu hình spa.

[Nêu các nội dung chưa thực hiện hoặc nằm ngoài phạm vi, ví dụ: thanh toán trực tuyến thực tế, gửi SMS, triển khai lên App Store/Google Play.]

## 3. Khảo sát và phân tích yêu cầu

### 3.1. Yêu cầu chức năng

| Mã | Chức năng | Đối tượng | Mô tả ngắn |
| --- | --- | --- | --- |
| F01 | Đăng ký tài khoản | Khách hàng | Tạo tài khoản mới bằng thông tin cá nhân |
| F02 | Đăng nhập | Khách hàng, quản trị viên | Đăng nhập bằng email/mật khẩu hoặc Google |
| F03 | Xem dịch vụ | Khách hàng | Xem danh sách và thông tin chi tiết dịch vụ |
| F04 | Tìm kiếm và lọc | Khách hàng | Tìm dịch vụ theo từ khóa hoặc danh mục |
| F05 | Đặt lịch | Khách hàng | Chọn dịch vụ, ngày giờ và cung cấp thông tin liên hệ |
| F06 | Quản lý lịch hẹn | Khách hàng | Xem các lịch hẹn sắp tới và lịch sử đặt lịch |
| F07 | Quản lý hồ sơ | Khách hàng | Cập nhật thông tin và tùy chọn thông báo |
| F08 | Quản lý dịch vụ | Quản trị viên | Thêm, sửa, xóa và cập nhật hình ảnh dịch vụ |
| F09 | Quản lý danh mục | Quản trị viên | Thêm, sửa, xóa danh mục dịch vụ |
| F10 | Quản lý lịch đặt | Quản trị viên | Xem, tạo và cập nhật trạng thái lịch đặt |
| F11 | Quản lý khách hàng | Quản trị viên | Xem danh sách và thông tin khách hàng |
| F12 | Cấu hình spa | Quản trị viên | Cập nhật thông tin và thiết lập của spa |

### 3.2. Yêu cầu phi chức năng

- Giao diện dễ sử dụng và hiển thị tốt trên thiết bị di động.
- Mật khẩu được băm trước khi lưu trữ; API sử dụng JWT để xác thực.
- Dữ liệu đầu vào được kiểm tra trước khi xử lý.
- Hệ thống có cơ chế phân quyền khách hàng và quản trị viên.
- API có giới hạn tần suất truy cập, CORS, Helmet và ghi nhật ký lỗi.
- Mã nguồn được chia thành các lớp để thuận tiện bảo trì và mở rộng.

### 3.3. Use case

[Chèn sơ đồ use case tại đây. Có thể lưu ảnh trong thư mục `docs/images/` rồi chèn bằng cú pháp sau:]

```md
![Sơ đồ use case](docs/images/use-case.png)
```

### 3.4. Quy trình đặt lịch

1. Khách hàng đăng nhập vào ứng dụng.
2. Khách hàng tìm kiếm và chọn một dịch vụ.
3. Hệ thống hiển thị thông tin chi tiết của dịch vụ.
4. Khách hàng chọn ngày, giờ và nhập thông tin liên hệ.
5. Ứng dụng gửi yêu cầu đặt lịch đến backend.
6. Backend kiểm tra dữ liệu, lưu lịch hẹn và trả kết quả.
7. Lịch hẹn mới xuất hiện trong màn hình lịch hẹn của khách hàng và trang quản trị.

## 4. Công nghệ sử dụng

| Thành phần | Công nghệ | Vai trò |
| --- | --- | --- |
| Ứng dụng | Flutter, Dart | Xây dựng giao diện khách hàng và quản trị viên |
| Quản lý trạng thái | Provider | Đồng bộ trạng thái giữa giao diện và dữ liệu |
| Giao tiếp API | HTTP | Gửi và nhận dữ liệu JSON qua REST API |
| Backend | Node.js, Express.js | Xử lý nghiệp vụ và cung cấp REST API |
| Cơ sở dữ liệu | PostgreSQL, Knex.js | Lưu trữ dữ liệu và quản lý migration |
| Bộ nhớ đệm | Redis | Tăng tốc truy xuất dữ liệu thường dùng |
| Xác thực | JWT, bcryptjs, Google Sign-In | Xác thực tài khoản và bảo vệ API |
| Lưu trữ đám mây | Firebase Admin, Firestore, Storage | Hỗ trợ dữ liệu Firebase và hình ảnh dịch vụ |
| Kiểm tra dữ liệu | Zod | Xác thực dữ liệu đầu vào ở backend |
| Kiểm thử | Jest, Supertest, Flutter Test | Kiểm thử backend và ứng dụng Flutter |
| Triển khai cục bộ | Docker, Docker Compose | Khởi tạo API, PostgreSQL và Redis |

## 5. Thiết kế hệ thống

### 5.1. Kiến trúc tổng thể

Hệ thống sử dụng mô hình client-server. Ứng dụng Flutter gửi yêu cầu HTTP đến REST API. Backend Express xử lý xác thực và nghiệp vụ, sau đó làm việc với PostgreSQL, Redis và các dịch vụ Firebase.

```text
Ứng dụng Flutter
       |
       | HTTP/JSON + JWT
       v
REST API (Node.js + Express)
       |
       +---- PostgreSQL: dữ liệu nghiệp vụ
       +---- Redis: bộ nhớ đệm
       +---- Firebase: xác thực/dữ liệu/hình ảnh hỗ trợ
```

### 5.2. Kiến trúc backend

Backend được tổ chức theo các lớp:

```text
Route -> Controller -> Service -> Repository -> Database
```

- **Route:** khai báo đường dẫn API và middleware.
- **Controller:** tiếp nhận request và trả response.
- **Service:** xử lý quy tắc nghiệp vụ.
- **Repository:** truy xuất và cập nhật dữ liệu.
- **Model/DTO/Validation:** mô tả, chuyển đổi và kiểm tra dữ liệu.

Các module chính gồm `auth`, `users`, `profiles`, `categories`, `spa-services`, `bookings`, `spa-settings` và `health`.

### 5.3. Thiết kế cơ sở dữ liệu

[Chèn sơ đồ ERD và mô tả các bảng chính tại đây.]

Các nhóm dữ liệu chính của hệ thống gồm:

- Người dùng và hồ sơ cá nhân.
- Danh mục dịch vụ và dịch vụ spa.
- Lịch đặt, trạng thái lịch đặt và trạng thái thanh toán.
- Thiết lập thông tin spa.

### 5.4. Thiết kế API

API sử dụng tiền tố mặc định `/api/v1`. Một số nhóm endpoint chính:

| Endpoint | Chức năng |
| --- | --- |
| `/api/v1/health` | Kiểm tra trạng thái backend |
| `/api/v1/auth` | Đăng ký, đăng nhập và xác thực |
| `/api/v1/users` | Quản lý người dùng |
| `/api/v1/profiles` | Quản lý hồ sơ cá nhân |
| `/api/v1/categories` | Quản lý danh mục |
| `/api/v1/services` | Quản lý dịch vụ spa |
| `/api/v1/bookings` | Quản lý lịch đặt |
| `/api/v1/settings` | Quản lý thiết lập spa |

## 6. Cấu trúc mã nguồn

```text
booking_spa_app/
├── Booking_spa_be/          # Backend Node.js/Express
│   ├── src/
│   │   ├── common/          # Middleware, bảo mật, cache, logger
│   │   ├── config/          # Cấu hình môi trường và kết nối
│   │   ├── database/        # Migration và seed
│   │   ├── modules/         # Các module nghiệp vụ
│   │   └── routes/          # Tổng hợp REST API
│   ├── tests/               # Kiểm thử backend
│   └── docker-compose.yml   # API, PostgreSQL và Redis
├── spa_booking_app/         # Ứng dụng Flutter
│   ├── lib/
│   │   ├── admin/           # Chức năng quản trị
│   │   ├── core/            # Cấu hình, giao diện và tiện ích dùng chung
│   │   ├── data/            # API service và nguồn dữ liệu
│   │   ├── models/          # Mô hình dữ liệu
│   │   ├── providers/       # Quản lý trạng thái
│   │   └── screens/         # Các màn hình khách hàng
│   ├── assets/              # Hình ảnh ứng dụng
│   └── test/                # Kiểm thử Flutter
└── README.md                # Báo cáo này
```

## 7. Cài đặt và chạy chương trình

### 7.1. Yêu cầu môi trường

- Node.js và npm/pnpm.
- Flutter SDK và Dart SDK.
- Docker Desktop (khuyến nghị).
- Android Studio/Android Emulator hoặc Chrome.
- Tài khoản Google Cloud/Firebase nếu sử dụng Google Sign-In và Firebase.

### 7.2. Chạy backend bằng Docker

```powershell
cd Booking_spa_be
Copy-Item .env.example .env
docker compose up --build -d
docker compose exec api pnpm db:migrate
docker compose exec api pnpm db:seed
```

Backend được ánh xạ ra địa chỉ `http://localhost:3002/api/v1`. Có thể kiểm tra bằng:

```powershell
Invoke-RestMethod http://localhost:3002/api/v1/health
```

### 7.3. Chạy ứng dụng Flutter

```powershell
cd spa_booking_app
Copy-Item .env.example .env
flutter pub get
flutter run
```

Khi cần chỉ định địa chỉ backend:

```powershell
flutter run --dart-define=API_BASE_URL=http://localhost:3002/api/v1
```

Với Android Emulator, có thể dùng `http://10.0.2.2:3002/api/v1` để truy cập backend chạy trên máy tính.

## 8. Kết quả thực hiện

### 8.1. Các chức năng đã hoàn thành

- [ ] Đăng ký và đăng nhập bằng email/mật khẩu.
- [ ] Đăng nhập bằng Google.
- [ ] Xem, tìm kiếm và lọc dịch vụ.
- [ ] Xem chi tiết dịch vụ.
- [ ] Đặt lịch dịch vụ.
- [ ] Xem và quản lý lịch hẹn.
- [ ] Cập nhật hồ sơ và tùy chọn thông báo.
- [ ] Quản lý dịch vụ và danh mục.
- [ ] Quản lý khách hàng và lịch đặt.
- [ ] Quản lý thiết lập spa.
- [ ] Kiểm thử các chức năng chính.

> Đánh dấu `[x]` cho các chức năng đã kiểm tra và hoàn thành.

### 8.2. Giao diện chương trình

[Chụp ảnh từng màn hình, lưu vào `docs/images/` và bổ sung chú thích.]

Gợi ý các ảnh cần có:

1. Màn hình đăng nhập và đăng ký.
2. Trang chủ.
3. Danh sách và chi tiết dịch vụ.
4. Màn hình đặt lịch.
5. Danh sách lịch hẹn.
6. Hồ sơ người dùng.
7. Trang tổng quan quản trị.
8. Màn hình quản lý dịch vụ và lịch đặt.

### 8.3. Kiểm thử

| STT | Trường hợp kiểm thử | Dữ liệu đầu vào | Kết quả mong đợi | Kết quả thực tế |
| --- | --- | --- | --- | --- |
| 1 | Đăng nhập đúng thông tin | [Email/mật khẩu] | Chuyển đến trang chủ | [Đạt/Không đạt] |
| 2 | Đăng nhập sai mật khẩu | [Dữ liệu thử] | Hiển thị thông báo lỗi | [Đạt/Không đạt] |
| 3 | Tìm kiếm dịch vụ | [Từ khóa] | Hiển thị dịch vụ phù hợp | [Đạt/Không đạt] |
| 4 | Đặt lịch hợp lệ | [Ngày/giờ/dịch vụ] | Tạo lịch hẹn thành công | [Đạt/Không đạt] |
| 5 | Gửi dữ liệu không hợp lệ | [Dữ liệu thử] | Backend từ chối yêu cầu | [Đạt/Không đạt] |
| 6 | Truy cập API cần quyền | [Không có token] | Trả lỗi xác thực | [Đạt/Không đạt] |

Lệnh chạy kiểm thử:

```powershell
# Backend
cd Booking_spa_be
pnpm test

# Flutter
cd ..\spa_booking_app
flutter test
```

## 9. Đánh giá

### 9.1. Kết quả đạt được

[Đánh giá mức độ hoàn thành so với mục tiêu ban đầu, chất lượng giao diện, API, cơ sở dữ liệu và trải nghiệm người dùng.]

### 9.2. Hạn chế

- [Liệt kê chức năng chưa hoàn thiện.]
- [Nêu giới hạn về hiệu năng, bảo mật hoặc kiểm thử.]
- [Nêu giới hạn của môi trường chạy và triển khai.]

### 9.3. Hướng phát triển

- Tích hợp cổng thanh toán trực tuyến.
- Gửi thông báo nhắc lịch qua push notification, email hoặc SMS.
- Cho phép khách hàng đánh giá dịch vụ.
- Bổ sung quản lý nhân viên và phân ca làm việc.
- Xây dựng hệ thống khuyến mãi và mã giảm giá.
- Triển khai backend và ứng dụng lên môi trường thực tế.
- Mở rộng kiểm thử tự động và giám sát hệ thống.

## 10. Kết luận

[Tóm tắt quá trình thực hiện, những kiến thức đã áp dụng, kết quả chính và giá trị thực tiễn của đề tài trong khoảng 1–3 đoạn văn.]

## 11. Tài liệu tham khảo

1. [Flutter Documentation](https://docs.flutter.dev/)
2. [Dart Documentation](https://dart.dev/guides)
3. [Express.js Documentation](https://expressjs.com/)
4. [PostgreSQL Documentation](https://www.postgresql.org/docs/)
5. [Firebase Documentation](https://firebase.google.com/docs)
6. [Knex.js Documentation](https://knexjs.org/guide/)
7. [Bổ sung giáo trình, bài báo hoặc tài liệu khác đã sử dụng.]

## 12. Phân công công việc

> Nếu thực hiện cá nhân, có thể xóa phần này.

| Thành viên | Công việc | Tỷ lệ đóng góp |
| --- | --- | --- |
| [Trần Trung Kiên] | [Thiết kế UI, UX phần login, logout] | [33%] |
| [Hoàng Trần Việt Khải] | [Đảm nhận chức năng đặt lịch và thiết kế giao diện người dùng] | [32%] |
| [Dương Xuân Hưng] | [Đảm nhận toàn bộ Backend và database] | [34%] |

---

**Ngày hoàn thành báo cáo:** [ngày 12/tháng 7/năm 2026]
