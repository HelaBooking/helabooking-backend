FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY common ./common
COPY notification-service/pom.xml ./notification-service/pom.xml
COPY notification-service/src ./notification-service/src
RUN mvn -f pom.xml -N install -DskipTests \
	&& mvn -f common/pom.xml install -DskipTests \
	&& mvn -f notification-service/pom.xml clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/notification-service/target/*.jar app.jar
EXPOSE 8085
ENTRYPOINT ["java", "-jar", "app.jar"]
