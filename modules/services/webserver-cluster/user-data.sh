#!/bin/bash
cat > index.html <<-EOF
<h1> ${text} </h1>
<p> The server IP: $(hostname -I | awk '{print $1}') </p>


EOF
nohup busybox httpd -f -p ${server_port} &