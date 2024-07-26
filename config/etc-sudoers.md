
- 添加只要在同相的终端下，一定时间内就只需要输入一次密码

- 在 sudo visudo

```shell
Defaults	use_pty
# 在这里添加
Defaults	!tty_tickets

```

