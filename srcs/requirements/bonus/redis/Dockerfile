FROM debian:bookworm

RUN apt-get update && apt-get install -y redis-server \
    && rm -rf /var/lib/apt/lists/*

COPY conf/redis.conf /etc/redis/redis.conf

RUN mkdir -p /var/run/redis /var/lib/redis \
    && chown redis:redis /var/run/redis /var/lib/redis

EXPOSE 6379

USER redis

CMD ["redis-server", "/etc/redis/redis.conf"]