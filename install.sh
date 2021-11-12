#!/bin/bash
set -ueo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$REPO_DIR/src"

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/themes"
else
  DEST_DIR="$HOME/.themes"
fi

THEME_NAME=MateriaSoft
COLOR_VARIANTS=('' '-dark' '-light')
SIZE_VARIANTS=('' '-compact')

if [[ "$(command -v gnome-shell)" ]]; then
  SHELL_VERSION="$(gnome-shell --version | cut -d ' ' -f 3 | cut -d . -f -1)"
  if [[ "${SHELL_VERSION:-}" -ge "40" ]]; then
    GS_VERSION="new"
  else
    GS_VERSION="old"
  fi
  else
    echo "'gnome-shell' not found, using styles for last gnome-shell version available."
    GS_VERSION="new"
fi

usage() {
  cat << EOF
Usage: $0 [OPTION]...

OPTIONS:
  -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)
  -n, --name NAME         Specify theme name (Default: $THEME_NAME)
  -c, --color VARIANT...  Specify color variant(s) [standard|dark|light] (Default: All variants)
  -s, --size VARIANT      Specify size variant [standard|compact] (Default: All variants)
  -h, --help              Show help

INSTALLATION EXAMPLES:
Install all theme variants into ~/.themes
  $0 --dest ~/.themes
Install standard theme variant only
  $0 --color standard --size standard
Install specific theme variants with different name into ~/.themes
  $0 --dest ~/.themes --name MyTheme --color light dark --size compact
EOF
}

