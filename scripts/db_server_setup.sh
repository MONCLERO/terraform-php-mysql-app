#!/bin/bash

set -e
export DEBIAN_FRONTEND=noninteractive

echo "=== DB tier setup started: $(date) ==="

# ----- APT CONFIG ------ #

sudo apt-get update 
sudo apt-get install mysql-server -y

# ------ PORTS SETUP ----- #

DB_IP=$(hostname -I | awk '{print $1}')
sudo sed -i "s/^bind-address.*/bind-address = $DB_IP/" /etc/mysql/mysql.conf.d/mysqld.cnf

# ----- DEPLOY NEW CONFIG ----- #

sudo systemctl restart mysql

# ------ MYSQL DB CREATION ----- #

sudo mysql <<'SQL'
    CREATE DATABASE IF NOT EXISTS studentdb;
    USE studentdb;

    CREATE TABLE IF NOT EXISTS students (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL
    );

    CREATE USER IF NOT EXISTS 'webapp'@'10.0.2.%' IDENTIFIED BY '${db_password}';
    GRANT SELECT, INSERT ON studentdb.* TO 'webapp'@'10.0.2.%';
SQL

echo "=== DB tier setup complete: $(date) ==="
