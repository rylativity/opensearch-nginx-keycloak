FROM opensearchproject/opensearch:1.3.2

COPY ./certs/* /usr/share/opensearch/config/
COPY ./config/opensearch.yml /usr/share/opensearch/config/opensearch.yml
COPY ./config/securityconfig.yml /usr/share/opensearch/plugins/opensearch-security/securityconfig/config.yml
COPY ./config/optional/log4j2.properties /usr/share/opensearch/config/log4j2.properties