install() {
  local dest="$1"
  local name="$2"
  local color="$3"
  local size="$4"

  [[ "$color" == '-dark' ]] && local ELSE_DARK="$color"
  [[ "$color" == '-light' ]] && local ELSE_LIGHT="$color"

  local THEME_DIR="$dest/$name$color$size"

  [[ -d "$THEME_DIR" ]] && rm -rf "${THEME_DIR:?}"

  echo "Installing '${THEME_DIR}'..."

  mkdir -p                                                                      "$THEME_DIR"
  cp -r "$REPO_DIR/COPYING"                                                     "$THEME_DIR"

  echo "[Desktop Entry]" >>                                                     "${THEME_DIR}/index.theme"
  echo "Type=X-GNOME-Metatheme" >>                                              "${THEME_DIR}/index.theme"
  echo "Name=$name$color$size" >>                                               "${THEME_DIR}/index.theme"
  echo "Comment=An elegant Gtk+ theme based on Material Design" >>		"${THEME_DIR}/index.theme"
  echo "Encoding=UTF-8" >>                                                      "${THEME_DIR}/index.theme"
  echo "" >>                                                                    "${THEME_DIR}/index.theme"
  echo "[X-GNOME-Metatheme]" >>                                                 "${THEME_DIR}/index.theme"
  echo "GtkTheme=$name$color$size" >>                                           "${THEME_DIR}/index.theme"
  echo "MetacityTheme=$name$color$size" >>                                      "${THEME_DIR}/index.theme"
  echo "IconTheme=Adwaita" >>                                                   "${THEME_DIR}/index.theme"
  echo "CursorTheme=Adwaita" >>                                                 "${THEME_DIR}/index.theme"
  echo "ButtonLayout=close,minimize,maximize:menu" >>                           "${THEME_DIR}/index.theme"

  mkdir -p                                                                                "${THEME_DIR}/gnome-shell"
  cp -ur "${SRC_DIR}/gnome-shell/pad-osd.css"                                             "${THEME_DIR}/gnome-shell"
  cp -ur "${SRC_DIR}/gnome-shell/common-assets"                                           "${THEME_DIR}/gnome-shell/assets"
  cp -ur "${SRC_DIR}"/gnome-shell/assets${ELSE_DARK:-}/*.svg                              "${THEME_DIR}/gnome-shell/assets"

  if [[ "$panel" == 'compact' || "$opacity" == 'solid' ]]; then
    if [[ "${GS_VERSION:-}" == 'new' ]]; then
      sassc $SASSC_OPT "$SRC_DIR/gnome-shell/shell-40-0/gnome-shell${ELSE_DARK:-}$size.scss" "$THEME_DIR/gnome-shell/gnome-shell.css"
    else
      sassc $SASSC_OPT "$SRC_DIR/gnome-shell/shell-3-28/gnome-shell${ELSE_DARK:-}$size.scss" "$THEME_DIR/gnome-shell/gnome-shell.css"
    fi
  else
    if [[ "${GS_VERSION:-}" == 'new' ]]; then
      cp -r "$SRC_DIR/gnome-shell/shell-40-0/gnome-shell${ELSE_DARK:-}$size.css"    "$THEME_DIR/gnome-shell/gnome-shell.css"
    else
      cp -r "$SRC_DIR/gnome-shell/shell-3-28/gnome-shell${ELSE_DARK:-}$size.css"    "$THEME_DIR/gnome-shell/gnome-shell.css"
    fi
  fi

  cd "${THEME_DIR}/gnome-shell"
  ln -s assets/no-events.svg no-events.svg
  ln -s assets/process-working.svg process-working.svg
  ln -s assets/no-notifications.svg no-notifications.svg

  mkdir -p                                                                      "$THEME_DIR/gtk-2.0"
  cp -r "$SRC_DIR/gtk-2.0/"{apps.rc,hacks.rc,main.rc}                           "$THEME_DIR/gtk-2.0"
  cp -r "$SRC_DIR/gtk-2.0/assets${ELSE_DARK:-}"                                 "$THEME_DIR/gtk-2.0/assets"
  cp -r "$SRC_DIR/gtk-2.0/gtkrc$color"                                          "$THEME_DIR/gtk-2.0/gtkrc"

  cp -r "$SRC_DIR/gtk/assets"                                                   "$THEME_DIR/gtk-assets"

  mkdir -p                                                                      "$THEME_DIR/gtk-3.0"
  ln -s ../gtk-assets                                                           "$THEME_DIR/gtk-3.0/assets"
  cp -r "$SRC_DIR/gtk/3.0/gtk$color$size.css"                                   "$THEME_DIR/gtk-3.0/gtk.css"
  [[ "$color" != '-dark' ]] && \
  cp -r "$SRC_DIR/gtk/3.0/gtk-dark$size.css"                                    "$THEME_DIR/gtk-3.0/gtk-dark.css"

  mkdir -p                                                                      "$THEME_DIR/gtk-4.0"
  ln -s ../gtk-assets                                                           "$THEME_DIR/gtk-4.0/assets"
  cp -r "$SRC_DIR/gtk/4.0/gtk$color$size.css"                                   "$THEME_DIR/gtk-4.0/gtk.css"
  [[ "$color" != '-dark' ]] && \
  cp -r "$SRC_DIR/gtk/4.0/gtk-dark$size.css"                                    "$THEME_DIR/gtk-4.0/gtk-dark.css"

  mkdir -p                                                                      "$THEME_DIR/plank"
  cp -r "$SRC_DIR/plank/dock.theme"                                             "$THEME_DIR/plank"
}

colors=()
sizes=()
opacity=""
panel=""

while [[ "$#" -gt 0 ]]; do
  case "${1:-}" in
    -d|--dest)
      dest="$2"
      mkdir -p "$dest"
      shift 2
      ;;
    -n|--name)
      _name="$2"
      shift 2
      ;;
    --tweaks)
      shift
      for tweaks in $@; do
        case "$tweaks" in
          solid)
            opacity="solid"
            shift
            ;;
          compact)
            panel="compact"
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized panel variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -c|--color)
      shift
      for variant in "$@"; do
        case "$variant" in
          standard)
            colors+=("${COLOR_VARIANTS[0]}")
            shift
            ;;
          dark)
            colors+=("${COLOR_VARIANTS[1]}")
            shift
            ;;
          light)
            colors+=("${COLOR_VARIANTS[2]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -s|--size)
      shift
      for variant in "$@"; do
        case "$variant" in
          standard)
            sizes+=("${SIZE_VARIANTS[0]}")
            shift
            ;;
          compact)
            sizes+=("${SIZE_VARIANTS[1]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized size variant '${1:-}'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '${1:-}'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

if [[ "${#colors[@]}" -eq 0 ]] ; then
  colors=("${COLOR_VARIANTS[@]}")
fi

if [[ "${#sizes[@]}" -eq 0 ]] ; then
  sizes=("${SIZE_VARIANTS[@]}")
fi

for color in "${colors[@]}"; do
  for size in "${sizes[@]}"; do
    install "${dest:-$DEST_DIR}" "${_name:-$THEME_NAME}" "$color" "$size"
  done
done

echo
echo "Done."
