FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
# Chaque build est servi sous un chemin unique (/b/<date>/) : aucun cache (téléphone, proxy, CDN) ne peut resservir
# l'ancien code ou les anciennes images, puisque leurs adresses changent. Seule la page d'entrée, jamais mise en cache,
# reste à la racine. L'ancien service worker est remplacé par un fichier qui vide les caches et se désinscrit.
RUN V=$(date -u +%Y%m%d%H%M) \
 && flutter build web --release --base-href /b/$V/ --dart-define=BUILD_TIME=$(date -u +%d/%m-%Hh%M) \
 && mkdir -p /out/b \
 && cp tool/web/kill_sw.js build/web/flutter_service_worker.js \
 && mv build/web /out/b/$V \
 && cp /out/b/$V/index.html /out/index.html \
 && cp /out/b/$V/favicon.png /out/favicon.png \
 && cp tool/web/kill_sw.js /out/flutter_service_worker.js

FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /out /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
