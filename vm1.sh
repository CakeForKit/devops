# Nginx 80
# Caddy 8080            http://192.168.170.138:8080/
# Prometheus 9090       http://192.168.170.138:9090
# node_exporter 9100 (default выдает метрики хоста)
# Alert                 http://192.168.170.138:9093     
# Blackbox probe_success{instance="https://yandex.ru"}
# Graphana              http://192.168.170.138:3000

# cron  -> /usr/local/bin/collect_nginx_metrics.sh 
#       -> /var/lib/node_exporter/textfile_collector/nginx_metrics.prom
# node_exporter читает /var/lib/node_exporter/textfile_collector

{__name__=~"caddy_.*"}
{__name__=~"nginx_.*"}
prometheus_storage_size_bytes

100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100) # Загрузка CPU в процентах (по всем ядрам)
(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100             # Доступная память (в процентах)
rate(node_disk_read_bytes_total[1m])            # Скорость чтения с диска (байт/сек)
rate(node_network_receive_bytes_total[1m])      # Скорость приема (байт/сек) по интерфейсам

# Установка Caddy
sudo /mnt/hgfs/devops/install_caddy.sh
# изменить порт на 8080
sudo nano /etc/caddy/Caddyfile
sudo systemctl daemon-reload && sudo systemctl enable caddy && sudo systemctl start caddy && sudo systemctl status caddy


# Prometheus
sudo useradd --no-create-home --shell /bin/false prometheus
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v3.10.0/prometheus-3.10.0.linux-amd64.tar.gz
tar xvfz prometheus-3.10.0.linux-amd64.tar.gz
cd prometheus-3.10.0.linux-amd64/

sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

sudo mkdir -p /etc/prometheus       # конфиг
sudo chown -R prometheus:prometheus /etc/prometheus
sudo cp prometheus.yml /etc/prometheus/
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml
sudo cp /mnt/hgfs/devops/copy_from_vm/prometheus.yml /etc/prometheus/prometheus.yml
sudo systemctl daemon-reload && sudo systemctl enable prometheus && sudo systemctl start prometheus && sudo systemctl status prometheus

sudo mkdir -p /var/lib/prometheus   # данные
sudo chown -R prometheus:prometheus /var/lib/prometheus



# Создать systemd сервис:
sudo nano /etc/systemd/system/prometheus.service
/etc/systemd/system/prometheus.service:
    '''
    [Unit]
    Description=Prometheus Monitoring System
    Documentation=https://prometheus.io/docs/introduction/overview/
    Wants=network-online.target
    After=network-online.target

    [Service]
    User=prometheus
    Group=prometheus
    Type=simple
    ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus \
    --storage.tsdb.retention.time=15d \
    --storage.tsdb.retention.size=500MB 
    --web.listen-address=0.0.0.0:9090

    Restart=always

    [Install]
    WantedBy=multi-user.target
    '''


sudo systemctl daemon-reload        # Перезагрузить systemd
sudo systemctl start prometheus
sudo systemctl enable prometheus    # Включить автозапуск

# Node Exporter
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz &&
tar xvfz node_exporter-1.10.2.linux-amd64.tar.gz &&
sudo cp node_exporter-1.10.2.linux-amd64/node_exporter /usr/local/bin/ &&
sudo useradd --no-create-home --shell /bin/false node_exporter &&
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

sudo mkdir -p /var/lib/node_exporter/textfile_collector
sudo chown -R node_exporter:node_exporter /var/lib/node_exporter
sudo cp /mnt/hgfs/devops/copy_from_vm/node_exporter.service /etc/systemd/system/node_exporter.service
sudo systemctl daemon-reload && sudo systemctl enable node_exporter && sudo systemctl start node_exporter

# Метрики status-страницы Nginx
sudo cp /mnt/hgfs/devops/copy_from_vm/nginx_conf.conf /etc/nginx/sites-available/default &&
sudo nginx -t &&
sudo systemctl reload nginx

# Скрипт для сбора метрик и представления в формате понятном прометеусу
sudo cp /mnt/hgfs/devops/copy_from_vm/collect_nginx_metrics.sh /usr/local/bin/collect_nginx_metrics.sh
sudo chmod +x /usr/local/bin/collect_nginx_metrics.sh

# cron (каждую минуту, */5 * * * *	Каждые 5 минут)
sudo crontab -e # через nano запистаь это
* * * * * /usr/local/bin/collect_nginx_metrics.sh
# каждую минуту обновляет файл /var/lib/node_exporter/textfile_collector/nginx_metrics.prom
# Node Exporter читает этот файл и отдает метрики Prometheus


# Размера папки Prometheus
sudo cp /mnt/hgfs/devops/copy_from_vm/collect_prometheus_size.sh /usr/local/bin/collect_prometheus_size.sh
sudo chmod +x /usr/local/bin/collect_prometheus_size.sh
sudo crontab -e
* * * * * /usr/local/bin/collect_prometheus_size.sh

# Caddy metrics
/etc/caddy/Caddyfile:
    ''' В начало файла (админ7истративный api caddy)
    {
        admin localhost:2019
        metrics
    }
    '''
sudo systemctl reload caddy
curl http://localhost:2019/metrics


# Alertmanager
cd /tmp
wget https://github.com/prometheus/alertmanager/releases/download/v0.31.1/alertmanager-0.31.1.linux-amd64.tar.gz
tar xvfz alertmanager-*.tar.gz
sudo cp alertmanager-*/alertmanager /usr/local/bin/
sudo cp alertmanager-*/amtool /usr/local/bin/
sudo mkdir /etc/alertmanager /var/lib/alertmanager
sudo useradd --no-create-home --shell /bin/false alertmanager
sudo chown -R alertmanager:alertmanager /etc/alertmanager /var/lib/alertmanager
sudo cp /mnt/hgfs/devops/copy_from_vm/alertmanager.yml /etc/alertmanager/alertmanager.yml
sudo cp /mnt/hgfs/devops/copy_from_vm/alertmanager.service /etc/systemd/system/alertmanager.service
sudo systemctl daemon-reload && sudo systemctl enable alertmanager && sudo systemctl start alertmanager

sudo mkdir -p /etc/prometheus/rules
sudo cp /mnt/hgfs/devops/copy_from_vm/alerts.yml /etc/prometheus/rules/alerts.yml


# Blackbox Exporter
cd /tmp
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.28.0/blackbox_exporter-0.28.0.linux-amd64.tar.gz
tar xvfz blackbox_exporter-*.tar.gz
sudo cp blackbox_exporter-*/blackbox_exporter /usr/local/bin/
sudo useradd --no-create-home --shell /bin/false blackbox_exporter
sudo mkdir /etc/blackbox_exporter
sudo cp /mnt/hgfs/devops/copy_from_vm/blackbox.yml /etc/blackbox_exporter/blackbox.yml
sudo cp /mnt/hgfs/devops/copy_from_vm/blackbox_exporter.service /etc/systemd/system/blackbox_exporter.service
sudo systemctl daemon-reload && sudo systemctl enable blackbox_exporter && sudo systemctl start blackbox_exporter && sudo systemctl status blackbox_exporter



---------------------------------------------------
sudo cp /mnt/hgfs/devops/copy_from_vm/prometheus.yml /etc/prometheus/prometheus.yml
sudo systemctl restart prometheus && sudo systemctl status prometheus
sudo journalctl -u prometheus -n 50 --no-pager
/etc/prometheus/prometheus.yml: 
    '''
    global:
    scrape_interval: 15s
    evaluation_interval: 15s

    alerting:
    alertmanagers:
        - static_configs:
            - targets:
            - localhost:9093

    rule_files:
    - /etc/prometheus/rules/*.yml

    scrape_configs:
    # Prometheus сам себя
    - job_name: 'prometheus'
        static_configs:
        - targets: ['localhost:9090']

    # Node Exporter (метрики хоста ВМ1) и status nginx
    - job_name: 'node_exporter_vm1'
        static_configs:
        - targets: ['localhost:9100']

    # НЕТ. Nginx (через node_exporter textfile)
    - job_name: 'nginx_metrics'
        static_configs:
        - targets: ['localhost:9100']
        params:
        collect[]: ['textfile']
        metric_relabel_configs:
        - source_labels: [__name__]
            regex: 'nginx_.*'
            action: keep

    # Caddy метрики
    - job_name: 'caddy'
        static_configs:
        - targets: ['localhost:2019']

    # Node Exporter ВМ2
    - job_name: 'node_exporter_vm2'
        static_configs:
        - targets: ['<IP_ВМ2>:9100']

    # Blackbox Exporter
    - job_name: 'blackbox_exporter'
        metrics_path: /probe
        params:
        module: [http_2xx]
        static_configs:
        - targets:
            - https://google.com  # или любой другой сайт
        relabel_configs:
        - source_labels: [__address__]
            target_label: __param_target
        - source_labels: [__param_target]
            target_label: instance
        - target_label: __address__
            replacement: localhost:9115
    '''




