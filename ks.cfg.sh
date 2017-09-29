#!/bin/bash


# 复制 ks.cfg.sh 到 ks.cfg 时，应该使用编辑器，否则会有变化


####
quenong_rules()
{
local UDISK_VID="$1"
local UDISK_PID="$2"
local UDISK_SN="$3"

if [[ -z "$UDISK_VID" ]] || [[ -z "$UDISK_PID" ]] || [[ -z "$UDISK_SN" ]]; then
        continue 1
fi

cat >> /etc/udev/rules.d/51-quenong.rules <<-EOF
KERNEL=="sd*", ATTRS{idVendor}=="${UDISK_VID}", ATTRS{idProduct}=="${UDISK_PID}", ATTRS{serial}=="${UDISK_SN}", SYMLINK+="myudisk%n"
ACTION=="add", KERNEL=="sd?1", ATTRS{idVendor}=="${UDISK_VID}", ATTRS{idProduct}=="${UDISK_PID}", ATTRS{serial}=="${UDISK_SN}", RUN+="mymount"
ACTION=="remove", ENV{DEVNAME}=="/dev/sd?1", ENV{ID_VENDOR_ID}=="${UDISK_VID}", ENV{ID_MODEL_ID}=="${UDISK_PID}", ENV{ID_SERIAL_SHORT}=="${UDISK_SN}", RUN+="myumount"

EOF
}


####
mount_device()
{
local MOUNT_DIRECTORY="$1"
local MOUNT_DEVICE="$2"
local MOUNT_DIR=
local UNIT_NAME=

MOUNT_DIRECTORY=$(echo "$MOUNT_DIRECTORY" | sed "s/^\///g" | sed "s/\/$//g")

MOUNT_DIR="/${MOUNT_DIRECTORY}"
UNIT_NAME=$(echo "$MOUNT_DIRECTORY" | sed "s/\//\-/g")

if [[ -z "$MOUNT_DIR" ]] || [[ -z "$MOUNT_DEVICE" ]] || [[ -z "$UNIT_NAME" ]]; then
        continue 1
fi

cat > /etc/systemd/system/${UNIT_NAME}.mount <<-EOF
[Unit]
Description=${UNIT_NAME} directory

[Mount]
What=${MOUNT_DEVICE}
Where=${MOUNT_DIR}
Type=xfs

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/${UNIT_NAME}.automount <<-EOF
[Unit]
Description=${UNIT_NAME} directory

[Automount]
Where=${MOUNT_DIR}

[Install]
WantedBy=multi-user.target
EOF
}


######custom######
UDISK_VID="0951"
UDISK_PID="1666"
UDISK_SN="002618525DD4F070C8744960"

MOUNT_DIR="/backup"
MOUNT_DEVICE="/dev/el/backup"

ROOT_PASSWORD='123456'
ADMIN_PASSWORD='123456'


######custom######
quenong_rules "$UDISK_VID" "$UDISK_PID" "$UDISK_SN"

mount_device "$MOUNT_DIR" "$MOUNT_DEVICE"


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

                sleep 3
                . /usr/local/bin/.myexec
                
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
cat > /usr/local/bin/.myexec <<-"EOF"
#!/bin/bash

EOF


####
chmod 755 /usr/lib/udev/{"mymount","myumount"}


####
/usr/bin/cp -af /usr/lib/systemd/system/systemd-udevd.service /etc/systemd/system/systemd-udevd.service
sed -i "s/^MountFlags=slave$/MountFlags=shared/g" /etc/systemd/system/systemd-udevd.service


####
echo "${ROOT_PASSWORD}" | passwd --stdin root
echo "${ADMIN_PASSWORD}" | passwd --stdin admin


####
systemctl disable postfix.service
curl -sS https://gitee.com/quefei/quenong/raw/master/install.sh | bash
