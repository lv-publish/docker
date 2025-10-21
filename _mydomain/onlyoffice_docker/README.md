# OnlyOffice Document Server Docker Setup

Hệ thống xem và chỉnh sửa tài liệu Office offline sử dụng OnlyOffice Document Server trên Docker.

## Tính năng

- ✅ Xem và chỉnh sửa tài liệu Word (DOCX, DOC)
- ✅ Xem và chỉnh sửa bảng tính Excel (XLSX, XLS)
- ✅ Xem và chỉnh sửa bản trình bày PowerPoint (PPTX, PPT)
- ✅ Hỗ trợ PDF
- ✅ Chỉnh sửa đồng thời nhiều người (collaborative editing)
- ✅ Bảo mật với JWT
- ✅ Nginx reverse proxy

## Yêu cầu hệ thống

- Docker Engine 20.10+
- Docker Compose 1.29+
- RAM tối thiểu: 4GB
- Dung lượng ổ cứng: 10GB+

## Cài đặt

### 1. Clone hoặc tải xuống dự án

```bash
cd office_docker
```

### 2. Cấu hình môi trường

Sao chép file `.env.example` thành `.env` và chỉnh sửa các giá trị:

```bash
cp .env.example .env
nano .env
```

**Quan trọng:** Thay đổi `JWT_SECRET` thành một chuỗi ngẫu nhiên mạnh:

```bash
# Tạo JWT secret ngẫu nhiên
openssl rand -hex 32
```

### 3. Chỉnh sửa domain trong nginx config

Mở file `nginx/conf.d/office.conf` và thay đổi `office.example.com` thành domain của bạn:

```nginx
server_name your-domain.com;
```

### 4. Khởi chạy dịch vụ

```bash
# Khởi chạy tất cả services
docker-compose up -d

# Xem logs
docker-compose logs -f

# Kiểm tra trạng thái
docker-compose ps
```

### 5. Truy cập

- Trực tiếp qua OnlyOffice: http://localhost:8880
- Qua Nginx proxy: http://localhost hoặc http://your-domain.com

## Cấu hình nâng cao

### SSL/HTTPS

1. Đặt SSL certificate vào thư mục `nginx/ssl/`:
   - `certificate.crt` - SSL certificate
   - `private.key` - Private key

2. Bỏ comment phần HTTPS trong `nginx/conf.d/office.conf`

3. Khởi động lại nginx:
   ```bash
   docker-compose restart nginx
   ```

### Tắt JWT (không khuyến nghị cho production)

Trong `docker-compose.yml`, thay đổi:
```yaml
environment:
  - JWT_ENABLED=false
```

### Tăng giới hạn upload file

Trong `nginx/conf.d/office.conf`, tăng giá trị:
```nginx
client_max_body_size 500M;  # Tăng từ 100M lên 500M
```

## Tích hợp với ứng dụng

### API Endpoints

- Document Server API: `http://your-domain/web-apps/apps/api/documents/api.js`
- Health check: `http://your-domain/healthcheck`

### Ví dụ tích hợp HTML

```html
<!DOCTYPE html>
<html>
<head>
    <title>OnlyOffice Editor</title>
    <script type="text/javascript" src="http://your-domain/web-apps/apps/api/documents/api.js"></script>
</head>
<body>
    <div id="placeholder"></div>
    <script type="text/javascript">
        var docEditor = new DocsAPI.DocEditor("placeholder", {
            "document": {
                "fileType": "docx",
                "key": "unique_document_key",
                "title": "Example Document.docx",
                "url": "http://your-server/path/to/document.docx"
            },
            "documentType": "word",
            "editorConfig": {
                "callbackUrl": "http://your-server/callback"
            }
        });
    </script>
</body>
</html>
```

## Quản lý

### Xem logs

```bash
# Tất cả services
docker-compose logs -f

# Chỉ OnlyOffice
docker-compose logs -f onlyoffice

# Chỉ Nginx
docker-compose logs -f nginx
```

### Khởi động lại

```bash
# Khởi động lại tất cả
docker-compose restart

# Khởi động lại một service
docker-compose restart onlyoffice
```

### Dừng và xóa

```bash
# Dừng services
docker-compose down

# Dừng và xóa volumes (xóa dữ liệu)
docker-compose down -v
```

### Backup dữ liệu

```bash
# Backup volumes
docker run --rm -v office_docker_onlyoffice_data:/data -v $(pwd):/backup alpine tar czf /backup/onlyoffice-backup-$(date +%Y%m%d).tar.gz -C /data .

# Restore
docker run --rm -v office_docker_onlyoffice_data:/data -v $(pwd):/backup alpine tar xzf /backup/onlyoffice-backup-YYYYMMDD.tar.gz -C /data
```

## Xử lý sự cố

### OnlyOffice không khởi động

```bash
# Kiểm tra logs
docker-compose logs onlyoffice

# Kiểm tra RAM
docker stats

# Tăng RAM limit trong docker-compose.yml
```

### Không mở được tài liệu

1. Kiểm tra JWT secret đúng chưa
2. Kiểm tra file có thể truy cập được qua HTTP không
3. Kiểm tra CORS headers

### Lỗi connection timeout

1. Kiểm tra firewall
2. Kiểm tra network trong Docker
3. Kiểm tra nginx logs: `docker-compose logs nginx`

## Tài liệu tham khảo

- [OnlyOffice Document Server Documentation](https://api.onlyoffice.com/editors/basic)
- [Docker Hub - OnlyOffice](https://hub.docker.com/r/onlyoffice/documentserver)
- [OnlyOffice API Documentation](https://api.onlyoffice.com/)

## Bảo mật

- ✅ Luôn sử dụng JWT trong production
- ✅ Sử dụng HTTPS/SSL
- ✅ Thay đổi JWT secret mặc định
- ✅ Giới hạn truy cập bằng firewall
- ✅ Cập nhật Docker images thường xuyên

## Giấy phép

OnlyOffice Document Server Community Edition là phần mềm mã nguồn mở theo giấy phép AGPL v3.
