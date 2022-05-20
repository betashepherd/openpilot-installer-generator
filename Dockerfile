FROM php:7.4.28-fpm-alpine3.15 as runtime
WORKDIR /app/fork
COPY ./fork .
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
    echo "date.timezone=Asia/Shanghai" >> /usr/local/etc/php/php.ini
#EXPOSE 9000
#CMD ["/usr/local/sbin/php-fpm"]