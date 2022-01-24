# Root CA
openssl genrsa -out root-ca-key.pem 2048
openssl req -new -days 3650 -x509 -sha256 -key root-ca-key.pem -out root-ca.pem -subj '/C=US/ST=Virginia/L=Falls Church/O=MYORG/CN=MYCA'
# Admin cert
openssl genrsa -out admin-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out admin-key.pem
openssl req -new -key admin-key.pem -out admin.csr -subj '/C=US/ST=Virginia/L=Falls Church/O=MYORG/CN=Ryan'
openssl x509 -req -days 3650 -in admin.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out admin.pem
# Node cert
openssl genrsa -out node-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in node-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out node-key.pem
openssl req -new -key node-key.pem -out node.csr -subj '/C=US/ST=Virginia/L=Falls Church/O=MYORG/CN=opensearch'
openssl x509 -req -days 3650 -in node.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out node.pem
# Cleanup
rm admin-key-temp.pem
rm admin.csr
rm node-key-temp.pem
rm node.csr
