FROM harbor.huaweicloud.com/ops-manager/jdk8:v1.0.1

MAINTAINER hqj-jenkins

WORKDIR /home

ARG JAR_FILE_PATH

ADD ${JAR_FILE_PATH} .

ENTRYPOINT  java  -javaagent:elastic-apm-agent-1.20.0.jar           \
            -Delastic.apm.server_urls=http://192.168.0.229:8200     \
            -Delastic.apm.application_packages=org.springframework  \
            -XX:+UnlockExperimentalVMOptions                        \
            -XX:+UseCGroupMemoryLimitForHeap                        \
            -jar -Dspring.config.location=application.properties  xxl*


EXPOSE 80
