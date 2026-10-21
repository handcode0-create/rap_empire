FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release --dart-define=BUILD_TIME=$(date -u +%d/%m-%Hh%M)
# Ancien service worker : remplacé par un fichier qui vide les caches et se désinscrit (voir tool/web/kill_sw.js).
RUN cp tool/web/kill_sw.js build/web/flutter_service_worker.js

FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
