#!/bin/bash




EntryPoint()
{
# Default Variables
blank=""
gwVersionDefault="2.35.0"
gwPortDefault="9001"
gwModeDefault="encrypt-everything"
gwTopologyDefault="outbound"
gwCksDefault="2"
gwInboundRelayDefault=""
gwFqdnDefault="gw.example.com"
gwDomainDefault="example.com"
gwDkimSelectorDefault="gw"
gwOutboundRelayDefault=""
gwAmplitudeTokenDefault="0000000000"
gwHmacNameDefault="0000000000"
gwHmacSecretDefault="0000000000"
gwDefaultFips="2"







# Final Variables
gwName=""
gwVersion=""
gwPort=""
gwMode=""
gwTopology=""
gwInboundRelay=""
gwCks=""
gwCksKey=""
gwFqdn=""
gwDkimSelector=""
gwOutboundRelay=""
gwAmplitudeToken=""
gwHmacName=""
gwHmacSecret=""
gwType=""
gwSmtpdTlsCompliance=""
gwSmtpdSecurityLevel=""
gwSmtpTlsCompliance=""
gwSmtpSecurityLevel=""









# Working Variables
tlsPath=""
tlsKeyFile=""
tlsKeyFull=""
tlsPemFile=""
tlsPemFull=""
dkimPath=""
dkimPrivateFull=""
dkimPublicFull=""
scriptFile=""








# Actions
ShowLogo
GetGwVersion $gwVersionDefault
GetGwPort $gwPortDefault
GetGwMode $gwModeDefault
GetGwTopology $gwTopologyDefault
GetGwFips $gwDefaultFips
GetGwName
GetGwInboundRelay $gwInboundRelayDefault
GetGwCks $gwCksDefault
GetGwFqdn $gwFqdnDefault
GetGwDomain $gwDomainDefault
GetGwDkimSelector $gwDkimSelectorDefault
GetGwOutboundRelay $gwOutboundRelayDefault
GetGwAmplitudeToken $gwAmplitudeTokenDefault
GetGwHmacName $gwHmacNameDefault
GetGwHmacSecret $gwHmacSecretDefault








MakeTlsPathVariables
MakeDkimPathVariables
MakeDirectories
MakeTlsCert
MakeDkimCert
WriteEnv
WriteScript
WriteTestScripts
clear
ShowLogo
ShowNextSteps




}












## Functions
GetGwName() {
 if [ $gwTopology = "outbound" ]
 then
   if [ $gwMode = "encrypt-everything" ]
   then
     gwName="oe-$gwPort"
   fi
   if [ $gwMode = "decrypt-everything" ]
   then
     gwName="od-$gwPort"
   fi
   if [ $gwMode = "dlp" ]
   then
     gwName="dlp-out-$gwPort"
   fi
 else
   if [ $gwMode = "encrypt-everything" ]
   then
     gwName="ie-$gwPort"
   fi
   if [ $gwMode = "decrypt-everything" ]
   then
     gwName="id-$gwPort"
   fi
   if [ $gwMode = "dlp" ]
   then
     gwName="dlp-in-$gwPort"
   fi
 fi


}




GetGwVersion() {
 local input=""
 read -p "Gateway Version [$1]: " input




 case "$input" in
   $blank )
     gwVersion=$1
   ;;
   * )
     gwVersion=$input
   ;;
 esac
 echo " "
}




GetGwPort() {
local input=""
 read -p "Gateway Port [$1]: " input




 case "$input" in
   $blank )
     gwPort=$1
   ;;
   * )
     gwPort=$input
   ;;
 esac
 echo " "
}




GetGwMode() {
 local input=""
 echo "Gateway Mode"
 echo "  Options"
 echo "  1 - encrypt-everything"
 echo "  2 - decrypt-everything"
 echo "  3 - dlp"
 echo " "
 read -p "Enter 1-3 [$1]: " input




 case "$input" in
   $blank )
     gwMode=$1
   ;;
   1 )
     gwMode="encrypt-everything"
   ;;
   2 )
     gwMode="decrypt-everything"
   ;;
   3 )
     gwMode="dlp"
   ;;
   * )
     gwMode=$1
   ;;
 esac
 echo " "
}




