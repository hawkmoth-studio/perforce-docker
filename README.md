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
| P4D\_SECURITY                      | 2                                      | Server security level.                                          |
| P4D\_TYPEMAP                       |                                        | Global server typemap.                                          |
| P4D\_LOAD\_USERS                   | false                                  | If true, loads user specifications on startup.                  |
| P4D\_LOAD\_USER\_PASSWORDS         | false                                  | If true, loads user passwords on startup.                       |
| P4D\_LOAD\_GROUPS                  | false                                  | If true, loads group specifications on startup.                 |
| P4D\_LOAD\_DEPOTS                  | false                                  | If true, loads depot specifications on startup.                 |
| P4D\_LOAD\_PROTECTIONS             | false                                  | If true, loads protection lists on startup.                     |
| P4D\_SSL\_CERTIFICATE\_FILE        |                                        | If set, file is copied and used as a TLS certificate.           |
| P4D\_SSL\_CERTIFICATE\_KEY\_FILE   |                                        | If set, file is copied and used as a TLS private key.           |
| SWARM\_URL                         |                                        | If set, used to update P4.Swarm.URL property.                   |
| INSTALL\_SWARM\_TRIGGER            | false                                  | Set to `true` to automatically install / update swarm triggers. |
| SWARM\_TRIGGER\_HOST               | http://swarm                           | URL to be used by p4d to access Swarm.                          |
| SWARM\_TRIGGER\_TOKEN              |                                        | Swarm token. Required if swarm trigger installation is enabled. |

### Initial configuration
When started for the first time, a new p4d server is initialized with superuser identified by `$P4USER` and `$P4PASSWD`.
Changing these variables after the server has been initialized does not change server's superuser.

