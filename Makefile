NAME=		xyzzy

JWS_PRIVKEY=	keys/jws-private.key
JWS_PUBKEY=	keys/jws-public.key

TLS_CSR=	keys/tls.csr
TLS_CERT=	keys/tls.crt
TLS_PUBKEY=	keys/tls-public.key
TLS_PRIVKEY=	keys/tls-private.key

CLEANFILES=	$(CSR) $(CERT) $(KEY)


all:

bootstrap: $(JWS_PRIVKEY) $(TLS_CSR)
	step certificate inspect $(TLS_CSR)

csr: $(TLS_CSR)

keys:
	-mkdir @keys

$(JWS_PRIVKEY): keys
	step crypto keypair $(JWS_PUBKEY) $(JWS_PRIVKEY) --insecure --no-password --kty EC --crv P-256

$(TLS_PRIVKEY): keys
	step crypto keypair $(TLS_PUBKEY) $(TLS_PRIVKEY) --insecure --no-password --kty EC --crv P-256

$(TLS_CSR): $(TLS_PRIVKEY)
	step certificate create $(NAME) $(TLS_CSR) --key $(TLS_PRIVKEY) --csr --insecure --no-password

openssl-boostrap: keys
	openssl ecparam -name prime256v1 -genkey -noout -out $(JWS_PRIVKEY)
	openssl ec -in $(JWS_PRIVKEY) -pubout -out $(JWS_PUBKEY)
	openssl ecparam -name prime256v1 -genkey -noout -out $(TLS_PRIVKEY)
	openssl ec -in $(TLS_PRIVKEY) -pubout -out $(TLS_PUBKEY)
	openssl req -new -out $(TLS_CSR) -key $(TLS_PRIVKEY) -subj "/CN=$(NAME)" -nodes
	openssl req -noout -text -in xyzzy-pki.csr $(TLS_CSR)

clean:
	rm -f $(TLS_CSR)

realclean: clean
	rm -f $(TLS_PUBKEY) $(TLS_PRIVKEY) $(TLS_CERT)
	rm -f $(JWS_PRIVKEY) $(JWS_PUBKEY)
