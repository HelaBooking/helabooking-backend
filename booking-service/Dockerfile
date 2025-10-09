FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY common ./common
COPY booking-service/pom.xml ./booking-service/pom.xml
COPY booking-service/src ./booking-service/src
RUN mvn -f pom.xml -N install -DskipTests \
	&& mvn -f common/pom.xml install -DskipTests \
	&& mvn -f booking-service/pom.xml clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/booking-service/target/*.jar app.jar
EXPOSE 8083
ENTRYPOINT ["java", "-jar", "app.jar"]
