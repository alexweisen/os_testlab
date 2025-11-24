terraform {
  backend "local" {
    path = "../../../terraform/tfstate/terraform.tfstate"
  }
}
