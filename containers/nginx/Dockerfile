FROM debian:jessie

MAINTAINER Vincent Composieux <vincent.composieux@gmail.com>

RUN apt-get update && apt-get install -y nginx

ADD nginx.conf /etc/nginx/
ADD projects.conf /etc/nginx/sites-available/
ADD nginx.key /etc/nginx/nginx.key
ADD nginx.crt /etc/nginx/nginx.crt
ADD nginx.csr /etc/nginx/nginx.csr


RUN ln -s /etc/nginx/sites-available/projects.conf /etc/nginx/sites-enabled/projects.conf
RUN rm /etc/nginx/sites-enabled/default

RUN echo "upstream php-upstream { server php:9000; }" > /etc/nginx/conf.d/upstream.conf

CMD ["nginx"]

EXPOSE 80
EXPOSE 443
