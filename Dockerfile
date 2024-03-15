FROM dzek69/docker-squash:25.0.4-1.2.0

COPY build /create
RUN chmod +x /create/make && ls /create
WORKDIR /create
