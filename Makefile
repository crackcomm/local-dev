
certs/ca.pem:
	cd certs && cfssl genkey -initca ../csr.json | cfssljson -bare ca

certs/registry.pem: certs/ca.pem
	cd certs && cfssl gencert -ca ca.pem -ca-key ca-key.pem -hostname registry.local ../csr.json | cfssljson -bare registry

certs/concourse.pem: certs/ca.pem
	cd certs && cfssl gencert -ca ca.pem -ca-key ca-key.pem -hostname registry.local ../csr.json | cfssljson -bare concourse

all: certs/ca.pem certs/registry.pem certs/concourse.pem
