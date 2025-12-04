########### STAGE 1: Build ###########
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy generic POMs first to cache dependencies
COPY pom.xml .
COPY common ./common

# Copy service-specific POM and Source
COPY notification-service/pom.xml ./notification-service/pom.xml
COPY notification-service/src ./notification-service/src

# Build the application
RUN mvn -f pom.xml -N install -DskipTests \
	&& mvn -f common/pom.xml install -DskipTests \
	&& mvn -f notification-service/pom.xml clean package -DskipTests

########### STAGE 2: Optimized Runtime ###########
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy the built JAR
COPY --from=build /app/notification-service/target/*.jar app.jar

# Expose port
EXPOSE 8085

# JVM TUNING EXPLAINED:
# 1. -XX:+UseSerialGC: Use the Serial Garbage Collector. It has the lowest memory footprint and is perfect for single-core containers or small microservices.
# 2. -XX:MaxRAMPercentage=75.0: Dynamically calculates the Heap size as 75% of the Kubernetes memory limit. This leaves 25% for "Non-Heap" memory (Metaspace, Threads, etc.), preventing "OOMKilled" crashes.
ENTRYPOINT ["java", "-XX:+UseSerialGC", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]