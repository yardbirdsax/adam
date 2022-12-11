EXAMPLE_DIR = example
EXAMPLE_TERRAFORM_DIR = $(EXAMPLE_DIR)/terraform
EXAMPLE_EKS_DIR = $(EXAMPLE_TERRAFORM_DIR)/eks

.PHONY: example-up
example-up:
	@cd $(EXAMPLE_EKS_DIR) && \
		terraform init && \
		terraform apply
	@EKS_CLUSTER_ID=$$(make example-output | \
		jq '.cluster_id.value' -r) && \
		aws eks update-kubeconfig --name $${EKS_CLUSTER_ID} --alias adam-example
	@export AWS_ROLE_ARN=$$(make example-output | \
		jq '.role_arn.value' -r) && \
		helmfile apply -f $(EXAMPLE_DIR)/helmfile.yml

.PHONY: example-output
example-output:
	@cd $(EXAMPLE_EKS_DIR) && \
	terraform output -json

.PHONY: example-down
example-down:
	@cd $(EXAMPLE_EKS_DIR) && \
	terraform destroy

.PHONY: clean
clean:
	find . -name .terraform | xargs -n 1 rm -rf