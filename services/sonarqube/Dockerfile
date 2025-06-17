# Dockerfile para SonarScanner (agregar en config/sonarqube/)
FROM sonarsource/sonar-scanner-cli:latest

RUN apk add --no-cache \
    php83 \
    php83-curl \
    php83-dom \
    php83-mbstring \
    php83-tokenizer

COPY sonar-scanner.properties /usr/bin/sonar-scanner/conf/