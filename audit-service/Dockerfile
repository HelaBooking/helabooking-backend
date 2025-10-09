FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY ../pom.xml .
COPY ../common ./common
COPY pom.xml ./audit-service/pom.xml
COPY src ./audit-service/src
RUN mvn -f audit-service/pom.xml clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/audit-service/target/*.jar app.jar
EXPOSE 8086
ENTRYPOINT ["java", "-jar", "app.jar"]
