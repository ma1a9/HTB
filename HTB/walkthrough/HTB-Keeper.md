![[Pasted image 20230816183321.png]]
port80 ipアドレスだとアクセスできない
![[Pasted image 20230816183419.png]]

/etc/hostsに追記
```
10.129.229.41   tickets.keeper.htb
```

ログイン画面が表示される
![[Pasted image 20230816184827.png]]

デフォルトのユーザー名とパスワードでログインできる
root:password

![[Pasted image 20230816210850.png]]
[[keepass]]の問題があることが分かる
ユーザー・セクションには、lnorgaard:Welcome2023というユーザーがいる！
![[Pasted image 20230816211229.png]]
lnorgaard:Welcome2023でSSH接続する

![[Pasted image 20230816211904.png]]
特権の昇格
ユーザーディレクトリ/home/lnorgaardにRT30000.zipというファイルがある。Windowsアプリケーションのクラッシュチケットでは、セキュリティ上の理由からメモリダンプがチケットから削除され、ホームディレクトリに置かれたと書かれています。

ローカルで調査するために、このファイルをダウンロードしてみよう：
![[Pasted image 20230816212528.png]]
![[Pasted image 20230816212605.png]]
[[CVE-2023-32784]]の問題があるよう。メモリ・ダンプからほぼ全てのパスワードを見つけることができる。

`git clone https://github.com/CMEPW/keepass-dump-masterkey`から[[poc.py]]をダウンロードしメモリダンプを解析する。
![[Pasted image 20230816213325.png]]
`med flode`を検索すると
`rødgrød med fløde`というパスフレーズが分かる
このパスワードを使ってpasscodex.kdbxを開く

kalilinuxのKeePssXCを使う
![[Pasted image 20230816213846.png]]

Puttyの秘密鍵を作成する為にPuttyをインストール
![[Pasted image 20230816214145.png]]

[[KeePassXC]]で分かったメモの部分をroot.ppkとして保存
[[puutygen]]で秘密鍵を生成する
![[Pasted image 20230816214447.png]]
![[Pasted image 20230816214514.png]]
id_rsaのパーミッションを600に変更
![[Pasted image 20230816214609.png]]

秘密鍵を使ってSSH接続をする
![[Pasted image 20230816214710.png]]

