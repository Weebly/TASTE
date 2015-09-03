all: fetch fetch_vms

fetch: Tools/selenium_conf/selenium-server-standalone.jar Tools/deuac.iso Tools/selenium_conf/IEDriverServer.exe Tools/jre-windows-i586.exe Tools/firefox.exe Tools/chrome.exe Tools/selenium_conf/chromedriver.exe

fetch_vms: VMs/IE11\ -\ Win7.ova VMs/IE8\ -\ Win7.ova VMs/IE10\ -\ Win7.ova VMs/IE9\ -\ Win7.ova

VMs/IE11\ -\ Win8.ova:
	curl -O -L "https://www.modern.ie/vmdownload?browserOS=IE11-Win8.1&parts=6&platform=Mac&virtPlatform=virtualbox&filename=VMBuild_20141027/VirtualBox/IE11/Mac/IE11.Win8.1.For.Mac.VirtualBox.zip{.001,.002,.003,.004,.005,.006}"
	chmod +x IE11.Win8.1.For.MacVirtualBox.part1.sfx
	./IE11.Win8.1.For.MacVirtualBox.part1.sfx
	mkdir VMs || true
	mv "$(@F)" VMs
	rm IE11.Win8.1.For.MacVirtualBox.part1.sfx IE11.Win8.1.For.MacVirtualBox.part2.rar IE11.Win8.1.For.MacVirtualBox.part3.rar IE11.Win8.1.For.MacVirtualBox.part4.rar

VMs/IE11\ -\ Win7.ova:
	curl -O -L "https://www.modern.ie/vmdownload?platform=mac&virtPlatform=virtualbox&browserOS=IE11-Win7&parts=4&filename=VMBuild_20131127/VirtualBox/IE11_Win7/Mac/IE11.Win7.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar}"
	chmod +x IE11.Win7.For.MacVirtualBox.part1.sfx
	./IE11.Win7.For.MacVirtualBox.part1.sfx
	mkdir VMs || true
	mv "$(@F)" VMs
	rm IE11.Win7.For.MacVirtualBox.part1.sfx IE11.Win7.For.MacVirtualBox.part2.rar IE11.Win7.For.MacVirtualBox.part3.rar IE11.Win7.For.MacVirtualBox.part4.rar


VMs/IE10\ -\ Win7.ova:
	curl -O -L "https://www.modern.ie/vmdownload?platform=mac&virtPlatform=virtualbox&browserOS=IE10-Win7&parts=4&filename=VMBuild_20131127/VirtualBox/IE10_Win7/Mac/IE10.Win7.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar}"
	chmod +x IE10.Win7.For.MacVirtualBox.part1.sfx
	./IE10.Win7.For.MacVirtualBox.part1.sfx
	mkdir VMs || true
	mv "$(@F)" VMs
	rm IE10.Win7.For.MacVirtualBox.part1.sfx IE10.Win7.For.MacVirtualBox.part2.rar IE10.Win7.For.MacVirtualBox.part3.rar IE10.Win7.For.MacVirtualBox.part4.rar

VMs/IE9\ -\ Win7.ova:
	curl -O -L "https://www.modern.ie/vmdownload?platform=mac&virtPlatform=virtualbox&browserOS=IE9-Win7&parts=4&filename=VMBuild_20131127/VirtualBox/IE9_Win7/Mac/IE9.Win7.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar}"
	chmod +x IE9.Win7.For.MacVirtualBox.part1.sfx
	./IE9.Win7.For.MacVirtualBox.part1.sfx
	mkdir VMs || true
	mv "$(@F)" VMs
	rm IE9.Win7.For.MacVirtualBox.part1.sfx IE9.Win7.For.MacVirtualBox.part2.rar IE9.Win7.For.MacVirtualBox.part3.rar IE9.Win7.For.MacVirtualBox.part4.rar

