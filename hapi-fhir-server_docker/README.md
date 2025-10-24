# HAPI FHIR Server Docker Deployment

Dự án này triển khai HAPI FHIR Server với hỗ trợ FHIR R4B và PostgreSQL database sử dụng Docker Compose.

## Tổng quan

HAPI FHIR là một implementation mã nguồn mở của HL7 FHIR standard. Cấu hình này thiết lập:

- **HAPI FHIR Server**: Phiên bản R4B với đầy đủ tính năng
- **PostgreSQL Database**: Lưu trữ dữ liệu FHIR resources 
- **Docker Compose**: Orchestration và quản lý containers

## Tính năng được hỗ trợ

### FHIR R4B Resources
Server hỗ trợ tất cả resource types chuẩn của FHIR R4B bao gồm:
- Patient, Practitioner, Organization
- Observation, DiagnosticReport, Medication
- Encounter, Condition, Procedure
- Và hơn 100 resource types khác

### Capabilities
- ✅ RESTful API đầy đủ (CREATE, READ, UPDATE, DELETE, SEARCH)
- ✅ FHIR R4B specification compliance
- ✅ PostgreSQL database backend
- ✅ JSON và XML encoding
- ✅ Search parameters và filters
- ✅ Bundle transactions
- ✅ CORS support
- ✅ Web UI để test API
- ✅ Validation của FHIR resources
- ✅ Subscription support (REST hooks)
- ✅ Binary resource storage

## Cấu trúc thư mục

```
hapi-fhir-server_docker/
├── docker-compose.yml          # Docker Compose configuration
├── config/
│   └── application.yaml        # HAPI FHIR server configuration
├── postgres/
│   └── init.sql               # PostgreSQL initialization script
├── nginx/                     # Nginx reverse proxy (tùy chọn)
│   └── conf.d/
│       └── hapi-fhir.conf
└── README.md                  # Documentation này
```

## Yêu cầu hệ thống

- Docker Engine 20.10+
- Docker Compose 2.0+
- Ít nhất 4GB RAM
- 10GB disk space

## Cài đặt và chạy

### 1. Clone repository và chuyển đến thư mục

```bash
cd /path/to/lv-publish/docker/hapi-fhir-server_docker
```

### 2. Khởi động services

```bash
# Khởi động trong background
docker-compose up -d

# Hoặc khởi động và xem logs
docker-compose up
```

### 3. Kiểm tra trạng thái

```bash
# Kiểm tra containers đang chạy
docker-compose ps

# Xem logs
docker-compose logs -f hapi-fhir
docker-compose logs -f postgres
```

### 4. Kiểm tra server

Sau khi khởi động, server sẽ có sẵn tại:

- **FHIR API**: http://localhost:8080/fhir
- **Web UI**: http://localhost:8080/
- **Capability Statement**: http://localhost:8080/fhir/metadata

## Configuration

### HAPI FHIR Server

Cấu hình chính trong `config/application.yaml`:

```yaml
hapi:
  fhir:
    fhir_version: R4B              # Phiên bản FHIR
    server_address: http://localhost:8080/fhir
    default_encoding: JSON         # Mặc định JSON response
    max_page_size: 200            # Kích thước trang tối đa
    allow_multiple_delete: true    # Cho phép xóa nhiều resources
```

### PostgreSQL Database

Cấu hình database:
- **Database**: hapi
- **Username**: hapi  
- **Password**: hapi_password
- **Port**: 5432

### Environment Variables

Có thể override cấu hình thông qua environment variables:

```bash
# Trong docker-compose.yml
environment:
  - hapi.fhir.fhir_version=R4B
  - spring.datasource.url=jdbc:postgresql://postgres:5432/hapi
  - hapi.fhir.default_encoding=JSON
```

## Sử dụng API

### Tạo Patient resource

```bash
curl -X POST http://localhost:8080/fhir/Patient \
  -H "Content-Type: application/json" \
  -d '{
    "resourceType": "Patient",
    "name": [{
      "family": "Doe",
      "given": ["John"]
    }],
    "gender": "male",
    "birthDate": "1990-01-01"
  }'
```

### Tìm kiếm Patients

```bash
# Tìm tất cả patients
curl http://localhost:8080/fhir/Patient

# Tìm theo tên
curl "http://localhost:8080/fhir/Patient?name=John"

# Tìm theo giới tính
curl "http://localhost:8080/fhir/Patient?gender=male"
```

### Lấy Patient cụ thể

```bash
curl http://localhost:8080/fhir/Patient/[id]
```

### Cập nhật Patient

