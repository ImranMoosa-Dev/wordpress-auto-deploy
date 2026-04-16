#!/bin/bash
set -e

# ── Colors ──
G='\033[0;32m' C='\033[0;36m' R='\033[0;31m' N='\033[0m'

# ── Root check ──
[ "$EUID" -eq 0 ] || { echo -e "${R}Run as root: sudo bash wp-deploy.sh${N}"; exit 1; }

clear
echo -e "${C}===== WordPress Auto Deploy =====${N}\n"

# ── Questions ──
echo "1) Apache2  2) Nginx"
read -rp "Web server (1/2): " ws
[ "$ws" = "1" ] && WEB=apache2 || WEB=nginx

echo "1) MySQL  2) MariaDB"
read -rp "Database (1/2): " db
if [ "$db" = "1" ]; then DB_PKG=mysql-server; DB_SVC=mysql; DB_CLI=mysql
else DB_PKG=mariadb-server; DB_SVC=mariadb; DB_CLI=mariadb; fi

read -rp "Domain (e.g. mysite.local): " DOMAIN
read -rp "DB Name: " DB_NAME
read -rp "DB User: " DB_USER
read -rsp "DB Password: " DB_PASS; echo

echo -e "\n${C}Starting deployment...${N}\n"

# ── 1. System update ──
echo -e "${G}[1/8] System update...${N}"
apt-get update -qq && apt-get upgrade -y -qq

# ── 2. Add PHP repo ──
echo -e "${G}[2/8] Adding PHP repo...${N}"
apt-get install -y -qq software-properties-common
add-apt-repository -y ppa:ondrej/php > /dev/null 2>&1
apt-get update -qq

# ── 3. Install PHP ──
echo -e "${G}[3/8] Installing PHP 8.3...${N}"
apt-get install -y php8.3 php8.3-fpm php8.3-mysql php8.3-curl php8.3-gd php8.3-mbstring php8.3-xml php8.3-zip
systemctl enable --now php8.3-fpm

# ── 4. Install web server ──
echo -e "${G}[4/8] Installing $WEB...${N}"
apt-get install -y "$WEB"
systemctl enable --now "$WEB"

# ── 5. Install database ──
echo -e "${G}[5/8] Installing $DB_PKG...${N}"
apt-get install -y "$DB_PKG"
systemctl enable --now "$DB_SVC"

$DB_CLI -u root <<SQL
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
SQL

# ── 6. Download WordPress ──
echo -e "${G}[6/8] Downloading WordPress...${N}"
WP_PATH="/var/www/$DOMAIN"
mkdir -p "$WP_PATH"
curl -sL https://wordpress.org/latest.tar.gz | tar -xz -C /tmp
cp -r /tmp/wordpress/. "$WP_PATH/"
rm -rf /tmp/wordpress

cp "$WP_PATH/wp-config-sample.php" "$WP_PATH/wp-config.php"
sed -i "s/database_name_here/$DB_NAME/" "$WP_PATH/wp-config.php"
sed -i "s/username_here/$DB_USER/"      "$WP_PATH/wp-config.php"
sed -i "s/password_here/$DB_PASS/"      "$WP_PATH/wp-config.php"

chown -R www-data:www-data "$WP_PATH"
chmod -R 755 "$WP_PATH"

# ── 7. SSL ──
echo -e "${G}[7/8] Generating SSL...${N}"
mkdir -p /etc/ssl/local
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/local/$DOMAIN.key \
  -out    /etc/ssl/local/$DOMAIN.crt \
  -subj   "/CN=$DOMAIN" 2>/dev/null

# ── 8. Virtual host ──
echo -e "${G}[8/8] Configuring $WEB...${N}"

if [ "$WEB" = "nginx" ]; then
  cat > /etc/nginx/sites-available/$DOMAIN <<EOF
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$host\$request_uri;
}
server {
    listen 443 ssl;
    server_name $DOMAIN;
    root $WP_PATH;
    index index.php;
    ssl_certificate     /etc/ssl/local/$DOMAIN.crt;
    ssl_certificate_key /etc/ssl/local/$DOMAIN.key;
    location / { try_files \$uri \$uri/ /index.php?\$args; }
    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF
  ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN
  rm -f /etc/nginx/sites-enabled/default
  systemctl reload nginx

else
  a2enmod rewrite ssl > /dev/null 2>&1
  cat > /etc/apache2/sites-available/$DOMAIN.conf <<EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    Redirect permanent / https://$DOMAIN/
</VirtualHost>
<VirtualHost *:443>
    ServerName $DOMAIN
    DocumentRoot $WP_PATH
    SSLEngine on
    SSLCertificateFile    /etc/ssl/local/$DOMAIN.crt
    SSLCertificateKeyFile /etc/ssl/local/$DOMAIN.key
    <Directory $WP_PATH>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
  a2ensite $DOMAIN.conf > /dev/null 2>&1
  a2dissite 000-default.conf > /dev/null 2>&1 || true
  systemctl reload apache2
fi

# ── /etc/hosts ──
grep -qF "$DOMAIN" /etc/hosts || echo "127.0.0.1    $DOMAIN" >> /etc/hosts

# ── Done ──
echo -e "\n${C}===== Done! =====${N}"
echo -e "URL: ${G}https://$DOMAIN${N}"
echo -e "Path: $WP_PATH"
