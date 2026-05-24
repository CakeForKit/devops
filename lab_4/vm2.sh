# ключ от vm1
kate@vm2:~$ cat ./.ssh/authorized_keys
ssh-rsa A......+qqMOQMppZ62HuQ== kate@vm1

sudo useradd -m -s /bin/bash ansible
sudo passwd ansible
sudo usermod -aG sudo ansible
id ansible  # проверка

sudo nano /etc/sudoers.d/ansible
    ansible ALL=(ALL) NOPASSWD: ALL

sudo -u ansible sudo whoami # проверка


sudo systemctl status postgresql 
sudo -u postgres psql -l | grep my_app_db # проверка что бд создана
sudo -u postgres psql -c "SELECT usename FROM pg_user;"

sudo systemctl status nginx
sudo nginx -t
curl -I http://localhost


# пингуем nfinx и caddy из вм2
curl -I http://192.168.75.129:8083
curl -I http://192.168.75.129:8082