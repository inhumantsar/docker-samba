# inhumantsar/samba

Hosts samba shares. It's got some fun port requirements but that's about it. 

## Running

    docker run --rm -it \
      -e '"SHARENAMES=share1 share2"' \
      -e 'USER=samba' \
      -e 'PASSWORD=password' \
      -e 'WORKGROUP=WORKGROUP' \
      -v '/path/to/somedir1:/share1' \
      -v '/path/to/somedir2:/share2' \
      -p '137:137/udp' \
      -p '138:138/udp' \
      -p '139:139' \
      -p '445:445' \
      inhumantsar/samba

 - You might see some scary looking Puppet errors regarding D-Bus problems (see below), but these can be safely ignored. 
 - The values you enter into SHARENAMES *must* match the names you use for the container's volumes.
 - This is tested and working with Win10 clients, but the workgroup names must be identical.
 - Not intended for use in an AD domain, will not function as a Domain Controller.
 - Should work fine with volumes mounted from other containers.

    Error: Could not start Service[supervisord]: Execution of '/usr/bin/systemctl start supervisord' returned 1: Failed to get D-Bus connection: Operation not permitted
    Error: /Stage[main]/Supervisord::Service/Service[supervisord]/ensure: change from stopped to running failed: Could not start Service[supervisord]: Execution of '/usr/bin/systemctl start supervisord' returned 1: Failed to get D-Bus connection: Operation not permitted


