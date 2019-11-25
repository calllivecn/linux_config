## 使用mergerFS 

- 安装： apt install mergerfs

- 挂载： mount.fuse  /dir1:/dir2:/dir3 /mnt/mergerfs/ -t mergerfs -o defaults,allow_other,noauto,use_ino,minfreespace=4G

## 前三行是三块存储盘的普通挂载，第四行是 mergerfs 的条目，它的挂载源是前三块盘的的挂载点，用冒号分隔。最后一列的参数说明：

- defaults: 开启以下 FUSE 参数以提升性能：atomic_o_trunc, auto_cache, big_writes, default_permissions, splice_move, splice_read, splice_write；

- noauto: 禁止开机自动挂载。意外关机重启之后我可能需要手动检查文件系统后再挂载，所以我不希望它自动挂载；

- allow_other: 允许挂载者以外的用户访问 FUSE。你可能需要编辑 /etc/fuse.conf 来允许这一选项；

- use_ino: 使用 mergerfs 而不是 libfuse 提供的 inode，使硬链接的文件 inode 一致；

- minfreespace=100G: 选择往哪个下层文件系统写文件时，跳过剩余空间低于 100G 的文件系统；

- ignorepponrename=true: 重命名文件时，不再遵守路径保留原则，见下一节详解。


## 使用 systemd.mount: (下面的内容不能直接使用，如果不知道 systemd.mount 的含义，不要使用。可以和先看看systemd.mount的用法。)

```shell
$ vim /etc/systemd/system/mnt-mergerfs.mount

[Unit]
Description=mount.fuse /dir1:/dir2:dir3 /mnt/mergerfs -t mergerfs
After=-.mount home.mount
Requires=-.mount home.mount

[Mount]
What=/dir1:/dir2:/dir3
Where=/mnt/mergerfs
Type=fuse.mergerfs
Options=defaults,allow_other,noauto,use_ino,minfreespace=4G

[Install]
WantedBy=multi-user.target

```


## mergerfs 的读写策略:

#### 如果多块硬盘里同名的目录或文件，从哪儿读？往哪儿写？如果多块硬盘都有足够的剩余空间，在哪块硬盘创建新文件？mergerfs 对 FUSE 的不同操作有着不同的读写策略。默认的策略是：

- action 类别：对于 chmod, chown 等改变文件或目录属性的操作，mergerfs 检索所有下层文件系统，确保所有文件或目录都得到更改；

- search 类别：对于 open, getattr 等读取文件或目录的操作，mergerfs 按挂载源列表的顺序检索下层文件系统，返回第一个找到结果；

- create 类别：对于 create, mkdir 等创建文件或目录的操作，mergerfs 优先选择相对路径已经存在的下层文件系统中剩余空间最大的那个作为写入目标。

#### 前两条很好理解，最后一条比较拗口。举例来说是这样：

- disk1 剩余 100 GiB 空间，有 /dir1 目录；

- disk2 剩余 200 GiB 空间，有 /dir2 目录；

- disk3 剩余 300 GiB 空间，有 /dir3 目录；

- mergerfs 将这三块硬盘的文件系统合并成一个，可以同时看到 /dir1, /dir2, /dir3 三个目录。

这时在 mergerfs 对于上层文件系统写入一个 150 GiB 的文件到 /dir2/foo.bin 位置，按照默认的策略，mergerfs 会选择 disk2 写入。因为：disk1 剩余空间不足（小于 minfreespace 或是只读文件系统也会被跳过选择），而虽然 disk3 比 disk2 剩余空间更多，但因为 disk2 已经有 /dir2 目录了，所以 mergerfs 会优先选择写入 disk2 而不是 disk3。

这个策略的意义在于，当下层文件系统的剩余空间差不多时，你的文件不会被分散开。比如你正在将你的相机图片文件夹复制到 mergerfs 里，一个文件夹里有 999 张图片，第一张图片的落点也将决定接下来 998 张文件的落点，而不会因为下层文件系统剩余空间的交替变化而一会儿落到这个文件系统，一会儿落到那个文件系统。最终下层文件系统会被平衡地使用，但相同目录的文件会尽可能地在同一个文件系统里，这非常棒。

但这个策略一直有一个痛点让我难受了很久：移动文件。比如 2016 年份的文件位于 disk1，而 2017 年份的文件因为 disk1 已经满了写到 disk2 来了，在 2018 年的时候我想把三年的文件都归到一个新目录里。此时 2016 年的文件可以瞬间完成，2017 年的文件则由于上述策略会优先选择 disk1，于是就从瞬间完成变成了缓慢的跨盘移动，当这些文件数量巨大的时候，已经开始的传输我又不敢贸然中止……这样的坑我在整理文件时掉过很多次。终于，mergerfs 2.23.0 版本新增了 ignorepponrename 选项，使得在重命名文件的时候，忽略路径保留规则，避免了简单的文件整理操作变成痛苦的跨盘移动的悲剧。

如果 mergerfs 的默认读写策略不适用于你的应用场景，可以通过挂载参数选用别的策略。