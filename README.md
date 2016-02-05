# inhumantsar/samba

Hosts samba shares. It's got some fun port requirements but that's about it. 

## Running

    docker run --rm -it \
      -e 'SHARENAMES=share1 share2' \
      -e 'USER=samba' \
      -e 'PASSWORD=password' \
      -e 'WORKGROUP=WORKGROUP' \
      -v '/path/to/share1:/share1' \
      -v '/path/to/share2:/share2' \
      -p '137:137/udp' \
      -p '138:138/udp' \
      -p '139:139' \
      -p '445:445' \
      inhumantsar/samba
