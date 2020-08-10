[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

# perforce-docker
Docker images for Perforce source control.

## helix-p4d
This image contains a [Helix Core Server](https://www.perforce.com/products/helix-core).

### Quickstart
```bash
docker run -v /srv/helix-p4d/data:/data -p 1666:1666 --name=helix-p4d hawkmothstudio/helix-p4d
```

### Volumes
| Volume Name | Description           |
| ----------- | --------------------- |
| /data       | Server data directory |

### Container environment variables
| Variable Name                      | Default value                          | Description                                                     |
| ---------------------------------- | -------------------------------------- | --------------------------------------------------------------- |
| P4NAME                             | master                                 | Service name, leave default value (recommended).                |
| P4ROOT                             | /data/master                           | p4d data directory, leave default value (recommended).          |
| P4SSLDIR                           | /data/master/root/ssl                  | Directory with ssl certificate and private key.                 |
| P4PORT                             | ssl:1666                               | Server port. By default, connection is secured by TLS.          |
| P4USER                             | super                                  | Login of the first user to be created.                          |
| P4PASSWD                           | P@ssw0rd                               | Password of the first user to be created.                       |
| P4D\_CASE\_SENSITIVE               | false                                  | Set to `true` to enable case-sensitive mode.                    |
| P4D\_USE\_UNICODE                  | true                                   | Set to `false` to disable unicode mode.                         |
| P4D\_SSL\_CERTIFICATE\_FILE        |                                        | If set, file is copied and used as a TLS certificate.           |
| P4D\_SSL\_CERTIFICATE\_KEY\_FILE   |                                        | If set, file is copied and used as a TLS private key.           |

### Initial configuration
When started for the first time, a new p4d server is initialized with superuser identified by `$P4USER` and `$P4PASSWD`.
Changing these variables after the server has been initialized does not change server's superuser.

### TLS support
If `$P4PORT` value starts with `ssl:`, p4d is configured with TLS support.
It is strongly recommended to provide proper custom key and certificate using `P4D_SSL_CERTIFICATE_FILE` and `P4D_SSL_CERTIFICATE_KEY_FILE` environment variables are set - these file are copied into `$P4SSLDIR` as `certificate.txt` and `privatekey.txt`.
Otherwise, new key and certificate are automatically generated (only during initialization).

Attention: when server detects that key and/or certificate has changed, a new server fingerprint is generated.
All the clients (including local container client) must be updated to trust this new fingerprint.


## helix-swarm
This image contains a [Helix Swarm](https://www.perforce.com/products/helix-swarm) core review tool along with a Redis cache server.
Currently using external Redis server is not supported.

### Quickstart
```bash
docker run -it --rm -e P4PORT=ssl:p4d:1666 -p 80:80 --name helix-swarm hawkmothstudio/helix-swarm
```

### Volumes
| Volume Name              | Description           |
| ------------------------ | --------------------- |
| /opr/perforce/swarm/data | Server data directory |

### Container environment variables
| Variable Name                      | Default value                          | Description                                                     |
| ---------------------------------- | -------------------------------------- | --------------------------------------------------------------- |
| P4PORT                             | ssl:p4d:1666                           | p4d server connection string.                                   |
| P4USER                             | super                                  | User to be used when running p4 commands from console.          |
| P4PASSWD                           | P@ssw0rd                               | `$P4USER`'s password.                                           |
| SWARM\_USER                        | super                                  | User to be used by Swarm to connect to p4d.                     |
| SWARM\_PASSWD                      | P@ssw0rd                               | `$SWARM_USER`'s password.                                       |
| SWARM\_USER\_CREATE                | false                                  | Set to `true` to create `$SWARM_USER` on the p4d server.        |
| SWARM\_GROUP\_CREATE               | false                                  | Set to `true` to create long-lived ticket group for swarm user. |
| SWARM\_HOST                        | localhost                              | Swarm machine hostname.                                         |
| SWARM\_PORT                        | 80                                     | Port Swarm is running on (HTTP).                                |
| SWARM\_SSL\_ENABLE                 | false                                  | Set to `true` to enable TLS support.                            |
| SWARM\_SSL\_CERTIFICATE\_FILE      | /etc/ssl/certs/ssl-cert-snakeoil.pem   | Path to certificate file.                                       |
| SWARM\_SSL\_CERTIFICATE\_KEY\_FILE | /etc/ssl/private/ssl-cert-snakeoil.key | Path to private key file.                                       |

### Initial configuration
When started, container checks if `/opt/perforce/swarm/data/config.php` is present.
If not, Swarm is initialized using provided environment variables.

After the container has been initialized, all modifications to the Swarm configuration should be done by editing the `config.php` (see [official documentation](https://www.perforce.com/manuals/swarm/Content/Swarm/admin.configuration.html)).

### TLS support
Set `SWARM_SSL_ENABLE` to `true` and provide correct certificate and key files to enable TLS support.
TLS support can be enabled/disabled/updated through the environment variables at any time (container restart is required).


## docker-compose
The following example `docker-compose.yml` starts both p4d and swarm:
```yaml
version: '2.1'
services:
  p4d:
    image: hawkmothstudio/helix-p4d
    ports:
      - '1666:1666'
    environment:
      P4USER: 'mysuperuser'
      P4PASSWD: 'MySup3rPwd'
      P4D_SSL_CERTIFICATE_FILE: '/etc/letsencrypt/live/example.com/fullchain.pem'
      P4D_SSL_CERTIFICATE_KEY_FILE: '/etc/letsencrypt/live/example.com/privkey.pem'
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - /etc/letsencrypt:/etc/letsecnrypt:ro
      - /srv/helix/p4d/data:/data
  swarm:
    image: hawkmothstudio/helix-swarm
    ports:
      - '80:80'
      - '443:443'
    environment:
      P4PORT: 'ssl:p4d:1666'
      P4USER: 'mysuperuser'
      P4PASSWD: 'MySup3rPwd'
      SWARM_USER: 'swarm'
      SWARM_PASSWD: 'MySwa3mPwd'
      SWARM_USER_CREATE: 'true'
      SWARM_GROUP_CREATE: 'true'
      SWARM_SSL_ENABLE: 'true'
      SWARM_SSL_CERTIFICATE_FILE: '/etc/letsencrypt/live/example.com/fullchain.pem'
      SWARM_SSL_CERTIFICATE_KEY_FILE: '/etc/letsencrypt/live/example.com/privkey.pem'
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - /etc/letsencrypt:/etc/letsecnrypt:ro
      - /srv/helix/swarm/data:/opt/perforce/swarm/data
    depends_on:
      - p4d
```

