export EC2_URL=https://ec2.eu-west-1.amazonaws.com
export EC2_AMITOOL_HOME=/opt/aws/amitools/ec2
export EC2_HOME=/opt/aws/apitools/ec2
export JAVA_HOME=/usr/lib/jvm/jre
export PATH=/usr/local/bin:/bin:/usr/bin:/opt/aws/bin:/home/ec2-user/bin

for VOLUME in `/opt/aws/bin/ec2-describe-volumes | grep ATTACHMENT | cut -f2` 
do
      echo "Creating snapshot for volume: $VOLUME"
          python /home/ec2-user/scripts/snapback.py -p /home/ec2-user/scripts/snapback -w 4 -d 7 $VOLUME
        done
done
