# OpenSearch Docker Compose Configuration

## Setup

If you want to change any of the certificate information, modify the certs/generate_certs.sh script and the opensearch.yml lines that include CN,O,OU etc...  The admin and node certificate information in opensearch.yml and generate_certs.sh must match
You can also just replace all certificates with your own certificates.
* Run `cd certs` to change into the certs directory
* Run `chmod +x generate_certs.sh` to make the cert-generation script executable
* Run `./generate_certs.sh` to generate the certificates
* You may need to modify the permissions of the certificates so that the container can read them.  Run `chmod a+r ./*`
* Run `docker-compose up -d`


* To create new hash passwords that you can include in internal_users.yml, run `docker-compose exec opensearch-node1 /usr/share/opensearch/plugins/opensearch-security/tools/hash.sh`

## OpenID Connect Steps
* Add a confidential "opensearch" client to Keycloak
* Copy the client secret to the opensearch_dashboards.yml file
* Add a realm roles mapper to the opensearch client in keycloak and set the token claim name to "roles"
* If setting a value for SERVER_BASEPATH, must also set the basepath for oidc redirect in opensearch_dashboards.yml

## To run this docker-compose stack on a remote host
* Update the command under the keycloak in docker-compose.yml: `command: ["-Dkeycloak.frontendUrl=http://localhost/auth"]` replacing `localhost` with the IP address or resolvable domain name of your server.