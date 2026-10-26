#!/bin/bash
# This tier runs the PHP code and talks to the database

set -e
export DEBIAN_FRONTEND=noninteractive

echo "=== App tier setup started: $(date) ==="

# ----- APT CONFIG ------ #

sudo apt-get update
sudo apt-get install apache2 php libapache2-mod-php -y

echo "Enable Apache service on boot..."
sudo systemctl enable apache2

echo "Verifying PHP module..."
apache2ctl -M | grep php
echo "PHP mod is available"

echo "PHP-MySQL (PDO) Connector/Extension"
sudo apt install php-mysql -y

echo "Env configuration complete!" | sudo tee -a /var/log/setup.log

# ----- PORTS SETUP --------#

sudo sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf
sudo sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-available/000-default.conf

# ------- PHP SOURCE CODE ------ #

cat > /var/www/html/student-pdo.php <<'EOF' 
<?php

$serverHostname = gethostname();
echo "<h1 style='text-align: center;'>Deployed by Meshach</h1>";
echo "<p style='text-align: center;'>Server Hostname: " . htmlspecialchars($serverHostname) . "</p>";

$dbUser = "webapp";
$dbPwd = "${db_password}";
$dbName = "studentdb";

try {
     $pdo = new PDO("mysql:host=${db_host};dbname=$dbName;charset=utf8mb4", $dbUser, $dbPwd);
     $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

     $stmt = $pdo->query("SELECT * FROM students");
     $students = $stmt->fetchAll(PDO::FETCH_ASSOC);

     if (count($students) === 0) {
         $insert = $pdo->prepare("INSERT INTO students (name) VALUES (:name)");
         $insert->execute(['name' => 'Meshach']);

         $stmt = $pdo->query("SELECT * FROM students");
         $students = $stmt->fetchAll(PDO::FETCH_ASSOC);
     }

     echo "<h2 style='text-align: center;'>Student Records</h2>";
     echo "<table style='margin-left: auto; margin-right: auto; width: 50%;' border='1' cellpadding='5' >";
       echo "<tr style='text-align: center;'><th>ID</th><th>Name</th></tr>";

       foreach ($students as $row) {
           echo "<tr style='text-align: center'><td>" . htmlspecialchars($row['id']) . "</td><td>" . htmlspecialchars($row['name']) . "</td></tr>";
       }

     echo "</table>";

     $pdo = null;

} catch (PDOException $e) {
    die("<p>Connection failed: " . htmlspecialchars($e->getMessage()) . "</p>");
}

?>
EOF

# ------ RESTART AFTER CONFIG ------ #

sudo systemctl restart apache2
sudo systemctl is-active --quiet apache2

echo "=== App tier setup complete: $(date) ==="
