# gateway-install-script
Gateway Install Script

Download the appropriate script to the host.

# Pull the Latest
```
curl -s https://api.github.com/repos/virtru/gateway-install-script/releases/latest \
| grep "browser_download_url.*sh" \
| cut -d : -f 2,3 \
| tr -d \" \
| sudo wget -qi -
```
Execute the script for each gateway required.
