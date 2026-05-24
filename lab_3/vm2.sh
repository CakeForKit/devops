
# Установка GitLab Runner
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
sudo apt install gitlab-runner

# Создание пользователя для раннера
sudo useradd -m -s /bin/bash gitlab-runner-user



# kate@vm2:~$ id gitlab-runner-user
# uid=1002(gitlab-runner-user) gid=1002(gitlab-runner-user) groups=1002(gitlab-runner-user)


sudo mkdir -p /home/gitlab-runner-user/.gitlab-runner &&
sudo chown -R gitlab-runner-user:gitlab-runner-user /home/gitlab-runner-user &&
sudo mkdir -p /home/gitlab-runner-user/builds &&
sudo chown -R gitlab-runner-user:gitlab-runner-user /home/gitlab-runner-user/builds &&
sudo mkdir -p /home/gitlab-runner-user/cache &&
sudo chown -R gitlab-runner-user:gitlab-runner-user /home/gitlab-runner-user/cache


sudo su - gitlab-runner-user    # Переключаемся на пользователя gitlab-runner-user

gitlab-runner register \
  --url https://git.iu7.bmstu.ru \
  --token glrt-mE5tV7RnT1lPKoA9MCFTyG86MQpwOjd1dAp0OjMKdToxZmUT.01.1c0cqhgyt \
  --executor shell \
  --description "VM2 Shell Runner"

# gitlab-runner register  --url https://git.iu7.bmstu.ru  --token glrt-mE5tV7RnT1lPKoA9MCFTyG86MQpwOjd1dAp0OjMKdToxZmUT.01.1c0cqhgyt


sudo cp /mnt/hgfs/devops/lab_3/gitlab-runner.service /etc/systemd/system/gitlab-runner.service
sudo systemctl daemon-reload && sudo systemctl enable gitlab-runner && sudo systemctl start gitlab-runner && sudo systemctl status gitlab-runner

# Отключение /bin/bash --login в shell
sudo -i -u gitlab-runner-user
echo "" > ~/.bash_logout


# ssh ключ
sudo -u gitlab-runner-user ssh-keygen -t rsa -b 4096 -N "" -f /home/gitlab-runner-user/.ssh/id_rsa
sudo -u gitlab-runner-user cat /home/gitlab-runner-user/.ssh/id_rsa.pub
# приватный ключ в маскированную переменную в gitlab
sudo -u gitlab-runner-user cat /home/gitlab-runner-user/.ssh/id_rsa | base64 -w0



# Настрокйка postfix
sudo apt install -y ssmtp mailutils
sudo nano /etc/ssmtp/ssmtp.conf
    mailhub=smtp.mail.ru:465
    AuthUser=katherine_2022@mail.ru
    AuthPass=ZOd1zNZtq8qcxmdRBB4q
    UseTLS=YES
    FromLineOverride=YES
# katherine_2022@mail.ru
# ZOd1zNZtq8qcxmdRBB4q

# gitlab api token glpat-SFnRcC5_GTFF9tzTxprK_286MQp1OjMxcgk.01.0z07qiqr0

# echo "qweqwe" | mail -a "From: katherine_2022@mail.ru" -s "22222T" "katherine_2022@mail.ru"