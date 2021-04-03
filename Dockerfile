FROM tomcat:7
MAINTAINER CISTOAWSCOE@cognizant.com
RUN apt-get update
RUN apt-get update && apt-get install default-jdk git python3-pip maven -y
RUN pip3 install awscli --upgrade
#RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
ADD https://archive.apache.org/dist/tomcat/tomcat-7/v7.0.96/bin/apache-tomcat-7.0.96.tar.gz /tmp/
ADD https://petclinicwarfiles.s3.amazonaws.com/openmrs-3tireapp12/OpenMRS3_1.tar.gz /tmp
ADD https://petclinicwarfiles.s3.amazonaws.com/openmrs-3tireapp12/awsopenmrs.zip /tmp/
ADD https://petclinicwarfiles.s3.amazonaws.com/openmrs-3tireapp12/awsprofile.tar /tmp/
RUN /bin/tar -xvzf /tmp/OpenMRS3_1.tar.gz -C /root
RUN /bin/tar -xvf /tmp/awsprofile.tar -C /root
RUN /bin/sed -i "s/logindemodb.c0fjlxlrwls9.us-east-1.rds.amazonaws.com/openmrsdb.cvxpfcgrnnre.us-east-1.rds.amazonaws.com/g" /root/.OpenMRS/openmrs-runtime.properties
RUN rm -f /root/.OpenMRS/modules/legacyui-1.6.0-SNAPSHOT.omod
RUN export AWS_DEFAULT_PROFILE=default
RUN /bin/tar -xvzf /tmp/apache-tomcat-7.0.96.tar.gz -C /usr/local/
RUN /bin/mkdir /root/awscoe
RUN git config --system credential.https://git-codecommit.us-east-1.amazonaws.com.helper '!aws --profile default codecommit credential-helper $@'
RUN git config --system credential.https://git-codecommit.us-east-1.amazonaws.com.UseHttpPath true
RUN git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/OpenMRS-original /root/awscoe
RUN /usr/bin/mvn -f /root/awscoe/openmrs-core/pom.xml clean install -Dmaven.test.skip=true
RUN sleep 5
RUN cp /root/awscoe/openmrs-core/webapp/target/openmrs.war /usr/local/apache-tomcat-7.0.96/webapps/
RUN sleep 5
RUN cd /root/awscoe/openmrs-module-legacyui/ && mvn clean install -Dmaven.test.skip=true; cd -
RUN sleep 5
RUN cp /root/awscoe/openmrs-module-legacyui/omod/target/legacyui-1.6.0-SNAPSHOT.omod /root/.OpenMRS/modules/
RUN sleep 5
RUN /usr/local/apache-tomcat-7.0.96/bin/catalina.sh start
