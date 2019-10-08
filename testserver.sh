array=( "portal" "meeting" "worktime" "recruit" "gate" "asset" "helpdesk" )

for ((i=0;i<${#array[@]};i++)); do {
        nslookup ${array[i]}.evolable.asia | tail -2 | head -1 | awk '{print $2}'

        access=$(curl -s --head https://${array[i]}.evolable.asia -k | head -n 1 | awk '{print $3}' | sed 's/\r$//')
        if [[ "$access" = "OK" ]]; then
        printf "Yes\n";
        else printf "No\n";
        fi

        ping -c 5 ${array[i]}.evolable.asia | tail -1| awk '{print $4}' | cut -d '/' -f 2
        stable=$(ping -c 20 ${array[i]}.evolable.asia | tail -2 | head -1 | awk '{print $6}')

        if [ "$stable" == "0%" ]; then
        printf "Y\n\n";
        else printf "N\n\n";
        fi
}
done