### Typemap support
Provide typemap id in `P4D_TYPEMAP` environment variable to load a pre-configured typemap on server startup.
Available typemaps:
* `default` (default perforce typemap)
* `ue4` (see [Unreal Engine documentation](https://docs.unrealengine.com/en-US/Engine/Basics/SourceControl/Perforce/index.html#p4typemap))

### Automatic data loading
`helix-p4d` supports loading certain data on startup.
This provides an easy way to automate production-ready container deployment.

#### Users
If `P4D_LOAD_USERS` is set to `true`, all `.txt`-files from `/p4-users`
are loaded as user specification files when starting container (in alphabetic order).

Example specification file:
```text
User:       johndoe
Email:      john.doe@example.localdomain
FullName:   John Doe
```

#### User passwords
`p4d` disallows setting user password using specification file when security level is set to `2` or higher.
If `P4D_LOAD_USER_PASSWORDS` is set to `true`, container uses all `.txt`-files
from `/p4-passwd` to set/update user passwords on startup.
All files should be named `<username>.txt` and contain only corresponding user password (without newlines).

#### Groups
If `P4D_LOAD_GROUPS` is set to `true`, all `.txt`-files from `/p4-groups`
are loaded as group specification files when starting container (in alphabetic order).

Example specification file:
```text
Group:      admins
Owners:     p4admin
Users:
            p4admin
            johndoe
```

#### Depots
If `P4D_LOAD_DEPOTS` is set to `true`, default depot `depot` is not created,
and all `.txt`-files from `/p4-depots` are loaded as depot specification files
when starting container.

Please be advised, certain operations (e.g. updating depot type) is not supported this way.
In such case, perforce administrator should re-create perforce depot manually. 

Example specification file:
```text
Depot:          depot
Owner:          p4admin
Description:
                Default depot.
Type:           local
Address:        local
Suffix:         .p4s
StreamDepth:    //depot/1
Map:            depot/...
```

#### Depots
If `P4D_LOAD_PROTECTIONS` is set to `true`, all `.txt`-files from `/p4-protect` (in alphabetic order)
are merged together and loaded as protection specification when starting container.

Example specification file (see documentation for `p4 protect` for more details):
```text
    write user * * //...
    list user * * -//spec/...
    super user p4admin * //...
```

### TLS support
If `$P4PORT` value starts with `ssl:`, p4d is configured with TLS support.
It is strongly recommended to provide proper custom key and certificate using `P4D_SSL_CERTIFICATE_FILE` and `P4D_SSL_CERTIFICATE_KEY_FILE` environment variables are set - these file are copied into `$P4SSLDIR` as `certificate.txt` and `privatekey.txt`.
Otherwise, new key and certificate are automatically generated (only during initialization).

Attention: when server detects that key and/or certificate has changed, a new server fingerprint is generated.
All the clients (including local container client) must be updated to trust this new fingerprint.

### Swarm trigger support
If `INSTALL_SWARM_TRIGGER` is set to `true`, swarm trigger script and configuration is installed / updated on every container startup.
The following tasks are performed as part of trigger installation:
1. Script creates `.swarm` depot if it does not exist.
1. Script creates a temporary workspace and syncs it to temp directory. This workspace will be deleted later.
1. Script installs / updates `//.swarm/triggers/swarm-trigger.pl` from the official package.
1. Using `SWARM_TRIGGER_HOST` and `SWARM_TRIGGER_TOKEN`, the script installs / updates `//.swarm/triggers/swarm-trigger.conf`.
1. Script submits changes (if any) to the p4d server.
1. Script updated `p4 triggers` (see [official documentation](https://www.perforce.com/manuals/v18.1/cmdref/Content/CmdRef/p4_triggers.html)).

Beware, setting `INSTALL_SWARM_TRIGGER` to value other than `true` does not remove currently installed triggers!


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
| SWARM\_TRIGGER\_TOKEN              |                                        | Swarm trigger token to be installed, if not empty.              |

### Initial configuration
When started, container checks if `/opt/perforce/swarm/data/config.php` is present.
If not, Swarm is initialized using provided environment variables.

After the container has been initialized, all modifications to the Swarm configuration should be done by editing the `config.php` (see [official documentation](https://www.perforce.com/manuals/swarm/Content/Swarm/admin.configuration.html)).

### TLS support
Set `SWARM_SSL_ENABLE` to `true` and provide correct certificate and key files to enable TLS support.
TLS support can be enabled/disabled/updated through the environment variables at any time (container restart is required).

### Swarm trigger support
If `SWARM_TRIGGER_TOKEN` is set, it is automatically added to a list of valid trigger tokens upon container startup.


## Examples
### Running with docker-compose
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

### Loading typemap into p4d
Warning: helix-p4d image comes with pre-configured typemaps. Please consider using them first before using a custom typemap.

In this example we will load a [UE4 Perforce Typemap](https://docs.unrealengine.com/en-US/Engine/Basics/SourceControl/Perforce/index.html).

There is a [known issue](https://github.com/docker/compose/issues/3352) with `docker-compose` and piping, so we need to use the `docker` command:
```bash
 docker exec -i helix_p4d_1 p4 typemap -i <<EOF
# Perforce File Type Mapping Specifications.
#
#  TypeMap:             a list of filetype mappings; one per line.
#                       Each line has two elements:
#
#                       Filetype: The filetype to use on 'p4 add'.
#
#                       Path:     File pattern which will use this filetype.
#
# See 'p4 help typemap' for more information.

TypeMap:
                binary+w //depot/....exe
                binary+w //depot/....dll
                binary+w //depot/....lib
                binary+w //depot/....app
                binary+w //depot/....dylib
                binary+w //depot/....stub
                binary+w //depot/....ipa
                binary //depot/....bmp
                text //depot/....ini
                text //depot/....config
                text //depot/....cpp
                text //depot/....h
                text //depot/....c
                text //depot/....cs
                text //depot/....m
                text //depot/....mm
                text //depot/....py
                binary+l //depot/....uasset
                binary+l //depot/....umap
                binary+l //depot/....upk
                binary+l //depot/....udk
                binary+l //depot/....ubulk
EOF
```

