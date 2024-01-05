Watsonを使って、潜在的な脆弱性/悪用がないかチェックします。

## .NET バージョンを取得する

まず、ターゲットにインストールされている .NET バージョンを調べる必要があります。
### レジストリクエリでそれを行うことができます：

```shell
c:\Users>reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP" reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP" HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v2.0.50727 HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.0 HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5
```


### \\Windows\\Microsoft.NET\\Framework
```shell
c:\Windows\Microsoft.NET\Framework>dir /A:D
dir /A:D 
Volume in drive C has no label. 
Volume Serial Number is 8620-71F1 
Directory of c:\Windows\Microsoft.NET\Framework 
14/07/2009 06:52 <DIR> . 
14/07/2009 06:52 <DIR> .. 
14/07/2009 04:37 <DIR> v1.0.3705 
14/07/2009 04:37 <DIR> v1.1.4322 
18/03/2017 01:06 <DIR> v2.0.50727 
14/07/2009 06:56 <DIR> v3.0 
14/07/2009 06:52 <DIR> v3.5 
							0 File(s) 0 bytes 
				7 Dir(s) 24.586.067.968 bytes free
```

[Watson](https://github.com/rasta-mouse/Watson) は、ローカルの privesc 脆弱性に対して不足しているソフトウェア パッチを迅速に特定するツールの C# 実装です。 GitHub ページから zip をダウンロードし、Windows VM で Watson.sln をダブルクリックして Visual Studio で開きます。

Visual Studio メニューに移動し、\[プロジェクト] -> \[Watson プロパティ] を開きます。 左側のメニューで「アプリケーション」が選択されていることを確認すると、「ターゲット フレームワーク」を設定できるようになります。

![[images/20230527204751.png]]

ターゲットにインストールされている最新版なので、3.5に設定することにします。

次に、Build -> Configuration Managerに進みます。ここで出力バイナリのアーキテクチャ（x86とx64）を設定します。systeminfoの出力から、x64プロセッサであることは覚えているが、OSはx86である：
プラットフォームを x86 に変更します。

![[images/20230527205250.png]]
では、「Build」→「Build Watson」と進みます。下のWindowに、こう表示されているはずです：

![[images/20230527205412.png]]
そのパスに移動して、出力 exe のコピーを取得し、それを Kali ボックスに転送して smb フォルダーにドロップします。