```bash
curl -X PUT http://localhost:8080/fhir/Patient/[id] \
  -H "Content-Type: application/json" \
  -d '{
    "resourceType": "Patient",
    "id": "[id]",
    "name": [{
      "family": "Smith",
      "given": ["John"]
    }],
    "gender": "male",
    "birthDate": "1990-01-01"
  }'
```

## Monitoring và Logs

### Xem logs

```bash
# HAPI FHIR logs
docker-compose logs -f hapi-fhir

# PostgreSQL logs  
docker-compose logs -f postgres

# Tất cả logs
docker-compose logs -f
```

### Health checks

```bash
# Kiểm tra server health
curl http://localhost:8080/fhir/metadata

# Kiểm tra database connection
docker-compose exec postgres pg_isready -U hapi -d hapi
```

## Performance Tuning

### PostgreSQL tuning

Chỉnh sửa `postgres/init.sql` hoặc tạo `postgresql.conf`:

```sql
-- Tăng memory buffers
shared_buffers = '256MB'
effective_cache_size = '1GB'
work_mem = '4MB'
maintenance_work_mem = '64MB'

-- Tối ưu checkpointing  
checkpoint_completion_target = 0.9
wal_buffers = '16MB'
```

### JVM tuning

Chỉnh sửa `JAVA_OPTS` trong docker-compose.yml:

```yaml
environment:
  - JAVA_OPTS=-Xms2g -Xmx4g -XX:+UseG1GC -XX:MaxGCPauseMillis=200
```

## Backup và Restore

### Backup database

```bash
# Backup toàn bộ database
docker-compose exec postgres pg_dump -U hapi hapi > hapi_backup.sql

# Backup với compression
docker-compose exec postgres pg_dump -U hapi -Fc hapi > hapi_backup.dump
```

### Restore database

```bash
# Restore từ SQL file
docker-compose exec -T postgres psql -U hapi hapi < hapi_backup.sql

# Restore từ dump file
docker-compose exec postgres pg_restore -U hapi -d hapi hapi_backup.dump
```

## Troubleshooting

### Server không khởi động

1. Kiểm tra logs:
```bash
docker-compose logs hapi-fhir
```

2. Kiểm tra database connection:
```bash
docker-compose exec postgres pg_isready -U hapi -d hapi
```

3. Kiểm tra memory:
```bash
docker stats
```

### Database connection errors

1. Đảm bảo PostgreSQL đã khởi động:
```bash
docker-compose ps postgres
```

2. Kiểm tra connection string trong `config/application.yaml`

3. Kiểm tra network connectivity:
```bash
docker-compose exec hapi-fhir ping postgres
```

### Performance issues

1. Monitor resource usage:
```bash
docker stats
```

2. Kiểm tra database queries:
```bash
docker-compose exec postgres psql -U hapi -d hapi -c "SELECT * FROM pg_stat_activity;"
```

3. Tăng memory limits trong docker-compose.yml

## Security Considerations

### Production deployment

1. **Thay đổi passwords mặc định**:
```yaml
# In docker-compose.yml
environment:
  POSTGRES_PASSWORD: your_secure_password
```

2. **Sử dụng secrets management**:
```yaml
secrets:
  postgres_password:
    file: ./secrets/postgres_password.txt
```

3. **Cấu hình HTTPS** với reverse proxy (nginx):
```bash
# Xem thư mục nginx/ để có cấu hình example
```

4. **Giới hạn network access**:
```yaml
# Chỉ expose port cần thiết
ports:
  - "127.0.0.1:8080:8080"  # Chỉ localhost
```

## Advanced Configuration

### Enabling Clinical Reasoning

```yaml
# In config/application.yaml
hapi:
  fhir:
    cr_enabled: true
```

### Enabling Subscriptions

```yaml
hapi:
  fhir:
    subscription:
      resthook_enabled: true
      websocket_enabled: true
```

### Custom Resource Types

Thêm custom resource types vào `supported_resource_types` trong config.

## Useful Commands

```bash
# Khởi động fresh
docker-compose down -v && docker-compose up -d

# Xem resource usage
docker stats

# Backup database quick
docker-compose exec postgres pg_dump -U hapi hapi | gzip > backup_$(date +%Y%m%d_%H%M%S).sql.gz

# Connect to database
docker-compose exec postgres psql -U hapi -d hapi

# Reset data volumes
docker-compose down -v
docker volume prune

# Update to latest image
docker-compose pull
docker-compose up -d
```

## Support

- [HAPI FHIR Documentation](https://hapifhir.io/hapi-fhir/docs/)
- [FHIR R4B Specification](https://hl7.org/fhir/R4B/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## License

Cấu hình này dựa trên HAPI FHIR Starter Project (Apache 2.0 License).