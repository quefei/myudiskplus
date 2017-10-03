# Quenong Myudisk+

内容目录：

 - [重要说明（参照 Myudisk）][1]
 - [制作 Myudisk（参照 Myudisk）][2]
 - [手动安装 CentOS-7.4-x86_64（参照 Myudisk）][3]
 - [自动安装 CentOS-7.4-x86_64][4]

## 自动安装 CentOS-7.4-x86_64

**1.1 下载 Myudisk+：**

下载 [Myudisk+][5]，将 `QUENONG` 目录下的所有文件拷贝到U盘的 `根目录` 并替换。

**1.2 配置 ks.cfg：**

打开U盘里的 `ks.cfg` 文件，搜索 ######custom######，然后：

 - 修改 IP `192.168.1.5`，网关 `192.168.1.1`
 - 设置系统用户 root 与 admin 的登录密码，`ROOT_PASSWORD='密码'`，`ADMIN_PASSWORD='密码'`
 - 设置你将要使用的U盘与硬盘的相关信息

例如：（[金士顿U盘][6]）

    # 1 - 第一个U盘的信息
    
    UDISK_VID="0951"                                        # VID/供应商ID：代表 金士顿
    UDISK_PID="1666"                                        # PID/产品ID：  代表 DataTraveler 100 G3
    UDISK_SN="102618525DD4F070C8744960"                     # SN/序列号：   U盘不同 序列号不同
    
    
    # 2 - 第一块硬盘的信息
    # 代表 将硬盘的逻辑卷 /dev/el/backup 挂载到 /backup 目录
    
    MOUNT_DIR="/backup"                                     # 挂载的目录
    MOUNT_DEVICE="/dev/el/backup"                           # 挂载的硬盘分区
    
    
    # 3 - 增加多个U盘
    
    quenong_rules "$UDISK_VID" "$UDISK_PID" "$UDISK_SN"     #
    
    quenong_rules "0951" "1666" "202618525DD4F070C8744960"  # 增加第二个U盘
    
    
    # 4 - 增加多块硬盘
    
    mount_device "$MOUNT_DIR" "$MOUNT_DEVICE"               #
    
    mount_device "/usr/local/data" "/dev/sdc1"              # 增加第二块硬盘    挂载第一个分区
    
    # 之后，你将给系统安装三块硬盘，一块用来安装系统，又额外增加了二块

**1.3 开始安装：**

 - 开机从U盘启动
 - 依次执行：

    \[10] 启动自定义ISO/IMG文件（LMT目录）
    
    [02] 自动搜索并列出LMT目录下所有文件
    
    [03] RUN CentOS-7-x86_64-NetInstall-1708.iso
    
    Install CentOS 7

 - 安装完成后自动关机
 - 增加硬盘后开机

**1.4 挂载硬盘：**

 - 如果硬盘已经分区，并且格式化为 `xfs`
 - 就可以直接挂载硬盘

例如：

    systemctl start   backup.mount
    systemctl stop    backup.mount
    
    systemctl restart backup.mount
    systemctl status  backup.mount
    
    systemctl enable  backup.mount
    systemctl disable backup.mount

 - 也可以自动挂载硬盘

例如：

    systemctl stop    backup.mount
    systemctl disable backup.mount
    
    
    systemctl start   backup.automount
    systemctl stop    backup.automount
    
    systemctl restart backup.automount
    systemctl status  backup.automount
    
    systemctl enable  backup.automount
    systemctl disable backup.automount

**1.5 挂载U盘：**

如果U盘的文件系统为 `vfat`，可以开启自动挂载U盘的功能：

 - U盘的卷标为 `QUENONG` 或者 `其他名称`：关闭自动挂载U盘的功能
 - U盘的卷标为 `QUENONG2017`：2017年，全年开启自动挂载U盘的功能
 - U盘的卷标为 `QUENONG1001`：10月01日，当天开启自动挂载U盘的功能（注意：`系统时间是否正确`）

拔出U盘后，当挂载目录 `/mnt/卷标名称` 空闲时，将自动卸载U盘，并删除挂载目录。

1.6













  [1]: https://github.com/quefei/myudisk#%E9%87%8D%E8%A6%81%E8%AF%B4%E6%98%8E
  [2]: https://github.com/quefei/myudisk#%E5%88%B6%E4%BD%9C-myudisk
  [3]: https://github.com/quefei/myudisk#%E6%89%8B%E5%8A%A8%E5%AE%89%E8%A3%85-centos-74-x86_64
  [4]: https://github.com/quefei/myudiskplus#%E8%87%AA%E5%8A%A8%E5%AE%89%E8%A3%85-centos-74-x86_64
  [5]: https://gitee.com/quefei/myudiskplus/repository/archive/master
  [6]: http://www.kingston.com/cn/usb/personal_business/dt100g3