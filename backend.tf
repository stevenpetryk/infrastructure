terraform {
  backend "s3" {
    bucket = "stevenpetryk-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
