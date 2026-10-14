
# Stage 1: Build the Java application
FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

COPY pom.xml .
RUN mvn -B dependency:go-offline

COPY src ./src
RUN mvn -B clean package

# Stage 2: Run with a lightweight Java runtime
FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

# Run as a non-root user
RUN groupadd --system appgroup \
    && useradd --system --gid appgroup appuser

COPY --from=build --chown=appuser:appgroup \
    /app/target/habit-tracker.jar /app/app.jar

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
