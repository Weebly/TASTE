for /f "delims=" %%a in ('VBoxControl.exe guestproperty get APPLICATION_NAME') do @set APPLICATION_NAME=%%a
set APPLICATION_NAME=%APPLICATION_NAME:Value: =%

for /f "delims=" %%a in ('VBoxControl.exe guestproperty get STATIC_IP') do @set STATIC_IP=%%a
set STATIC_IP=%STATIC_IP:Value: =%

for /f "delims=" %%a in ('VBoxControl.exe guestproperty get STATIC_GATEWAY') do @set STATIC_GATEWAY=%%a
set STATIC_GATEWAY=%STATIC_GATEWAY:Value: =%

for /f "delims=" %%a in ('VBoxControl.exe guestproperty get STATIC_DNS') do @set STATIC_DNS=%%a
set STATIC_DNS=%STATIC_DNS:Value: =%

for /f "delims=" %%a in ('VBoxControl.exe guestproperty get HUBHOST') do @set HUBHOST=%%a
set HUBHOST=%HUBHOST:Value: =%

netsh interface ipv4 set address 13 static address=%STATIC_IP% gateway=%STATIC_GATEWAY% mask=255.255.255.0
ping -n 5 127.0.0.1 >nul
netsh interface ipv4 set dns 13 static %STATIC_DNS%

ping -n 1 %HUBHOST% -w 60000

java -cp c:\selenium\selenium-server-standalone.jar org.openqa.grid.selenium.GridLauncher -browserTimeout 1800 -remoteHost "http://%STATIC_IP%:5555" -hubHost %HUBHOST% -role node -proxy com.weebly.automation.TASTERemoteProxy -browser "browserName=firefox,platform=WINDOWS,applicationName=%APPLICATION_NAME%,maxInstances=1" -browser "browserName=internet explorer,platform=WINDOWS,applicationName=%APPLICATION_NAME%,maxInstances=1" -browser "browserName=chrome,platform=WINDOWS,applicationName=%APPLICATION_NAME%,maxInstances=1"

rem If we get here, it means that selenium failed to start. Wait 15s, then try again...
ping -n 15 127.0.0.1 >nul

java -cp c:\selenium\selenium-server-standalone.jar org.openqa.grid.selenium.GridLauncher -browserTimeout 1800 -remoteHost "http://%STATIC_IP%:5555" -hubHost %HUBHOST% -role node -proxy com.weebly.automation.TASTERemoteProxy -browser "browserName=firefox,platform=WINDOWS,applicationName=%APPLICATION_NAME%,maxInstances=1" -browser "browserName=internet explorer,platform=WINDOWS,applicationName=%APPLICATION_NAME%,maxInstances=1" -browser "browserName=chrome,platform=WINDOWS,applicationName=%APPLICATION_NAME%,maxInstances=1"

pause
