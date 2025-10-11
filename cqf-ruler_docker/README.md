# cqf-ruler Docker and Kubernetes manifests

This folder provides a Dockerfile, docker-compose.yml and basic Kubernetes manifests to build and run the cqf-ruler project from https://github.com/cqframework/cqf-ruler.

Files
- Dockerfile - multi-stage build: clones repo and builds with Maven, produces `app.jar` and runs with Java 17.
- docker-compose.yml - example Compose file to build and run locally exposing port 8080.
- k8s/deployment.yaml - Kubernetes Deployment using image `cqf-ruler:latest`.
- k8s/service.yaml - Kubernetes Service exposing port 8080.

Quickstart (local)

1. Build and run with Docker Compose

```bash
# from this directory
docker compose up --build
```

2. Verify the service is listening on http://localhost:8080

Notes and caveats
- This Dockerfile clones the cqf-ruler GitHub repo during image build. If you prefer to build the jar locally and COPY it into the image, replace the build stage accordingly.
- The build uses Maven and may take several minutes. Ensure you have enough memory for the build.
- You may need to adjust Java memory (`JAVA_OPTS`) or pass additional environment variables required by cqf-ruler.

Kubernetes

1. Build and push the image to your registry, then update `k8s/deployment.yaml` image ref.

```bash
# build locally
docker build -t <your-registry>/cqf-ruler:1.0 .
# push
docker push <your-registry>/cqf-ruler:1.0
# update k8s/deployment.yaml to use the image URL and apply
kubectl apply -f k8s/deployment.yaml -f k8s/service.yaml
```

Next steps
- Add ConfigMap or Secret for configuration-driven values.
- Add persistent volumes if the service writes data you want to keep.
- Harden the image: use a non-root user and smaller base image if possible.
