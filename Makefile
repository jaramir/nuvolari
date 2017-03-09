plan: aws.secret.tf
	terraform plan
	@echo "apply with make apply"

apply:
	terraform apply

destroy:
	terraform destroy

get:
	terraform get

aws.secret.tf:
	@echo "no aws.secret.tf file present"
	@exit 1
