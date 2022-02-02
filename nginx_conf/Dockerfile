FROM nginx

#(Note: you need to have generated the site.crt and site.key using the generate_certs.sh script in the certs folder or provided your own certificates)
COPY nginx_conf/nginx.tls.conf /etc/nginx/nginx.conf
COPY --chown=nginx:nginx certs/site.crt /etc/nginx/site.crt
COPY --chown=nginx:nginx certs/site.key /etc/nginx/site.key
# Comment out the three lines above and uncomment the line below to disable TLS
# COPY nginx_conf/nginx.conf /etc/nginx/nginx.conf