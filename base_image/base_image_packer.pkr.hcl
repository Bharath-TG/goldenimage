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
  region          = "ap-south-1"  # ohio region
  ami_name        = "rocky-ami-version-1-{{timestamp}}"
  instance_type   = "t3a.large"    # Instance type (can adjust as needed)
  source_ami      = "ami-0321f0c22d67f6571"   # "ami-05150ea4d8a533099" Replace with the correct Rocky Linux AMI ID
  ssh_username    = "rocky"  # Default SSH username for Rocky Linux
  ami_regions     = [
    "ap-south-1" #, "us-east-1"
  ]
  # ssh_keypair_name  = "keypair"
  # ssh_private_key_file = "/etc/ansible/keypair.pem"
  launch_block_device_mappings {
    volume_type = "gp3"
    device_name = "/dev/xvda"
    delete_on_termination = true
    volume_size = 30
    }

  launch_block_device_mappings  {
    volume_type = "gp3"
    device_name = "/dev/sdf"
    delete_on_termination = true
    volume_size = 100
    kms_key_id = "9934778b-963e-498d-8a4e-0fa3e3f83678"
  }
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
    playbook_file = "composer_playbook.yml"
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
