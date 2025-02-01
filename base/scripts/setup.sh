#!/bin/bash

# Ensure SSM agent is installed and running
sudo snap install amazon-ssm-agent --classic
sudo snap list amazon-ssm-agent
sudo snap start amazon-ssm-agent
sudo snap services amazon-ssm-agent

sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

# Create a directory for mounting
sudo mkdir -p /mnt/data
sudo touch /mnt/data/test-file

sudo file -s /dev/xvdf
sudo mkfs.ext4 /dev/xvdf

# Mount the volume to the directory
sudo mount /dev/xvdf /mnt/data
df -h
ls /mnt/data

# Add entry to /etc/fstab for persistence after reboot
echo '/dev/xvdf /mnt/data ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
sudo mount -a

# Verify the mount
df -h | grep /mnt/data

# Nginx setup
echo 'Resolving incomplete configurations...'
sudo dpkg --configure -a || true

echo 'Updating package list...'
sudo apt update -y

echo 'Checking if Nginx is installed...'
if ! command -v nginx >/dev/null; then
    echo 'Nginx not found. Installing Nginx...'
    sudo apt install -y nginx
else
    echo 'Nginx is already installed.'
fi

echo 'Checking if Certbot is installed...'
if ! command -v certbot >/dev/null; then
    echo 'Certbot not found. Installing Certbot...'
    sudo apt install -y python3-certbot-nginx
else
    echo 'Certbot is already installed.'
fi

echo 'Enabling and starting Nginx...'
sudo systemctl enable --now nginx

echo 'Add default content'
cat <<EOL | sudo tee /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hurray!! Nginx is Running</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            color: #333;
        }
        .container {
            text-align: center;
            padding: 20px;
            background: white;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
        }
        h1 {
            color: #28a745;
        }
        p {
            font-size: 18px;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Ej Best, Nginx is Up and Running!</h1>
        <p>If you see this page, your Nginx web server is successfully running on your EC2 instance.</p>
    </div>
</body>
</html>


EOL

echo 'Requesting SSL certificates for domain ${DOMAIN_NAME}...'
sudo certbot certonly --nginx --non-interactive --agree-tos --register-unsafely-without-email -d ${DOMAIN_NAME} -v

# Create the Nginx server block configuration
cat <<EOL | sudo tee /etc/nginx/sites-available/default
server {
    listen 80;
    server_name ${DOMAIN_NAME};
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name ${DOMAIN_NAME};

    ssl_certificate /etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    root /var/www/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOL

echo 'Testing Nginx configuration...'
sudo nginx -t

echo 'Restarting Nginx...'
sudo systemctl restart nginx

echo 'Reloading Nginx to apply SSL certificates...'
sudo systemctl reload nginx

echo 'Adding Certbot renewal crontab entry...'
(crontab -l 2>/dev/null; echo "43 6 * * * certbot renew --post-hook 'systemctl reload nginx'") | crontab -
