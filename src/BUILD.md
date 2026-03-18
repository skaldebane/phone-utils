# Building

```bash
cd src
javac -source 8 -target 8 SetNetworkModePoll.java
/home/skaldebane/Android/Sdk/build-tools/36.0.0/d8 --output out/ SetNetworkModePoll.class
rm SetNetworkModePoll.class
```

Output: `out/classes.dex`
