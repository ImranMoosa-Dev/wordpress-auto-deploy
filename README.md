# WordPress Auto Deploy Script

A Bash automation script to deploy **WordPress** on Ubuntu using either **Nginx** or **Apache2** with **MySQL/MariaDB** and PHP.

This project demonstrates **Linux administration, Bash scripting, web server configuration, and database automation**.

The repository also includes a **manual deployment guide** so users can understand the full process before using automation.

---

# Project Goals

* Automate WordPress deployment
* Learn server configuration
* Understand web server + database integration
* Practice Bash scripting for DevOps tasks

---

# Features

* Interactive Bash deployment
* Supports **Apache2** or **Nginx**
* Supports **MySQL** or **MariaDB**
* Automatic PHP installation
* Automatic database creation
* Automatic WordPress configuration
* Automatic virtual host setup
* Self-signed SSL certificate generation

---

# Requirements

System requirements:

* Ubuntu 20.04 / 22.04 / 24.04
* Root or sudo privileges
* Internet connection

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

This section explains how to deploy WordPress **manually** without automation.

## 1 Update system

```
sudo apt update
sudo apt upgrade
```

---

## 2 Install web server

Apache:

```
sudo apt install apache2
```

Nginx:

```
sudo apt install nginx
```

---

## 3 Install PHP

```
sudo apt install php php-fpm php-mysql php-curl php-xml php-mbstring php-zip php-gd
```

---

## 4 Install database

MySQL:

```
sudo apt install mysql-server
```

MariaDB:

```
sudo apt install mariadb-server
```

Secure installation:

```
sudo mysql_secure_installation
```

---

## 5 Create WordPress database

Login to database:

```
sudo mysql
```

Create database and user:

```
CREATE DATABASE wordpressdb;

CREATE USER 'wpuser'@'localhost'
IDENTIFIED BY 'password';

GRANT ALL PRIVILEGES
ON wordpressdb.*
TO 'wpuser'@'localhost';

FLUSH PRIVILEGES;
EXIT;
```

---

## 6 Download WordPress

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
```

---

## 7 Configure WordPress

```
cd /var/www/mysite
cp wp-config-sample.php wp-config.php
```

Edit configuration:

```
nano wp-config.php
```

Set:

```
DB_NAME
DB_USER
DB_PASSWORD
```

---

## 8 Configure web server

### Apache Virtual Host

```
sudo nano /etc/apache2/sites-available/mysite.conf
```

Example configuration:

```
<VirtualHost *:80>
ServerName mysite.local
DocumentRoot /var/www/mysite
</VirtualHost>
```

Enable site:

```
sudo a2ensite mysite.conf
sudo systemctl reload apache2
```

---

### Nginx Server Block

```
sudo nano /etc/nginx/sites-available/mysite
```

Example configuration:

```
server {
listen 80;
server_name mysite.local;

root /var/www/mysite;
index index.php;
}
```

Enable site:

```
sudo ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/
sudo systemctl reload nginx
```

---

# Automated Deployment

Instead of doing the manual process above, you can run the automation script.

Make the script executable:

```
chmod +x wp-deploy.sh
```

Run the script:

```
sudo bash wp-deploy.sh
```

The script will ask for:

* Web server choice
* Database choice
* Domain name
* Database name
* Database user
* Database password

After deployment, open:

```
https://your-domain
```

---

# Example

Example input during deployment:

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

* Linux server administration
* Bash scripting automation
* Web server configuration
* Database integration
* WordPress deployment workflow

---

# Author

Imran Moosa

DevOps & Cloud Computing Student
