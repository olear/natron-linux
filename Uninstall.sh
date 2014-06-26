#!/bin/sh
if [ -d /opt/Natron-0.9.4 ]; then
  rm -rf /opt/Natron-0.9.4
fi
if [ -f /usr/share/applications/natron.desktop ]; then
  rm -f /usr/share/applications/natron.desktop || exit 1
fi
if [ -f /usr/share/pixmaps/natronIcon256_linux.png ]; then
  rm -f /usr/share/pixmaps/natronIcon256_linux.png || exit 1
fi
if [ -f /usr/bin/Natron ]; then
  rm -f /usr/bin/Natron || exit 1
fi
if [ -f /usr/bin/NatronRenderer ]; then
  rm -f /usr/bin/NatronRenderer || exit 1
fi

echo "Natron uninstall complete."
