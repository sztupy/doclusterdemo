FROM nginx:1.11.5-alpine

ENV API_ROOT_URL http://127.0.0.1:9090/todos
COPY . /usr/share/nginx/html

CMD ["/usr/share/nginx/html/entrypoint.sh"]
