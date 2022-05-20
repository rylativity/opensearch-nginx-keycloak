# OpenSearch Docker Compose Configuration

## Setup Steps
You must have docker, docker-compose, and openssl (if you don't plan to provide your own certificates) installed.  You can find dDetailed, official installation instructions for your operating system for each of these tools online.

If you want to change any of the certificate information, modify the certs/generate_certs.sh script and the opensearch.yml lines that include CN,O,OU etc...  The admin and node certificate information in opensearch.yml and generate_certs.sh must match. If you want to serve your connection over HTTPS with NginX, you can also modify the subject alternative names in the site.cnf (for example, if you want the certificate to be valid for both domain.com and *.domain.com).
You can also just replace all certificates with your own certificates.

### If you don't want to NginX to use TLS (skip this if you are happy using TLS)
This container stack is configured to use TLS(HTTPS) by default.  If you don't want to use TLS between NginX and the client (browser), you should first:
* Comment out and uncomment the appropriate lines in the nginx_conf/Dockerfile (see nginx_conf/Dockerfile for more detail)
* Modify the line `command: ["-Dkeycloak.frontendUrl=https://localhost/auth"]` in docker-compose.yml, replacing "https" with "http"
* Modify the line `opensearch_security.openid.base_redirect_url: "https://localhost/kibana"` in opensearch_dashboards.yml, replacing "https" with "http"
* See note at the bottom of this README about secure cookies if you are planning to deploy on a remote host (i.e. not "localhost") without using TLS (not recommended)

### 1) Generating the Certificates (If you want to use your own certificates, skip these steps and simply place your certificates in the certs/ directory with the appropriate names)
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
* Add a realm roles mapper to the opensearch client in keycloak and set the token claim name to "roles" (go to clients > opensearch > mappers > "Add Builtin" > Select "realm roles", and change the token claim from "realmAccess.roles" to "roles". You must also select the option to "Add to ID Token", since Opensearch Dashboards will collect the backend roles from the ID Token (and not the access token)
* Note: If setting a value for SERVER_BASEPATH in docker-compose.yml under the opensearch-dashboards service, you must also set the basepath for oidc redirect in opensearch_dashboards.yml
* Run `docker-compose up -d --build opensearch-node1 opensearch-dashboards`
* Note: If you need to modify your config and restart the containers, it's easiest to just remove the opensearch-node1 and opensearch-dashboards containers, delete the associated docker volume, and rerun `docker-compose up -d --build opensearch-node1 opensearch-dashboards`
* Wait for the containers to start and navigate to http://localhost/kibana in your browser (use the admin user to login to keycloak if you get redirected to keycloak to login)

### Adding new users
Since OpenSearch is using Keycloak as its OpenID Connect provider, we can create new users and grant them access to OpenSearch by adding them to Keycloak and giving them the appropriate roles.  The admin user in Keycloak is granted the "admin" role by default, and the "admin" role (referred to as a "backend_role" by OpenSearch) is mapped to the internal "all_access" role in Opensearch by default.  This means that, by default, the admin user in Keycloak has superuser privileges in Opensearch.

If you are going to add a new user, you must grant them a role with an appropriate role mapping set up in OpenSearch or they will not be able to login.  You can create additional role mappings in OpenSearch through the "admin" user if you want to create custom roles in Keycloak and have them map to OpenSearch roles.  This can be very useful for providing limited or restricted access to your Opensearch/Opensearch-Dashboards containers.  For more information, see https://opensearch.org/docs/latest/security-plugin/access-control/users-roles/#roles_mappingyml  

Alternatively, if you simply grant your new user the role of "admin" in Keycloak, they will be granted the "all_access" role in Opensearch.

### Using a different Keycloak realm
To use a Keycloak realm other than the "master" realm, search (CTRL + SHIFT + F) for all instances of "realms/master" and replace it with the appropriate realm name.  You must configure the opensearch client as described in steps 2 and 3 of the "Setup" section above in your new realm.  You will likely need to create new users in your new realm as described in the "Adding new users" section above.

### To run this docker-compose stack on a remote host
* Update the command under the keycloak in docker-compose.yml: `command: ["-Dkeycloak.frontendUrl=https://localhost/auth"]` replacing `localhost` with the IP address or resolvable domain name of your server.
* Update the value of opensearch_security.openid.base_redirect_url: in opensearch_dashboards.yml, replacing `localhost` with the IP address or resolvable domain name of your server.
* Set the corresponding redirect URI in your keycloak client
* If you are not serving HTTPS connections from NginX (or some other method), you must set the value of "opensearch_security.cookie.secure:" to false (Note: http://localhost is considered secure by most web browsers)

### IMPORTANT NOTE: This docker-compose file is for testing and development.  Copying certificates and keys into images is inherently insecure, because anyone who is able to access your images can also access your sensitive files.  Consider using docker swarm mode (i.e. `docker stack deploy -c docker-compose.yml opensearch`) and using secrets to manage sensitive files.  For more information, see https://docs.docker.com/engine/swarm/secrets/
