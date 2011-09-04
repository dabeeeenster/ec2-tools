#! /bin/bash

ADMIN="<Alert Email Address>"
ALERT=80

export EC2_PRIVATE_KEY=/home/ec2-user/.ssh/pk.pem
export EC2_CERT=/home/ec2-user/.ssh/cert.pem
export EC2_URL=https://ec2.eu-west-1.amazonaws.com
export EC2_AMITOOL_HOME=/opt/aws/amitools/ec2
export EC2_HOME=/opt/aws/apitools/ec2
export JAVA_HOME=/usr/lib/jvm/jre
export PATH=/usr/local/bin:/bin:/usr/bin:/opt/aws/bin:/home/ec2-user/bin

ec2-describe-instances | egrep ^INSTANCE | cut -f5 > /home/ec2-user/scripts/servers-diskspace.txt

for SERVER in `cat ~/scripts/servers-diskspace.txt`
do
    ssh -i ~/.ssh/key.pem -oStrictHostKeyChecking=no -oConnectTimeout=5 $SERVER df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
    do
      echo $SERVER $output
      usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
      partition=$(echo $output | awk '{ print $2 }' )
      if [ $usep -ge $ALERT ]; then
        echo "Running out of space \"$partition ($usep%)\" on $SERVER as on $(date)" | 
         mail -s "Alert: Almost out of disk space $usep" -r $ADMIN $ADMIN
      fi
    done
done
