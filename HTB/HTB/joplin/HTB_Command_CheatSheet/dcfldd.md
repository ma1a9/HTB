>dcfldd は、当初、国防総省コンピューター フォレンジック ラボ (DCFL) で開発されました。このツールは、次の追加機能を備えた dd プログラムに基づいています。  
>オンザフライでのハッシング: dcfldd は入力データを転送中にハッシュできるため、データの整合性を確保するのに役立ちます。  
ステータス出力: dcfldd は、転送されたデータの量と操作にかかる時間をユーザーに知らせます。  
柔軟なディスク ワイプ: dcfldd を使用して、必要に応じて既知のパターンでディスクをすばやくワイプできます。  
イメージ/ワイプ検証: dcfldd は、ターゲット ドライブが指定された入力ファイルまたはパターンとビット単位で一致することを検証できます。 
複数の出力: dcfldd は、同時に複数のファイルまたはディスクに出力できます。 
出力の分割: dcfldd は、出力を複数のファイルに分割でき、split コマンドよりも構成可能性が高くなります。  
パイプ出力とログ: dcfldd は、すべてのログ データと出力をコマンドやファイルにネイティブに送信できます。  
dd が 512 バイトのデフォルト ブロック サイズ (bs、ibs、obs) を使用する場合、dcfldd は 32768 バイト (32 KiB) を使用します。これは非常に効率的です。  
次のオプションは dcfldd にはありますが、dd にはありません: ALGORITHMlog:、errlog、hash、hashconv、hashformat、hashlog、hashlog:、hashwindow、limit、of:、pattern、sizeprobe、split、splitformat、statusinterval、textpattern、totalhashformat、verifylog 、verifylog:、vf.  
装着サイズ： 113 KB  
>装着方法： sudo apt install dcfldd   

[dcfldd](https://www.kali.org/tools/dcfldd/)

>if=FILE　標準入力の代わりにFILEから読み込む    
>of=FILE　標準出力ではなく、FILEに書き込む
## バックトラックフォレンジック: dcfldd
dcfldd は、古い dd イメージング ツールの拡張バージョンであり、いくつかの新機能があります。
- オンザフライでハッシュ - dcfldd は入力データを転送中にハッシュできるため、データの整合性を確保できます。
- ステータス出力 - dcfldd は、転送されたデータの量と操作にかかる時間をユーザーに更新できます。
- 柔軟なディスク ワイプ - dcfldd を使用して、必要に応じて既知のパターンでディスクをすばやくワイプできます。
- イメージ/ワイプ検証 - dcfldd は、ターゲット ドライブが指定された入力ファイルまたはパターンとビット単位で一致することを検証できます。
- 複数の出力 - dcfldd は同時に複数のファイルまたはディスクに出力できます。
- 出力の分割 - dcfldd は出力を複数のファイルに分割でき、split コマンドよりも構成可能性が高くなります。
- パイプ出力とログ - dcfldd はすべてのログ データと出力をコマンドやファイルにネイティブに送信できます。
使用例:
```
#イメージファイルを作成
$ dcfldd if=/dev/sdb of=usb1G.dd   
```
```
#イメージング後にハッシュを計算
$ dcfldd if=/dev/sdb of=usb1G.dd hash=md5,sha1 hashconv=after hashlog=hashlog.txt 
```
```
#イメージを 512M チャンクに分割し、それぞれに 2 つの数値 (カウンター) を追加します。分割は、出力ファイルの前に定義する必要があります。
$ dcfldd if=/dev/sdb  splitformat=nn split=512M  of=usb1G.dd 
```
