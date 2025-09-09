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
  region          = "ap-south-2" # ohio region "ap-south-1"
  ami_name        = "beta-rocky-ami-version-{{timestamp}}"
  instance_type   = "t3.xlarge"    # Instance type (can adjust as needed)
  source_ami      = "ami-09f32eccb3e71734c" #  "ami-0321f0c22d67f6571" # "ami-05150ea4d8a533099" Replace with the correct Rocky Linux AMI ID
  ssh_username    = "rocky"  # Default SSH username for Rocky Linux
  ami_regions     = [
    "ap-south-2"
  ]
  # ssh_keypair_name  = "keypair"
  # ssh_private_key_file = "/etc/ansible/keypair.pem"

  iam_instance_profile = "packer_role"

  launch_block_device_mappings  {
    volume_type = "gp3"
    device_name = "/dev/sda1"
    delete_on_termination = true
    volume_size = 20
  }
  
  launch_block_device_mappings  {
    volume_type = "gp3"
    device_name = "/dev/sdf"
    delete_on_termination = true
    volume_size = 100
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

  provisioner "file" {
    source      = "scripts"
    destination = "/tmp/scripts"
  }

  provisioner "shell" {
    inline = [
      "sudo mkdir -p /root/scripts",
      "sudo mv /tmp/scripts/* /root/scripts/",
      "sudo chown -R root:root /root/scripts",
      "sudo chmod +x /root/scripts/"
    ]
  }

  provisioner "ansible-local" {
    playbook_file = "../additional_packages/user_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../nginx/nginx_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../squid/squid_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../php-fpm/php_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../exporters/node_exporter_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../exporters/nginx_prometheus_exporter_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../exporters/phpfpm_prometheus_exporter_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../additional_packages/composer_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../filebeat/filebeat_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../additional_packages/basic_packages_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../additional_packages/tripwire_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../additional_packages/logwatch_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../additional_packages/supervisord_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../additional_packages/host_conf_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../additional_packages/logrotate_conf_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../filebeat/filebeat_conf_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../nginx/nginx_conf_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../php-fpm/phpfpm_conf_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../squid/squid_conf_playbook.yml"
  }

  provisioner "ansible-local" {
    playbook_file = "../additional_packages/checkout_install_playbook.yml"
  }

  provisioner "shell" {
    script= "cleanup.sh"
  }

}