GetGwTopology() {
 local input=""
 echo "Gateway Topology"
 echo "  Options"
 echo "  1 - inbound"
 echo "  2 - outbound"
 echo " "
 read -p "Enter 1-2 [$1]: " input




 case "$input" in
   $blank )
     gwTopology=$1
   ;;
   1 )
     gwTopology="inbound"
   ;;
   2 )
     gwTopology="outbound"
   ;;
   * )
     gwTopology=$1
   ;;
 esac
 echo " "
}


GetGwFips() {
 local input=""
 echo "Do you have a FIPS requirement?"
 echo "  Options"
 echo "  1 - Yes"
 echo "  2 - No"
 echo " "
 read -p "Enter 1-2 [$1]: " input




 case "$input" in
   $blank )
     gwType="gateway"
     gwSmtpdSecurityLevel="GATEWAY_SMTPD_SECURITY_LEVEL=opportunistic"
     gwSmtpdTlsCompliance="# GATEWAY_SMTPD_TLS_COMPLIANCE_UPSTREAM=MEDIUM"
     gwSmtpSecurityLevel="GATEWAY_SMTP_SECURITY_LEVEL=opportunistic"
     gwSmtpTlsCompliance="# GATEWAY_SMTP_TLS_COMPLIANCE_DOWNSTREAM=MEDIUM"


   ;;
   1 )
     gwType="gateway-fips"
     gwSmtpdSecurityLevel="GATEWAY_SMTPD_SECURITY_LEVEL=mandatory"
     gwSmtpdTlsCompliance="GATEWAY_SMTPD_TLS_COMPLIANCE_UPSTREAM=HIGH"
     gwSmtpSecurityLevel="GATEWAY_SMTP_SECURITY_LEVEL=mandatory"
     gwSmtpTlsCompliance="GATEWAY_SMTP_TLS_COMPLIANCE_DOWNSTREAM=HIGH"


   ;;
   2 )
     gwType="gateway"
     gwSmtpdSecurityLevel="GATEWAY_SMTPD_SECURITY_LEVEL=opportunistic"
     gwSmtpdTlsCompliance="# GATEWAY_SMTPD_TLS_COMPLIANCE_UPSTREAM=MEDIUM"
     gwSmtpSecurityLevel="GATEWAY_SMTP_SECURITY_LEVEL=opportunistic"
     gwSmtpTlsCompliance="# GATEWAY_SMTP_TLS_COMPLIANCE_DOWNSTREAM=MEDIUM"


   ;;
   * )
     gwType="gateway"
     gwSmtpdSecurityLevel="GATEWAY_SMTPD_SECURITY_LEVEL=opportunistic"
     gwSmtpdTlsCompliance="# GATEWAY_SMTPD_TLS_COMPLIANCE_UPSTREAM=MEDIUM"
     gwSmtpSecurityLevel="GATEWAY_SMTP_SECURITY_LEVEL=opportunistic"
     gwSmtpTlsCompliance="# GATEWAY_SMTP_TLS_COMPLIANCE_DOWNSTREAM=MEDIUM"


   ;;
 esac
 echo " "
}




