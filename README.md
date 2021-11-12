# MateriaSoft

MateriaSoft is a [Material Design](https://material.io) theme for GNOME/GTK based desktop environments.
[Original](https://github.com/vinceliuice/ChromeOS-theme) based on nana-4 -- [materia-theme](https://github.com/nana-4/materia-theme)

Modified to unify dark colors in the dark gtk themes.

## Requirements

- GTK `>=3.20`
- `gnome-themes-extra` (or `gnome-themes-standard`)
- Murrine engine — The package name depends on the distro.
  - `gtk-engine-murrine` on Arch Linux
  - `gtk-murrine-engine` on Fedora
  - `gtk2-engine-murrine` on openSUSE
  - `gtk2-engines-murrine` on Debian, Ubuntu, etc.
- `bc` — build dependency

## Installation

### Manual Installation

Run the following commands in the terminal:

```sh
./install.sh
```

> `./install.sh` allows the following options:

```
-d, --dest DIR          Specify destination directory (Default: /usr/share/themes)
-n, --name NAME         Specify theme name (Default: MateriaSoft)
-c, --color VARIANT...  Specify color variant(s) [standard|dark|light] (Default: All variants)
-s, --size VARIANT      Specify size variant [standard|compact] (Default: All variants)
-h, --help              Show help
```

> For more information, run: `./install.sh --help`
