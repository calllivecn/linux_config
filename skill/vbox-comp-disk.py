#!/usr/bin/env python3
# coding=utf-8
# date 2024-02-02 08:41:38
# author calllivecn <calllivecn@outlook.com>


import os

os.chdir("""c:\\""")


BUF = bytes((1<<20))


try:
    with open("empty", "wb") as f:
        f.seek(0, os.SEEK_END)
        c = 0
        while True:
            f.write(BUF)
            f.flush()
            c += 1
            print("已写入{}M".format(c))

except OSError:
    print("磁盘已满。")
    #os.remove("empty")





