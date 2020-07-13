#! /bin/bash

: ${KDC_HOSTNAME:=$(hostname -f)}

if [ -f /.docker-first-launch ]; then
	echo "DAEMON_ARGS=\"-r $REALM\"" > /etc/default/krb5-kdc
	echo "DAEMON_ARGS=\"-r $REALM\"" > /etc/default/krb5-admin-server

	cat <<EOF > /etc/krb5.conf
[libdefaults]
	default_realm = $REALM
	dns_lookup_realm = false
	dns_lookup_kdc = false

[realms]
	$REALM = {
		kdc = $KDC_HOSTNAME
		admin_server = $KDC_HOSTNAME
	}

[domain_realm]
	.$DOMAIN_REALM = $REALM
	$DOMAIN_REALM = $REALM
EOF
	rm -f /.docker-first-launch
fi

create_principal() {
	local user="$1"; local key="$2"
	local f=`echo $user | sed -e 's/\//_/g' -e 's/\..*//'`.keytab

	if [ -n "$key" ]; then
		kadmin.local -r $REALM -q "ank -pw $key $user@$REALM"
	else
		kadmin.local -r $REALM -q "ank -randkey $user@$REALM"
	fi
	if [ -n "$DESTDIR" ]; then
		kadmin.local -r $REALM -q "ktadd -norandkey -k $DESTDIR/$f $user@$REALM"
	fi
}

if [ ! -f /var/lib/krb5kdc/principal ]; then
	if [ -z "$MASTER_KEY" ]; then
		pass="`dd if=/dev/random bs=1 count=15 2>/dev/null | base64`"
		MASTER_KEY="$pass"
	fi

	echo "*/admin@$REALM *" > /etc/krb5kdc/kadm5.acl

	kdb5_util create -P "$MASTER_KEY" -r $REALM -s

	[ -n "$DESTDIR" ] && mkdir -p "$DESTDIR" 2>&1 || :

	if [ -n "$ADMIN_USER" ]; then
		create_principal $ADMIN_USER $ADMIN_KEY
		echo "$ADMIN_USER@$REALM *" >> /etc/krb5kdc/kadm5.acl
	fi

	IFS=,; for p in $PRINCIPALS; do
		create_principal $p ''
	done
	unset IFS
fi

unset MASTER_KEY
unset ADMIN_KEY

service krb5-admin-server start
service krb5-kdc start

if [ -z "$1" ]; then
	tail -f /dev/null
else
	exec "$@"
fi
