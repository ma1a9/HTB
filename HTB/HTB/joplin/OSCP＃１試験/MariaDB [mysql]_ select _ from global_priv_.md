MariaDB [mysql]> select * from global_priv;
+-----------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Host      | User | Priv                                                                                                                                                                                                                                                                                                         |
+-----------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| localhost | root | {"access":18446744073709551615}                                                                                                                                                                                                                                                                              |
| %         | test | {"access":1073741823,"plugin":"mysql_native_password","authentication_string":"*742C65012CA4D4D0C4393047922B4D45EAF95E6B","password_last_changed":1639042939,"ssl_type":0,"ssl_cipher":"","x509_issuer":"","x509_subject":"","max_questions":0,"max_updates":0,"max_connections":0,"max_user_connections":0} |
| 127.0.0.1 | root | {"access":18446744073709551615}                                                                                                                                                                                                                                                                              |
| ::1       | root | {"access":18446744073709551615}                                                                                                                                                                                                                                                                              |
| localhost | pma  | {"access":0,"plugin":"mysql_native_password","authentication_string":"","password_last_changed":1571661132}                                                                                                                                                                                                  |
+-----------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
5 rows in set (0.186 sec)


21/tcp   open  ftp
3306/tcp open  mysql
3389/tcp open  ms-wbt-server
7680/tcp open  pando-pub
