#### nmap
![Pasted image 20230825054645.png](https://github.com/ma1a9/HTB/blob/main/HTB/Pasted%20image%2020230825054645.png?raw=true)
webサイトにアクセスすると認証画面が表示される
下の方にサーバー名とバージョンがあるので検索してみる
![[Pasted image 20230824061130.png]]
「Cacti 1.2.22 exploit」で検索すると
https://github.com/FredBrave/CVE-2022-46169-CACTI-1.2.22 が見つかるので
ダウンロードして実行すると直ぐに初期シェルがとれる。
ただし、www-dataユーザなのでフラグはとれない。

ルートディレクトリにいくと「entrypointo.sh」という謎のスクリプトがあるので確認してみる。

![[Pasted image 20230825053754.png]]

![[Pasted image 20230825053836.png]]

mysqlに接続できそうなので接続してみる。

データベースを確認すると「cacti」があるのでそれを使用する
![[Pasted image 20230825054222.png]]

テーブルを表示すると「user_auth」があるので中を確認してみると、ユーザー名とパスワードのハッシュが分かる
![[Pasted image 20230825054429.png]]

ハッシュをjohnにかけると「marcus」パスワードが分かる
![[Pasted image 20230825054601.png]]

#### SSH接続
幸い判明したユーザー名とパスワードはSSH接続のクレデンシャルと同じだったのでSSH接続を実行する

![[Pasted image 20230825055755.png]]

www-dataユーザーでログインしたとき「.dockeerenv」ふぁいるがあったので
dockerのバージョンを調べてみると脆弱性があることが分かった
![[Pasted image 20230826095925.png]]

「docker 20.10.5 exploit」で検索すると
https://github.com/UncleJ4ck/CVE-2021-41091 が見つかる

www-dataユーザーでsuidを検索すると「capsh」が見つかる

![[Pasted image 20230826103112.png]]

GTFOBinsで検索すると
![[Pasted image 20230826133442.png]]

docker上でrootになりbashにsudiをセットする
```bash
chmod u+s /bin/bash
```

「exp.sh」をターゲットにダウンロードして実行する
![[Pasted image 20230826134425.png]]

最後の行の/var/lib・・・にいどうして「./bin/bash -p」を実行すればルートになれる
![[Pasted image 20230826134715.png]]

