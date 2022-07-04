#!/usr/bin/python

import subprocess

lsscsi = subprocess.Popen(['lsscsi'], stdout=subprocess.PIPE,)
grep = subprocess.Popen(['grep', 'nfs'], stdin=lsscsi.stdout, stdout=subprocess.PIPE,)
a = []
c = []
for i in grep.stdout:
  a.append(i[-5:-2])
for i in a:
  ls = subprocess.Popen(['ls -l /dev/disk/by-id/scsi-*'], shell=True, stdout=subprocess.PIPE,)
  grep = subprocess.Popen(['grep', i], stdin=ls.stdout, stdout=subprocess.PIPE,)
  grep2 = subprocess.Popen(['grep', 'scsi-3'], stdin=grep.stdout, stdout=subprocess.PIPE,)
  for b in grep2.stdout:
    subprocess.call(['sudo', 'sbd', '-d', b[-68:-14], '-1', '60', '-4', '120', 'create'])
  c.append(b[-68:-14])
e = open("/tmp/sbd", "a")
f = open("/etc/sysconfig/sbd", "r")
for i in (f.read().splitlines()):
  if "SBD_DEVICE=" in i:
    e.write("SBD_DEVICE=" + "\"" + ";".join(c) + "\"" + "\n")
  else:
    e.write(i + "\n")
e.close()
f.close()
subprocess.call(['cp', '/tmp/sbd', '/etc/sysconfig/sbd'])
subprocess.call(['rm', '/tmp/sbd'])
g = open("/etc/delete.to.retry.nfs.sbd.config.py", "w")
g.close()