# Use an official PHP image with PHP-FPM
FROM php:8.2-fpm

# Set the working directory to /var/www/html
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
        libzip-dev \
        zip \
        unzip

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql zip

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy composer.json and composer.lock
COPY composer.json composer.lock /var/www/html/

# Set COMPOSER_ALLOW_SUPERUSER to allow Composer to run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

# Install application dependencies
RUN composer install --no-scripts --no-autoloader \
    && ln -s $(pwd)/vendor/bin/artisan /usr/local/bin/artisan

# Copy the application code
COPY ./laravel /var/www/html/

# Generate autoload files
RUN composer dump-autoload --no-scripts --optimize \
    && php artisan key:generate \
    && php artisan config:cache \
    && php artisan route:cache
    
# Run artisan package:discover
# RUN php artisan package:discover --ansi

# Set the appropriate permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
