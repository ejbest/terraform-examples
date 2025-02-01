# be sure VAULT vars are created and access to vault
[ -f ".env" ] && source .env
source vars.sh

terraform fmt
terraform plan 



