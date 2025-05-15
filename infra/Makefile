.PHONY: init new_workspace

init:
	terraform -chdir=terraform/ init -backend-config=environments/backend.conf

init-reconfigure:
	terraform -chdir=terraform/ init -reconfigure -backend-config=environments/backend.conf

new_workspace:
	terraform -chdir=terraform/ workspace new testnet

testnet: tf_testnet refresh apply

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

output:
	terraform -chdir=terraform/ output

output_ssh:
	terraform -chdir=terraform/ output iap_tunnel_command

output_scp:
	terraform -chdir=terraform/ output iap_scp_command

output_lightnode_scp:
	terraform -chdir=terraform/ output iap_lightnode_scp_command

output_scripts_scp:
	terraform -chdir=terraform/ output scripts_scp_command

output_lightnode_scripts_scp:
	terraform -chdir=terraform/ output lightnode_scripts_scp_command

make_rsync:
	./scripts/rsync.sh

make_lightnode_rsync:
	./scripts/lightnode.rsync.sh

trigger_docker_pull:
	./scripts/ssh.sh "docker pull ghcr.io/xerberusteam/xerberus-node-v2:full-node-latest"

trigger_lightnode_docker_pull:
	./scripts/lightnode.ssh.sh "docker pull ghcr.io/xerberusteam/xerberus-node-v2:light-node-latest"

trigger_ansible:
	./scripts/ssh.sh ./ansible/scripts/03-provision.sh

trigger_lightnode_ansible:
	./scripts/lightnode.ssh.sh ./ansible/scripts/03-provision.sh

ansible_provision: make_rsync trigger_docker_pull trigger_ansible

lightnode_ansible_provision: make_lightnode_rsync trigger_lightnode_docker_pull trigger_lightnode_ansible
