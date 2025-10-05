FROM openjdk:24-slim
VOLUME /tmp
COPY target/config-server-1.0.0.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
