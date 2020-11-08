FROM vito/oci-build-task:latest
COPY certs/ca.pem /usr/local/share/ca-certificates/local-ca.crt
RUN update-ca-certificates