VMs/IE8\ -\ Win7.ova:
	curl -O -L "https://www.modern.ie/vmdownload?platform=mac&virtPlatform=virtualbox&browserOS=IE8-Win7&parts=4&filename=VMBuild_20131127/VirtualBox/IE8_Win7/Mac/IE8.Win7.For.MacVirtualBox.part{1.sfx,2.rar,3.rar,4.rar}"
	chmod +x IE8.Win7.For.MacVirtualBox.part1.sfx
	./IE8.Win7.For.MacVirtualBox.part1.sfx
	mkdir VMs || true
	mv "$(@F)" VMs
	rm IE8.Win7.For.MacVirtualBox.part1.sfx IE8.Win7.For.MacVirtualBox.part2.rar IE8.Win7.For.MacVirtualBox.part3.rar IE8.Win7.For.MacVirtualBox.part4.rar


#Tools/selenium_conf/selenium-server-standalone.jar:
#	cp /mnt/isi-weebly-live/automation/tools/selenium_conf/selenium-server-standalone.jar Tools/selenium_conf/selenium-server-standalone.jar
#
#Tools/deuac.iso:
#	cp /mnt/isi-weebly-live/automation/tools/deuac.iso Tools/deuac.iso
#
#Tools/selenium_conf/IEDriverServer_32.exe:
#	cp /mnt/isi-weebly-live/automation/tools/selenium_conf/IEDriverServer_32.exe Tools/selenium_conf/IEDriverServer_32.exe
#
#Tools/selenium_conf/IEDriverServer_64.exe:
#	cp /mnt/isi-weebly-live/automation/tools/selenium_conf/IEDriverServer_64.exe Tools/selenium_conf/IEDriverServer_64.exe
#
#Tools/jre-windows-i586.exe:
#	cp /mnt/isi-weebly-live/automation/tools/jre-windows-i586.exe Tools/jre-windows-i586.exe
#
#Tools/firefox.exe:
#	cp /mnt/isi-weebly-live/automation/tools/firefox.exe Tools/firefox.exe
#
#Tools/chrome.exe:
#	cp /mnt/isi-weebly-live/automation/tools/chrome.exe Tools/chrome.exe
#
#Tools/selenium_conf/chromedriver.exe:
#	cp /mnt/isi-weebly-live/automation/tools/selenium_conf/chromedriver.exe Tools/selenium_conf/chromedriver.exe

Tools/selenium_conf/selenium-server-standalone.jar:
	curl -o Tools/selenium_conf/selenium-server-standalone.jar -L http://selenium-release.storage.googleapis.com/2.44/selenium-server-standalone-2.44.0.jar

Tools/deuac.iso:
	curl -o Tools/deuac.iso -L https://github.com/tka/SeleniumBox/blob/master/deuac.iso?raw=true

Tools/selenium_conf/IEDriverServer.exe:
	curl -o Tools/selenium_conf/IEDriverServer.zip -L http://selenium-release.storage.googleapis.com/2.44/IEDriverServer_Win32_2.44.0.zip
	#curl -o Tools/selenium_conf/IEDriverServer.zip -L http://selenium-release.storage.googleapis.com/2.44/IEDriverServer_x64_2.44.0.zip
	cd Tools/selenium_conf && unzip IEDriverServer.zip

Tools/selenium_conf/chromedriver.exe:
	curl -o Tools/selenium_conf/chromedriver.zip -L http://chromedriver.storage.googleapis.com/2.15/chromedriver_win32.zip
	cd Tools/selenium_conf && unzip chromedriver.zip

Tools/jre-windows-i586.exe:
	curl -j -o Tools/jre-windows-i586.exe -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u75-b13/jre-7u75-windows-i586.exe

Tools/firefox.exe:
	curl -o $@ -L "https://download.mozilla.org/?product=firefox-34.0.5-SSL&os=win&lang=en-GB"

Tools/chrome.exe:
	curl -o $@ -L "https://dl.google.com/update2/installers/ChromeStandaloneSetup.exe"
