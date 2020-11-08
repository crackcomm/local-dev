
HUB_USER?=crackcomm

certs/ca.pem:
	mkdir -p certs
	cd certs && cfssl genkey -initca ../csr.json | cfssljson -bare ca

certs/nginx.pem: certs/ca.pem
	cd certs && cfssl gencert -ca ca.pem -ca-key ca-key.pem -cn "*.dev" -hostname registry.dev,concourse.dev,gitea.dev ../csr.json | cfssljson -bare nginx

certs/%.crt: certs/%.pem
	openssl x509 -in certs/$*.pem -inform PEM -out certs/$*.crt

certs: certs/ca.crt certs/nginx.crt

all: certs

install-%: certs/%.crt
	sudo mkdir -p /usr/share/ca-certificates/local-dev
	sudo cp certs/$*.crt /usr/share/ca-certificates/local-dev/$*.crt
	sudo chmod 644 /usr/share/ca-certificates/local-dev/$*.crt
	sudo update-ca-certificates
	# something might be wrong still…
	# it works after this though:
	sudo dpkg-reconfigure ca-certificates -u

install: install-ca
	echo "Go to Brave → Settings → Security → Manage Certificates → Authorities → Import"
	echo "	Import $(pwd)/certs/ca.crt to your browser authorities."

uninstall-%:
	sudo rm /usr/share/ca-certificates/local-dev/$*.crt

uninstall: uninstall-ca
	sudo update-ca-certificates --fresh

registry-image-resource:
	git clone https://github.com/concourse/registry-image-resource.git

patch-image: registry-image-resource
	cp certs/ca.pem registry-image-resource/ca.pem
	cd registry-image-resource && git apply ../cc-ca.patch

registry-image: patch-image
	cd registry-image-resource && sudo docker build -t $(HUB_USER)/registry-image-resource -f dockerfiles/alpine/Dockerfile .
	sudo docker push $(HUB_USER)/registry-image-resource

oci-build-image:
	sudo docker build -t $(HUB_USER)/oci-build-task-local -f oci-build-task/Dockerfile .
	sudo docker push $(HUB_USER)/oci-build-task-local

clean:
	rm -rf certs registry-image-resource