GetGwInboundRelay() {
 local input=""
 echo "Inbound Relay Addresses"
 echo "  Options"
 echo "  1 - G Suite"
 echo "  2 - O365"
 echo "  3 - All"
 echo "  4 - None"
 read -p  "Enter (1-4) [$1]: " input




 case "$input" in
   $blank )
     gwInboundRelay=$1
   ;;
   1 )
     gwInboundRelay="GATEWAY_RELAY_ADDRESSES=35.190.247.0/24,64.233.160.0/19,66.102.0.0/20,66.249.80.0/20,72.14.192.0/18,74.125.0.0/16,108.177.8.0/21,173.194.0.0/16,209.85.128.0/17,216.58.192.0/19,216.239.32.0/19,172.217.0.0/19,172.217.32.0/20,172.217.128.0/19,172.217.160.0/20,172.217.192.0/19,108.177.96.0/19,35.191.0.0/16,130.211.0.0/22"
   ;;
   2 )
     gwInboundRelay="GATEWAY_RELAY_ADDRESSES=23.103.132.0/22,23.103.136.0/21,23.103.144.0/20,23.103.198.0/23,23.103.200.0/22,23.103.212.0/22,40.92.0.0/14,40.107.0.0/17,40.107.128.0/18,52.100.0.0/14,65.55.88.0/24,65.55.169.0/24,94.245.120.64/26,104.47.0.0/17,104.212.58.0/23,134.170.132.0/24,134.170.140.0/24,157.55.234.0/24,157.56.110.0/23,157.56.112.0/24,207.46.51.64/26,207.46.100.0/24,207.46.163.0/24,213.199.154.0/24,213.199.180.128/26,216.32.180.0/23"
   ;;
   3 )
     gwInboundRelay="GATEWAY_RELAY_ADDRESSES=0.0.0.0/0"
   ;;
   4 )
     gwInboundRelay="GATEWAY_RELAY_ADDRESSES="
   ;;
   * )
     gwInboundRelay="GATEWAY_RELAY_ADDRESSES=$1"
   ;;
 esac
 echo " "
}




GetGwCks() {
 local input=""
 echo "CKS Enabled"
 echo "  Options"
 echo "  1 - Yes"
 echo "  2 - No"
 echo " "
 read -p "Enter 1-2 [$1]: " input




 case "$input" in
   $blank )
     gwCks="# GATEWAY_ENCRYPTION_KEY_PROVIDER=CKS"
     gwCksKey="# GATEWAY_CKS_SESSION_KEY_EXPIRY_IN_MINS=360"


   ;;
   1 )
     gwCks="GATEWAY_ENCRYPTION_KEY_PROVIDER=CKS"
     gwCksKey="GATEWAY_CKS_SESSION_KEY_EXPIRY_IN_MINS=360"
   ;;
   2 )
     gwCks="# GATEWAY_ENCRYPTION_KEY_PROVIDER=CKS"
     gwCksKey="# GATEWAY_CKS_SESSION_KEY_EXPIRY_IN_MINS=360"
   ;;
   * )
     gwCks="# GATEWAY_ENCRYPTION_KEY_PROVIDER=CKS"
     gwCksKey="# GATEWAY_CKS_SESSION_KEY_EXPIRY_IN_MINS=360"
   ;;
 esac
 echo " "


 if [ $gwMode = "decrypt-everything" ]
 then
     gwCks="GATEWAY_ENCRYPTION_KEY_PROVIDER=CKS"
     gwCksKey="GATEWAY_CKS_SESSION_KEY_EXPIRY_IN_MINS=360"
 fi
}




GetGwFqdn() {
 local input=""
 read -p "Gateway FQDN [$1]: " input




 case "$input" in
   $blank )
     gwFqdn=$1
   ;;
   * )
     gwFqdn=$input
   ;;
 esac
 echo " "
}




GetGwDomain() {
 local input=""
 read -p "Gateway Domain [$1]: " input




 case "$input" in
   $blank )
     gwDomain=$1
   ;;
   * )
     gwDomain=$input
   ;;
 esac
 echo " "
}




GetGwOutboundRelay() {
 local input=""
 echo "Outbound Relay - Next Hop in SMTP mailflow after the gateway."
 echo "  Gmail Relay"
 echo "  [smtp-relay.gmail.com]:587"
 echo " "
 echo "  Office 365"
 echo "  [MX Record]:25"
 echo " "
 echo "  Custom"
 echo "  [1.1.1.1]:25"
 echo " "
 echo "  Blank (Gateway performs final delivery)"
 read -p "Enter Relay Address []: " input




 case "$input" in
   $blank )
     gwOutboundRelay="# GATEWAY_TRANSPORT_MAPS=*=>$1"
   ;;
   * )
     gwOutboundRelay="GATEWAY_TRANSPORT_MAPS=*=>$input"
   ;;
 esac
 echo " "
}




