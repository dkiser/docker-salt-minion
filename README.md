# docker-salt-minion

A Docker image which allows you to run a containerized Salt-Minion for testing with a master.

>NOTE: salt minion config must have ```user: salt``` as this container runs unprivileged!

## Running the Container

You can easily run the container like so:

    docker run --rm -it dkiser/salt-minion

## Environment Variables

The following environment variables can be set:

* `LOG_LEVEL`: The level to log at, defaults to `error`

## Volumes

There are several volumes which can be mounted to Docker data container as
described here: https://docs.docker.com/userguide/dockervolumes/. The following
volumes can be mounted:

* `/etc/salt` - This contains the minion config file and/or grains
* `/etc/salt/pki` - This holds the Salt Minion authentication keys
* `/var/cache/salt` - Job and Minion data cache
* `/var/log/salt` - Salts log directory
* `/etc/salt/minion.d` - Minion configuration include directory

### Data Container

To create a data container you are going to want the thinnest possible docker
image, simply run this docker command, which will download the simplest possible
docker image:

    docker run -v /etc/salt salt-minion-data busybox true

This will create a stopped container wwith the name of `salt-minoin-data` and
will hold our persistent salt minion data. Now we just need to run our minion
container with the `--volumes-from` command:

    docker run --rm -it --volumes-from salt-minion-data dkiser/salt-minion

>Make sure /etc/salt/minion and optionally /etc/salt/grains exists in your data container!

### Sharing Local Folders

To share folders on your local system so you can have your own master
configuration, states, pillars etc just alter the `salt-minion-data`
command:

```bash
docker run -it -v /path/to/local/etc/salt:/etc/salt --name salt-minion-data busybox /bin/true
```

Now `/path/to/local` can hold your minion config and grains.

>Make sure uid:gid permissions match the salt user and group in the salt-master container for any items in locally shared folders!
```bash
docker run dkiser/salt-minion "/usr/bin/id"
uid=999(salt) gid=999(salt) groups=999(salt)
```

#### OSX boot2docker

If you are using OSX boot2docker, there is an issue where the VirtualBox '''vboxfs''' share used in the boot2docker vm does not allow for ACL's to properly share from local folders to the containers within the boot2docker VM. Perform the workaround below to switch from ```vboxfs``` to ```nfs``` mounted shares on OSX.

1. Make sure OSX firewall allows nfs (e.g. "Block all incomming connections" is NOT checked)
2. Create/Modify ```/etc/exports``` on your OSX host as below, substituting your boot2docker ip as appropriate.
```bash
/Users [boot2dockerip]
```
3. ```sudo nfsd update``` on the OSX host
3. ```boot2docker ssh``` to ssh into the boot2docker vm
4. ```sudo umount /Users```
5. ```sudo /usr/local/etc/init.d/nfs-client start```
6. ```sudo mount 192.168.59.3:/Users /Users -o  rw,async,noatime,rsize=32768,wsize=32768,proto=tcp```

## Running Salt-Call Commands

Utilize ```docker exec``` in order to jump into the salt master and execute Salt commands.

Once installed run:

    $ docker exec salt-minoin /bin/bash
    $ salt-call '*' test.ping
    $ salt-call '*' grains.items
