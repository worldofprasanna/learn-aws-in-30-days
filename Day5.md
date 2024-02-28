# Script for Setting up the Apache Server with NodeJs

## Infrastructure Setup

```
#!/bin/bash

apt update -y
apt install nodejs
apt install npm

# NVM Installation
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

source ~/.bashrc
nvm list-remote
nvm install v20.0.4

# Install Apache2

apt install apache2
systemctl status apache2
```

## Deployment

```
#!/bin/bash

npm install
npm run build
cp index.html styles.css Poster.png /var/www/html/
```
