    ssh -L "target_port":ip_address:"destination_port" host

Connections to tcp `host`:`target_port` will be made to `ip_address`:`destination_port` via SSH tunnel to `host`.

Example:

    ssh -L 8080:192.168.1.1:9200 localhost

Connections to `localhost:8080` will be made to `192.168.1.1:9200`
