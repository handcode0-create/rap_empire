FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
# Build servi depuis la racine : évite les chemins /b/<version>/ périmés qui renvoient 404
# sur les navigateurs mobiles et les raccourcis iOS/Android.
RUN flutter build web --release --base-href / --dart-define=BUILD_TIME=$(date -u +%d/%m-%Hh%M) \
 && cp tool/web/kill_sw.js build/web/flutter_service_worker.js \
 && mkdir -p /out \
 && cp -a build/web/. /out/ \
 && cp tool/web/kill_sw.js /out/flutter_service_worker.js

FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /out /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
