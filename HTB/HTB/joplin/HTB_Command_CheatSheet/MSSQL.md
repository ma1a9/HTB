現在のユーザーの権限を確認
```
SQL> SELECT * FROM fn_my_permissions(NULL, 'SERVER');
```
利用可能なデータベースの確認
```
SQL> SELECT name FROM master.sys.databases
```
ユーザーが作成したテーブルを探す
```
SQL> use volume
SQL> SELECT name FROM sysobjects WHERE xtype = 'U'
```