GetGwDkimSelector() {
 local input=""
 read -p "Gateway DKIM Selector [$1]: " input




 case "$input" in
   $blank )
     gwDkimSelector=$1
   ;;
   * )
     gwDkimSelector=$input
   ;;
 esac
 echo " "
}




GetGwAmplitudeToken() {
 local input=""
 read -p "Amplitude Token (Provided by Virtru) [$1]: " input




 case "$input" in
   $blank )
     gwAmplitudeToken=$1
   ;;
   * )
     gwAmplitudeToken=$input
   ;;
 esac
 echo " "
}




GetGwHmacName() {
 local input=""
 read -p "Token ID (Provided by Virtru) [$1]: " input




 case "$input" in
   $blank )
     gwHmacName=$1
   ;;
   * )
     gwHmacName=$input
   ;;
 esac
 echo " "
}




GetGwHmacSecret() {
 local input=""
 read -p "Token (Provided by Virtru) [$1]: " input




 case "$input" in
   $blank )
     gwHmacSecret=$1
   ;;
   * )
     gwHmacSecret=$input
   ;;
 esac
 echo " "
}








MakeTlsPathVariables() {
  tlsPath="/var/virtru/vg/tls/$gwFqdn"
  tlsKeyFile="client.key"
  tlsKeyFull="$tlsPath/$tlsKeyFile"
  tlsPemFile="client.pem"
  tlsPemFull="$tlsPath/$tlsPemFile"
}




MakeDkimPathVariables() {
  dkimPath="/var/virtru/vg/dkim"
  dkimPrivateFull="$dkimPath/$gwDkimSelector"
  dkimPrivateFull="$dkimPrivateFull._domainkey.$gwDomain.pem"
  dkimPublicFull="$dkimPath/$gwDkimSelector._domainkey.$gwDomain-public.pem"
}




MakeDirectories(){
  mkdir -p /var/virtru/vg/
  mkdir -p /var/virtru/vg/env
  mkdir -p /var/virtru/vg/scripts
  mkdir -p /var/virtru/vg/tls
  mkdir -p /var/virtru/vg/queue
  mkdir -p /var/virtru/vg/queue/$gwName
  chown -R 149:149 /var/virtru/vg/queue/$gwName
  mkdir -p /var/virtru/vg/test
  mkdir -p $tlsPath
  mkdir -p /var/virtru/vg/dkim
}




MakeTlsCert(){
## Make TLS Certs
openssl genrsa -out $tlsKeyFull 2048
openssl req -new -key $tlsKeyFull -x509 -subj /CN=$gwFqdn -days 3650 -out $tlsPemFull

}




MakeDkimCert(){
openssl genrsa -out $dkimPrivateFull 1024 -outform PEM
openssl rsa -in $dkimPrivateFull -out $dkimPublicFull -pubout -outform PEM
}

