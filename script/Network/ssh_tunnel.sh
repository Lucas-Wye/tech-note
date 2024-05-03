# porting to local 7701
ssh -qTfnN -D 7701 remote_server -o "ServerAliveInterval 30" -o "TCPKeepAlive yes"
