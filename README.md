# Installation

## cfssl

Temporary installation

```shell
export CFSSLPATH=$(mktemp -d)
wget -O $CFSSLPATH/cfssl https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssl_1.5.0_linux_amd64
wget -O $CFSSLPATH/cfssljson https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssljson_1.5.0_linux_amd64
chmod +x $CFSSLPATH/cfssl $CFSSLPATH/cfssljson
export PATH=$PATH:$CFSSLPATH
```

## fly (concourse CLI)

```shell
wget https://concourse.local/api/v1/cli\?arch\=amd64\&platform\=linux -O fly
chmod +x fly
```
