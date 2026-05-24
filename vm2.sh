# Node Exporter
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz &&
tar xvfz node_exporter-1.10.2.linux-amd64.tar.gz &&
sudo cp node_exporter-1.10.2.linux-amd64/node_exporter /usr/local/bin/ &&
sudo useradd --no-create-home --shell /bin/false node_exporter &&
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter


sudo cp /mnt/hgfs/devops/vm2/node_exporter.service /etc/systemd/system/node_exporter.service
sudo systemctl daemon-reload && sudo systemctl enable node_exporter && sudo systemctl start node_exporter && sudo systemctl status node_exporter


# Docker 
sudo apt install docker.io -y
sudo systemctl daemon-reload && sudo systemctl enable docker && sudo systemctl start docker && sudo systemctl status docker
sudo usermod -aG docker $USER
newgrp docker


# Grafana
sudo mkdir -p /opt/grafana/data
sudo chown -R 472:472 /opt/grafana/data

(admin admin )

docker stop grafana &&  docker rm grafana
docker run -d \
  --name=grafana \
  --restart=unless-stopped \
  -p 3000:3000 \
  -v /opt/grafana/data:/var/lib/grafana \
  -e "GF_SECURITY_ADMIN_PASSWORD=admin" \
  grafana/grafana:latest



Connections - Data Sources - Add data source - Prometheus
http://192.168.170.138:9090 
Dashboard - import - ID = 1860
import
Blackbox Exporter (ID: 7587):

http://192.168.170.138:3000/d/rYdddlPWk/node-exporter-full?orgId=1&from=now-24h&to=now&timezone=browser&var-ds_prometheus=dfg4mqehwlu68b&var-job=node_exporter_vm1&var-nodename=vm1&var-node=localhost:9100&refresh=1m

16124



ab -n 10000 -c 100 http://localhost:8080/