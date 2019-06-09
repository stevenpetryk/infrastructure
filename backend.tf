data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "stevenpetryk-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
