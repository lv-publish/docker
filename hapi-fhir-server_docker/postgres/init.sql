-- Tạo database và user cho HAPI FHIR
-- Database đã được tạo thông qua environment variables

-- Tạo schema và cấu hình cần thiết
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Cấu hình timezone
SET timezone = 'UTC';

-- Tạo chỉ mục cần thiết cho hiệu suất
-- Các chỉ mục này sẽ được HAPI FHIR tự động tạo, nhưng có thể pre-create một số cơ bản

-- Grant quyền cần thiết
GRANT ALL PRIVILEGES ON DATABASE hapi TO hapi;
GRANT ALL PRIVILEGES ON SCHEMA public TO hapi;

-- Cấu hình PostgreSQL để tối ưu cho HAPI FHIR
-- Những cấu hình này nên được áp dụng trong postgresql.conf trong production
-- ALTER SYSTEM SET shared_buffers = '256MB';
-- ALTER SYSTEM SET effective_cache_size = '1GB';
-- ALTER SYSTEM SET work_mem = '4MB';
-- ALTER SYSTEM SET maintenance_work_mem = '64MB';
-- ALTER SYSTEM SET checkpoint_completion_target = 0.9;
-- ALTER SYSTEM SET wal_buffers = '16MB';
-- ALTER SYSTEM SET default_statistics_target = 100;

-- Tạo bảng để theo dõi migration nếu cần
CREATE TABLE IF NOT EXISTS migration_info (
    version VARCHAR(50) PRIMARY KEY,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    description TEXT
);

INSERT INTO migration_info (version, description) 
VALUES ('1.0.0', 'Initial database setup for HAPI FHIR R4B') 
ON CONFLICT (version) DO NOTHING;