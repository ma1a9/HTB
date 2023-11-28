# ***<span style="color:blue;">権限昇格の流れ</span>***
- リバースシェル上で情報の列挙を行う   
	- 他のユーザ、プロセス、定期実行されるタスク・・・etc   
- 収集した情報から権限昇格できそうなものを見つけて調査する
- エクスプロイトの概要把握と実行（例外あり）   
	- エラーが起きた場合はトラブルシューティング   
- 最終的にインタラクティブなrootシェルを獲得する  
	- proof.txtを読み取るだけでなくシェルを取る必要がある
# ***<span style="color:blue;">rootシェルの取り方</span>***
- sudo    
```
$ sudo /bin/bash
```   
- suid   
	-   /bin/bashにsuidを設定する   
```
$ /bin/bash -p
````
- ユーザを追加   
	- /etc/passwdにuid=0のユーザを追加する   
- パスワードの上書き   
	- /etc/passwdのパスワード部分を消す
# ***<span style="color:blue;">権限昇格のパターン</span>***
１　サービスやアプリを悪用する   
２　ファイルの権限設定ミス    
３　sudoが実行出来る    
４　suidのある実行ファイルがある    
５　configやhistoryにパスワードが平文のまま保存されている     
６　定期実行されるスクリプトの悪用     
７　カーネルエクスプロイト    
# ***<span style="color:blue;">サービスの悪用</span>***
- 高権限で動作しているサービスで悪用可能なものを探す   
	- 基本的に公開されているPoCがあることが多い    
```
$ ps aux | grep root    
$ dpkg -l
$ rpm -qa   
$ <program> --version
```   
- 内部にのみ公開されているサービスを悪用する   
	- オープンポートを調査してポートフォワーディングする   
```
ss -antp
```   
# ***<span style="color:blue;">ファイルの権限設定ミス</span>***
- 重要なファイルへの読み取り権限や書き込み権限を悪用  
	- /etc/passwd　→　rootのパスワードをnullにできてしまう    
	- /etc/shadow　→　rootのパスワードを上書きできてしまう   
	- バックアップ系ファイル　→　本来読めないファイルが読めていしまう   
- linpeasを使えば列挙してくれるが、手動の場合はfindを使う   
```
$ find /etc -writable -type f 2>/dev/null   
$ find /etc -readable -type f 2>/dev/null   
$ find / -type f -name *backup* 2>/dev/null
```  
# ***<span style="color:blue;">sudoでの実行</span>***
- 権限昇格の中で最も単純かつ最も簡単   
```
$ sudo -l
```   
- 他のユーザ（主にroot）になってプログラムを実行する   
	- /etc/sudoersが設定ファイルになっている   
- パスワードを求められる場合と求められない場合がある
- 他のユーザになることが出来たら先ず試す   
<span style="color: red;">※sudoを行う前にシェルをアプグレードしておくことに注意</span>   
# ***<span style="color:blue;">suidバイナリの悪用</span>***
- 実行時にファイルの所有者として実行される   
	- passwd（パスワード変更に使うコマンド）など   
- findコマンドで列挙可能   
```
find / -perm -4000 2 >/dev/null   
find / -perm -u=s -type f 2>/dev/null
```
- 悪用出来ないものも多くある   
	- 判断してくれるツールもある（SUID3NUM)
# ***<span style="color:blue;">Passwordの平文保存</span>***
- パスワードが使いまわしされていることがある   
	- Webappのconfigに書かれているデータベースのパスワード   
```
$su - john
```    
- historyファイルから過去に実行されたコマンドを確認する   
	- パスワードがコマンドに含まれている場合がある   
- sshの秘密鍵   
	- バックアップを取る際に秘密鍵もまとめて圧縮されている場合など   
# ***<span style="color:blue;">定期的に実行されているスクリプトの悪用</span>***
- root（または他の高権限のユーザ）で定期実行されるものを探す   
- cronjobの確認   
```
$ cat /etc/crontab
```   
- ツールを使ってプロセスを監視する   
```
$ ./pspy64
```   
- リアルタイムで実行出来るが他の列挙ができなくなる   
- ５分毎や10分毎に実行されいそうなコマンドに注目  
# ***<span style="color:blue;">カーネルエクスプロイト</span>***
- 最終手段   
	- ラボ環境は古いカーネルが使われていることが多い   
- カーネルのバージョンを調べる   
```
$ uname -r
```   
- ターゲットマシン上でコンパイル出来ないことも   
	- コンパイル済みバイナリを探す　or　環境を構築してコンパイル
# ***<span style="color:blue;">権限昇格列挙の流れ</span>***
１　リバースシェルを複数作成する    
　　効率を向上させるため(pspyを動作させつつ手動で列挙など）   
２　手動の列挙を行いつつlinpeasを動作させる    
　　sudo,suid,内部のみに公開されているポートなど    
３　自作したチェックリストに沿って確認する   
　　ラボを攻略しながら独自のものを作成    
４　実行しておいたlinpeasやpspyの出力を確認する