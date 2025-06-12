# Use Red Hat UBI 8 minimal base image
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

# Install Apache (httpd) and create sample index.html
RUN microdnf install -y httpd && \
    microdnf clean all && \
    echo "<html><body><h1>MyProject: Docker Automations using Jenkins and Local Registry</h1><p>Automated by Jenkins</p></body></html>" > /var/www/html/index.html

# Modify Apache config to listen on 8088
RUN sed -i 's/Listen 80/Listen 8088/g' /etc/httpd/conf/httpd.conf

# Expose custom port 8088
EXPOSE 8088

# Run Apache in foreground
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
