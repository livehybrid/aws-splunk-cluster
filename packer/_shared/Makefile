args =

guard-%:
	@ if [ "${${*}}" = "" ]; then \
        echo "Environment variable $* not set"; \
        exit 1; \
    fi

packer-build:  guard-env
	packer build -var-file=vars/$(env).vars $(args) packer.json
