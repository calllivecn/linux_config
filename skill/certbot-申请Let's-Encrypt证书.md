## 更详细的安装可参考官方文档：https://certbot.eff.org/

### 申请通配符证书
客户在申请 Let’s Encrypt 证书的时候，需要校验域名的所有权，证明操作者有权利为该域名申请证书，目前支持三种验证方式：

- dns-01：给域名添加一个 DNS TXT 记录。

- http-01：在域名对应的 Web 服务器下放置一个 HTTP well-known URL 资源文件。

- tls-sni-01：在域名对应的 Web 服务器下放置一个 HTTPS well-known URL 资源文件。


### 使用 Certbot 客户端申请证书方法非常的简单，只需如下一行命令就搞定了。

```shell
$ ./certbot-auto certonly  -d "*.xxx.com" --manual --preferred-challenges dns-01  --server https://acme-v02.api.letsencrypt.org/directory
```

1. 申请通配符证书，只能使用 dns-01 的方式。

2. xxx.com 请根据自己的域名自行更改。

### 相关参数说明：

certonly 表示插件，Certbot 有很多插件。不同的插件都可以申请证书，用户可以根据需要自行选择。
-d 为哪些主机申请证书。如果是通配符，输入 *.xxx.com (根据实际情况替换为你自己的域名)。
--preferred-challenges dns-01，使用 DNS 方式校验域名所有权。
--server，Let's Encrypt ACME v2 版本使用的服务器不同于 v1 版本，需要显示指定。


#### 执行完这一步之后，就是命令行的输出，请根据提示输入相应内容：

```shell
zx@hthl:~$ certbot certonly --config-dir .certbot/ --work-dir .certbot/ --logs-dir .certbot/ --manual --preferred-challenges dns-01 -d www.calllive.cc                                                          
Saving debug log to /home/zx/.certbot/letsencrypt.log                                                                                                                                                              
Plugins selected: Authenticator manual, Installer None                                                                                                                                                             
Enter email address (used for urgent renewal and security notices) (Enter 'c' to                                                                                                                                   
cancel): ******@qq.com                                                                                                  
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -          
Please read the Terms of Service at                                                      
https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf. You must              
agree in order to register with the ACME server at                                       
https://acme-v02.api.letsencrypt.org/directory                                           
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -          
(A)gree/(C)ancel: a 
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing to share your email address with the Electronic Frontier
Foundation, a founding partner of the Let's Encrypt project and the non-profit
organization that develops Certbot? We'd like to send you email about our work
encrypting the web, EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: y
Obtaining a new certificate
Performing the following challenges:
dns-01 challenge for www.calllive.cc

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
NOTE: The IP of this machine will be publicly logged as having requested this
certificate. If you're running certbot in manual mode on a machine that is not
your server, please ensure you're okay with that.

Are you OK with your IP being logged?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: y

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please deploy a DNS TXT record under the name
_acme-challenge.www.calllive.cc with the following value:

b9IlhrjstjmZ_GfOmOwUTK3iWzAIaFDitJe8nGE41KA

Before continuing, verify the record is deployed.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Press Enter to Continue

Waiting for verification...  # 请添加 _acme-challenge.www.calllive.cc 域名的 TXT 记录后回车。

Cleaning up challenges
Non-standard path(s), might not work with crontab installed by your operating system package manager

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /home/zx/.certbot/live/www.calllive.cc/fullchain.pem
   Your key file has been saved at:
   /home/zx/.certbot/live/www.calllive.cc/privkey.pem
   Your cert will expire on 2020-02-16. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
 - Your account credentials have been saved in your Certbot
   configuration directory at /home/zx/.certbot. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le


```
