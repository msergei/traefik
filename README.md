# Create user:password:
``echo $(htpasswd -nB YOUR_USER) | sed -e s/\\$/\\$\\$/g``

Add the result to docker-compose.override.yml

### Add network proxy as external=true to another docker-compose

