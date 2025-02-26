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
    "us-east-2" #, "us-east-1"
  ]
  # ssh_keypair_name  = "keypair"
  # ssh_private_key_file = "/etc/ansible/keypair.pem"
  # Adding a 200GB EBS volume
  ebs_block_device {
    device_name           = "/dev/xvda"  # Device name (e.g., /dev/sdh or /dev/xvdf depending on your instance)
    volume_size           = 200         # Size in GB
    volume_type           = "gp3"       # General Purpose SSD (can be modified to gp3, io1, etc. if needed)
    delete_on_termination = true        # Automatically delete the volume when the instance is terminated
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
