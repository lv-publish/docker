# Multi-stage Dockerfile for building and running cqf-ruler
# Stage 1: build from source using Maven
FROM maven:3.8.8-openjdk-17 AS build
WORKDIR /build

# Install git to clone the repository
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Clone the cqf-ruler repository (shallow) and build
RUN git clone --depth 1 https://github.com/cqframework/cqf-ruler.git . \
  && mvn -DskipTests package -T1C

# Locate the first produced jar in target/ and copy to /output
RUN mkdir -p /output \
  && JAR=$(find target -type f -name "*.jar" | grep -v "original" | head -n 1) \
  && if [ -n "$JAR" ]; then cp "$JAR" /output/app.jar; fi

# Stage 2: runtime image
FROM eclipse-temurin:17-jre
LABEL maintainer="maintainer@example.com"
ENV LANG=C.UTF-8
WORKDIR /app
COPY --from=build /output/app.jar /app/app.jar

EXPOSE 8080
# Allow overriding java args via JAVA_OPTS env var
ENV JAVA_OPTS="-Xms256m -Xmx512m"
ENTRYPOINT ["sh","-c","exec java $JAVA_OPTS -jar /app/app.jar"]
