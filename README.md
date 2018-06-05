# Docker container for MythTV Backend
[![Docker Automated build](https://img.shields.io/docker/automated/sammonsjl/mythtv.svg)](https://hub.docker.com/r/sammonsjl/mythtv/) [![Docker Image](https://images.microbadger.com/badges/image/sammonsjl/mythtv.svg)](https://microbadger.com/images/sammonsjl/mythtv) [![Build Status](https://travis-ci.org/sammonsjl/docker-mythtv.svg?branch=master)](https://travis-ci.org/sammonsjl/docker-mythtv)

This is a Docker container for MythTV Backend.

MythTV Setup is accessed through a modern web browser or via any VNC client.

---

[![MythTV logo](https://www.mythtv.org/img/mythtv.png)](https://mythtv.org/)

[MythTV](mythtv.org) is an Open Source DVR that started development in 2002. It contains many features found in many commercial DVR solutions.  MythTV can receive original TV programming from over the air or cable TV systems and integrates with various guide data services.

---

## Table of Contents

   * [Docker container for MythTV](#docker-container-for-mythtv)
      * [Table of Content](#table-of-content)
      * [Quick Start](#quick-start)
      * [Usage](#usage)
         * [Environment Variables](#environment-variables)
         * [Data Volumes](#data-volumes)
         * [Ports](#ports)
         * [Changing Parameters of a Running Container](#changing-parameters-of-a-running-container)
      * [Docker Compose File](#docker-compose-file)
      * [Docker Image Update](#docker-image-update)
         * [Synology](#synology)
         * [unRAID](#unraid)
      * [User and Group IDs](#user-and-group-ids)
      * [Accessing the GUI](#accessing-the-gui)
      * [Shell Access](#shell-access)
      * [Support or Contact](#support-or-contact)

## About
This MythTV docker container aims to ease MythTV configuration by making it easy to configure the 
system using modern web browsers.  MythTV can be complex to configure due to the requirement of needing
a GUI to configure the backend.  The other thing that can make MythTV difficult is the setup process
requires the backend process to be stopped.  Since service supervisors such as runit and S6 try to keep the services
from stopping, this image uses a config mode to prevent mythbackend from starting.

> **_IMPORTANT_**: When creating the container, the **--hostname** flag must be used to set a hostname in the image.
This is because MythTV binds itself to the hostname used to configure the database.  The option **--net=host** must also be used 
because mythbackend needs to be accessible on the public network so mythfrontend can properly locate it.

## Quick Start

**NOTE**: The Docker command provided in this quick start is given as an example
and parameters should be adjusted to your need.

Launch the MythTV docker container with the following command:
```
docker run -d \
    --name=mythbackend \
    -v /docker/appdata/mythtv/config:/home/mythtv \
    -v /docker/appdata/mythtv/data:/var/lib/mysql \
    -v /docker/appdata/mythtv/media:/var/lib/mythtv \
    --hostname=mythbackend --net=host \
    sammonsjl/mythtv:29-fixes
```

Where:
  - `/docker/appdata/mythtv/config`: This is where MythTV stores its configuration.
  - `/docker/appdata/mythtv/data`: This is where MythTV stores it's MariaDB database.
  - `/docker/appdata/mythtv/media`: This is where MythTV stores it's media files such as recordings.

Browse to `http://your-host-ip:6507` to access the Mate Desktop GUI.  From here MythTV can be configured using the MythTV Backend Setup shortcut.  MythTV can be also be tested using the MythTV Backend Startup shortcut.  Setting the variable CONFIG_MODE=0 will disable the GUI and properly configure S6 to control mythbackend startup.

## Usage

```
docker run [-d] \
    --name=mythbackend \
    [-e <VARIABLE_NAME>=<VALUE>]... \
    [-v <HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]]... \
    [---hostname=<HOSTNAME>]... \
    sammonsjl/mythtv:29-fixes
```
| Parameter | Description |
|-----------|-------------|
| -d        | Run the container in background.  If not set, the container runs in foreground. |
| -e        | Pass an environment variable to the container.  See the [Environment Variables](#environment-variables) section for more details. |
| -v        | Set a volume mapping (allows to share a folder/file between the host and the container).  See the [Data Volumes](#data-volumes) section for more details. |

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Default |
|----------------|----------------------------------------------|---------|
|`USERID`| ID of the user the application runs as.  See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `120` |
|`GROUPID`| ID of the group the application runs as.  See [User/Group IDs](#usergroup-ids) to better understand when this should be set. | `121` |
|`TZ`| [TimeZone] of the container.  Timezone can also be set by mapping `/etc/localtime` between the host and the container. | `America/Chicago"` |
|`CONFIG_MODE`| When set to `1`, The mythbackend service will be disabled and a Mate Desktop will be started at: `http://your-host-ip:6507`. | `1` |

### Data Volumes

The following table describes data volumes used by the container.  The mappings
are set via the `-v` parameter.  Each mapping is specified with the following
format: `<HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path  | Permissions | Description |
|-----------------|-------------|-------------|
|`/home/mythtv`| rw | This is where MythTV stores its configuration. |
|`/var/lib/mysql`| rw |  This is where MythTV stores it's MariaDB database. |
|`/var/lib/mythtv`| rw | This is where MythTV stores it's media files such as recordings. |

### Ports

Here is the list of ports used by the container.  They will be mapped to the host
via the `--net=host` parameter.

| Port | Description |
|------|------------------------------|
| 6506 | MariaDB instance accessed by Mythfrontend. |
| 6543 | Port Mythbackend runs on. |
| 6544 | Mythbackend status port. Also where MythTV WebFrontend runs. |
| 6554 | Web Socket Port. |
| 6570 | Port used to configure MythTV via a Mate Desktop. |
| 6580 | Port used to access the MythWeb GUI. |

### Changing Parameters of a Running Container

As seen, environment variables, volume mappings and port mappings are specified
while creating the container.

The following steps describe the method used to add, remove or update
parameter(s) of an existing container.  The generic idea is to destroy and
re-create the container:

  1. Stop the container (if it is running):
```
docker stop mythbackend
```
  2. Remove the container:
```
docker rm mythbackend
```
  3. Create/start the container using the `docker run` command, by adjusting
     parameters as needed.

**NOTE**: Since all application's data is saved under the various volumes, 
destroying and re-creating a container is not a problem: nothing is lost
and the application comes back with the same state (as long as the volume mappings 
remain the same).

## Docker Compose File

Here is an example of a `docker-compose.yml` file that can be used with
[Docker Compose](https://docs.docker.com/compose/overview/).

Make sure to adjust according to your needs.

```yaml
version: '3'
services:
  mythbackend:
    build: .
    environment:
      - CONFIG_MODE=1
    volumes:
      - config:/home/mythtv:nocopy
      - data:/var/lib/mysql:nocopy
      - media:/var/lib/mythtv:nocopy
      - ./shared:/shared
    hostname: mythbackend
    network_mode: "host"
volumes:
  config:
  data:
  media:
```

## Docker Image Update

If the system on which the container runs doesn't provide a way to easily update
the Docker image, the following steps can be followed:

  1. Fetch the latest image:
```
docker pull sammonsjl/mythtv:29-fixes
```
  2. Stop the container:
```
docker stop mythbackend
```
  3. Remove the container:
```
docker rm mythbackend
```
  4. Start the container using the `docker run` command.

### Synology

For owners of a Synology NAS, the following steps can be use to update a
container image.

  1.  Open the *Docker* application.
  2.  Click on *Registry* in the left pane.
  3.  In the search bar, type the name of the container (`sammonsjl/mythtv`).
  4.  Select the image, click *Download* and then choose the `29-fixes` tag.
  5.  Wait for the download to complete.  A  notification will appear once done.
  6.  Click on *Container* in the left pane.
  7.  Select your MythTV container.
  8.  Stop it by clicking *Action*->*Stop*.
  9.  Clear the container by clicking *Action*->*Clear*.  This removes the
      container while keeping its configuration.
  10. Start the container again by clicking *Action*->*Start*. **NOTE**:  The
      container may temporarily disappear from the list while it is re-created.

### unRAID

For unRAID, a container image can be updated by following these steps:

  1. Select the *Docker* tab.
  2. Click the *Check for Updates* button at the bottom of the page.
  3. Click the *update ready* link of the container to be updated.

## User and Group IDs

When using data volumes (`-v` flags), permissions issues can occur between the
host and the container.  For example, the user within the container may not
exists on the host.  This could prevent the host from properly accessing files
and folders on the shared volume.

To avoid any problem, you can specify the user the application should run as.

This is done by passing the user ID and group ID to the container via the
`USERID` and `GROUPID` environment variables.

To find the right IDs to use, issue the following command on the host, with the
user owning the data volume on the host:

    id <username>

Which gives an output like this one:
```
uid=1000(myuser) gid=1000(myuser) groups=1000(myuser),4(adm),24(cdrom),27(sudo),46(plugdev),113(lpadmin)
```

The value of `uid` (user ID) and `gid` (group ID) are the ones that you should
be given the container.

## Accessing the GUI

The graphical interface of the application can be accessed via:

  * A web browser:
```
http://<HOST IP ADDR>:6700
```

## Shell Access

To get shell access to a the running container, execute the following command:

```
docker exec -it CONTAINER /bin/bash 
```

Where `CONTAINER` is the ID or the name of the container used during its
creation (e.g. `mythbackend`).

[TimeZone]: http://en.wikipedia.org/wiki/List_of_tz_database_time_zones
[official documentation]: https://mythtv.org

## Support or Contact

Having troubles with the container or have questions?  Please
[create a new issue].

[create a new issue]: https://github.com/sammonsjl/docker-mythtv/issues
