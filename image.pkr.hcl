packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.6"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

source "amazon-ebs" "dotnet-windows-base" {
  ami_name              = "dotnet-windows-base"
  communicator          = "winrm"
  instance_type         = "t2.micro"
  region                = "${var.region}"
  source_ami            = "ami-0ced908879ca69797"
  force_deregister      = true
  force_delete_snapshot = true

  tags = {
    Name = "dotnet-windows-base"
  }

  user_data_file = "./winrm.ps1"

  winrm_password = "${var.admin_password}"
  winrm_username = "Administrator"
}

build {
  name    = "dotnet-windows-base"
  sources = ["source.amazon-ebs.dotnet-windows-base"]

  provisioner "powershell" {
    script = "./setup.ps1"
  }
}