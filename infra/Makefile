.PHONY: init new_workspace

init:
	terraform -chdir=terraform/ init -backend-config=environments/backend.conf

init-reconfigure:
	terraform -chdir=terraform/ init -reconfigure -backend-config=environments/backend.conf

new_workspace:
	terraform -chdir=terraform/ workspace new testnet

testnet: tf_testnet refresh plan apply

tf_testnet:
	terraform -chdir=terraform/ workspace select testnet

plan:
	terraform -chdir=terraform/ plan

refresh:
	terraform -chdir=terraform/ refresh

apply:
	terraform -chdir=terraform/ apply

apply-auto:
	terraform -chdir=terraform/ apply -auto-approve

destroy:
	terraform -chdir=terraform/ destroy
