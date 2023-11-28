# evil-winrm
## Windows リモート管理 (WinRM) シェル
ヘルプ  
使用法: Evil-winrm  -i  IP  -u  USER [-s SCRIPTS_PATH] [-e EXES_PATH] [-P PORT] [-p PASS] [-H HASH] [ -U URL] [-S] [-c PUBLIC_KEY_PATH] [-k PRIVATE_KEY_PATH] [-r REALM] [--spn SPN_PREFIX]    
    ***-S,  --ssl***                        &emsp; ssl を有効にする   
    ***-c,  --pub-key  PUBLIC_KEY_PATH*** &emsp;パブリックへのローカル パスkey certificate    
    ***-k,  --priv-key  PRIVATE_KEY_PATH*** &emsp;秘密鍵証明書へのローカル パス   
    ***-r,  --realm  DOMAIN*** &emsp;Kerberos 認証、この形式を使用して /etc/krb5.conf ファイルにも設定する必要があります ->  CONTOSO.COM = { kdc = fooserver.contoso.com }    
    ***-s,  --scripts PS_SCRIPTS_PATH***  &emsp; Powershellスクリプト ローカル パス    
       ***--spn  SPN_PREFIX*** &emsp;Kerberos 認証用の SPN プレフィックス (既定の HTTP)    
    ***-e,  --executables***  EXES_PATH &emsp;C# 実行可能ファイル ローカル パス    
    ***-i,  --ip  IP*** &emsp;リモート ホストの IP またはホスト名。Kerberos 認証の FQDN (必須)    
    ***-U,  --url***  &emsp;URL リモート URL エンドポイント (デフォルト /wsman)    
    ***-u,  --user***  &emsp;USER ユーザー名 (Kerberos を使用しない場合は必須)    
    ***-p,  --password***  &emsp;PASS パスワード    
    ***-H,  --hash HASH*** &emsp;NTHash    
    ***-P,  --port PORT*** &emsp;リモート ホスト ポート (デフォルトは 5985)    
    ***-V,  --version***                   &emsp; バージョンを表示     
    ***-n,  --no-colors*** &emsp;色を無効 にする  
    ***-h,  --help***                       &emsp;このヘルプ メッセージを表示する    
```
#ホストに接続する
$ Evil-winrm --ip [ip] --user [ユーザー] --password [パスワード]
```
```
#ホストに接続し、パスワード ハッシュを渡します
$ Evil-winrm --ip [ip] --user [ユーザー] --hash [nt_hash]
```
```
#スクリプトと実行可能ファイルのディレクトリを指定して、ホストに接続します
$ Evil-winrm --ip [ip] --user [ユーザー] --password [パスワード] --scripts [path/to/scripts] --executables [path/to/executables]
```
```
#SSLを使用してホストに接続する
$ Evil-winrm --ip [ip] --user [ユーザー] --password [パスワード] --ssl --pub-key [path/to/pubkey] --priv-key [path/to/privkey]
#ホストにファイルをアップロードする
$ PS > upload [path/to/local/file] [path/to/remote/file]
#読み込まれた PowerShell 関数のリストを取得する
$ PS > menu
--scripts ディレクトリから PowerShell スクリプトをロードします。
$ PS > [script.ps1]
--executables ディレクトリからホスト上のバイナリを呼び出します
$ PS > Invoke-Binary [binary.exe]
```
```
#ホストからファイルをダウンロード
$ PS > download [path/to/remote/file][path/to/local/file]
```
```
#service一覧取得
$ PS > services
```
