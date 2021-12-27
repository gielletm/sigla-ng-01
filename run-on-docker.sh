echo "Cloning SIGLA NG repo ..."
git clone https://github.com/consiglionazionaledellericerche/sigla-ng.git

echo "Moving to Sigla-ng working dir..."
cd sigla-ng

echo "Running H2 containter ..."
docker run -d --name sigla-h2 -e H2_OPTIONS='-ifNotExists' -ti oscarfonts/h2

echo "Running sigla-thorntail container ..." 
docker run -d --name sigla-thorntail --link sigla-h2:db -e THORNTAIL_PROJECT_STAGE="demo-h2" -e THORNTAIL_DATASOURCES_DATA-SOURCES_SIGLA_CONNECTION-URL="jdbc:h2:tcp://db:1521/db-sigla" -ti consiglionazionalericerche/sigla-main:release

echo "Running sigla-ng container ..."
docker run -d --name sigla-ng --link sigla-h2:db -e SPRING_PROFILES_ACTIVE=demo -e SPRING_DATASOURCE_URL="jdbc:h2:tcp://db:1521/db-sigla" -ti consiglionazionalericerche/sigla-ng:latest

echo "Running NGINX container ..."
docker run -d --name sigla-nginx -p 8080:80 --link sigla-thorntail:sigla-thorntail --link sigla-ng:sigla-ng -v $(pwd)/conf.d/:/etc/nginx/conf.d/:ro -ti nginx
