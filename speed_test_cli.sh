#!/bin/bash
array=( "go.chatwork.com" "www.skype.com/en/" "www.youtube.com" )

for ((i=0;i<${#array[@]};i++)); do {
        access=$(curl -s --head https://${array[i]} -k | head -n 1 | awk '{print $3}' | sed 's/\r$//')
        if [ "$access" = "OK" ] || [ "$access" = "Found" ]; then
        printf "${array[i]}: OK\n";
        else printf "${array[i]}: PROBLEM\n";
        fi
}
done

waccess1=$(curl -s --head https://www.facebook.com -k | head -n 1 | awk '{print $3}' | sed 's/\r$//')
waccess2=$(curl -s --head https://www.google.com.vn -k | head -n 1 | awk '{print $3}' | sed 's/\r$//')
waccess3=$(curl -s --head https://edition.cnn.com -k | head -n 1 | awk '{print $3}' | sed 's/\r$//')
if [ "$waccess1" = "OK" ] && [ "$waccess2" = "OK" ] && [ "$waccess3" = "OK" ]; then
        printf "WEB: OK\n";
        else printf "WEB: PROBLEM\n";
fi

#stable=$(ping -c 100 www.google.com.vn | tail -2 | head -1 | awk '{print $6}')
#if [ "$stable" == "0%" ]; then
#       printf "Y\n\n";
#        else printf "N\n\n";
#fi

./speedtest-cli --server 2428 | tail -3 | head -1
./speedtest-cli --server 2428 | tail -1

./speedtest-cli --server 8193 | tail -3 | head -1
./speedtest-cli --server 8193 | tail -1

echo "Ping 8.8.8.8: "
ping -c 50 8.8.8.8 | tail -1 | awk '{print $4}' | cut -d '/' -f 2
echo "Ping google.com"
ping -c 50 www.google.com | tail -1 | awk '{print $4}' | cut -d '/' -f 2