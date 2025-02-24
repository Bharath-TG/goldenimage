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
 # ssh_keypair_name  = "keypair"
 # ssh_private_key_file = "/etc/ansible/keypair.pem"
}

# Build configuration to install, configure, and provision
build {
  name = "rocky-packer"
  sources = [
    "source.amazon-ebs.rocky-linux"
  ]
  
  provisioner "file" {
  source      = "fstab"  
  destination = "/tmp/fstab" 
  }

  provisioner "shell" {
  inline  = [ "sudo mv /tmp/fstab /etc/fstab" ]
  }

  provisioner "shell" {
    script= "ansible.sh"
  }
  
  provisioner "ansible-local" {
    playbook_file = "user_playbook.yml"
  }
  provisioner "ansible-local" {
    playbook_file = "nginx_playbook.yml"
  }
  provisioner "ansible-local" {
    playbook_file = "php_playbook.yml"
  }
  provisioner "ansible-local" {
    playbook_file = "nginx_prometheus_exporter_playbook.yml"
  }
  provisioner "ansible-local" {
    playbook_file = "node_exporter_playbook.yml"
  }
  provisioner "ansible-local" {
    playbook_file = "phpfpm_prometheus_exporter_playbook.yml"
  }
  provisioner "ansible-local" {
    playbook_file = "code_deploy_playbook.yml"
  }
  provisioner "ansible-local" {
    playbook_file = "filebeat_playbook.yml"
  }
  provisioner "ansible-local" {
    playbook_file = "initial_packages_playbook.yml"
  }
  provisioner "ansible-local" {
    playbook_file = "update_config_playbook.yml"
  }

  provisioner "shell" {
    script= "cleanup.sh"
  }

}
