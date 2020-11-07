
certs/ca.pem:
	mkdir -p certs
	cd certs && cfssl genkey -initca ../csr.json | cfssljson -bare ca

certs/nginx.pem: certs/ca.pem
	cd certs && cfssl gencert -ca ca.pem -ca-key ca-key.pem -cn "*.local" -hostname registry.local,concourse.local,gitea.local ../csr.json | cfssljson -bare nginx

certs/%.crt: certs/%.pem
	openssl x509 -in certs/$*.pem -inform PEM -out certs/$*.crt

certs: certs/ca.crt certs/nginx.crt

all: certs

install-%: certs/%.crt
	mkdir -p /usr/share/ca-certificates/local-dev
	cp certs/$*.crt /usr/share/ca-certificates/local-dev/$*.crt
	chmod 644 /usr/share/ca-certificates/local-dev/$*.crt
	update-ca-certificates
	# something might be wrong still…
	# it works after this though:
	dpkg-reconfigure ca-certificates -u

install: install-ca install-nginx
	echo "Go to Brave → Settings → Security → Manage Certificates → Authorities → Import"
	echo "	Import $(pwd)/certs/ca.crt to your browser authorities."

uninstall-%:
	rm /usr/share/ca-certificates/local-dev/$*.crt
	update-ca-certificates

uninstall: uninstall-ca uninstall-nginx

clean:
	make clean
