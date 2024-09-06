NAME=		xyzzy

JWS_PRIVKEY=	$(NAME)-jws-private.key
JWS_PUBKEY=		$(NAME)-jws-public.key

PKI_CSR=		$(NAME)-pki.csr
PKI_CERT=		$(NAME)-pki.crt
PKI_PUBKEY=		$(NAME)-pki-public.key
PKI_PRIVKEY=	$(NAME)-pki-private.key

CLEANFILES= $(CSR) $(CERT) $(KEY)


all:

bootstrap: $(JWS_PRIVKEY) $(PKI_CSR)

csr: $(PKI_CSR)

$(JWS_PRIVKEY):
	step crypto keypair $(JWS_PUBKEY) $(JWS_PRIVKEY) --insecure --no-password --kty EC --crv P-256

$(PKI_PRIVKEY):
	step crypto keypair $(PKI_PUBKEY) $(PKI_PRIVKEY) --insecure --no-password --kty EC --crv P-256

$(PKI_CSR): $(PKI_PRIVKEY)
	step certificate create $(NAME) $(PKI_CSR) --key $(PKI_PRIVKEY) --csr --insecure --no-password

clean:
	rm -f $(PKI_CSR)

realclean: clean
	rm -f $(PKI_PUBKEY) $(PKI_PRIVKEY) $(PKI_CERT)
	rm -f $(JWS_PRIVKEY) $(JWS_PUBKEY)
