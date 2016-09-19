# docker-sensu-server

CentOS 7 and sensu.
It runs redis, rabbitmq-server, uchiwa, sensu-api, sensu-server, supervisord.

## Installation

Install from Dockerfile

```
git clone https://github.com/vertrost/docker-sensu-server.git
cd docker-sensu-server
docker build -t yourname/docker-sensu-server .
```

## Run

```
docker run -d -p 10022:22 -p 3000:3000 -p 4567:4567 -p 5672:5672 -p 15672:15672 vertrost/docker-sensu-server
```

## How to access via browser and sensu-client

### rabbitmq console

* http://your-server:15672/
* id/pwd : sensu/password

### uchiwa

* http://your-server:3000/

### sensu-client

To run sensu-client, create client.json (see example below), then just run sensu-client process.

These are examples of sensu-client configuration.

* /etc/sensu/config.json

```
{
  "rabbitmq": {
    "host": "localhost",
    "port": 5671,
    "vhost": "/sensu",
    "user": "sensu",
    "password": "password",
    "ssl": {
      "cert_chain_file": "/etc/sensu/ssl/cert.pem",
      "private_key_file": "/etc/sensu/ssl/key.pem"
    }
  }
}
```

## License

MIT
