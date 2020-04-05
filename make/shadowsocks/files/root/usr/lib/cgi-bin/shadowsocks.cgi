#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg


sec_begin 'Starttyp'
cgi_print_radiogroup_service_starttype "enabled" "$SHADOWSOCKS_ENABLED" "" "" 0
sec_end

sec_begin 'Konfiguration'
cat << EOF
<ul>
<li>
Optionale Kommandozeilenarameter:
<input type="text" name="cmdline" size="55" maxlength="250" value="$(html "$SHADOWSOCKS_CMDLINE")">
<li>
<a href="$(href file shadowsocks conf)">Konfigurationsdatei bearbeiten</a></li>
</ul>
EOF
sec_end
