#!/bin/sh -e
# ESET Security Management Center
# Copyright (c) 1992-2018 ESET, spol. s r.o. All Rights Reserved

files2del="$(mktemp -q /tmp/XXXXXXXX.files)"
dirs2del="$(mktemp -q /tmp/XXXXXXXX.dirs)"
echo "$dirs2del" >> "$files2del"
dirs2umount="$(mktemp -q /tmp/XXXXXXXX.mounts)"
echo "$dirs2umount" >> "$files2del"

finalize()
{
  set +e

  echo "Cleaning up:"

  if test -f "$dirs2umount"
  then
    while read f
    do
      sudo -S hdiutil detach "$f"
    done < "$dirs2umount"
  fi

  if test -f "$dirs2del"
  then
    while read f
    do
      test -d "$f" && rmdir "$f"
    done < "$dirs2del"
  fi

  if test -f "$files2del"
  then
    while read f
    do
      unlink "$f"
    done < "$files2del"
    unlink "$files2del"
  fi
}

trap 'finalize' HUP INT QUIT TERM EXIT

eraa_server_hostname="10.200.10.28"
eraa_server_port="2222"
eraa_peer_cert_b64="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"
eraa_peer_cert_pwd=""
eraa_ca_cert_b64="MIIDITCCAgmgAwIBAgIQHqx/zsoaQLRPusVUTdbj8zANBgkqhkiG9w0BAQUFADApMScwJQYDVQQDEx5TZXJ2ZXIgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTcwNjIzMTcwMDAwWhcNMjcwNjI1MTcwMDAwWjApMScwJQYDVQQDEx5TZXJ2ZXIgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDdlPO2vjo3/VeKSCjMOfBkjLyRfKcHlDFNarPVXNZzUap3htYYUMzx5la8KsxMY9z454KcEr098rALOxXmd5i+ivLEs3vsZIZ9tzA7ekAIHvVi3FbQaLhQFeW7eYA/ohm5n32swV91m6eLgv77JQBFpZ6Bh07GNvDkhE5SvKh/7F+C8jO0HbL/P/vluIcWZW9FvPquTy4mycs8zJ+hzKExYAQ2o6T50+EZV+yk0cDa9wGQsqR2P0Av02ZsjioQIOL49TBPemNuBm6MONZ9g0duB3q3lJ7MzLm+MXL6iwfK0TnDjL4HWkalhFEizsDjYzRZ2yP6cy3MkwKZvj8n27pvAgMBAAGjRTBDMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBTzhq2IyaAQf0owWo1qEbxPnh9bGzANBgkqhkiG9w0BAQUFAAOCAQEAa9/ayb1dgwI+0twIx3KxOHOSHn6ZWAMU/tZX/6JRUAH9eXgh7E4ozT8mUUTPLcPc7rYHOciHD5OfobERSDijelKPiSC3ZPpinNMZWI1K1FIw9rCHYnHbsho3QeYrZawLl7dJWW0sGGZqPyXu8hVtbmA1sPCCXi+RPp5YTd7/V8gBmRah/CoFJa3sMfUQ1BGuhO4UnLZ4YmcKk58X/103Gb11bpPZxVMfKYm+nhIXqjzJ8Oa6LUy5CiG/uCFrdNGViW2I7PNvt1JLc1FNMGbL53u4IMQyWW5yIxNuaUmE8ViWDbcfllqUiUXXkgxQtAy2/t5GYDhMQb9mKUidNBN8QQ=="
eraa_product_uuid=""

eraa_installer_url="http://repository.eset.com/v1/com/eset/apps/business/era/agent/v7/7.0.447.0/agent_macosx_x86_64.dmg"
eraa_installer_checksum="c0ee6644e43b894045c19d9c6efcdaf8df93b9c9"
eraa_initial_sg_token="MDAwMDAwMDAtMDAwMC0wMDAwLTcwMDEtMDAwMDAwMDAwMDAyQmCRzji9TOak487IcEmaEu2/fJiWu0VHvh+aMEyrRakbQU9OYFqsnc/2ITUI2281C3G1dg=="
eraa_enable_telemetry="1"

arch=$(uname -m)
if $(echo "$arch" | grep -E "^(x86_64|amd64)$" 2>&1 > /dev/null)
then
    eraa_installer_url="http://repository.eset.com/v1/com/eset/apps/business/era/agent/v7/7.0.447.0/agent_macosx_x86_64.dmg"
    eraa_installer_checksum="c0ee6644e43b894045c19d9c6efcdaf8df93b9c9"
fi

if test -z $eraa_installer_url
then
  echo "No installer available for '$arch' arhitecture. Sorry :/"
  exit 1
fi

local_params_file="/tmp/postflight.plist"
echo "$local_params_file" >> "$files2del"

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> "$local_params_file"
echo "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">" >> "$local_params_file"
echo "<plist version=\"1.0\">" >> "$local_params_file"
echo "<dict>" >> "$local_params_file"

