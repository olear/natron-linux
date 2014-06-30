#!/bin/sh
mkdir -p /opt/Natron-0.9.4 || exit 1
cp share/applications/natron.desktop /usr/share/applications/ || exit 1
chown root:root /usr/share/applications/natron.desktop || exit 1
cp share/pixmaps/natronIcon256_linux.png /usr/share/pixmaps/ || exit 1
chown root:root /usr/share/pixmaps/natronIcon256_linux.png || exit 1
cat Natron | sed 's#=share#=/opt/Natron-0.9.4#;s#=lib#=/opt/Natron-0.9.4/lib#;s#bin/Natron#/opt/Natron-0.9.4/bin/Natron#' > /usr/bin/Natron || exit 1
cat NatronRenderer | sed 's#=share#=/opt/Natron-0.9.4#;s#=lib#=/opt/Natron-0.9.4/lib#;s#bin/Natron#/opt/Natron-0.9.4/bin/Natron#' > /usr/bin/NatronRenderer || exit 1
chmod +x /usr/bin/Natron /usr/bin/NatronRenderer || exit 1
cp -a * /opt/Natron-0.9.4/ || exit 1
chown root:root -R /opt/Natron-0.9.4 || exit 1
echo "Natron installation complete."
