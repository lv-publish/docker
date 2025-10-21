CDS Connect Authoring Tool - Docker deployment

This folder contains a docker-compose file to run the CDS Connect Authoring Tool (frontend + API), MongoDB, and the CQL translation service. It also includes an example Nginx config to reverse-proxy the application under the domain cds.tabca.vn.

Files:
- `docker-compose.yml` - Compose stack (cds-at, cds-at-mongo, cds-at-cql2elm)
- `nginx_cds_at.conf` - Example nginx server block to proxy `cds.tabca.vn` to the services

Quick start (on the host where you want to run the stack):

1. Place any custom API config files (for example `local.json` and `local-users.json`) into `./api/config` relative to this folder. If you want to use the default configs baked into the image, skip this step.

2. Start Docker Compose:

   docker compose up -d

3. Verify services are running:

   docker compose ps

Nginx integration options:

- Host nginx (recommended if you already run nginx on the host):
  - Copy `nginx_cds_at.conf` into your nginx sites-enabled (or conf.d) and reload nginx.
  - Ensure `proxy_pass` targets (127.0.0.1:9000 and 127.0.0.1:3001) are reachable from the host. If you run the compose on a different machine, change targets accordingly.
  - To enable HTTPS, add an SSL server block with your TLS certificates (or use Certbot).

- Run nginx as a container on the same Docker network:
  - Create an nginx container and mount `nginx_cds_at.conf` into `/etc/nginx/conf.d/`.
  - Change `proxy_pass` in the config to point to the docker service names, e.g. `http://cds-at:9000/authoring/` and `http://cds-at:3001/authoring/api/`.

Notes and troubleshooting:
- The compose file exposes ports 27017, 8080, 3001, and 9000 on the host. If you already have services using these ports, change the host mappings.
- The frontend by default proxies API requests to the API server. For an external nginx to handle proxying to `/authoring/api`, set `API_PROXY_ACTIVE=false` in the compose environment (already set in the compose file).
- If you want to enable HTTPS between clients and nginx, configure TLS in nginx; the application itself can be run behind nginx with HTTP.

If you want, I can also generate a dockerized nginx service in the compose file so the whole stack (including nginx) runs with a single `docker compose up` command — tell me if you'd like that.
