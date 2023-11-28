```
cd /tmp
virtualenv -p /usr/bin/python2.7 venv
venv
```
pip2.7が/tmp/venv/binの中にあるので移動して使う
```
pip2.7 install sshuttle==0.78.
```
```
sudo /tmp/venv/bin/sshuttle -e "ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 -oHostKeyAlgorithms=+ssh-dss" -r j0hn@10.11.1.252:22000 10.2.2.0/24
j0hn@10.11.1.252's password:bzuisJDnuI6WUDl
```