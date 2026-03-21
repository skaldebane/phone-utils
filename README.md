personal adb cli utilities.

- `phone refresh`: refresh mobile network (switch to 2g then back to 4g)
  - may require root
- `phone tether`: switch usb function to tethering (rndis)
- `phone mtp`: switch usb function to mtp

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
