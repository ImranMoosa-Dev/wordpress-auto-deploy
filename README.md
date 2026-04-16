WordPress Auto Deploy Script

A Bash automation script to deploy WordPress on Ubuntu using either Nginx or Apache2 with MySQL or MariaDB and PHP.

This project demonstrates Linux administration, Bash scripting, web server configuration, database setup, and automation for DevOps environments.

The repository also includes a manual deployment guide to help understand the complete WordPress installation process before using automation.

Project Goals

The purpose of this project is to practice real DevOps and system administration tasks.

Goals of this project:

Automate WordPress deployment using Bash scripting
Learn how web servers work
Understand database integration with web applications
Practice Linux server configuration
Build a DevOps portfolio project
Features
Interactive Bash deployment script
Supports Apache2 or Nginx web server
Supports MySQL or MariaDB database
Automatic PHP installation
Automatic database creation
Automatic WordPress download and configuration
Automatic virtual host / server block setup
Self-signed SSL certificate generation
Beginner-friendly manual deployment guide included
Requirements

System requirements:

Ubuntu 20.04 / 22.04 / 24.04
Root or sudo privileges
Internet connection

Recommended:

Fresh Ubuntu installation
Minimum 2GB RAM
Repository Structure
wordpress-auto-deploy
│
├── wp-deploy.sh
├── README.md
└── configs
Manual WordPress Deployment Guide

This section explains how to deploy WordPress manually step by step.

Understanding the manual process helps understand what the automation script does.

1 Update System

Update package list and upgrade system packages.

sudo apt update
sudo apt upgrade -y
2 Install Web Server

Choose one web server.

Install Apache:

sudo apt install apache2 -y

Install Nginx:

sudo apt install nginx -y

Start service:

sudo systemctl start apache2
sudo systemctl enable apache2

or

sudo systemctl start nginx
sudo systemctl enable nginx
3 Configure Firewall (UFW)

Allow web traffic.

Check firewall status:

sudo ufw status

Allow HTTP and HTTPS:

sudo ufw allow 80
sudo ufw allow 443

Or allow profiles:

Apache:

sudo ufw allow "Apache Full"

Nginx:

sudo ufw allow "Nginx Full"

Reload firewall:

sudo ufw reload
4 Install PHP

WordPress requires PHP and additional modules.

sudo apt install php php-fpm php-mysql php-curl php-xml php-mbstring php-zip php-gd -y

Check PHP version:

php -v
5 Install Database Server

Choose one database server.

Install MySQL:

sudo apt install mysql-server -y

Install MariaDB:

sudo apt install mariadb-server -y

Run secure installation:

sudo mysql_secure_installation

Follow prompts to secure the database server.

6 Create WordPress Database

Login to database:

sudo mysql

Create database:

CREATE DATABASE wordpressdb;

Create database user:

CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'password';

Grant privileges:

GRANT ALL PRIVILEGES ON wordpressdb.* TO 'wpuser'@'localhost';

Apply changes:

FLUSH PRIVILEGES;
EXIT;
7 Download WordPress

Download latest WordPress package.

cd /tmp
curl -O https://wordpress.org/latest.tar.gz

Extract archive:

tar -xvf latest.tar.gz

Move files to web directory:

sudo cp -r wordpress /var/www/mysite

Set ownership:

sudo chown -R www-data:www-data /var/www/mysite

Set permissions:

sudo chmod -R 755 /var/www/mysite
8 Configure WordPress

Navigate to site directory.

cd /var/www/mysite

Copy configuration file:

cp wp-config-sample.php wp-config.php

Edit configuration:

nano wp-config.php

Update database settings:

DB_NAME
DB_USER
DB_PASSWORD
9 Configure Apache Virtual Host

Create new virtual host:

sudo nano /etc/apache2/sites-available/mysite.conf

Example configuration:

<VirtualHost *:80>

ServerName mysite.local

DocumentRoot /var/www/mysite

<Directory /var/www/mysite>
AllowOverride All
</Directory>

</VirtualHost>

Enable Apache rewrite module:

sudo a2enmod rewrite

Enable site:

sudo a2ensite mysite.conf

Disable default site:

sudo a2dissite 000-default.conf

Restart Apache:

sudo systemctl restart apache2
10 Configure Nginx Server Block

Create configuration file:

sudo nano /etc/nginx/sites-available/mysite

Example configuration:

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

location ~ /\.ht {
deny all;
}

}

Enable site:

sudo ln -s /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/

Test configuration:

sudo nginx -t

Restart Nginx:

sudo systemctl restart nginx
11 Configure Local Domain (Important)

For local testing, edit hosts file.

sudo nano /etc/hosts

Add this line:

127.0.0.1 mysite.local

Save and exit.

12 Complete WordPress Installation

Open browser and visit:

http://mysite.local

Follow WordPress installation wizard.

Set:

Site title
Admin username
Admin password
Email address

After completion, WordPress will be installed successfully.

Automated Deployment

Instead of performing the manual steps above, you can use the automation script.

Make script executable:

chmod +x wp-deploy.sh

Run the script:

sudo bash wp-deploy.sh

The script will ask for:

Web server choice
Database choice
Domain name
Database name
Database user
Database password

The script will automatically:

Install required packages
Configure web server
Create database
Install WordPress
Configure virtual host
Generate SSL certificate
Example Deployment

Example input during script execution:

Web Server: Nginx
Database: MySQL
Domain: mysite.local
Database Name: wordpressdb
Database User: wpuser

After deployment open:

https://mysite.local
Learning Outcomes

This project helps understand:

Linux server administration
Bash scripting automation
Web server configuration
Database management
WordPress deployment workflow
DevOps automation concepts
Author

Imran Moosa

DevOps & Cloud Computing Student

License

This project is open-source and available for learning purposes.
