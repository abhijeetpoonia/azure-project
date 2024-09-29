# Use Ubuntu 18.04 as the base image
FROM ubuntu:18.04

# Update the package list and install nginx
RUN apt-get update && apt-get install -y nginx

# Remove default Nginx configurations for minimal image size
RUN rm -rf /var/lib/apt/lists/*

# Copy custom nginx config if needed (optional)
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start Nginx in the foreground using the 'daemon off' directive
CMD ["nginx", "-g", "daemon off;"]
