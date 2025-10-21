# Cấu hình OnlyOffice trên Subpath

Hướng dẫn cấu hình OnlyOffice Document Server chạy trên subpath (ví dụ: `mydomain.vn/onlyoffice`)

## Cấu hình đã thực hiện

File `nginx/conf.d/office.conf` đã được cấu hình để OnlyOffice chạy tại `/onlyoffice` thay vì root domain.

## Truy cập

- **URL chính**: `http://mydomain.vn/onlyoffice`
- **API Editor**: `http://mydomain.vn/onlyoffice/web-apps/apps/api/documents/api.js`
- **Health check**: `http://mydomain.vn/onlyoffice/healthcheck`

## Tích hợp với ứng dụng

### JavaScript/HTML

Khi tích hợp với ứng dụng web, bạn cần chỉnh sửa URL API:

```html
<!DOCTYPE html>
<html>
<head>
    <title>OnlyOffice Editor - Subpath</title>
    <!-- Chú ý thêm /onlyoffice vào đường dẫn -->
    <script type="text/javascript" src="http://mydomain.vn/onlyoffice/web-apps/apps/api/documents/api.js"></script>
</head>
<body>
    <div id="placeholder"></div>
    <script type="text/javascript">
        var docEditor = new DocsAPI.DocEditor("placeholder", {
            "document": {
                "fileType": "docx",
                "key": "unique_document_key_123",
                "title": "Example Document.docx",
                "url": "http://your-app-server/path/to/document.docx"
            },
            "documentType": "word",
            "editorConfig": {
                "callbackUrl": "http://your-app-server/callback",
                "lang": "vi"  // Tiếng Việt
            }
        });
    </script>
</body>
</html>
```

### PHP Integration

```php
<?php
$config = [
    'document' => [
        'fileType' => 'docx',
        'key' => 'unique_key_' . time(),
        'title' => 'Document.docx',
        'url' => 'http://your-app/files/document.docx'
    ],
    'documentType' => 'word',
    'editorConfig' => [
        'callbackUrl' => 'http://your-app/onlyoffice-callback',
        'lang' => 'vi'
    ]
];
?>
<!DOCTYPE html>
<html>
<head>
    <title>OnlyOffice Editor</title>
    <!-- Thêm /onlyoffice vào path -->
    <script src="http://mydomain.vn/onlyoffice/web-apps/apps/api/documents/api.js"></script>
</head>
<body>
    <div id="placeholder"></div>
    <script>
        new DocsAPI.DocEditor("placeholder", <?= json_encode($config) ?>);
    </script>
</body>
</html>
```

### WordPress Integration (với plugin)

Nếu dùng OnlyOffice WordPress plugin, cần cấu hình:

1. **OnlyOffice Settings** trong WordPress Admin
2. **Document Server URL**: `http://mydomain.vn/onlyoffice/`
3. **Secret Key**: (JWT secret từ docker-compose.yml)

### NextCloud Integration

Trong NextCloud admin settings:

1. **Document Server address**: `http://mydomain.vn/onlyoffice/`
2. **Secret key**: (JWT secret từ docker-compose.yml)
3. **Server address for internal requests**: `http://onlyoffice/` (nếu trong cùng Docker network)

## Lưu ý quan trọng

### 1. JWT Configuration

File URL phải có thể truy cập từ OnlyOffice server. Nếu sử dụng JWT, phải include token:

```javascript
// Tạo JWT token (backend)
const jwt = require('jsonwebtoken');
const payload = {
    document: {
        url: "http://your-app/files/document.docx",
        fileType: "docx"
    }
};
const token = jwt.sign(payload, 'your_jwt_secret');

// Frontend config
var config = {
    document: {
        url: "http://your-app/files/document.docx",
        fileType: "docx"
    },
    token: token  // Thêm JWT token
};
```

### 2. CORS Headers

Nếu ứng dụng của bạn ở domain khác, cần cấu hình CORS trong Nginx:

Thêm vào `nginx/conf.d/office.conf`:

```nginx
location /onlyoffice/ {
    # ... existing config ...
    
    # CORS headers
    add_header 'Access-Control-Allow-Origin' '*' always;
    add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
    
    if ($request_method = 'OPTIONS') {
        return 204;
    }
}
```

### 3. File URL Requirements

