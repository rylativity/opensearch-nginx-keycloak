# OpenSearch Docker Compose Configuration

## Setup Steps

If you want to change any of the certificate information, modify the certs/generate_certs.sh script and the opensearch.yml lines that include CN,O,OU etc...  The admin and node certificate information in opensearch.yml and generate_certs.sh must match. If you want to serve your connection over HTTPS with NginX, you can also modify the subject alternative names in the site.cnf (for example, if you want the certificate to be valid for both domain.com and *.domain.com).
You can also just replace all certificates with your own certificates.

### If you don't want to NginX to use TLS (skip this if you are happy using TLS)
This container stack is configured to use TLS(HTTPS) by default.  If you don't want to use TLS between NginX and the client (browser), you should first:
* Comment out and uncomment the appropriate lines in the nginx_conf/Dockerfile (see nginx_conf/Dockerfile for more detail)
* Modify the line `command: ["-Dkeycloak.frontendUrl=https://localhost/auth"]` in docker-compose.yml, replacing "https" with "http"
* Modify the line `opensearch_security.openid.base_redirect_url: "https://localhost/kibana"` in opensearch_dashboards.yml, replacing "https" with "http"
* See note at the bottom of this README about secure cookies if you are planning to deploy on a remote host (i.e. not "localhost") without using TLS (not recommended)

### 1) Generating the Certificates
* Run `cd certs` to change into the certs directory
* Run `chmod +x generate_certs.sh` to make the cert-generation script executable
* Run `./generate_certs.sh` to generate the certificates.  In addition to the certificates required for Opensearch security, this will also generate a site key and certificate for serving your NginX container with HTTPS.
* Note: If you want to use HTTPS instead of HTTP, 
* You may need to modify the permissions of the certificates so that the container can read them.  Run `chmod a+r ./*`
### 2) Initializing Keycloak, Postgres, and NginX
* Run `docker-compose up -d postgres keycloak nginx` and allow them to initialize
* Add a confidential "opensearch" client to Keycloak's master realm (go to http://localhost/auth and login with the admin username and password specified in the docker-compose.yml under the keycloak section; make sure you also set the Valid Redirect URLS to "\*" or http://localhost/* or http://localhost/kibana/*)
### 3) Configuring Opensearch and Opensearch Dashboards
* Copy the client secret for the opensearch client in Keycloak to the opensearch_dashboards.yml file
* Add a realm roles mapper to the opensearch client in keycloak and set the token claim name to "roles" (go to clients > opensearch > mappers > "Add Builtin" > Select "realm roles", and change the token claim from "realmAccess.roles" to "roles"
* Note: If setting a value for SERVER_BASEPATH in docker-compose.yml under the opensearch-dashboards service, you must also set the basepath for oidc redirect in opensearch_dashboards.yml
* * Run `docker-compose up -d --build opensearch-node1 opensearch-dashboards`
* Note: If you need to modify your config and restart the containers, it's easiest to just remove the opensearch-node1 and opensearch-dashboards containers, delete the associated docker volume, and rerun `docker-compose up -d --build opensearch-node1 opensearch-dashboards`
* Wait for the containers to start and navigate to http://localhost/kibana in your browser (use the admin user to login to keycloak if you get redirected to keycloak to login)

### To run this docker-compose stack on a remote host
* Update the command under the keycloak in docker-compose.yml: `command: ["-Dkeycloak.frontendUrl=https://localhost/auth"]` replacing `localhost` with the IP address or resolvable domain name of your server.
* Update the value of opensearch_security.openid.base_redirect_url: in opensearch_dashboards.yml, replacing `localhost` with the IP address or resolvable domain name of your server.
* Set the corresponding redirect URI in your keycloak client
* If you are not serving HTTPS connections from NginX (or some other method), you must set the value of "opensearch_security.cookie.secure:" to false (Note: http://localhost is considered secure by most web browsers)

### IMPORTANT NOTE: This docker-compose file is for testing and development.  Copying certificates and keys into images is inherently insecure, because anyone who is able to access your images can also access your sensitive files.  Consider using docker swarm mode (i.e. `docker stack deploy -c docker-compose.yml opensearch`) and using secrets to manage sensitive files.  For more information, see https://docs.docker.com/engine/swarm/secrets/