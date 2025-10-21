# docker

## Elasticsearch

🎯 Chính xác rồi — giá trị `vm.max_map_count = 65530` trên máy bạn **chính là nguyên nhân gây lỗi 78** khi Elasticsearch khởi động ⚠️

👉 Elasticsearch yêu cầu tối thiểu `vm.max_map_count = 262144` để có thể **allocate đủ vùng nhớ ảo** cho các segment, index và plugin (đặc biệt là ICU hoặc các analyzer nâng cao).

---

## 🧰 Cách khắc phục dứt điểm:

Chạy trên **host** (không phải trong container):

```bash
sudo sysctl -w vm.max_map_count=262144
```

Đảm bảo thay đổi được áp dụng:

```bash
sysctl vm.max_map_count
# Kết quả mong đợi:
# vm.max_map_count = 262144
```

---

## 📝 Để thiết lập vĩnh viễn sau khi reboot

Thêm vào cuối file `/etc/sysctl.conf`:

```bash
vm.max_map_count=262144
```

Rồi load lại cấu hình:

```bash
sudo sysctl -p
```

---

## 🚀 Sau đó restart toàn bộ cluster

```bash
docker compose down -v
docker compose build
docker compose up -d
```

*(`-v` là để đảm bảo các node cũ không giữ lại trạng thái fail)*

---

## ✅ Kiểm tra lại trạng thái

Sau khi khởi động lại, kiểm tra:

```bash
curl -s http://localhost:9200/_cluster/health?pretty
```

👉 Kết quả mong đợi:

```json
{
  "cluster_name" : "es_cluster",
  "status" : "green",
  "number_of_nodes" : 2,
  ...
}
```

Và kiểm tra plugin ICU có sẵn:

```bash
curl -s http://localhost:9200/_cat/plugins?v
```

---

📌 **Tóm lại**:

| Thông số           | Hiện tại | Yêu cầu ES | Trạng thái          |
| ------------------ | -------- | ---------- | ------------------- |
| `vm.max_map_count` | 65530 ❌  | 262144 ✅   | ❌ Gây lỗi 78        |
| Sau khi chỉnh      | 262144 ✅ | 262144 ✅   | ✅ Cluster khởi chạy |

---

