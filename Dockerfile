FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive

# Mise à jour des paquets et installation des dépendances nécessaires
RUN apt-get update && apt-get install -y     software-properties-common     curl     gnupg     unzip     git     python3     python3-pip     ufw     fail2ban &&     curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg &&     echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main" | tee /etc/apt/sources.list.d/hashicorp.list &&     apt-get update && apt-get install -y terraform &&     pip3 install ansible &&     ansible --version &&     ufw default deny incoming && ufw default allow outgoing && ufw allow ssh && ufw enable

CMD ["/bin/bash"]
