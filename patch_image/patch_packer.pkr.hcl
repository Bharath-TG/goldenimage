packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# Using a Rocky Linux AMI as the base
source "amazon-ebs" "rocky-linux" {
  region          = "us-east-2"  # ohio region
  ami_name        = "rocky-ami-version-1-{{timestamp}}"
  instance_type   = "t2.small"    # Instance type (can adjust as needed)
  source_ami      = "ami-0f21a8af23757e873"  # Replace with the correct Rocky Linux AMI ID
  ssh_username    = "rocky"  # Default SSH username for Rocky Linux
  ami_regions     = [
    "us-east-2"
  ]
 # ssh_keypair_name  = "bharath_tg"
 # ssh_private_key_file = "/etc/ansible/bharath_tg.pem"
}

# Build configuration to install, configure, and provision
build {
  name = "rocky-packer"
  sources = [
    "source.amazon-ebs.rocky-linux"
  ]
  
  provisioner "shell" {
    script= "ansible.sh"
  }

  provisioner "ansible-local" {
    playbook_file = "patch_playbook.yml"
  }

  provisioner "shell" {
    script= "cleanup.sh"
  }

}
