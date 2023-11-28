```
wmic.exe PROCESS get Caption,Commandline,Processid
```

実行中のサービス名、表示名、パス名、開始モードの表示
```
wmic service get name,displayname,pathname,startmode
```
特定の単語を検索する場合はwmicコマンドをfindstrにパイプで渡す。/iで大文字小文字を区別しない
```
wmic service get name,displayname,pathname,startmode | findstr /i "auto"
```
/vで指定した文字列を無視できる
```
wmic service get name,displayname,pathname,startmode |findstr /i "auto" |findstr /i /v "c:\windows"
```
