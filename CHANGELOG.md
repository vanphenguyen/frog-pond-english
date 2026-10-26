# Nhật ký thay đổi

## 0.1.0 (chưa phát hành)
- Bản chơi được đầu tiên: 4 chủ đề (Animals, Fruits, Colors, Numbers), mỗi chủ đề 4 màn.
- Giọng đọc tiếng Anh, hiện nghĩa tiếng Việt khi tìm thấy ếch.
- Tính sao, mở khóa màn, lưu tiến độ trên máy.
- Bản chơi trên web (GitHub Pages) để chơi bằng Safari trên iPhone.
- Bản web: luôn chọn giọng tiếng Anh (trước đây Safari có thể đọc bằng giọng tiếng Việt của máy).
- Câu gợi ý không còn lặp lại: lượt đầu đọc đủ câu, các lượt sau luân phiên câu ngắn (`shortClues` trong JSON).
- Câu đầy đủ "Where is the frog? ..." không còn tự động đọc ở lượt đầu mỗi màn: chơi nhiều màn liên tiếp sẽ không nghe lại câu đó mỗi lần vào màn mới.
- Bỏ "frog" khỏi lời đọc và chữ hiển thị mỗi lượt (ví dụ "Listen! Can you find the apple?" thay vì "Where is the frog? It is under the apple!"): con ếch chỉ là phần thưởng khi chạm đúng, không phải thứ bé cần nghe để tìm, và nhắc đến dễ gây nhầm vì không có hình con ếch trên lá sen nào.
- Thêm từ vựng cho cả 4 chủ đề để chơi lâu đỡ nhàm: Animals 12→20 (elephant, tiger, zebra, sheep, chicken, owl, penguin, turtle), Fruits 12→17 (kiwi, coconut, melon, avocado, blueberry), Colors 9→11 (pink, cyan), Numbers 1–10→1–15.
- Thêm màn 5 (khó nhất) cho mỗi chủ đề: 12 lá sen, chỉ nghe (riêng Colors 11 lá sen vì chủ đề chỉ có 11 từ).
- Hàng ếch ở đầu màn chơi vẫn sáng dần theo số lượt đã giải đúng như cũ, nhưng giờ mỗi lần chọn sai sẽ trừ đi 1 chú ếch, tính dồn trong suốt màn (không xuống dưới 0). Không ảnh hưởng đến cách tính sao cuối màn.
