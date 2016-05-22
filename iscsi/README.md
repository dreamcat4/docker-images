### iscsi

* Runs ietd in a container (apt-get install iscsitarget)
* Requires kmods loaded in host kernel
* Requires `net=host`

### Steps

Run the following cmds on host side:

    apt-get install iscsitarget
    sed -i -e 's/ISCSITARGET_ENABLE=false/ISCSITARGET_ENABLE=true/' /etc/default/iscsitarget
    sudo systemctl disable iscsitarget
    sudo service iscsitarget stop
    sudo modprobe iscsi_trgt


Put your iscsi luns as files in a host folder, then bind mount them to `/iscsi/targets` within the container.

Ensure you have included the following docker run flags as shown in the yaml fragment below.

## Docker compose

Sorry there isn't an example specifically for compose. However you can adapt from this `crane.yml` file which is very similar:

```yaml

containers:

  iscsi:
    image: dreamcat4/iscsi
    run:
      net: host
      device:
        - /dev/ietctl
      volume:
        - /path/to/your/iscsi/targets:/iscsi/targets
```


### Credit

* Version 1 - By Dreamcat4.


