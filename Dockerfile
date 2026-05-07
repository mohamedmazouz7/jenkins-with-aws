FROM nginx:alpine

RUN echo "<h1>Hello from EKS! My Pipeline is Working!</h1>" > /usr/share/nginx/html/index.html

EXPOSE 80
