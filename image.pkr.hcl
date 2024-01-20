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
  type = string
}

source "amazon-ebs" "dotnet-windows-final" {
  ami_name              = "dotnet-windows-final"
  communicator          = "winrm"
  instance_type         = "t2.micro"
  region                = "${var.region}"
  force_deregister      = true
  force_delete_snapshot = true

  source_ami_filter {
    filters = {
      name = "dotnet-windows-base"
    }
    owners = ["self"]
  }

  tags = {
    Name = "dotnet-windows-final"
  }

  user_data_file = "./winrm_setup.txt"
  winrm_password = "${var.admin_password}"
  winrm_username = "Administrator"
}

build {
  name    = "dotnet-windows-final"
  sources = ["source.amazon-ebs.dotnet-windows-final"]

  provisioner "powershell" {
    script = "./setup.ps1"
  }
}