plan:
	terraform plan
	@echo "apply with make apply"

apply:
	terraform apply

destroy:
	terraform destroy

get:
	terraform get
