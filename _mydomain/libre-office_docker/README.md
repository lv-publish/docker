# LibreOffice Online Excel Viewer

## 🚀 Khởi động LibreOffice Docker
```bash
docker-compose up -d
```

## 📊 Xem file Excel

### 🔗 Link trực tiếp để xem file Excel:
```
http://localhost:9980/liboffice/loleaflet/6ba706662/loleaflet.html?file_path=https%3A%2F%2Flvai.surelrn.vn%2Fapi-proxy%2Fapi%2FDocument%2F7659%2Fpreview
```

### 📝 Cách tạo link cho file khác:

1. **Lấy URL của file Excel**
2. **Encode URL** bằng công cụ online hoặc JavaScript:
   ```javascript
   encodeURIComponent('https://example.com/file.xlsx')
   ```
3. **Thay thế vào template:**
   ```
   http://localhost:9980/liboffice/loleaflet/6ba706662/loleaflet.html?file_path=[ENCODED_URL]
   ```

### 🛠 Tool tạo link:
Mở file `index.html` trong trình duyệt để có giao diện tạo link tự động.

## 📋 Cấu hình Docker

### Docker Compose
- **Image**: `libreoffice/online:master`
- **Port**: 9980
- **Service Root**: `/liboffice`
- **SSL**: Disabled (có thể dùng nginx làm SSL termination)

### Custom Config
- File `config/coolwsd.xml` cấu hình service_root = `/liboffice`
- Frame ancestors = `*` để cho phép embed trong iframe
- SSL termination = true

## 🔧 Nginx Integration (Optional)

File `nginx/locations/libre-office.location.conf` để chạy qua nginx:

```nginx
location ^~ /liboffice/ {
    proxy_pass http://127.0.0.1:9980/liboffice/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # WebSocket support
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    
    proxy_connect_timeout 30s;
    proxy_send_timeout 300s;
    proxy_read_timeout 36000s;
    proxy_buffering off;
    proxy_redirect off;
    client_max_body_size 100M;
}
```

## ⚡ Quick Test

1. **Khởi động**: `docker-compose up -d`
2. **Truy cập**: Click link trên hoặc mở `index.html`
3. **Xem file**: File Excel sẽ hiển thị trong LibreOffice Online