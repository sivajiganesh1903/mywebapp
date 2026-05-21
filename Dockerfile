# ─── Stage 1: Build ───────────────────────────────────────
FROM maven:3.9.6-amazoncorretto-21 AS builder

# Set working directory
WORKDIR /app

# Copy pom.xml first (layer caching — only re-downloads deps if pom changes)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build
COPY src ./src
RUN mvn clean package -DskipTests -B

# ─── Stage 2: Run ─────────────────────────────────────────
FROM amazoncorretto:21-alpine

# Set working directory
WORKDIR /app

# Copy the built JAR from Stage 1
COPY --from=builder /app/target/*.jar app.jar

# Expose application port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s \
  CMD wget -qO- http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
