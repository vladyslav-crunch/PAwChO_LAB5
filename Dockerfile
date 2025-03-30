# Etap 1: Tworzenie obrazu aplikacji Node.js
FROM scratch AS builder
ADD alpine-minirootfs-3.21.3-x86_64.tar /

WORKDIR /web-app

# Instalacja Node.js oraz npm
RUN apk add --no-cache nodejs npm

# Kopiowanie plików konfiguracyjnych aplikacji
COPY package*.json ./

# Instalacja wymaganych zależności
RUN npm install

# Kopiowanie pliku głównego serwera aplikacji
COPY web-server.js ./

# Udostępnienie portu, na którym działa aplikacja
EXPOSE 3000

# Etap 2: Konfiguracja Nginx jako reverse proxy
FROM nginx:alpine

# Ustawienie zmiennej środowiskowej przechowującej wersję aplikacji
ARG VERSION
ENV VERSION=$VERSION

# Instalacja Node.js oraz npm w obrazie Nginx
RUN apk add --no-cache nodejs npm

WORKDIR /web-app

# Kopiowanie aplikacji z pierwszego etapu do katalogu w serwerze Nginx
COPY --from=builder /web-app ./

# Kopiowanie konfiguracji Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Dodanie mechanizmu sprawdzania kondycji aplikacji
HEALTHCHECK --interval=20s --timeout=10s --retries=5 \
  CMD curl --fail http://localhost:80 || exit 1

# Udostępnienie portu 80 dla ruchu HTTP
EXPOSE 80

# Uruchomienie aplikacji Node.js i serwera Nginx
CMD sh -c "node /web-app/web-server.js & nginx -g 'daemon off;'"
