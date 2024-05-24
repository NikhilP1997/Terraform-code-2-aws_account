provider "aws" {
  alias      = "account_a"
  region     = "ap-south-1"
  profile    = "account_a_profile"
  access_key = "***************"
  secret_key = "***************"
}
provider "aws" {
  alias      = "account_b"
  region     = "ap-south-1"
  profile    = "account_b_profile"
  access_key = "******************"
  secret_key = "*******************"
}

terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}
