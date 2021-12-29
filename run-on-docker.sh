#!/bin/bash

echo "[Step 1/6] Cloning SIGLA NG repo ..."
git clone https://github.com/consiglionazionaledellericerche/sigla-ng.git

echo "[Step 2/6] Moving to Sigla-ng working dir..."
cd sigla-ng

echo "[Step 3/6] Running H2 containter ..."
docker run -d --name sigla-h2 -e H2_OPTIONS='-ifNotExists' -ti oscarfonts/h2

echo "[Step 4/6] Running sigla-thorntail container ..." 
docker run -d --name sigla-thorntail --link sigla-h2:db -e THORNTAIL_PROJECT_STAGE="demo-h2" -e THORNTAIL_DATASOURCES_DATA-SOURCES_SIGLA_CONNECTION-URL="jdbc:h2:tcp://db:1521/db-sigla" -ti consiglionazionalericerche/sigla-main:release

echo "[Step 5/6] Running sigla-ng container ..."
docker run -d --name sigla-ng --link sigla-h2:db -e SPRING_PROFILES_ACTIVE=demo -e SPRING_DATASOURCE_URL="jdbc:h2:tcp://db:1521/db-sigla" -ti consiglionazionalericerche/sigla-ng:latest

echo "[Step 6/6] Running NGINX container ..."
docker run -d --name sigla-nginx -p 8080:80 --link sigla-thorntail:sigla-thorntail --link sigla-ng:sigla-ng -v $(pwd)/conf.d/:/etc/nginx/conf.d/:ro -ti nginx

echo "Attendere qualche minuto e collegarsi a SIGLA-NG cliccando sull'icona Web Preview in alto a destra."
echo "Utilizzare come username ENTE e cliccare cambia password al primo login."

