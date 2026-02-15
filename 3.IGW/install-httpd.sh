#!/bin/bash
# Обновляем списки пакетов
sudo apt-get update -y

# Устанавливаем Apache (в Debian он называется apache2, а не httpd)
sudo apt-get install -y apache2

# Запускаем и включаем автозагрузку
sudo systemctl start apache2
sudo systemctl enable apache2

# Создаем простую html страницу для проверки
sudo echo "<h1>Hello from Terraform and Debian!</h1>" > /var/www/html/index.html