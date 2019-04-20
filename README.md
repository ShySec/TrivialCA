Trivial openssl wrapper to initialize and use a local, and preferably offline, certificate authority

    ./generate-ca.sh <name>

Generate a new certificate authority in ./ca/<name>

    ./generate-domain.sh <ca> <domain>

Generate a new FQDN domain key, csr, and certificate in ./servers/<domain> signed by <ca> (skips common certificate questions about region and organizational units)

    ./generate-server.sh <ca> <server>

Generate a new server key, csr, and certificate in ./servers/<server> signed by <ca> (- asks all common certificate questions including region and organizational units)

    ./sign-request.sh <ca> <request> [<domain>]

Sign the indicated <request> with <ca> and stores the certificate in ./servers/<domain>
