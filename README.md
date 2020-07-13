# Info

MIT Kerberos server.

# Launch

## Basic usage example

    docker run -it --rm --name kerberos valtri/kerberos bash -l

## Advanced usage example

    mkdir config db
    #for SELinux: chcon -Rt svirt_sandbox_file_t config db

    docker run -d --name kerberos \
        -v `pwd`/config:/etc/krb5kdc \
        -v `pwd`/db:/var/lib/krb5kdc \
        -e REALM=MONKEY_ISLAND \
        -e DOMAIN_REALM=monkey.island \
        -e PRINCIPALS=service/server.monkey.island,serviceuser \
        valtri/kerberos

    docker cp kerberos:/etc/krb5.conf .
    docker cp kerberos:/keytabs .

# Parameters

* *ADMIN\_USER*: admin principal name (default: *admin/admin*)
* *ADMIN\_KEY*: admin key, empty means randomize (default: (empty))
* *DESTDIR*: output directory with keytabs (default: */keytabs*)
* *DOMAIN\_REALM*: Kerberos domain (default: *EXAMPLE.COM*)
* *KDC\_HOSTNAME*: server hostname used in local krb5.conf, empty means autodetect (default: (empty))
* *MASTER\_KEY*: Kerberos master key, empty means randomize (default: (empty))
* *REALM*: Kerberos realm (default: *EXAMPLE.COM*)
* *PRINCIPALS*: additional principals to create
