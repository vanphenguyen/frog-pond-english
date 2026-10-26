# 🐸 Frog Pond English

Game cho trẻ em học từ vựng tiếng Anh: nghe gợi ý và tìm chú ếch nấp trong đầm sen.
Viết bằng Flutter, chạy trên Android và iOS từ cùng một mã nguồn.

## Tài liệu
- [Thiết kế game](docs/GAME_DESIGN.md): luật chơi, độ khó, cách thêm chủ đề và màn chơi.
- [Hướng dẫn ra lệnh cho Claude](docs/HUONG_DAN_RA_LENH.md): mẫu lệnh để thêm tính năng, sửa lỗi.
- [Nhật ký thay đổi](CHANGELOG.md).

## Thử trên điện thoại Android
Mỗi lần có thay đổi, GitHub Actions tự build file APK:
**Actions** → lần chạy mới nhất → mục **Artifacts** → tải `frog-pond-apk`, giải nén và cài lên điện thoại
(cần cho phép "cài ứng dụng từ nguồn không xác định").

## Chạy trên máy (khi đã cài Flutter)
```bash
flutter pub get
flutter run          # chạy trên máy ảo hoặc điện thoại đang cắm
flutter test         # chạy kiểm thử
```

## Thông tin app
- Mã định danh: `com.phenv.frogpondenglish`
- Phiên bản: xem `version` trong `pubspec.yaml`
