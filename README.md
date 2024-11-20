# Install Docker

```
sudo apt update

sudo apt install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

apt-cache policy docker-ce

sudo apt install docker-ce

sudo systemctl status docker

sudo usermod -aG docker ${USER}

su - ${USER}
```

# Install Kubectl

```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

# Install Minikube

```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
```

# Deploy app

```
minikube start

kubectl apply -f guestbook-go/redis-master-controller.yaml

kubectl apply -f guestbook-go/redis-master-service.yaml

kubectl apply -f guestbook-go/redis-replica-controller.yaml

kubectl apply -f guestbook-go/redis-replica-service.yaml

kubectl apply -f guestbook-go/guestbook-controller.yaml

kubectl apply -f guestbook-go/guestbook-service.yaml

```

# Config 

```
minikube tunnel

kubectl port-forward --address 0.0.0.0 svc/guestbook 3000:3000
```

# On Bastion

## Install Nginx
```
sudo apt update

sudo apt install nginx

systemctl status nginx

sudo nano /etc/nginx/sites-available/default
```

```
    location / {
        proxy_set_header Host "localhost";
        proxy_pass http://127.0.0.1:3000;
    }
```

```
sudo service nginx restart
```

## Install Jenkins

```
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
```
```
sudo apt update
sudo apt install fontconfig openjdk-17-jre
java -version
openjdk version "17.0.8" 2023-07-18
OpenJDK Runtime Environment (build 17.0.8+7-Debian-1deb12u1)
OpenJDK 64-Bit Server VM (build 17.0.8+7-Debian-1deb12u1, mixed mode, sharing)
```


# Install Plugins:

CSRF Protection: Enable proxy compatibility

SSH Pipeline Steps, Go, Kubernetes, Docker, Docker Commons, Docker Pipeline, SonarQube Scanner

# creds

private-instance-ssh

docker-registry-credentials

github-credentials

# Tools configuration

Go Installation

Docker Installation

# zzz
```
sudo apt update
sudo apt install -y docker.io golang
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```


```
sudo tee /etc/systemd/system/guestbook-port-forward.service << EOF
[Unit]
Description=Kubernetes port forward for guestbook
After=network.target

[Service]
Type=simple
User=ubuntu
ExecStart=/usr/local/bin/kubectl port-forward --address 0.0.0.0 svc/guestbook 3000:3000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable guestbook-port-forward
sudo systemctl start guestbook-port-forward
```

# SonarQube

```
docker pull sonarqube
docker run -d --name sonarqube -p 9000:9000 sonarqube
```
```
admin
akt@SonarQub3
```
```
create new API Token

Follow "Analyze your project with Jenkins"

Add SonarQube server

sudo apt install nodejs
```
test 1
test 2
test 3