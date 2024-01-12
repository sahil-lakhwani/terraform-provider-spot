# Note that provider name should not contain underscore or dash, it causes issues while discovery
PROVIDER_NAME := rxtspot

.PHONY: generate scaffold-ds scaffold-rs scaffold-provider build install apply clean uninstall test fmt lint check-versions docs

generate:
	echo "Generating provider, resources, data-sources schema files from provider_code_spec.json..."
	tfplugingen-framework generate all --input ./provider_code_spec.json --output internal/provider

install:
	echo "Installing provider..."
	go install .

apply:
	echo "Applying sample-terraform..."
	cd examples/simple-cloudspace && terraform apply -auto-approve && cd ../..

clean:
	echo "Cleaning up..."
	rm -rf ~/go/bin/terraform-provider-$(PROVIDER_NAME)

uninstall:
	echo "Uninstalling provider..."
	go clean -i .
	rm -f ~/go/bin/terraform-provider-$(PROVIDER_NAME)

test:
	echo "Running tests..."
	go test ./...

fmt:
	echo "Formatting code..."
	go fmt ./...

docs:
	echo "Generating docs..."
	tfplugindocs generate --rendered-provider-name "Rackspace Spot"

lint:
	echo "Linting code..."
	go vet ./...

scaffold-ds:
	echo "Scaffolding data-source code..."
	@if [ -z "$(NAME)" ]; then \
		echo "Error: Data-source name not provided. Usage: make scaffold NAME=<data-source-name>"; \
		exit 1; \
	fi
	echo "Scaffolding code for data-source $(NAME)..."
	tfplugingen-framework scaffold data-source --name $(NAME) --output-dir ./internal/provider --force

scaffold-rs:
	echo "Scaffolding resource code..."
	@if [ -z "$(NAME)" ]; then \
		echo "Error: resource name not provided. Usage: make scaffold NAME=<resource-name>"; \
		exit 1; \
	fi
	echo "Scaffolding code for resource $(NAME)..."
	tfplugingen-framework scaffold resource --name $(NAME) --output-dir ./internal/provider --force

scaffold-provider:
	echo "Scaffolding provider code..."
	tfplugingen-framework scaffold resource --name $(PROVIDER_NAME) --output-dir ./internal/provider --force

dependencies:
	echo "Installing dependencies..."
	go install github.com/deepmap/oapi-codegen/v2/cmd/oapi-codegen@latest
	go install github.com/hashicorp/terraform-plugin-codegen-framework/cmd/tfplugingen-framework@latest

check-versions:
	echo "Checking Go version..."
	# TODO: Do this programmatically
	echo "Go version must be at least 1.21.4"
	echo "Checking Terraform version..."
	echo "Terraform version must be at least 1.6.6"
	echo "Checking tfplugingen-framework version..."
	echo "tfplugingen-framework version must be at least 0.3.1"
