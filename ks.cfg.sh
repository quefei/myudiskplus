#!/bin/bash


####
quenong_rules()
{
cat >> /etc/udev/rules.d/51-quenong.rules <<-EOF
KERNEL=="sd*", ATTRS{idVendor}=="${1}", ATTRS{idProduct}=="${2}", ATTRS{serial}=="${3}", SYMLINK+="myudisk%n"
ACTION=="add", KERNEL=="sd?1", ATTRS{idVendor}=="${1}", ATTRS{idProduct}=="${2}", ATTRS{serial}=="${3}", RUN+="mymount"
ACTION=="remove", ENV{DEVNAME}=="/dev/sd?1", ENV{ID_VENDOR_ID}=="${1}", ENV{ID_MODEL_ID}=="${2}", ENV{ID_SERIAL_SHORT}=="${3}", RUN+="myumount"

EOF
}


######custom######
UDISK_VID="0951"
UDISK_PID="1666"
UDISK_SN="002618525DD4F070C8744960"

MOUNT_DEVICE="/dev/el/backup"
MOUNT_DIR="/backup"

ROOT_PASSWORD='quenong'
ADMIN_PASSWORD='quenong'


######custom######
quenong_rules "$UDISK_VID" "$UDISK_PID" "$UDISK_SN"


####
MOUNT_DIR=$(echo "$MOUNT_DIR" | sed "s/^\///g")


####
cat > /usr/lib/udev/mymount <<-"EOF"
#!/bin/bash

MYUDISK_TYPE="vfat"
MYUDISK_LABEL1="QUENONG$(date +"%Y")"
MYUDISK_LABEL2="QUENONG$(date +"%m%d")"

if [[ "$MYUDISK_TYPE" == "$ID_FS_TYPE" ]]; then
        if [[ "$MYUDISK_LABEL1" == "$ID_FS_LABEL" ]] || [[ "$MYUDISK_LABEL2" == "$ID_FS_LABEL" ]]; then
                
                mkdir -p /mnt/${ID_FS_LABEL}
                mount -t ${ID_FS_TYPE} ${DEVNAME} /mnt/${ID_FS_LABEL}
                
        fi
fi
EOF


####
cat > /usr/lib/udev/myumount <<-"EOF"
#!/bin/bash

MYUDISK_LABEL1="QUENONG$(date +"%Y")"
MYUDISK_LABEL2="QUENONG$(date +"%m%d")"
MYUDISK_LABEL3="QUENONG$(date +"%m%d" -d "-1day")"

if [[ "$MYUDISK_LABEL1" == "$ID_FS_LABEL" ]] || [[ "$MYUDISK_LABEL2" == "$ID_FS_LABEL" ]] || [[ "$MYUDISK_LABEL3" == "$ID_FS_LABEL" ]]; then
        
        umount -l /mnt/${ID_FS_LABEL}
        rm -rf /mnt/${ID_FS_LABEL}
        
fi
EOF


####
chmod 755 /usr/lib/udev/{"mymount","myumount"}


####
/usr/bin/cp -af /usr/lib/systemd/system/systemd-udevd.service /etc/systemd/system/systemd-udevd.service
sed -i "s/^MountFlags=slave$/MountFlags=shared/g" /etc/systemd/system/systemd-udevd.service


####
cat > /etc/systemd/system/${MOUNT_DIR}.mount <<-EOF
[Unit]
Description=${MOUNT_DIR} directory

[Mount]
What=${MOUNT_DEVICE}
Where=/${MOUNT_DIR}
Type=xfs

[Install]
WantedBy=multi-user.target
EOF


####
cat > /etc/systemd/system/${MOUNT_DIR}.automount <<-EOF
[Unit]
Description=${MOUNT_DIR} directory

[Automount]
Where=/${MOUNT_DIR}

[Install]
WantedBy=multi-user.target
EOF


####
echo "${ROOT_PASSWORD}" | passwd --stdin root
echo "${ADMIN_PASSWORD}" | passwd --stdin admin


####
systemctl disable postfix.service
curl -sS https://gitee.com/quefei/quenong/raw/master/install.sh | bash
