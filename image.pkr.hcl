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
  type    = string
  default = "Parola123!!!"
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

  user_data_file = "./winrm_setup.txt"
  winrm_password = "${var.admin_password}"
  winrm_username = "Administrator"
}

build {
  name    = "dotnet-windows-base"
  sources = ["source.amazon-ebs.dotnet-windows-base"]

  provisioner "powershell" {
    script = "./setup.ps1"
  }

  provisioner "powershell" {
    inline = [
      "dotnet-install.ps1 -Channel 8.0 -Runtime windowsdesktop",
      "dotnet-install.ps1 -Channel 8.0 -Runtime aspnetcore"
    ]
  }
}