# COTURN
- ip nội bộ tới máy chủ xử lý media trong LAN: 10.0.1.2
- ip public ra internet: 210.2.89.139
- domain đã trỏ vào máy chủ: turn.suremeet.vn, stun.suremeet.vn
- port TCP được mở đi internet: 80, 443
- port UDP vào máy chủ xử lý media: 40000-65000


# cấu hình docker run đang chạy
```bash
docker run -d --restart unless-stopped --network=host coturn/coturn -n --realm=turn.suremeet.vn --listening-port=80 --listening-port=443 --external-ip=210.2.89.139/10.0.1.2 --log-file=stdout
```

# cấu hình kết nối đang chạy
```json
{
    "IceServers": [
      {
        "urls": [
          "stun:stun.suremeet.vn:80",
          "stuns:stun.suremeet.vn:443"
        ],
        "username": "root",
        "credential": "123456"
      },
      {
        "urls": [
          "turn:turn.suremeet.vn:80?transport=tcp",
          "turns:turn.suremeet.vn:443?transport=tcp"
        ],
        "username": "root",
        "credential": "123456"
      }
    ]
}
```

# Cấp chứng chỉ SSL (Let's Encrypt)
```bash
sudo apt update
sudo apt install certbot -y
sudo certbot certonly --standalone -d turn.suremeet.vn
sudo certbot certonly --standalone -d stun.suremeet.vn

ls /etc/letsencrypt/live/turn.suremeet.vn
# cert.pem  chain.pem  fullchain.pem  privkey.pem
ls /etc/letsencrypt/live/stun.suremeet.vn
# cert.pem  chain.pem  fullchain.pem  privkey.pem
```

# RUN DOCKER
```bash
# docker-compose.yml (version: "3.3")
docker-compose up -d
```

# Check PORT
```bash
ss -tulpen | egrep '3478|5349|80|443|40000'
```