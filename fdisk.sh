sudo apt clean
sudo apt autoremove --purge -y

sudo fdisk /dev/sda
    Command (m for help): n
# n, чтобы создать новый раздел (new partition).
Partition number (4-128, default 4): enter
First sector (12580864-16777182, default 12580864): enter
Last sector, +/-sectors or +/-size{K,M,G,T,P} (12580864-16777182, default 16777182): enter
Command (m for help): w     # После создания раздела, нужно записать изменения:

sudo partprobe          #  Обновить информацию о разделах
sudo pvcreate /dev/sda4 # Создать физический том LVM
sudo pvs                # Посмотреть текущие физические тома
sudo vgs                # Посмотреть информацию о группе томов
sudo vgextend ubuntu-vg /dev/sda4                   # Расширить группу томов новым физическим томом
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv #  Расширить логический том
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv             # Расширить файловую систему

# Проверить результат
df -h /






# Расширяем раздел 4 так как он последний
kate@vm1:~$ sudo pvs
  PV         VG        Fmt  Attr PSize  PFree
  /dev/sda3  ubuntu-vg lvm2 a--  <4.25g    0
  /dev/sda4  ubuntu-vg lvm2 a--  <2.00g    0

kate@vm1:~$ sudo parted /dev/sda unit s print free
Model: VMware, VMware Virtual S (scsi)
Disk /dev/sda: 20971520s
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start      End        Size      File system  Name  Flags
        34s        2047s      2014s     Free Space
 1      2048s      4095s      2048s                        bios_grub
 2      4096s      3674111s   3670016s  ext4
 3      3674112s   12580863s  8906752s
 4      12580864s  16777182s  4196319s
        16777183s  20971486s  4194304s  Free Space - !!!!

sudo apt update && sudo apt install cloud-guest-utils -y    # 1. Устанавливаем growpart 
sudo growpart /dev/sda 4        # 2. Расширяем раздел 4 на всё свободное место
sudo partprobe /dev/sda         # 3. Обновляем информацию о разделах в ядре
sudo parted /dev/sda unit s print free  # 4. Проверяем, что раздел увеличился
sudo pvresize /dev/sda4                 # 5. Расширяем физический том (PV) внутри раздела 4
sudo vgs                                # 6. Проверяем, что теперь есть свободное место в группе томов  VFree != 0
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv # 7. Расширяем логический том на всё свободное место
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv             # 8. Расширяем файловую систему (ext4)