echo "  <key>Hostname</key><string>$eraa_server_hostname</string>" >> "$local_params_file"
echo "  <key>SendTelemetry</key><string>$eraa_enable_telemetry</string>" >> "$local_params_file"

echo "  <key>Port</key><string>$eraa_server_port</string>" >> "$local_params_file"

if test -n "$eraa_peer_cert_pwd"
then
  echo "  <key>PeerCertPassword</key><string>$eraa_peer_cert_pwd</string>" >> "$local_params_file"
  echo "  <key>PeerCertPasswordIsBase64</key><string>yes</string>" >> "$local_params_file"
fi

echo "  <key>PeerCertContent</key><string>$eraa_peer_cert_b64</string>" >> "$local_params_file"


if test -n "$eraa_ca_cert_b64"
then
  echo "  <key>CertAuthContent</key><string>$eraa_ca_cert_b64</string>" >> "$local_params_file"
fi
if test -n "$eraa_product_uuid"
then
  echo "  <key>ProductGuid</key><string>$eraa_product_uuid</string>" >> "$local_params_file"
fi
if test -n "$eraa_initial_sg_token"
then
  echo "  <key>InitialStaticGroup</key><string>$eraa_initial_sg_token</string>" >> "$local_params_file"
fi

echo "</dict>" >> "$local_params_file"
echo "</plist>" >> "$local_params_file"

# optional list of G1 migration parameters (MAC, UUID, LSID)
local_migration_list="$(mktemp -q /tmp/XXXXXXXX.migration)"
tee "$local_migration_list" 2>&1 > /dev/null << __LOCAL_MIGRATION_LIST__

__LOCAL_MIGRATION_LIST__
test $? = 0 && echo "$local_migration_list" >> "$files2del"

# get all local MAC addresses (normalized)
for mac in $(ifconfig -a | grep ether | sed -e "s/^[[:space:]]ether[[:space:]]//g")
do
    macs="$macs $(echo $mac | sed 's/\://g' | awk '{print toupper($0)}')"
done

while read line
do
  if test -n "$macs" -a -n "$line"
  then
    mac=$(echo $line | awk '{print $1}')
    uuid=$(echo $line | awk '{print $2}')
    lsid=$(echo $line | awk '{print $3}')
    if $(echo "$macs" | grep "$mac" > /dev/null)
    then
      if test -n "$mac" -a -n "$uuid" -a -n "$lsid"
      then
        /usr/libexec/PlistBuddy -c "Add :ProductGuid string $uuid" "$local_params_file"
        /usr/libexec/PlistBuddy -c "Add :LogSequenceID integer $lsid" "$local_params_file"
         break
      fi
    fi
  fi
done < "$local_migration_list"

local_dmg="$(mktemp -q -u /tmp/EraAgentOnlineInstaller.dmg.XXXXXXXX)"
echo "Downloading installer image '$eraa_installer_url':"

eraa_http_proxy_value="http://10.200.10.28:3128"
if test -n "$eraa_http_proxy_value"
then
  export use_proxy=yes
  export http_proxy="$eraa_http_proxy_value"
  (curl --connect-timeout 300 --insecure -o "$local_dmg" "$eraa_installer_url" || curl --connect-timeout 300 --noproxy "*" --insecure -o "$local_dmg" "$eraa_installer_url") && echo "$local_dmg" >> "$files2del"
else
  curl --connect-timeout 300 --insecure -o "$local_dmg" "$eraa_installer_url" && echo "$local_dmg" >> "$files2del"
fi

os_version=$(system_profiler SPSoftwareDataType | grep "System Version" | awk '{print $6}' | sed "s:.[[:digit:]]*.$::g")
if test "10.7" = "$os_version"
then
  local_sha1="$(mktemp -q -u /tmp/EraAgentOnlineInstaller.sha1.XXXXXXXX)"
  echo "$eraa_installer_checksum  $local_dmg" > "$local_sha1" && echo "$local_sha1" >> "$files2del"
  /bin/echo -n "Checking integrity of of downloaded package " && shasum -c "$local_sha1"
else
  /bin/echo -n "Checking integrity of of downloaded package " && echo "$eraa_installer_checksum  $local_dmg" | shasum -c
fi

local_mount="$(mktemp -q -d /tmp/EraAgentOnlineInstaller.mount.XXXXXXXX)" && echo "$local_mount" | tee "$dirs2del" >> "$dirs2umount"
echo "Mounting image '$local_dmg':" && sudo -S hdiutil attach "$local_dmg" -mountpoint "$local_mount" -nobrowse

local_pkg="$(ls "$local_mount" | grep "\.pkg$" | head -n 1)"

echo "Installing package '$local_mount/$local_pkg':" && sudo -S installer -pkg "$local_mount/$local_pkg" -target /
