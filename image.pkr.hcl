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

// variable "admin_password" {
//   type      = string
//   default   = "Parola123!!!"
//   sensitive = true
// }

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

  // user_data      = "net user Administrator Parola123!!!"
  user_data_file = "./winrm.ps1"

  winrm_password = "Parola123!!!"
  winrm_username = "Administrator"
}

build {
  name    = "dotnet-windows-base"
  sources = ["source.amazon-ebs.dotnet-windows-base"]

  provisioner "powershell" {
    script = "./setup.ps1"
  }

  provisioner "powershell" {
    script = "./dotnet-install.ps1 -Channel 8.0 -Runtime windowsdesktop"
  }

  provisioner "powershell" {
    script = "./dotnet-install.ps1 -Channel 8.0 -Runtime aspnetcore"
  }
}