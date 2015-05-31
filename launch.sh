#!/bin/bash
echo 'Starting...'

if [ ! -d '/etc/puppet/modules/samba' ]; then
  echo 'No samba puppet module! Bailing out!'
  exit -1
fi

if [ "$SHARENAMES" == "" ]; then
  echo 'No share names defined! Bailing out!'
  exit -1
fi

if [ "$USER" == "" ]; then
  u='samba'
else
  u="$USER"
fi

if [ "$PASSWORD" == "" ]; then
  p='password'
else
  p="$PASSWORD"
fi

if [ "$WORKGROUP" == "" ]; then
  w='WORKGROUP'
else
  w="$WORKGROUP"
fi

#echo "Params processed: $u $p $w Shares: $SHARENAMES"

sudo="""
include sudo
sudo::conf { 'disable_requiretty' :
  priority => 10,
  content => 'Defaults !requiretty',
}
"""
echo 'Applying sudo puppet code...'
echo "$sudo" > /tmp/sudo.pp
puppet apply /tmp/sudo.pp
if [ "$?" != 0 ]; then
  echo 'Could not apply sudo settings! Bailing out.'
  exit -1
fi


server="""
class { 'samba::server' :
  workgroup => '$w',
  server_string => 'Samba Server',
  interfaces => 'eth0 lo',
  security => 'share'
}

user { '$u' :
  shell => '/sbin/nologin',
}

samba::server::user { '$u' :
  password => '$p',
}

"""

echo 'Prepping server puppet code...'
echo "$server" > /tmp/samba.pp

share_template="""
samba::server::share { 'replaceme':
  comment => 'replaceme',
  path => '/replaceme',
  browsable => true,
  public => true,
  writable => true,
  write_list => $u,
  require => Class['samba::server'],
}

"""

echo 'Applying puppet code for shares...'
for s in $SHARENAMES; do
  t="${share_template//replaceme/$s}"
  echo "$t" >> /tmp/samba.pp
done

echo 'Here goes nothing...'
puppet apply /tmp/samba.pp

supervisord_template="""
class { '::supervisord' :
  install_pip => true,
}

supervisord::program { 'smbd' :
  command => 'smbd -F -S',
}

supervisord::program { 'nmbd' :
  command => 'nmbd -F -S',
}
"""

echo 'Applying puppet code for supervisord...'
echo "$supervisord_template" > /tmp/supervisord.pp
puppet apply /tmp/supervisord.pp
	
echo -e "\n\nDon't worry about those big scary puppet errors above."
echo 'Giving supervisord a kick to get the ball rolling...'
/usr/bin/supervisord -n

