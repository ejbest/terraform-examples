source vars.sh


# be sure VAULT vars are created and access to vault
[ -f ".env" ] && source .env




env | grep -i TF_VAR

# read -p "Do you want to continue? (y/n): " choice
# if [[ "$choice" == [Yy] ]]; then
#   echo "Continuing..."
# else
#   echo "Exiting..."
#   exit 1
# fi

terraform init -upgrade \
                -reconfigure \
                -backend-config="endpoint=$(vault kv get -field=S3_MINIO_ENDPOINT ejbest/terraform/s3_minio)" \
                -backend-config="bucket=$(vault kv get -field=S3_MINIO_BUCKET ejbest/terraform/s3_minio)" \
                -backend-config="access_key=$(vault kv get -field=S3_MINIO_ACCESS_KEY ejbest/terraform/s3_minio)" \
                -backend-config="secret_key=$(vault kv get -field=S3_MINIO_SECRET_KEY ejbest/terraform/s3_minio)" \
                -backend-config="region=$(vault kv get -field=S3_MINIO_REGION ejbest/terraform/s3_minio)" \
                -backend-config="key=aws-webserver"
terraform fmt



