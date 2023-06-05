#!/bin/bash

# Variables
s3_bucket="your-s3-bucket"
bundle_file="bundle.pem.p7b"
local_bundle_file="/path/to/local/bundle.pem.p7b"
local_cert_path="/path/to/local/"
certdir=/etc/pki/ca-trust/source/anchors
certdir_debian=/usr/local/share/ca-certificates

# Download bundle.pem.p7b from S3 bucket
aws s3 cp "s3://${s3_bucket}/${bundle_file}" "${local_bundle_file}"

# Convert bundle.pem.p7b to individual certificates
openssl pkcs7 -print_certs -in "${local_bundle_file}" |
awk '/subject=/ {print > "'${local_cert_path}'cert." ++c ".pem"}'

# Update CA trust
if [[ -f /etc/redhat-release ]]; then
  update-ca-trust
elif [[ -f /etc/lsb-release ]]; then
  update-ca-certificates
else
  echo "Unsupported distribution. Please update CA trust manually."
fi
