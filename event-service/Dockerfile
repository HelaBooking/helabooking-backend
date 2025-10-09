FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY ../pom.xml .
COPY ../common ./common
COPY pom.xml ./event-service/pom.xml
COPY src ./event-service/src
RUN mvn -f event-service/pom.xml clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/event-service/target/*.jar app.jar
EXPOSE 8082
ENTRYPOINT ["java", "-jar", "app.jar"]
