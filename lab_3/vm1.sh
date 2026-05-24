sudo iptables -L -n -v --line-numbers
# На машине ВМ1 (пограничный маршрутизатор из ЛР1) открыть средствами сетевого экрана порт 22 для доступа только с ВМ2 и 80 для доступа из открытой сети.
sudo iptables -A INPUT -p tcp --dport 22 -s 192.168.75.2 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j DROP
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables-save > /etc/iptables/rules.v4

# Создание пользователя для деплоя
sudo useradd -m -s /bin/bash deployer
sudo usermod -aG sudo deployer
sudo mkdir -p /var/www/myapp    #  для хранения файлов веб-приложения,
sudo chown -R deployer:deployer /var/www/myapp

# Создаем группу и даем права на nginx
sudo groupadd nginx-users
sudo usermod -aG nginx-users deployer
# Даем группе права на порты
sudo setcap 'cap_net_bind_service=+ep' /usr/sbin/nginx

# На ВМ1

# Список доверенных публичных ключей
# Вставить из  sudo -u gitlab-runner-user cat /home/gitlab-runner-user/.ssh/id_rsa.pub
sudo nano /home/deployer/.ssh/authorized_keys
sudo chmod 600 /home/deployer/.ssh/authorized_keys
sudo chown -R deployer:deployer /home/deployer/.ssh

# Настроить sudo без пароля для Nginx команд
sudo visudo -f /etc/sudoers.d/deployer
    deployer ALL=(ALL) NOPASSWD: ALL

# проверить изменения конфикга !!!
sudo nano /etc/nginx/sites-available/default


