### Shell Upgrade

```shell
# Enter while in reverse shell
$ python -c 'import pty; pty.spawn("/bin/bash")'

Ctrl-Z

# In Kali
$ stty raw -echo;fg

Enter
Enter
# In reverse shell
$ reset
$ export SHELL=bash
$ export TERM=xterm-256color
$ stty rows <num> columns <cols>


#Resource
https://netsec.ws/?p=337
```

### rbash回避
```shell
ssh alfred@10.11.1.101 -t "bash --noprofile"
```
```shell
https://oscpnotes.infosecsanyam.in/My_OSCP_Preparation_Notes--Enumeration--SSH--rbash_shell_esacping.html

$ BASH_CMDS[a]=/bin/sh;a
$ export PATH=$PATH:/bin/
$ export PATH=$PATH:/usr/bin
```

# pythonが無い時
```shell
script /dev/null -c bash
```