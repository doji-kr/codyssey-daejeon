FROM nginx:stable-alpine

LABEL org.opencontainers.image.title="dev-workstation"

COPY site/ /usr/share/nginx/html/

EXPOSE 80
