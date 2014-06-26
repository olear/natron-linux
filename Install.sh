#!/bin/sh
mkdir -p /opt/Natron-0.9.3 || exit 1
cp share/applications/natron.desktop /usr/share/applications/ || exit 1
cp share/pixmaps/* /usr/share/pixmaps/ || exit 1
cat Natron | sed 's#=lib#=/opt/Natron-0.9.3/lib#;s#bin/Natron#/opt/Natron-0.9.3/bin/Natron#' > /usr/bin/Natron || exit 1
cat NatronRenderer | sed 's#=lib#=/opt/Natron-0.9.3/lib#;s#bin/Natron#/opt/Natron-0.9.3/bin/Natron#' > /usr/bin/NatronRenderer || exit 1
chmod +x /usr/bin/Natron /usr/bin/NatronRenderer || exit 1
cp -a * /opt/Natron-0.9.3/ || exit 1
echo "Natron installation complete."
