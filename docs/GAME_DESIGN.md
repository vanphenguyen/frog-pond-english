# Thiết kế game: Frog Pond English

## Ý tưởng
Đầm sen có nhiều lá sen, mỗi lá có một hình (con vật, trái cây, màu, số).
Mỗi lượt, giọng đọc chọn ngẫu nhiên một trong các câu của chủ đề — câu đầy đủ
*"Where is the frog? It is under the **apple**!"* hoặc một câu ngắn (*"Find the **apple**!"*,
*"Can you find the **apple**?"*…) — không trùng câu ở lượt ngay trước. Câu đầy đủ không bị
ép đọc ở lượt đầu mỗi màn, nên chơi nhiều màn liên tiếp không bị nghe "Where is the frog?"
lặp lại mỗi lần vào màn mới. Bé chạm vào lá sen đúng để tìm chú ếch.

- **Chọn sai:** lá rung, mờ đi, hiện chữ và đọc từ đó ("banana. Try again!"). Bé vẫn học được một từ mới.
- **Chọn đúng:** ếch nhảy lên, khung gợi ý hiện nghĩa tiếng Việt ("apple = quả táo").
- **Hết màn:** nhận 1–3 sao. 3 sao khi không sai lần nào; 2 sao khi số lần sai không quá nửa số lượt; còn lại 1 sao.
- Màn sau mở khóa khi màn trước có ít nhất 1 sao. Sao được lưu trên máy, chơi lại không bị giảm sao.

## Độ khó
| Màn | Số lá sen | Hiện chữ? | Kỹ năng |
|---|---|---|---|
| 1 | 4 | Có | Nghe + nhìn chữ + nhìn hình |
| 2 | 6 | Có | Như trên, nhiều lựa chọn hơn |
| 3 | 6 | Không ("👂 Listen!") | Chỉ nghe |
| 4 | 9 | Không | Chỉ nghe, nhiều lựa chọn |

## Định dạng file chủ đề (`assets/topics/<id>.json`)
```json
{
  "id": "fruits",
  "title": "Fruits",
  "titleVi": "Trái cây",
  "icon": "🍎",
  "clue": "Where is the frog? It is under the {word}!",
  "shortClues": ["Find the {word}!", "Can you find the {word}?"],
  "words": [
    {"word": "apple", "picture": "🍎", "vi": "quả táo"}
  ],
  "levels": [
    {"pads": 4, "rounds": 4, "showWord": true},
    {"pads": 6, "rounds": 5, "showWord": false, "words": ["apple", "banana", "..."]}
  ]
}
```
- `clue`: câu đầy đủ, `{word}` được thay bằng từ cần tìm. Cũng nằm trong vòng xoay câu đọc mỗi lượt,
  không riêng gì lượt đầu.
- `shortClues` (tùy chọn): các câu ngắn, cùng xoay vòng với `clue`. Bỏ trống thì dùng bộ câu mặc định;
  để `[]` thì lượt nào cũng đọc `clue`. Mỗi câu phải có `{word}`.
- `picture`: emoji hoặc chữ ngắn (ví dụ `"3"`).
- `pads`: số lá sen (không vượt quá số từ của màn). `rounds`: số chú ếch cần tìm.
- `words` (tùy chọn, trong level): chỉ dùng một phần từ vựng của chủ đề.
- Thêm chủ đề mới: tạo file và thêm tên file vào `index.json`.

## Chủ đề hiện có
Animals (12 từ), Fruits (12), Colors (9), Numbers (1–10).

## Ý tưởng cho các phiên bản sau
- Ghi âm giọng người thật thay cho giọng máy.
- Âm thanh hiệu ứng (tiếng ếch, tiếng nước), nhạc nền có nút tắt.
- Chủ đề mới: Body parts, Family, Toys, Weather, Vehicles, Clothes, School things.
- Chế độ "đọc chữ": lá sen hiện chữ thay vì hình.
- Màn ôn tập trộn từ của nhiều chủ đề; sổ từ vựng bé đã học.
- Hình vẽ riêng cho ếch và lá sen (thay emoji) để có phong cách riêng.
- Góc phụ huynh (khóa bằng phép tính) để xem tiến độ, cài đặt.
