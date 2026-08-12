# bootstrap

Creates your personal Terraform remote-state backend: one S3 bucket
(versioned, encrypted, private) and one DynamoDB table (for state
locking), both namespaced with your trainee name.

## Usage

```bash
cd bootstrap
terraform init
terraform apply -var="trainee_name=<your-name>"
terraform output
```

Take the `bucket` and `dynamodb_table` output values and use them to
fill in `../backend.hcl` (copy from `../backend.hcl.example`).

Keep `bootstrap/terraform.tfstate` safe — it is the only record of the
state bucket/table itself, and it is git-ignored like all other
`*.tfstate` files in this repo. Back it up somewhere private (not Git)
if you want to be able to tear the bootstrap resources down later with
`terraform destroy`.
