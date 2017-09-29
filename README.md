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

--- 例如：

    #
    UDISK_VID="0951"
    UDISK_PID="1666"
    UDISK_SN="002618525DD4F070C8744960"
    
    MOUNT_DIR="/backup"
    MOUNT_DEVICE="/dev/el/backup"
    
    quenong_rules "$UDISK_VID" "$UDISK_PID" "$UDISK_SN"
    
    mount_device "$MOUNT_DIR" "$MOUNT_DEVICE"
    
    123

















  [1]: https://github.com/quefei/myudisk#%E9%87%8D%E8%A6%81%E8%AF%B4%E6%98%8E
  [2]: https://github.com/quefei/myudisk#%E5%88%B6%E4%BD%9C-myudisk
  [3]: https://github.com/quefei/myudisk#%E6%89%8B%E5%8A%A8%E5%AE%89%E8%A3%85-centos-74-x86_64
  [4]: https://github.com/quefei/myudiskplus#%E8%87%AA%E5%8A%A8%E5%AE%89%E8%A3%85-centos-74-x86_64
  [5]: https://gitee.com/quefei/myudiskplus/repository/archive/master