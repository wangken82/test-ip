#!/usr/bin/python

import subprocess
import time

ls = subprocess.check_output(['ls', '/dev/disk/azure/scsi1/'])
for i in ls.split():
  if "part" not in i:
    subprocess.call(['parted', '-s', '/dev/disk/azure/scsi1/' + i, 'mklabel', 'gpt', 'mkpart', 'primary', '0%', '100%'])
time.sleep(3)
vol = subprocess.check_output(['ls', '/dev/disk/azure/scsi1/'])
a = 1
for i in vol.split():
  if "part" in i:
    subprocess.check_output(['pvcreate', '/dev/disk/azure/scsi1/' + i,])
    subprocess.check_output(['vgcreate', 'vg-NW' + str(a) + '-NFS', '/dev/disk/azure/scsi1/' + i,])
    subprocess.check_output(['lvcreate', '-l', '100%FREE', '-n', 'NW' + str(a), 'vg-NW' + str(a) + '-NFS'])
    a += 1
g = open("/etc/delete.to.retry.nfs.lvm.config.py", "w")
g.close()