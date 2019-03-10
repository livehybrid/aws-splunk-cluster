SHELL := /bin/bash
########################################################################################################################
##
## Makefile for managing Splunk cluster on AWS
##
########################################################################################################################
THIS_FILE := $(lastword $(MAKEFILE_LIST))
activate = VIRTUAL_ENV_DISABLE_PROMPT=true . .venv/bin/activate;
pwd := ${PWD}
dirname := $(notdir ${PWD})
# DO NOT ADD DEVELOP / LOCAL CONFIG TO THIS LIST
standard_terraform_layers := account iam instances 


ensure-venv:
ifeq ($(wildcard .venv),)
	@$(MAKE) -f $(THIS_FILE) venv
endif

guard-%:
	@ if [ "${${*}}" = "" ]; then \
        echo "Environment variable $* not set"; \
        exit 1; \
    fi

# environment initilisation
venv:
	if [ -d .venv ]; then rm -rf .venv; fi
	python3.6 -m venv .venv --clear
	$(activate) pip3 install --upgrade pip

terraform-clean:
	for layer in $(standard_terraform_layers); do \
		make -C terraform/layers/$$layer terraform-clean; \
	done

# terraform
terraform: guard-env
	for layer in $(standard_terraform_layers); do \
		env=$(env) make -C terraform/layers/$$layer terraform; \
	done
	

terraform-no-init: guard-env
	for layer in $(standard_terraform_layers); do
		env=$(env) make -C terraform/layers/$$layer terraform-no-init; \
	done

terraform-local: guard-env
	for layer in $(standard_terraform_layers); do \
		env=$(env) make -C terraform/layers/$$layer terraform-local; \
	done

terraform-local-no-init: guard-env
	for layer in $(standard_terraform_layers); do \
		env=$(env) make -C terraform/layers/$$layer terraform-local-no-init; \
	done

# packer
packer-build-core-ubuntu-base:
	$(MAKE) -C packer/core-ubuntu-base packer-build

packer-build-splunk:
	$(MAKE) -C packer/core-proxy packer-build

# ansible
sync-up: guard-env guard-RELEASE
	env=$(env) RELEASE=$(RELEASE) $(MAKE) -C ansible sync-up


run-cmd: guard-host guard-cmd
	ansible -m shell tag_Name_$(host) -a '$(cmd)'

run-sudo-cmd: guard-host guard-cmd
	ansible -m shell tag_Name_$(host) -b -a '$(cmd)'

# super crazy run things this is for jenkins really .. it mirrors the commands for the management server

#########################################################################################################################
###
### Generic ansible command running
###
#########################################################################################################################
first_target := $(firstword $(MAKECMDGOALS))
cmd_targets := run run-tag run-name ansible
run_targets := run run-tag run-host
ifneq ($(filter $(first_target),$(cmd_targets)),)
  cmd := $(wordlist 2, $(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(cmd):;@true)
  ifneq ($(filter $(first_target),$(run_targets)),)
  	host := $(wordlist 1, 1,$(cmd))
	cmd := $(wordlist 2, $(words $(cmd)),$(cmd))
$(eval $(host):;@true)
$(eval $(cmd):;@true)
    ifneq ($(filter $(first_target),run-tag),)
    	tag := $(host)
      	tag_val := $(wordlist 1, 1,$(cmd))
    	cmd := $(wordlist 2, $(words $(cmd)),$(cmd))
$(eval $(tag):;@true)
$(eval $(tag_val):;@true)
$(eval $(cmd):;@true)
  	endif
  endif
endif

run: guard-host guard-cmd
	ansible -m shell tag_Name_$(host) -a '$(cmd)'

run-sudo: guard-host guard-cmd
	ansible -m shell tag_Name_$(host) -b -a '$(cmd)'

run-host: guard-host guard-cmd
	ansible -m shell $(host) -a '$(cmd)'

run-tag: guard-tag guard-tag_val guard-cmd
	ansible -m shell tag_$(tag)_$(tag_val) -a '$(cmd)'
