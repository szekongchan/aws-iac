# Hello Ansible

## Provision of ec2 instances using terraform

1. Keeping things simple, using localhost as control node. TODO: create a control node next step.
2. Generate the inventory.ini with the pem file and hostname of the managed nodes added to the file

Ref: [hcl](hcl)

## Automate the adding of these ec2 instances to .ssh/known_hosts

1. add created host to known_hosts automatically
2. Tests

```
cd ~/Projects/aws-iac/ansible/hcl
terraform apply
cd ..
ansible-playbook -i inventory.ini playbooks/bootstrap_known_hosts.yml
ansible -i inventory.ini server -m ping
```

Ref: [playbooks](playbooks)
