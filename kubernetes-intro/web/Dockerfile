FROM nginx:latest
COPY homework.html /app/
COPY nginx.conf /etc/nginx/
COPY default.conf /etc/nginx/conf.d
RUN useradd -u 1001 -d /app appuser
