FROM debian:bookworm

RUN apt-get update && apt-get -y install lighttpd \
    && rm -rf /var/lib/apt/lists/* 

COPY conf/lighttpd.conf /etc/lighttpd/lighttpd.conf

COPY tools/* /var/www/html/

EXPOSE 9090

CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]