# LibreOffice Online (Collabora CODE) Docker Setup

Cấu hình này thiết lập LibreOffice Online server (Collabora CODE) có thể chạy dưới subpath `/liboffice/`.

> **Lưu ý quan trọng**: Khác với OnlyOffice Document Server (không hỗ trợ subpath), LibreOffice Online/Collabora CODE **CÓ THỂ** chạy dưới subpath nếu cấu hình đúng `service_root` và nginx proxy.

## Cấu hình

### Docker Compose
File `docker-compose.yml` chứa cấu hình cho LibreOffice Online container:

- **Image**: `libreoffice/online:master` (Collabora CODE)
- **Port**: 9980 (internal)
- **Service Root**: `/liboffice` (được set qua environment variable)
- **SSL**: Disabled (nginx sẽ xử lý SSL termination)
- **Config**: Mount custom `coolwsd.xml` để cấu hình service_root

### Nginx Location
File `nginx/locations/libre-office.location.conf` chứa cấu hình nginx để:

- **Quan trọng**: Sử dụng `location ^~ /liboffice/` với `proxy_pass http://127.0.0.1:9980/` (có dấu `/` cuối)
- **Không dùng rewrite**: Collabora rất nhạy cảm với path rewriting
- Hỗ trợ WebSocket cho real-time collaboration  
- Cấu hình timeout phù hợp cho large documents
- Disable proxy_redirect để tránh lỗi path

### Custom coolwsd.xml
File `config/coolwsd.xml` cấu hình:

- `<service_root>/liboffice</service_root>` - **BẮT BUỘC** cho subpath
- SSL termination = true (nginx xử lý SSL)
- Frame ancestors = * (cho phép embed trong iframe)
- Admin console settings

## Triển khai

### 1. Khởi động LibreOffice Container
```bash
cd _mydomain/libre-office_docker
docker-compose up -d
```

### 2. Cấu hình Nginx
Include location config vào nginx server block:

```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;
    
    # Include LibreOffice location - QUAN TRỌNG: phải match với service_root
    include /path/to/libre-office.location.conf;
    
    # Other locations...
}
```

### 3. Reload Nginx
```bash
nginx -t
systemctl reload nginx
```

## Truy cập

- **Admin Panel**: `https://your-domain.com/liboffice/browser/dist/admin/admin.html`
- **Document Editor**: Qua WOPI protocol integration

## Tích hợp với ứng dụng

### WOPI Protocol Integration
```javascript
// Example: Open document in LibreOffice Online
const wopiSrc = encodeURIComponent('https://your-app.com/wopi/files/[file-id]');
const accessToken = 'your-wopi-access-token';

// URL pattern cho subpath
const editorUrl = `https://your-domain.com/liboffice/browser/[hash]/ws?WOPISrc=${wopiSrc}&access_token=${accessToken}`;

// Load trong iframe
const iframe = document.createElement('iframe');
iframe.src = editorUrl;
iframe.style.width = '100%';
iframe.style.height = '600px';
document.body.appendChild(iframe);
```

### Direct File Integration
```javascript
// Để xem file trực tiếp (không qua WOPI)
const fileUrl = 'https://your-domain.com/liboffice/browser/[document-hash]';
```

## So sánh với OnlyOffice

| Tính năng              | LibreOffice Online (CODE) | OnlyOffice Document Server |
|------------------------|---------------------------|----------------------------|
| **Subpath Support**    | ✅ Có (cần config đúng)   | ❌ Không hỗ trợ             |
| **SSL Termination**    | ✅ Linh hoạt              | ⚠️ Khó khăn                |
| **WOPI Protocol**      | ✅ Đầy đủ                 | ✅ Có                      |
| **Real-time Collab**   | ✅ WebSocket              | ✅ WebSocket               |
| **Docker Deployment**  | ✅ Dễ dàng                | ✅ Dễ dàng                 |

## Troubleshooting

### ❌ Lỗi 404 khi truy cập /liboffice/
**Nguyên nhân**: `service_root` trong coolwsd.xml không match với nginx location
**Giải pháp**: 
- Kiểm tra `service_root` trong `config/coolwsd.xml` = `/liboffice`
- Restart container: `docker-compose restart`

### ❌ WebSocket connection failed
**Nguyên nhân**: Thiếu headers WebSocket trong nginx
**Giải pháp**: Đảm bảo có:
```nginx
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

### ❌ Infinite loading hoặc blank page
**Nguyên nhân**: 
- `proxy_pass` thiếu dấu `/` cuối
- `proxy_redirect` chưa được disable
**Giải pháp**: Sử dụng:
```nginx
proxy_pass http://127.0.0.1:9980/;  # Có dấu / cuối
proxy_redirect off;
```

### ❌ Cannot embed in iframe
**Nguyên nhân**: Frame ancestors restriction
**Giải pháp**: Set trong coolwsd.xml:
```xml
<frame_ancestors>*</frame_ancestors>
```

### Performance Issues
- Tăng `proxy_read_timeout` lên 36000s cho WebSocket
- Sử dụng SSD storage cho volumes
- Cấu hình thêm memory cho container nếu cần