OnlyOffice cần truy cập URL của file document. File phải:
- ✅ Có thể truy cập qua HTTP/HTTPS
- ✅ Không yêu cầu authentication (hoặc dùng JWT)
- ✅ Content-Type header đúng (`application/vnd.openxmlformats-officedocument.wordprocessingml.document` cho DOCX)
- ✅ Có thể tải xuống trực tiếp

### 4. Callback URL

OnlyOffice sẽ gọi callback URL khi:
- Người dùng save document
- Document bị đóng
- Có lỗi xảy ra

Callback phải xử lý POST request từ OnlyOffice:

```javascript
// Node.js/Express example
app.post('/onlyoffice-callback', (req, res) => {
    const status = req.body.status;
    
    switch(status) {
        case 2: // Document is ready for saving
        case 3: // Document saving error
            const downloadUri = req.body.url;
            // Download and save the document
            // downloadDocument(downloadUri, 'path/to/save');
            break;
        case 6: // Document is being edited
        case 7: // Error has occurred while force saving
            break;
    }
    
    res.json({ error: 0 });
});
```

## Testing

### 1. Kiểm tra OnlyOffice hoạt động

```bash
# Test health check
curl http://mydomain.vn/onlyoffice/healthcheck

# Test API script
curl http://mydomain.vn/onlyoffice/web-apps/apps/api/documents/api.js
```

### 2. Test với file HTML đơn giản

Tạo file `test.html`:

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>OnlyOffice Test</title>
    <script src="http://mydomain.vn/onlyoffice/web-apps/apps/api/documents/api.js"></script>
</head>
<body>
    <h1>OnlyOffice Subpath Test</h1>
    <div id="placeholder" style="height: 600px;"></div>
    
    <script>
        // Test URL - Thay bằng URL file thật của bạn
        var docEditor = new DocsAPI.DocEditor("placeholder", {
            "document": {
                "fileType": "docx",
                "key": "test_key_" + Date.now(),
                "title": "Test Document.docx",
                "url": "https://example.com/sample.docx"  // URL file thật
            },
            "documentType": "word",
            "height": "600px"
        });
        
        console.log("OnlyOffice Editor initialized on subpath!");
    </script>
</body>
</html>
```

## Troubleshooting

### Lỗi: "The document could not be saved"

**Nguyên nhân**: OnlyOffice không thể gọi callback URL

**Giải pháp**:
1. Kiểm tra callback URL có thể truy cập từ container không
2. Nếu callback ở localhost, dùng host.docker.internal (Docker Desktop) hoặc IP của host

### Lỗi: "Download failed"

**Nguyên nhân**: OnlyOffice không thể tải file từ URL

**Giải pháp**:
1. Kiểm tra file URL có thể truy cập công khai
2. Kiểm tra DNS resolution trong Docker
3. Nếu dùng local file, đảm bảo OnlyOffice có thể reach được

### Lỗi: Static resources không load (404)

**Nguyên nhân**: Nginx không proxy đúng static files

**Giải pháp**: Đã cấu hình location block cho `web-apps`, `sdkjs`, `fonts` trong nginx config

### Lỗi: WebSocket connection failed

**Nguyên nhân**: WebSocket không được proxy đúng

**Giải pháp**: Đã cấu hình `Upgrade` và `Connection` headers trong nginx

## Multiple Instances (Nhiều OnlyOffice servers)

Nếu muốn chạy nhiều instance OnlyOffice trên các subpath khác nhau:

```nginx
# OnlyOffice instance 1
location /onlyoffice1/ {
    rewrite ^/onlyoffice1(.*)$ $1 break;
    proxy_pass http://onlyoffice1:80;
    # ... other configs
}

# OnlyOffice instance 2  
location /onlyoffice2/ {
    rewrite ^/onlyoffice2(.*)$ $1 break;
    proxy_pass http://onlyoffice2:80;
    # ... other configs
}
```

## Khởi động lại services

Sau khi thay đổi config:

```bash
# Restart nginx
docker-compose restart nginx

# Hoặc restart tất cả
docker-compose restart

# Xem logs
docker-compose logs -f nginx
docker-compose logs -f onlyoffice
```

## Tham khảo thêm

- [OnlyOffice API Documentation](https://api.onlyoffice.com/editors/config/)
- [OnlyOffice Integration Examples](https://github.com/ONLYOFFICE/document-server-integration)
- [Nginx Reverse Proxy Guide](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)
