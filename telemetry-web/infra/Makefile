.PHONY: init new_workspace

0-step: init
1-step: new_workspace
2-step: prod
3-step: make_rsync
4-step: trigger_ansible
5-step: trigger_docker_compose_status

all: 0-step 1-step 2-step 3-step 4-step 5-step

init:
	terraform -chdir=terraform/ init -backend-config=environments/backend.conf

init-reconfigure:
	terraform -chdir=terraform/ init -reconfigure -backend-config=environments/backend.conf

new_workspace:
	terraform -chdir=terraform/ workspace new prod

prod: tf_prod refresh apply

tf_prod:
	terraform -chdir=terraform/ workspace select prod

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

ansible_provision: make_rsync trigger_docker_pull trigger_ansible

make_rsync:
	./scripts/rsync.sh

trigger_docker_pull:
	./scripts/ssh.sh "docker pull ghcr.io/xerberusteam/xerberus-node:telemetry-frontend-latest"

trigger_ansible:
	./scripts/ssh.sh ./ansible/scripts/03-provision.sh

trigger_install_ansible:
	./scripts/ssh.sh ./ansible/scripts/00-install-ansible.sh

trigger_docker_compose_status:
	./scripts/ssh.sh "sudo docker compose -f /opt/xerberus/xerberus_dc/xerberus-compute.yml ps"

trigger_docker_compose_logs:
	./scripts/ssh.sh "sudo docker compose -f /opt/xerberus/xerberus_dc/xerberus-compute.yml logs -f"

trigger_docker_compose_restart:
	./scripts/ssh.sh "sudo docker compose -f /opt/xerberus/xerberus_dc/xerberus-compute.yml restart"

trigger_docker_compose_clean:
	./scripts/ssh.sh "sudo docker compose -f /opt/xerberus/xerberus_dc/xerberus-compute.yml down -v --remove-orphans --rmi all"
