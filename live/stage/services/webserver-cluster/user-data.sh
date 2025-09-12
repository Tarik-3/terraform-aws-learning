#!/bin/bash
cat > index.html <<-EOF
<h1> Hi!! Tarik is here again, so enjoy the pain !! </h1>
<p> The database port: ${db_port} </p>
<p> The database address: ${db_address} </p>

EOF
nohup busybox httpd -f -p ${server_port} &