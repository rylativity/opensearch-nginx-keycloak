# OpenSearch Docker Compose Configuration

## Setup

If you want to change any of the certificate information, modify the certs/generate_certs.sh script and the opensearch.yml lines that include CN,O,OU etc...  The admin and node certificate information in opensearch.yml and generate_certs.sh must match.
You can also just replace all certificates with your own certificates.
* Run `cd certs` to change into the certs directory
* Run `chmod +x generate_certs.sh` to make the cert-generation script executable
* Run `./generate_certs.sh` to generate the certificates
* You may need to modify the permissions of the certificates so that the container can read them.  Run `chmod a+r ./*`
* Run `docker-compose up -d postgres keycloak nginx` and allow them to initialize
* Add a confidential "opensearch" client to Keycloak's master realm (go to http://localhost/auth and login with the admin username and password specified in the docker-compose.yml under the keycloak section; make sure you also set the Valid Redirect URLS to "*" or "http://localhost/*" or "http://localhost/kibana/*")
* Copy the client secret for the opensearch client in Keycloak to the opensearch_dashboards.yml file
* Add a realm roles mapper to the opensearch client in keycloak and set the token claim name to "roles" (go to clients > opensearch > mappers > "Add Builtin" > Select "realm roles", and change the token claim from "realmAccess.roles" to "roles"
* Note: If setting a value for SERVER_BASEPATH, must also set the basepath for oidc redirect in opensearch_dashboards.yml
* * Run `docker-compose up -d --build opensearch-node1 opensearch-dashboards`
* Note: If you need to modify your config and restart the containers, it's easiest to just remove the opensearch-node1 and opensearch-dashboards containers, delete the associated docker volume, and rerun `docker-compose up -d --build opensearch-node1 opensearch-dashboards`
