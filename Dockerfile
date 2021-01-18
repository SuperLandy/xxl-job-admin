FROM harbor.huaweicloud.com/ops-manager/jdk8:v1.0.0

MAINTAINER hqj-jenkins

WORKDIR /home

ARG JAR_FILE_PATH

ADD ${JAR_FILE_PATH} app.jar

ENTRYPOINT ["java", "-XX:+UnlockExperimentalVMOptions", "-XX:+UseCGroupMemoryLimitForHeap", "-Djava.security.egd=file:/dev/./urandom", "-Dspring.config.location=application.properties","-jar", "app.jar"]

EXPOSE 80
