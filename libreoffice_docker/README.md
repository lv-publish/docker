# LibreOffice Online Docker

Triển khai LibreOffice Online sử dụng Docker với nginx proxy.

## 🚀 Khởi chạy

```bash
docker-compose up -d
```

## 📖 Embed Office Files

### Cách sử dụng với tham số URL

LibreOffice Online hỗ trợ embed các file Office thông qua URL parameters:

```
http://libreoffice.tabca.vn/?WOPISrc=<URL_TO_FILE>
```

**Hoặc sử dụng trực tiếp:**
```
http://localhost:3000/?WOPISrc=<URL_TO_FILE>
```

### Ví dụ embed

#### 1. Embed file Word (.docx)
```html
<iframe 
    src="http://libreoffice.tabca.vn/?WOPISrc=https://example.com/document.docx" 
    width="100%" 
    height="600px">
</iframe>
```

#### 2. Embed file Excel (.xlsx)
```html
<iframe 
    src="http://libreoffice.tabca.vn/?WOPISrc=https://example.com/spreadsheet.xlsx" 
    width="100%" 
    height="600px">
</iframe>
```

#### 3. Embed file PowerPoint (.pptx)
```html
<iframe 
    src="http://libreoffice.tabca.vn/?WOPISrc=https://example.com/presentation.pptx" 
    width="100%" 
    height="600px">
</iframe>
```

#### 4. Ví dụ thực tế với file của bạn
```html
<iframe 
    src="http://localhost:3000/?WOPISrc=https://lvai.surelrn.vn/api-proxy/api/Document/7659/preview" 
    width="100%" 
    height="600px">
</iframe>
```

### Các tham số hỗ trợ

| Tham số | Mô tả | Ví dụ |
|---------|-------|-------|
| `WOPISrc` | URL đến file Office | `https://example.com/file.docx` |
| `permission` | Quyền truy cập (view/edit) | `permission=view` |
| `closebutton` | Hiển thị nút đóng | `closebutton=1` |

### Ví dụ đầy đủ

```html
<iframe 
    src="http://libreoffice.tabca.vn/?WOPISrc=https://example.com/document.docx&permission=view&closebutton=1" 
    width="100%" 
    height="700px"
    frameborder="0">
</iframe>
```

### 🔧 Các cách truy cập khác nhau

#### Option 1: Truy cập trực tiếp (đơn giản nhất)
```
http://localhost:3000/
```
Sau đó upload file trực tiếp qua giao diện

#### Option 2: Sử dụng WOPI URL (cần cấu hình)
```
http://localhost:3000/?WOPISrc=https://lvai.surelrn.vn/api-proxy/api/Document/7659/preview
```

#### Option 3: Collabora Online (Khuyến nghị cho embed URL)

**Collabora Online là gì?**
- Phiên bản thương mại của LibreOffice Online
- Được tối ưu để embed file từ URL
- Hỗ trợ tốt hơn cho WOPI protocol
- Dễ cấu hình hơn LibreOffice Online

**⚠️ Lưu ý về License:**
- 🆓 **Miễn phí**: Cho mục đích thử nghiệm và phát triển
- 💰 **Trả phí**: Cho sử dụng th商業 (commercial)
- 📝 **License**: Cần mua license cho production
- 🔢 **Giới hạn**: Bản free có giới hạn số người dùng đồng thời

**Thay thế LibreOffice bằng Collabora:**
```yaml
services:
  collabora:
    image: collabora/code:latest
    container_name: collabora
    ports:
      - "9980:9980"
    environment:
      - domain=localhost
      - username=admin
      - password=admin
      - DONT_GEN_SSL_CERT=1
    restart: unless-stopped
```

**Cách sử dụng với URL:**
```
http://localhost:9980/loleaflet/dist/loleaflet.html?WOPISrc=https://lvai.surelrn.vn/api-proxy/api/Document/7659/preview
```

## 📁 Định dạng file hỗ trợ

- **Word**: .doc, .docx, .odt
- **Excel**: .xls, .xlsx, .ods  
- **PowerPoint**: .ppt, .pptx, .odp
- **PDF**: .pdf

## 🔧 Cấu hình

- **Container**: LibreOffice Online chạy trên port 3000
- **Domain**: libreoffice.tabca.vn
- **Nginx**: Proxy từ domain về localhost:3000

## � Troubleshooting

### LibreOffice Online không mở file từ URL
**Nguyên nhân:** LibreOffice Online cần WOPI server để mở file từ URL bên ngoài.

**Giải pháp:**
1. **Upload trực tiếp:** Truy cập `http://localhost:3000/` và upload file
2. **Sử dụng Collabora Online:** Thay thế LibreOffice bằng Collabora (hỗ trợ URL tốt hơn)
3. **Cấu hình WOPI server:** Phức tạp, cần setup riêng

### Thay đổi sang Collabora Online
```bash
# Dừng LibreOffice
docker-compose down

# Sửa docker-compose.yml thành:
# image: collabora/code:latest
# ports: "9980:9980"
# environment: domain=localhost

docker-compose up -d
```

## 📋 Lưu ý

- LibreOffice Online chủ yếu dùng để upload và chỉnh sửa file trực tiếp
- Để embed file từ URL, nên sử dụng Collabora Online (cần cân nhắc license)
- File từ URL cần hỗ trợ CORS và có thể truy cập public

## 💡 Giải pháp thay thế MIỄN PHÍ

### OnlyOffice Document Server
```yaml
services:
  onlyoffice:
    image: onlyoffice/documentserver:latest
    container_name: onlyoffice
    ports:
      - "8080:80"
    environment:
      - JWT_ENABLED=false
    restart: unless-stopped
```

**Ưu điểm OnlyOffice:**
- ✅ Hoàn toàn miễn phí
- ✅ Hỗ trợ embed URL tốt
- ✅ Giao diện đẹp như Microsoft Office
- ✅ Không có giới hạn license