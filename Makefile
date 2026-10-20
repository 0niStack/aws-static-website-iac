ENV      ?= dev
SITE_DIR ?= ./dist
TF       ?= $(shell command -v tofu >/dev/null 2>&1 && echo tofu || echo terraform)
DIR       = environments/$(ENV)

.PHONY: bootstrap init plan apply destroy output fmt validate lint sec deploy

bootstrap: ## create the remote-state bucket (once per AWS account)
	cd bootstrap/state-backend && $(TF) init && $(TF) apply

init:
	$(TF) -chdir=$(DIR) init -backend-config=backend.hcl

plan: init
	$(TF) -chdir=$(DIR) plan -out=tfplan

apply:
	$(TF) -chdir=$(DIR) apply tfplan

destroy:
	$(TF) -chdir=$(DIR) destroy

output:
	$(TF) -chdir=$(DIR) output

fmt:
	$(TF) fmt -recursive

validate:
	@for d in modules/static-site bootstrap/state-backend environments/*; do \
	  echo "==> $$d"; $(TF) -chdir=$$d init -backend=false -input=false >/dev/null && $(TF) -chdir=$$d validate || exit 1; \
	done

lint:
	tflint --recursive

sec: ## static security scan
	trivy config --severity HIGH,CRITICAL .

deploy:
	scripts/deploy.sh $(ENV) $(SITE_DIR)
