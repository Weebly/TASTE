source .python/bin/activate

mkdir -p VMs

#PLATFORM=Linux
PLATFORM=Mac

# cleanup
rm -f IE11.Win7.For.${PLATFORM}.VirtualBox.zip
rm -f IE10.Win7.For.${PLATFORM}.VirtualBox.zip
rm -f IE9.Win7.For.${PLATFORM}.VirtualBox.zip
rm -f IE11\ -\ Win7.ova
rm -f IE10\ -\ Win7.ova
rm -f IE9\ -\ Win7.ova
rm -f VMs/IE11\ -\ Win7.ova
rm -f VMS/IE10\ -\ Win7.ova
rm -f VMs/IE9\ -\ Win7.ova

# download
curl -O -L "https://az412801.vo.msecnd.net/vhd/VMBuild_`python parse.py`/VirtualBox/IE11/${PLATFORM}/IE11.Win7.For.${PLATFORM}.VirtualBox.zip"
curl -O -L "https://az412801.vo.msecnd.net/vhd/VMBuild_`python parse.py`/VirtualBox/IE10/${PLATFORM}/IE10.Win7.For.${PLATFORM}.VirtualBox.zip"
curl -O -L "https://az412801.vo.msecnd.net/vhd/VMBuild_`python parse.py`/VirtualBox/IE9/${PLATFORM}/IE9.Win7.For.${PLATFORM}.VirtualBox.zip"

# extract
unzip IE11.Win7.For.${PLATFORM}.VirtualBox.zip
unzip IE10.Win7.For.${PLATFORM}.VirtualBox.zip
unzip IE9.Win7.For.${PLATFORM}.VirtualBox.zip

# move to VMs folder
mv IE11\ -\ Win7.ova VMs/
mv IE10\ -\ Win7.ova VMs/
mv IE9\ -\ Win7.ova VMs/
