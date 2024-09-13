NAME=		xyzzy

CA_URL=		https://step.dev.dnstapir.se:9000
CA_FINGERPRINT=	e251913b8e39765ac5ae0cb6782a892ac0af800d703c509a70c19bf3a8a0b73e

JWS_PRIVKEY=	keys/jws.key
JWS_PUBKEY=	keys/jws-public.key

TLS_CA_CERT=	keys/ca.crt
TLS_CSR=	keys/tls.csr
TLS_CERT=	keys/tls.crt
TLS_PRIVKEY=	keys/tls.key
TLS_PUBKEY=	keys/tls-public.key

COMPOSE_ENV=	.env

EDM_TOML=	edm/config/edm.toml

all:

bootstrap: $(JWS_PRIVKEY) $(TLS_CSR) $(TLS_CA_CERT) $(COMPOSE_ENV) $(EDM_TOML)
	step certificate inspect $(TLS_CSR)

csr: $(TLS_CSR)


renew:
	step ca renew $(TLS_CERT) $(TLS_PRIVKEY)

keys:
	-mkdir $@

$(JWS_PRIVKEY): keys
	step crypto keypair $(JWS_PUBKEY) $(JWS_PRIVKEY) --insecure --no-password --kty EC --crv P-256

$(TLS_PRIVKEY): keys
	step crypto keypair $(TLS_PUBKEY) $(TLS_PRIVKEY) --insecure --no-password --kty EC --crv P-256

$(TLS_CSR): $(TLS_PRIVKEY)
	step certificate create $(NAME) $(TLS_CSR) --key $(TLS_PRIVKEY) --csr --insecure --no-password

$(TLS_CA_CERT):
	step ca root --ca-url=$(CA_URL) --fingerprint $(CA_FINGERPRINT) > $@

openssl-boostrap: keys
	openssl ecparam -name prime256v1 -genkey -noout -out $(JWS_PRIVKEY)
	openssl ec -in $(JWS_PRIVKEY) -pubout -out $(JWS_PUBKEY)
	openssl ecparam -name prime256v1 -genkey -noout -out $(TLS_PRIVKEY)
	openssl ec -in $(TLS_PRIVKEY) -pubout -out $(TLS_PUBKEY)
	openssl req -new -out $(TLS_CSR) -key $(TLS_PRIVKEY) -subj "/CN=$(NAME)" -nodes
	openssl req -noout -text -in xyzzy-pki.csr $(TLS_CSR)

clean:
	rm -f $(TLS_CSR) $(COMPOSE_ENV) $(EDM_TOML)

realclean: clean
	rm -f $(TLS_PUBKEY) $(TLS_PRIVKEY) $(TLS_CERT) $(TLS_CA_CERT)
	rm -f $(JWS_PRIVKEY) $(JWS_PUBKEY)

edm:
	mkdir -p $@/config

$(EDM_TOML): edm
	@echo cryptopan-key = \"$(shell openssl rand -base64 15)\" > $@

$(COMPOSE_ENV):
	echo NAME=$(NAME) > $@
