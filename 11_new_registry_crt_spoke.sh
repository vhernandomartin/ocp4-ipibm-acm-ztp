#!/bin/bash
REGISTRY_CONF_DIR=/opt/registry
REGISTRY_CERT_DIR=$REGISTRY_CONF_DIR/certs
REGISTRY_DNS_NAME=ipibm-installer.lab-ipibm
SPOKE_REGISTRY_DNS_NAME=ipibm-installer.lab-spoke

function stop_registry () {
  podman stop registry
  podman rm registry
  mv $REGISTRY_CERT_DIR/domain.crt $REGISTRY_CERT_DIR/domain.crt.$(date +%d%m%y-%H%M%S)
  mv $REGISTRY_CERT_DIR/domain.key $REGISTRY_CERT_DIR/domain.key.$(date +%d%m%y-%H%M%S)
}

function create_new_cert () {
  openssl req -newkey rsa:4096 -nodes -sha256 -keyout $REGISTRY_CERT_DIR/domain.key -x509 -days 365 -out $REGISTRY_CERT_DIR/domain.crt -subj "/C=ES/ST=Madrid/L=Madrid/O=test/OU=test/CN=$REGISTRY_DNS_NAME" -addext "subjectAltName=DNS:$REGISTRY_DNS_NAME, DNS:$SPOKE_REGISTRY_DNS_NAME"
  cp $REGISTRY_CERT_DIR/domain.crt /etc/pki/ca-trust/source/anchors/
  update-ca-trust extract
}

function start_registry () {
  podman create --name registry --net host --security-opt label=disable -v /opt/registry/data:/var/lib/registry:z -v /opt/registry/auth:/auth:z -v /opt/registry/conf/config.yml:/etc/docker/registry/config.yml -e "REGISTRY_AUTH=htpasswd" -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry" -e "REGISTRY_HTTP_SECRET=ALongRandomSecretForRegistry" -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd -v /opt/registry/certs:/certs:z -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key quay.io/saledort/registry:2
  podman start registry
}

# MAIN
stop_registry
create_new_cert
start_registry

