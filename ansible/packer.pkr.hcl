packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}

# Using a Rocky Linux AMI as the base
source "amazon-ebs" "rocky-linux" {
  region          = "us-east-2"  # ohio region
  ami_name        = "rocky-ami-version-1-{{timestamp}}"
  instance_type   = "t2.small"    # Instance type (can adjust as needed)
  source_ami      = "ami-05150ea4d8a533099"  # Replace with the correct Rocky Linux AMI ID
  ssh_username    = "rocky"  # Default SSH username for Rocky Linux
  ami_regions     = [
    "us-east-2"
  ]
}

# Build configuration to install, configure, and provision
build {
  name = "rocky-packer"
  sources = [
    "source.amazon-ebs.rocky-linux"
  ]

  provisioner "ansible" {
    playbook_file = "main_playbook.yml"  # Master playbook that includes others
    extra_arguments = ["-u", "rocky"]
  }
}
