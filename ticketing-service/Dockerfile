FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY common ./common
COPY ticketing-service/pom.xml ./ticketing-service/pom.xml
COPY ticketing-service/src ./ticketing-service/src
RUN mvn -f pom.xml -N install -DskipTests \
	&& mvn -f common/pom.xml install -DskipTests \
	&& mvn -f ticketing-service/pom.xml clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/ticketing-service/target/*.jar app.jar
EXPOSE 8084
ENTRYPOINT ["java", "-jar", "app.jar"]
