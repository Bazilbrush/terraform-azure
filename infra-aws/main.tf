terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    ansible = {
        source = "nbering/ansible"
        version = "1.0.4"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "backend"
      storage_account_name = "backendthni7"
      container_name       = "backend"
      key                  = "tests/integration-aws/basic.tfstate"
  }

}

provider "azurerm" {
  use_oidc = true
  features {}
}
provider "aws" {
  region = "eu-west-1"
#   assume_role_with_web_identity {
#     role_arn                = "arn:aws:iam::123456789012:role/ROLE_NAME"
#     session_name            = "SESSION_NAME"
#     web_identity_token_file = "/Users/tf_user/secrets/web-identity-token"
#   }
}