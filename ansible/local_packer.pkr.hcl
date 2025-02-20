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
  source_ami      = "ami-05150ea4d8a533099"  # Replace with the correct Rocky Linux AMI ID
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
    playbook_file = "main_playbook.yml"
    "extra_files": [
        "nginx_prometheus_exporter_playbook.yml",
        "nginx_playbook.yml",
        "user_playbook.yml",
        "php_playbook.yml",
        "node_exporter_playbook.yml",
        "filebeat_playbook.yml",
        "phpfpm_prometheus_exporter_playbook.yml"
      ]
  }

  provisioner "shell" {
    script= "cleanup.sh"
  }

}
