# Building SetNetworkModePoll.dex

```bash
cd "$(dirname "$0")"

# Compile Java to DEX
javac -source 8 -target 8 SetNetworkModePoll.java
/home/skaldebane/Android/Sdk/build-tools/36.0.0/d8 --output . SetNetworkModePoll.class

# d8 outputs classes.dex - the script uses that file
# The DEX is pushed to /data/local/tmp/ on the phone by phone-refresh.sh
```
