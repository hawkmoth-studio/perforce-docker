[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

# perforce-docker
Docker images for Perforce source control.

## helix-p4d
This image contains a [Helix Core Server](https://www.perforce.com/products/helix-core]).

### Quickstart
```bash
docker run -v /srv/helix-p4d/data:/data -p 1666:1666 -e P4CASE=1 hawkmothstudio/helix-p4d
```

### Container Environment Variables
| Variable Name | Default value         | Description                                               |
| ------------- | --------------------- | --------------------------------------------------------- |
| P4NAME        | master                | Service name. Do not change.                              |
| P4ROOT        | /data/master          | p4d data directory. Do not change.                        |
| P4SSLDIR      | /data/master/root/ssl | Directory with ssl certificate and private key.           |
| P4PORT        | ssl:1666              | Server port. By default, connection is secured by TLS.    |
| P4USER        | super                 | Login of the first user to be created.                    |
| P4PASSWD      | P@ssw0rd              | Password of the first user to be created.                 |
| P4CASE        | 0                     | Set to 1 to use case-insensitive mode.                    |

### docker-compose
Example `docker-compose.yml` when running under Linux:
```yaml
version: '2.1'
services:
  server:
    image: hawkmothstudio/helix-p4d
    ports:
    - "1666:1666"
    environment:
      P4USER: mysuperuser
      P4PASSWD: MySup3rPwd
      P4CASE: '1'
    volumes:
    - /etc/localtime:/etc/localtime:ro
    - /etc/timezone:/etc/timezone:ro
    - /srv/helix-p4d:/data
```
