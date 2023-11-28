- PleaseSubscribe!とhashcatのルールでパスワードリストを作成する
```command
vi pw
>>>>>PleaseSubscribe!(pwファイルに単語を登録しておく)
```

```command
hashcat --stdout pw -r /usr/share/hachcat/rules/best64.rule > pwlist
```

- hashcatのモード一覧を表示させる
```command
hashcat --example-hashes | less
```

- モード3200を踏まえてhashcatを実行してみる
```command
hashcat -m 3200 hash.txt pw -r /usr/share/hashcat/rules/abset64.rule
```
```command
※既にクラックしたファイルを再度クラックする時は以下のコマンドを実行する
rm ~/.hashcat/hachcat.potfile
```

再実行する場合
```
rm /home/kali/.local/share/hashcat/hashcat.potfile
```
上記のファイルを削除

パスワードリスト作成
![af6a51cb8cecff1bc2f341171da9966d.png](../_resources/af6a51cb8cecff1bc2f341171da9966d.png)