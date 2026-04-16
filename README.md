# WordPress Auto Deploy Script

A Bash automation script to deploy **WordPress** on Ubuntu using either **Nginx** or **Apache2** with **MySQL or MariaDB** and PHP.

This project demonstrates Linux administration, Bash scripting, web server configuration, and database automation.

The repository also includes a manual deployment guide so users can understand the full process before using automation.

---

# Project Goals

- Automate WordPress deployment
- Learn server configuration
- Understand web server + database integration
- Practice Bash scripting for DevOps tasks
- Build a beginner DevOps portfolio project

---

# Features

- Interactive Bash deployment
- Supports **Apache2 or Nginx**
- Supports **MySQL or MariaDB**
- Automatic PHP installation
- Automatic database creation
- Automatic WordPress configuration
- Automatic virtual host setup
- Self-signed SSL certificate generation

---

# Requirements

System requirements:

- Ubuntu 20.04 / 22.04 / 24.04
- Root or sudo privileges
- Internet connection

Recommended:

- Fresh Ubuntu installation
- Minimum 2GB RAM

---

# Repository Structure

```
wordpress-auto-deploy
│
├── wp-deploy.sh
├── README.md
└── configs
```

---

# Manual WordPress Deployment Guide

This section explains how to deploy WordPress manually step by step.

---

# 1 Update System

```
sudo apt update
sudo apt upgrade -y
```

---

# 2 Install Web Server

Apache:

```
sudo apt install apache2 -y
```

Nginx:

```
sudo apt install nginx -y
```

Start service:

```
sudo systemctl enable apache2
sudo systemctl start apache2
```

or

```
sudo systemctl enable nginx
sudo systemctl start nginx
```

---

# 3 Configure Firewall

Allow HTTP and HTTPS traffic.

```
sudo ufw allow 80
sudo ufw allow 443
sudo ufw reload
```

Apache profile:

```
sudo ufw allow "Apache Full"
```

Nginx profile:

```
sudo ufw allow "Nginx Full"
```

---

# 4 Install PHP

```
sudo apt install php php-fpm php-mysql php-curl php-xml php-mbstring php-zip php-gd -y
```

Check version:

```
php -v
```

---

# 5 Install Database

MySQL:

```
sudo apt install mysql-server -y
```

MariaDB:

```
sudo apt install mariadb-server -y
```

Secure database installation:

```
sudo mysql_secure_installation
```

---

# 6 Create WordPress Database

Login:

```
sudo mysql
```

Create database:

```
CREATE DATABASE wordpressdb;
```

Create user:

```
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'password';
```

Grant permissions:

```
GRANT ALL PRIVILEGES ON wordpressdb.* TO 'wpuser'@'localhost';
```

Apply changes:

```
FLUSH PRIVILEGES;
EXIT;
```

---

# 7 Download WordPress

```
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar -xvf latest.tar.gz
```

Move files:

```
sudo cp -r wordpress /var/www/mysite
```

Set permissions:

```
sudo chown -R www-data:www-data /var/www/mysite
sudo chmod -R 755 /var/www/mysite
```

---

# 8 Configure WordPress

```
cd /var/www/mysite
cp wp-config-sample.php wp-config.php
```

Edit configuration:

```
nano wp-config.php
```

Update:

```
DB_NAME
DB_USER
DB_PASSWORD
```

---

# 9 Configure Apache Virtual Host

```
sudo nano /etc/apache2/sites-available/mysite.conf
```

Example:

```
<VirtualHost *:80>

ServerName mysite.local
DocumentRoot /var/www/mysite

<Directory /var/www/mysite>
AllowOverride All
</Directory>

</VirtualHost>
```

Enable site:

```
sudo a2enmod rewrite
sudo a2ensite mysite.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2
```

---

# 10 Configure Nginx Server Block

```
sudo nano /etc/nginx/sites-available/mysite
```

Example:

```
server {

listen 80;
server_name mysite.local;

root /var/www/mysite;
index index.php index.html;

location / {
try_files $uri $uri/ /index.php?$args;
}

location ~ \.php$ {
include snippets/fastcgi-php.conf;
fastcgi_pass unix:/run/php/php-fpm.sock;
}

}
```

Enable site:

```
sudo ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

---

# 11 Configure Local Domain

Edit hosts file:

```
sudo nano /etc/hosts
```

Add line:

```
127.0.0.1 mysite.local
```

---

# 12 Complete WordPress Setup

Open browser:

```
http://mysite.local
```

Complete WordPress installation:

- Site title
- Admin username
- Admin password
- Email address

---

# Automated Deployment

Make script executable:

```
chmod +x wp-deploy.sh
```

Run script:

```
sudo bash wp-deploy.sh
```

Script will ask for:

- Web server
- Database
- Domain
- Database name
- Database user
- Database password

After deployment open:

```
https://your-domain
```

---

# Example

```
Web server: Nginx
Database: MySQL
Domain: mysite.local
DB Name: wordpressdb
DB User: wpuser
```

---

# Learning Outcomes

This project helps understand:

- Linux server administration
- Bash scripting automation
- Web server configuration
- Database integration
- WordPress deployment workflow
- DevOps automation basics

---

# Author

Imran Moosa  
DevOps & Cloud Computing Student

---

# License

Open-source project for learning and educational purposes.
