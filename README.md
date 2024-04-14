# Create user:password:
``echo $(htpasswd -nB YOUR_USER) | sed -e s/\\$/\\$\\$/g``

Add the result to docker-compose.override.yml

### Add network proxy as external=true to another docker-compose

### Copy docker-compose override example:
``cp docker-compose.override.example docker-compose.override.yml``

Fill with your own data

### Start the stuff:
```docker-compose up```