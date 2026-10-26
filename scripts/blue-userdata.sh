#!/bin/bash

# Update Ubuntu package repositories

apt-get update -y

# Install Apache web server

apt-get install -y apache2

# Enable and start Apache

systemctl enable --now apache2

# Create Blue Environment web page

cat > /var/www/html/index.html <<'EOF'

<!DOCTYPE html>

<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Blue Environment</title>
</head>
<body>
    <h1>BLUE ENVIRONMENT</h1>
    <h2>Application Version 1</h2>
    <p>AWS Blue-Green Deployment Project</p>
    <p>Server: Blue-Server</p>
</body>
</html>
EOF

# Restart Apache to ensure the web server is running

systemctl restart apache2
