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

  user_data = <<-EOF
<powershell>
# Set administrator password
net user Administrator Parola123!!!
wmic useraccount where " name = ' Administrator ' " set PasswordExpires=FALSE

# First, make sure WinRM can't be connected to
netsh advfirewall firewall set rule name=" Windows Remote Management(HTTP-In) " new enable=yes action=block

# Delete any existing WinRM listeners
winrm delete winrm/config/listener?Address=*+Transport=HTTP  2>$Null
winrm delete winrm/config/listener?Address=*+Transport=HTTPS 2>$Null

# Disable group policies which block basic authentication and unencrypted login

Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client -Name AllowBasic -Value 1
Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client -Name AllowUnencryptedTraffic -Value 1
Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service -Name AllowBasic -Value 1
Set-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service -Name AllowUnencryptedTraffic -Value 1


# Create a new WinRM listener and configure
winrm create winrm/config/listener?Address=*+Transport=HTTP
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB=" 0 "}'
winrm set winrm/config '@{MaxTimeoutms=" 7200000 "}'
winrm set winrm/config/service '@{AllowUnencrypted=" true "}'
winrm set winrm/config/service '@{MaxConcurrentOperationsPerUser=" 12000 "}'
winrm set winrm/config/service/auth '@{Basic=" true "}'
winrm set winrm/config/client/auth '@{Basic=" true "}'

# Configure UAC to allow privilege elevation in remote shells
$Key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$Setting = 'LocalAccountTokenFilterPolicy'
Set-ItemProperty -Path $Key -Name $Setting -Value 1 -Force

# Configure and restart the WinRM Service; Enable the required firewall exception
Stop-Service -Name WinRM
Set-Service -Name WinRM -StartupType Automatic
netsh advfirewall firewall set rule name=" Windows Remote Management(HTTP-In) " new action=allow localip=any remoteip=any
Start-Service -Name WinRM
</powershell>
EOF

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
    inline = [
      "./dotnet-install.ps1 -Channel 8.0 -Runtime windowsdesktop",
      "./dotnet-install.ps1 -Channel 8.0 -Runtime aspnetcore"
    ]
  }
}