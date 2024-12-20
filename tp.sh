#!/bin/bash

# Désactive les prompts interactifs pendant les installations
export DEBIAN_FRONTEND=noninteractive

# Création d'un Dockerfile pour configurer le conteneur
cat <<EOF > Dockerfile
FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive

# Mise à jour des paquets et installation des dépendances nécessaires
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    gnupg \
    unzip \
    git \
    python3 \
    python3-pip \
    ufw \
    fail2ban && \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform && \
    pip3 install ansible && \
    ansible --version && \
    ufw default deny incoming && ufw default allow outgoing && ufw allow ssh && ufw enable

CMD ["/bin/bash"]
EOF


# Créer et exécuter un conteneur Docker
echo "Création et démarrage du conteneur Docker..."
docker rm -f dock-thom-terra-ansi 2>/dev/null || true
docker run -it --name dock-thom-terra-ansi debian:latest

# Création d'un playbook Ansible
cat <<EOP > playbook.yml
---
- name: Playbook Ansible
  hosts: localhost
  tasks:
    - name: Vérifier les versions des outils
      command: "{{ item }}"
      with_items:
        - terraform version
        - python3 --version
        - ansible --version

    - name: Configurer UFW
      become: true
      ansible.builtin.shell: |
        ufw default deny incoming
        ufw default allow outgoing
        ufw allow ssh
        ufw enable

    - name: Vérifier Fail2Ban
      become: true
      ansible.builtin.command: fail2ban-client --version
EOP

echo "Playbook Ansible 'playbook.yml' créé."

# Création d'un fichier terraform
cat <<EOP > main.tf
  terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.16.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}
EOP

echo "fichier terraform 'main.tf' créé."
