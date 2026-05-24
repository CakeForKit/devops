sudo apt install -y ansible
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
ssh-copy-id kate@192.168.75.2

ssh-copy-id ansible@192.168.75.2
ssh ansible@192.168.75.2    # работает без пароля

mkdir -p ~/ansible-lab/{inventory,roles,playbooks}
sudo cp /mnt/hgfs/devops/lab_4/for_copy/inventory_hosts.ini ~/ansible-lab/inventory/hosts.ini 

# проверка
ansible -i ./ansible-lab/inventory/hosts.ini -m ping all

ansible-galaxy init ./ansible-lab/roles/postgresql
ansible-galaxy init ./ansible-lab/roles/nginx

echo "sudo cp -r ~/ansible-lab/roles/nginx  /mnt/hgfs/devops/lab_4/for_copy/roles
sudo cp -r ~/ansible-lab/roles/postgresql  /mnt/hgfs/devops/lab_4/for_copy/roles
" >   to_me_tasks.sh
echo "sudo cp -r  /mnt/hgfs/devops/lab_4/for_copy/roles/nginx/. ~/ansible-lab/roles/nginx
sudo cp -r  /mnt/hgfs/devops/lab_4/for_copy/roles/postgresql/. ~/ansible-lab/roles/postgresql
" >   from_me_tasks.sh


# Написны задачи для подустановки пакетов, запуска сервери и поднятия бд и т д в ~/ansible-lab/roles/***/tasks/main.yml
roles/nginx/templates/default.conf.j2 # шаблон
roles/nginx/defaults/main.yml # переменные для шаблона
roles/nginx/handlers/main.yml


curl http://192.168.75.2:8089

sudo cp -r  /mnt/hgfs/devops/lab_4/for_copy/playbooks/site.yml ~/ansible-lab/playbooks/site.yml
sudo cp -r  /mnt/hgfs/devops/lab_4/for_copy/ansible.cfg ~/ansible-lab/ansible.cfg

ansible -i inventory/hosts.ini -m ping all
ansible-playbook -i inventory/hosts.ini playbooks/site.yml



##  Terraform
wget https://hashicorp-releases.yandexcloud.net/terraform/1.14.6/terraform_1.14.6_linux_amd64.zip
sudo apt install -y unzip
unzip terraform_1.14.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform --version

mkdir terraform-lab
echo "sudo cp -r  /mnt/hgfs/devops/lab_4/for_copy/terraform-lab/. ~/terraform-lab
sudo cp -r  /mnt/hgfs/devops/lab_4/for_copy/.terraformrc ~/.terraformrc
" >   from_me_terraform.sh

terraform init
sudo terraform fmt  # проверка форматирования
sudo terraform validate
terraform plan

# Docker 
sudo apt install docker.io -y
sudo systemctl daemon-reload && sudo systemctl enable docker && sudo systemctl start docker && sudo systemctl status docker
sudo usermod -aG docker $USER
newgrp docker

terraform apply -auto-approve