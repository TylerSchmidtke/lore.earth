FROM joseluisq/static-web-server:2-debian
RUN mkdir -p /app/public
WORKDIR /app
ENV SERVER_PORT 8080
