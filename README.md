personal adb cli utilities.

- `phone refresh`: refresh mobile network (switch to 2g then back to 4g)
- `phone tether`: switch usb function to tethering (rndis)
- `phone mtp`: switch usb function to mtp
- `phone hotspot`: manage mobile hotspot
  - `hostpot [on|off]`: toggle hotspot
  - `hotspot status`: show current hotspot ssid and client count, if on
  - `hotspot config`: edit hotspot configuration (`~/.config/phone/hotspot.conf`)

---

install to `~/.local/share`:

```sh
make install
```

install to `./build` and run:

```sh
make install PREFIX=build
./build/bin/phone <command>
```

requires javac and android sdk

> works on my machine™
> ymmv
