#!/bin/bash
# Install necessary packages
yum update -y
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create a simple web page
cat > /var/www/html/index.html << 'ENDHTML'
<!DOCTYPE html>
<html>
<head>
    <title>TechNova Web App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            color: #333;
            line-height: 1.6;
        }
        .container {
            width: 80%;
            margin: auto;
            overflow: hidden;
            padding: 20px;
        }
        header {
            background: #0069d9;
            color: white;
            padding: 30px;
            text-align: center;
        }
        .content {
            background: white;
            padding: 20px;
            margin-top: 20px;
            border-radius: 5px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.12);
        }
        h1 {
            margin: 0;
        }
        footer {
            background: #333;
            color: white;
            text-align: center;
            padding: 10px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <header>
        <div class="container">
            <h1>TechNova Web App</h1>
        </div>
    </header>
    
    <div class="container">
        <div class="content">
            <h2>Welcome to TechNova's Web Application</h2>
            <p>This page is being served from an Amazon EC2 instance that is part of an Auto Scaling Group.</p>
            <p>Instance ID: <span id="instance-id">Loading...</span></p>
            <p>Availability Zone: <span id="availability-zone">Loading...</span></p>
        </div>
    </div>
    
    <footer>
        <div class="container">
            <p>&copy; 2025 TechNova. All rights reserved.</p>
        </div>
    </footer>
    
    <script>
        // Fetch EC2 instance metadata
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(response => response.text())
            .then(data => {
                document.getElementById('instance-id').textContent = data;
            });
            
        fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone')
            .then(response => response.text())
            .then(data => {
                document.getElementById('availability-zone').textContent = data;
            });
    </script>
</body>
</html>
ENDHTML

# Set correct permissions
chmod 644 /var/www/html/index.html
