```
mvn install
```

After compiling jar file, place jar in same directory as selenium-standalone-server.jar, and start hub.

```
java -cp *:. org.openqa.grid.selenium.GridLauncher -role hub
```
