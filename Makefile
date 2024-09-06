NAME=		xyzzy

JWS_PRIVKEY=	$(NAME)-jws-private.key
JWS_PUBKEY=	$(NAME)-jws-public.key

PKI_CSR=	$(NAME)-pki.csr
PKI_CERT=	$(NAME)-pki.crt
PKI_PUBKEY=	$(NAME)-pki-public.key
PKI_PRIVKEY=	$(NAME)-pki-private.key

CLEANFILES= $(CSR) $(CERT) $(KEY)


all:

bootstrap: $(JWS_PRIVKEY) $(PKI_CSR)
	step certificate inspect $(PKI_CSR)

csr: $(PKI_CSR)

$(JWS_PRIVKEY):
	step crypto keypair $(JWS_PUBKEY) $(JWS_PRIVKEY) --insecure --no-password --kty EC --crv P-256

$(PKI_PRIVKEY):
	step crypto keypair $(PKI_PUBKEY) $(PKI_PRIVKEY) --insecure --no-password --kty EC --crv P-256

$(PKI_CSR): $(PKI_PRIVKEY)
	step certificate create $(NAME) $(PKI_CSR) --key $(PKI_PRIVKEY) --csr --insecure --no-password

openssl-boostrap:
	openssl ecparam -name prime256v1 -genkey -noout -out $(JWS_PRIVKEY)
	openssl ec -in $(JWS_PRIVKEY) -pubout -out $(JWS_PUBKEY)
	openssl ecparam -name prime256v1 -genkey -noout -out $(PKI_PRIVKEY)
	openssl ec -in $(PKI_PRIVKEY) -pubout -out $(PKI_PUBKEY)
	openssl req -new -out $(PKI_CSR) -key $(PKI_PRIVKEY) -subj "/CN=$(NAME)" -nodes
	openssl req -noout -text -in xyzzy-pki.csr $(PKI_CSR)

clean:
	rm -f $(PKI_CSR)

realclean: clean
	rm -f $(PKI_PUBKEY) $(PKI_PRIVKEY) $(PKI_CERT)
	rm -f $(JWS_PRIVKEY) $(JWS_PUBKEY)
