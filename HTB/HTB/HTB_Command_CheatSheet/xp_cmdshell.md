```shell

-- アドバンストオプションを変更できるようにする。 
EXEC sp_configure 'show advanced options', 1
EXEC sp_configure 'xp_cmdshell', 1
-- この機能に対して現在設定されている値を更新する。 
RECONFIGURE
go
EXEC sp_configure 'xp_cmdshell', 1
RECONFIGURE
go
```
![[Pasted image 20230404215233.png]]