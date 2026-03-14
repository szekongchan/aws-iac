# Coaching 8

## Local Setup

Use the example tfvars file to provide environment-specific values.

1. Copy the template:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` and set your VPC Name tag:

```hcl
vpc_name = "ce-learner-vpc"
```

3. Validate the configuration:

```bash
terraform init
terraform validate
```

Notes:

- `terraform.tfvars.example` is committed as a safe template.
- `terraform.tfvars` is ignored by git and should stay local.
