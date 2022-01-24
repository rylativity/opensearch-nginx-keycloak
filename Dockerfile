FROM opensearchproject/opensearch:latest

COPY ./certs/* /usr/share/opensearch/config/
COPY ./config/opensearch.yml /usr/share/opensearch/config/opensearch.yml
COPY ./config/securityconfig.yml /usr/share/opensearch/plugins/opensearch-security/securityconfig/config.yml