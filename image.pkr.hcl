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

source "amazon-ebs" "dotnet-windows-base" {
  ami_name              = "dotnet-windows-base"
  communicator          = "winrm"
  instance_type         = "t2.micro"
  region                = "${var.region}"
  force_deregister      = true
  force_delete_snapshot = true

  source_ami_filter {
    filters = {
      name = "windows-dotnet-base"
    }
    owners = ["self"]
  }

  user_data_file = "./winrm_setup.txt"
  winrm_password = "SuperS3cr3t!!!!"
  winrm_username = "Administrator"
}

build {
  name    = "dotnet-windows-base"
  sources = ["source.amazon-ebs.dotnet-windows-base"]

  provisioner "powershell" {
    script = "./setup.ps1"
  }
}