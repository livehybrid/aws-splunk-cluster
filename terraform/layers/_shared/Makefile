args =
tf-command = apply
force = false
env = audit
guard-%:
	@ if [ "${${*}}" = "" ]; then \
        echo "Environment variable $* not set"; \
        exit 1; \
    fi

.ONESHELL:

terraform-clean-output: guard-env
	@terraform init -var-file=vars/$(env).tfvars -backend-config=conf/$(env).backend.conf 2>&1 >/dev/null
	if terraform workspace list | grep $(env); then terraform workspace select $(env); else terraform workspace new $(env); fi 2>&1 >/dev/null
	terraform output $(args)

terraform-init: guard-env
	terraform init -var-file=vars/$(env).tfvars -backend-config=conf/$(env).backend.conf
	if terraform workspace list | grep $(env); then terraform workspace select $(env); else terraform workspace new $(env); fi

terraform: guard-env
	terraform init -var-file=vars/$(env).tfvars -backend-config=conf/$(env).backend.conf
	if terraform workspace list | grep $(env); then terraform workspace select $(env); else terraform workspace new $(env); fi
	@ if [ "$(tf-command)" != "output" ]; then \
    	terraform $(tf-command) -var-file=vars/$(env).tfvars $(args); \
	else \
    	terraform $(tf-command) $(args); \
	fi

terraform-import: guard-env guard-object guard-arn
	terraform init -var-file=vars/$(env).tfvars -backend-config=conf/$(env).backend.conf
	if terraform workspace list | grep $(env); then terraform workspace select $(env); else terraform workspace new $(env); fi
	terraform import -var-file=vars/$(env).tfvars  $(object) $(arn)

terraform-rm: guard-env guard-object
	terraform init -var-file=vars/$(env).tfvars -backend-config=conf/$(env).backend.conf
	if terraform workspace list | grep $(env); then terraform workspace select $(env); else terraform workspace new $(env); fi
	terraform state rm -var-file=vars/$(env).tfvars  $(object)

terraform-clean:
	rm -r .terraform | true
	rm errored.tfstate | true


terraform-no-init: guard-env
	@ if [ "$(tf-command)" != "output" ]; then \
    	terraform $(tf-command) -var-file=vars/$(env).tfvars $(args); \
	else \
    	terraform $(tf-command) $(args); \
	fi
