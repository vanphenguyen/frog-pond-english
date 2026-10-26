# Frog Pond English: ghi chú cho Claude

Game Flutter cho trẻ em học từ vựng tiếng Anh: nghe gợi ý, chạm vào lá sen có chú ếch.
Chủ dự án không phải lập trình viên: trả lời bằng tiếng Việt, đơn giản, kèm ảnh chụp màn hình khi đổi giao diện.

## Cấu trúc
- `assets/topics/*.json`: chủ đề từ vựng và màn chơi. **Thêm từ, chủ đề hay màn chơi thì chỉ sửa JSON**, không sửa code. Định dạng xem `docs/GAME_DESIGN.md`.
- `assets/topics/index.json`: danh sách và thứ tự chủ đề trên màn hình chính.
- `lib/models/topic.dart`: đọc JSON và kiểm tra hợp lệ (`Topic.validate`).
- `lib/game/game_session.dart`: luật chơi thuần logic (lượt, chọn sai, tính sao), không phụ thuộc giao diện.
- `lib/screens/`: màn hình chính, chọn màn, màn chơi.
- `lib/widgets/`: đầm sen, lá sen (vẽ bằng code, chưa dùng file ảnh).
- `lib/services/`: giọng đọc (`flutter_tts`) và lưu sao (`shared_preferences`, chỉ lưu trên máy).

## Lệnh
- Kiểm tra trước khi commit: `flutter analyze && flutter test`. Cả hai phải sạch.
- `test/topic_assets_test.dart` kiểm tra mọi file JSON; luôn chạy sau khi sửa dữ liệu.
- Phiên cloud: nếu chưa có lệnh `flutter`, chạy `bash scripts/claude_session_start.sh` (cài Flutter vào `~/flutter`),
  rồi thêm `~/flutter/bin` vào `PATH`.
- Xem giao diện trên cloud: `flutter build web --no-web-resources-cdn`, phục vụ `build/web` bằng `python3 -m http.server`,
  chụp bằng Playwright (Node) khung 390x844 và đặt `locale: 'vi-VN'` (thiếu locale thì Flutter web báo lỗi và trang trắng).
- Container cloud không tải được Android SDK; APK được build bởi GitHub Actions (`.github/workflows/build.yml`).

## Quy ước
- Mã định danh app: `com.phenv.frogpondenglish` (Android và iOS). Không đổi sau khi đã lên store.
- Đây là app trẻ em: không quảng cáo, không thu thập dữ liệu, không cần mạng, không thêm thư viện gửi dữ liệu ra ngoài
  nếu chủ dự án chưa đồng ý (chính sách Google Play Families và Apple Kids Category).
- Mỗi thay đổi đáng kể: cập nhật `CHANGELOG.md`; khi phát hành tăng `version` trong `pubspec.yaml`
  (`x.y.z+build`, số build luôn tăng).
- Làm trên nhánh riêng, mở Pull Request vào `main`.
