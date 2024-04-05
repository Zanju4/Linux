#!/bin/bash


echo "server setup..."

# network settings and /etc/hosts
configure_network() {
  echo "Configuring network..."
  sudo sed -i '/addresses:/c\      addresses: [192.168.16.21/24]' /etc/netplan/01-netcfg.yaml
  sudo netplan apply
  echo "192.168.16.21 server1" | sudo tee -a /etc/hosts
}

# software installation
install_software() {
  required_packages=("apache2" "squid")
  for package in "${required_packages[@]}"; do
    echo "Checking installation for $package..."
    if ! dpkg -l | grep -qw $package; then
      echo "Installing $package..."
      sudo apt-get install -y $package
    else
      echo "$package is already installed."
    fi
  done
}

# firewall rules
configure_firewall() {
  echo "Configuring firewall..."
  sudo ufw allow 22/tcp
  sudo ufw allow 80/tcp
  sudo ufw allow 3128/tcp
  sudo ufw --force enable
}

# create user accounts
create_users() {
  users=("dennis" "aubrey" "captain")
  echo "Creating user accounts..."
  for user in ${users[@]}; do
    if ! id "$user" &>/dev/null; then
      sudo adduser --gecos "" --disabled-password $user
      echo "User $user created."
    else
      echo "User $user already exists."
    fi
  done
  # Adding sudo access for dennis
  sudo usermod -aG sudo dennis
}

main() {
  configure_network
  sudo apt-get update
  install_software
  configure_firewall
  create_users
  echo "Server setup completed."
}

main