WriteTestScripts(){
    testScript1=/var/virtru/vg/test/checkendpoints.sh
/bin/cat <<EOM >$testScript1
#!/bin/bash

echo https://google.com
curl --connect-timeout 10 -o /dev/null --silent --head --write-out '%{http_code}\n' https://google.com
echo ""

echo https://acm.virtru.com
curl --connect-timeout 10 -o /dev/null --silent --head --write-out '%{http_code}\n' https://acm.virtru.com
echo ""

echo https://api.virtru.com
curl --connect-timeout 10 -o /dev/null --silent --head --write-out '%{http_code}\n' https://acm.virtru.com
echo ""

echo https://accounts.virtru.com
curl --connect-timeout 10 -o /dev/null --silent --head --write-out '%{http_code}\n' https://accounts.virtru.com
echo ""

echo https://secure.virtru.com
curl --connect-timeout 10 -o /dev/null --silent --head --write-out '%{http_code}\n' https://secure.virtru.com
echo ""

echo https://api.amplitude.com
curl --connect-timeout 10 -o /dev/null --silent --head --write-out '%{http_code}\n' https://api.amplitude.com
echo ""

echo https://cdn.virtru.com
curl --connect-timeout 10 -o /dev/null --silent --head --write-out '%{http_code}\n' https://cdn.virtru.com
echo ""

echo https://hub.docker.com
curl --connect-timeout 10 -o /dev/null --silent --head --write-out '%{http_code}\n' https://hub.docker.com
echo ""

EOM


 testScript2=/var/virtru/vg/test/runall.sh
/bin/cat <<EOM >$testScript2
#!/bin/bash

for container in \`docker ps -q\`; do
  # show the name of the container
  docker inspect --format='{{.Name}}' \$container;
  # run the command (date in the case)
  docker exec -it \$container \$1
done


EOM


 testScript3=/var/virtru/vg/test/sendtestmessage.sh
/bin/cat <<EOM >$testScript3
#!/bin/bash

echo "Update Virtru Gateway ENV file to include the lan ip of the Gateway."
echo "Use the lan IP and not the loopback (127.0.0.1)"
read -p "SMTP Server: " server
read -p "SMTP Port: " port
read -p "FROM: " from
read -p "TO: " to

swaks --To \$to --From \$from --header "Subject: Test mail" --body "This is a test mail" --server \$server --port \$port -tls -4




EOM


}


ShowLogo() {
echo " "
echo "                      +++                '++."
echo "                      +++                ++++"
echo "                                         ++++"
echo "     ,:::      +++    +++     :+++++++   +++++++    .+++++++   .++     '++"
echo "     ++++     .+++.  '+++    ++++++++++  ++++++++  ++++++++++  ++++    ++++"
echo "     ++++     ++++   ++++    +++++''++   +++++++   +++++++++   ++++    ++++"
echo "     ++++   .++++    ++++    ++++        ++++      ++++        ++++    ++++"
echo "     ++++  .++++     ++++    ++++        ++++      ++++        ++++    ++++"
echo "     ++++ ++++       ++++    ++++        ++++      ++++        ++++    ++++"
echo "     ++++++          ;+++    ++++        ++++      ++++          ++++++++"
echo "     ++++             +++     ++'         ++        ++'           .++++"
echo " "
echo "        R   e   s   p   e   c   t        t   h   e         D  a  t  a"
echo " "
echo " "








}
WriteEnv() {
  envFile=/var/virtru/vg/env/$gwName.env








/bin/cat <<EOM >$envFile
# Required to match the CN (Common Name) on the certificate.
# TLS will not function unless this matches.
#
GATEWAY_HOSTNAME=$gwFqdn


# Enable verbose logging in Gateway.
# Values
#   Enable: 1
#   Disable: 0
# Default: 0
# Required: No
# Note: Set this to 0 unless you are debugging something.
#
GATEWAY_VERBOSE_LOGGING=0



# Domain name of organization
# Values
#   Domain
# Required: Yes
#
GATEWAY_ORGANIZATION_DOMAIN=$gwDomain



# Comma delimited list of trusted networks in CIDR formate.
# Inbound addresses allowed to connect to the gateway
# Values (examples)
#   All IP: 0.0.0.0/0
#   2 IP: 2.2.2.2/32,2.2.2.3/32
# Required: Yes
#
$gwInboundRelay



# Enable Proxy Protocol for SMTP.
# For use behind a load balancer.
# Values
#   Enable: 1
#   Disable: 0
# Default: 1
# Required: No
#
GATEWAY_PROXY_PROTOCOL=0



# Define the next-hop destination and port, supports FQDN and IPV4 address
# Values
#   Not defined/Commented out - Final delivery by MX
#   GATEWAY_TRANSPORT_MAPS=*=>[Next hop FQDN]:port
# Default: Not defined/Commented out - Final delivery by MX
# Required: No
#
# Examples:
#
# Gmail Relay
# GATEWAY_TRANSPORT_MAPS=*=>[smtp-relay.gmail.com]:587
#
# Office 365
# GATEWAY_TRANSPORT_MAPS=*=>[MX Record]:25
#
# Custom
# GATEWAY_TRANSPORT_MAPS=*=>[1.1.1.1]:25
#
$gwOutboundRelay


# The mode for the Gateway.
# Values
#    decrypt-everything
#    encrypt-everything
#    dlp - Use rules defined on Virtru Dashboard (https://secure.virtru.com/dashboard)
# Default: encrypt-everything
# Required: Yes
#
GATEWAY_MODE=$gwMode



# Topology of the gateway.
# Values
#   outbound
#   inbound
# Default: outbound
# Required: Yes
GATEWAY_TOPOLOGY=$gwTopology



# URL to Virtru's ACM service.
# Required: Yes
# Note: Do not change this.
#
GATEWAY_ACM_URL=https://api.virtru.com/acm



# URL to Virtru's Accounts service.
# Required: Yes
# Note: Do not change this.
#
GATEWAY_ACCOUNTS_URL=https://api.virtru.com/accounts



# The base URL for remote content.
# Required: Yes
# Note: Do not change unless directed by Virtru.  If Custom Secure Reader URL is in use the URL should match.
#
GATEWAY_REMOTE_CONTENT_BASE_URL=https://secure.virtru.com/start



# DKIM certificate information
# Values
#   Not defined/Commented out - Gateway will not perform any DKIM signing
#   Complete record for DKIM signing
# Required: No
# Example:
# GATEWAY_DKIM_DOMAINS=gw._domainkey.example.com
#
# GATEWAY_DKIM_DOMAINS=$gwDkimSelector._domainkey.$gwDomain



# HMAC Token Name to connect to Virtru services such as Accounts and ACM.
# Values
#   Value provided by Virtru
# Required: Yes
# Note:Contact Virtru Support for getting your token Name.
#
GATEWAY_API_TOKEN_NAME=$gwHmacName



# HMAC Token Secret to connect to Virtru services such as Accounts and ACM.
# Values
#   Value provided by Virtru
# Required: Yes
# Note:Contact Virtru Support for getting your Token Secret.
#
GATEWAY_API_TOKEN_SECRET=$gwHmacSecret



# Amplitude Token to connect to the Virtru Events platform
# Values
#   Value provided by Virtru
# Required: Yes
# Note:Contact Virtru Support for getting your Token.
#
GATEWAY_AMPLITUDE_API_KEY=$gwAmplitudeToken



# Consider a message as undeliverable, when delivery fails with a temporary error, and the time in the queue
# has reached the maximal_queue_lifetime limit.
# Time units: s (seconds), m (minutes), h (hours), d (days), w (weeks). The default time unit is d (days).
# Postfix default is '5d'. Set this ENV variable if default does not work.
# Values
#   NumberUnits
# Default: 5d
# Required: No
# Note: Specify 0 when mail delivery should be tried only once.
#
MAX_QUEUE_LIFETIME=5m



# The maximal time between attempts to deliver a deferred message.
# Values
#   NumberUnits
# Default: 4000s
# Required: No
# Note: Set to a value greater than or equal to MIN_BACKOFF_TIME
#
MAX_BACKOFF_TIME=45s



# The minimal time between attempts to deliver a deferred message
# Values
#   NumberUnits
# Default: 300s
# Required: No
# Note: Set to a value greater than or equal to MIN_BACKOFF_TIME
#
MIN_BACKOFF_TIME=30s



# The time between deferred queue scans by the queue manager
# Values
#   NumberUnits
# Default: 300s
# Required: No
#
QUEUE_RUN_DELAY=30s



# Gateway Inbound
# Enable Inbound TLS to the Gateway.
# Values
#   1 Enabled
#   0 Disabled
# Default: 1
# Required: No
#
GATEWAY_SMTPD_USE_TLS=1



# TLS Compliance Level for upstream (inbound) connections.
# This sets TLS version and cipher list accordingly.
# Customer is still responsible for following other NIST and/or OWASP recommendations,
# notably making sure certificates are signed and keys are rotated regularly.
# Values:
#   LOW
#   MEDIUM
#   HIPPA_2018
#   PCI_321
#   HIGH
#
#  Default: N/A
#  Required: No
#  Note: If any level above LOW, you must set:
#    GATEWAY_SMTPD_SECURITY_LEVEL= mandatory
#    GATEWAY_SMTPD_USE_TLS=1
#
#
$gwSmtpdTlsCompliance



# Gateway Inbound
# TLS level for inbound connections
# Values
#   none
#   mandatory
#   opportunistic
# Require: No
# Note: Only used when:
#   GATEWAY_SMTPD_USE_TLS=1
#
$gwSmtpdSecurityLevel



# Gateway Outbound
# Enable TLS at the Gateway.
# Values
#   1 Enabled
#   0 Disabled
# Default: 1
# Require: No
#
GATEWAY_SMTP_USE_TLS=1



# Gateway Outbound
# TLS level for outbound connections
# Values
#   none
#   mandatory
#   opportunistic
# Require: No
#
$gwSmtpSecurityLevel



# TLS Compliance Level for downstream (outbound) connections.
# This sets TLS version and cipher list accordingly.
# Customer is still responsible for following other NIST and/or OWASP recommendations,
# notably making sure certificates are signed and keys are rotated regularly.
# Values:
#   LOW
#   MEDIUM
#   HIPPA_2018
#   PCI_321
#   HIGH
#
#  Default: N/A
#  Required: No
#  Note: If any level above LOW, you must set:
#    GATEWAY_SMTP_SECURITY_LEVEL= mandatory
#    GATEWAY_SMTP_USE_TLS=1
#
#
$gwSmtpTlsCompliance



# Gateway Outbound
# If SASL_ENABLED_DOWNSTREAM enabled, specify Postfix SMTP client SASL security options here.
# Default: N/A
# Required: No
# Values: Text
#
# GATEWAY_SMTP_SASL_SECURITY_OPTIONS=noanonymous
#



# Gateway Outbound
# Require SASL authentication for outbound downstream or relay servers attempting to connect this server.
# Default: 0
# Required: No
# Values:
#   0 (Disabled)
#   1 (Enabled)
#
# GATEWAY_SMTP_SASL_ENABLED_DOWNSTREAM=0
#



# Gateway Outbound
# Accounts for Authentication
# Example:
# GATEWAY_SMTPD_SASL_GATEWAY_SMTPD_SASL_ACCOUNTS=example.com=>user1=>password1,example.net=>user2=>password2
# Required: No
#
# GATEWAY_SMTP_SASL_ACCOUNTS=
#



# Gateway Outbound
# Outbound TLS requirements for a domain.  Comma separated list.
# Example
#   example.com=>none
#   example.net=>maybe
#   example.org=>encrypt
# GATEWAY_SMTP_TLS_POLICY_MAPS=example.com=>none,example.net=>maybe
#
# GATEWAY_SMTP_TLS_POLICY_MAPS=



# Inbound Authentication enablement.
# Enable inbound authentication.
# Supported modes: CRAM-MD5 or DIGEST-MD5
# Values
#   1 Enabled
#   0 Disabled
# Default: 0
# Require: No
#
# GATEWAY_SMTPD_SASL_ENABLED=0



# Inbound Authentication mechanisms.
# Space-delimited list of SASL mechanisms to support for upstream SASL.
#
# Default: N/A
# Required: No
# Values:
#   PLAIN
#   LOGIN
#   CRAM-MD5
#   DIGEST-MD5
# Note: Only required when:
#   GATEWAY_SMTPD_SASL_ENABLED_UPSTREAM=1
#
# GATEWAY_SMTPD_SASL_MECHANISMS=
#


# Inbound Authentication
# Accounts for Authentication
# Example:
# GATEWAY_SMTPD_SASL_ACCOUNTS=example.net=>user1=>password1,example.com=>user2=>password2
# Required: No
#
# GATEWAY_SMTPD_SASL_ACCOUNTS=
#



# Inbound X-Header Authentication
# Enable inbound X-Header authentication
# Values
#   1 Enabled
#   0 Disabled
# Default: 0
# Require: No
#
# GATEWAY_XHEADER_AUTH_ENABLED=
#



# Inbound X-Header Authentication
# Enable inbound X-Header authentication Shared Secret
# Example variable:
# GATEWAY_XHEADER_AUTH_SECRET=123456789
# Example of applied header with secret
# X-Header-Virtru-Auth=123456789
# Require: No
#
# GATEWAY_XHEADER_AUTH_SECRET=
#



# CKS Enabled Organization
#
# If Gateway is in Decrypt Mode Required
#      Required: Yes
# If Gateway is in Encrypt Mode Required  only if the Organization is CKS enabled.
#      Required: No
#
# GATEWAY_ENCRYPTION_KEY_PROVIDER=CKS
#
$gwCks



# CKS Key Intergenerational Period
# Time between Gateway CKS public/private client Key Generation
#
# Required: No
# Default: 360
#
# GATEWAY_CKS_SESSION_KEY_EXPIRY_IN_MINS=360
#
$gwCksKey



# Time to Cache DLP rule.
# The interval of time between refreshing the DLP rules in minutes.
#
# Required: No
# Default: 30
# Minimum: 0
#
# Note: Number in minutes.  To refresh every request, set to 0.
#
# GATEWAY_DLP_CACHE_DURATION=30


# Inbound FROM address rewrite.
# Enable or disable from address rewriting (inbound topology only).  This feature allows the Virtru Gateway to support DKIM.
#
# Required: No
# Default: 1
# Values:
#    1 - Enabled
#    0 - Disabled
#
# GATEWAY_REPLACEMENT_FROM_ENABLED=1



# Enable decryption of PFP protected files
# The feature to enable/disable the option to decrypt Virtru Persistent File Protection
# protected files (DECRYPT mode only)
#
# Required: No
# Default: 1
# Values:
#    1 - Enabled
#    0 - Disabled
#
# GATEWAY_DECRYPT_PERSISTENT_PROTECTED_ATTACHMENTS=1


# SMTP XHeaders for the Gateway to set on all mail it processes
# Example Header Values
# X-Header-1: value1, X-Header-2: value2
# GATEWAY_ROUTING_XHEADERS=

# Cache Outgoing SMTP Connections
# Whether to cache outgoing connections to mailservers.
# If "1", use on-demand connection caching. If "0", do not cache.
# If a list of domains (e.g. example.org,hotmail.com,gmail.com)
# then use per-destination connection caching.
#
# Required: No
# Default: 0
# Values:
#   1 - True
#   0 - False
#
# GATEWAY_SMTP_CACHE_CONNECTIONS=0

# Outgoing SMTP Connection Cache Time Limit
# How long to cache SMTP connections for.
# Sets smtp_connection_cache_time_limit to the provied value
# so that the smtp daemon doesn't close the connection and
# sets connection_cache_ttl_limit to the same value so that the cached value is still valid
#
# Required: No
# Default: None
# Example Values:
#   30s
#   2m
#
# GATEWAY_SMTP_CONNECTION_CACHE_TIME_LIMIT=30s

# Decrypt Then Re-Encrypt Workflow
# If you use a multi-gateway approach for sending email.
# I.e. your workflow looks something like
# (Decrypt -> Scan -> Encrypt) before sending/receiving email.
#
# Required: No
# Default: Disabled
# Values:
#   1 - Enabled
#   0 - Disabled
#
# GATEWAY_DECRYPT_THEN_ENCRYPT=0


EOM








}




WriteScript() {
echo $gwVersion
  echo "script"
  scriptFile=/var/virtru/vg/scripts/setup-$gwName.sh




  /bin/cat <<EOM >$scriptFile
docker run \\
--env-file /var/virtru/vg/env/$gwName.env \\
-v /var/virtru/vg/tls/:/etc/postfix/tls \\
-v /var/virtru/vg/queue/$gwName/:/var/spool/postfix \\
-v /var/virtru/vg/dkim/:/etc/opendkim/keys \\
--name $gwName \\
--publish $gwPort:25 \\
--interactive --tty --detach \\
--restart unless-stopped \\
--log-driver json-file \\
--log-opt max-size=10m \\
--log-opt max-file=100 \\
virtru/$gwType:$gwVersion
EOM








chmod +x $scriptFile








}
ShowNextSteps() {
  echo "next steps"
  echo "-----------------------"
  echo " Deploy Successful!"
  echo " Next Steps:"
  echo " "
  echo " run: sh $scriptFile"
  echo "-----------------------"
}










# Entry Point








clear
EntryPoint
