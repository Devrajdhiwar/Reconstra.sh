#!/bin/bash

#color variables
dark_red='\033[0;31m'
# Clear the color after that
clear='\033[0m'

echo -e " ${dark_red}
██████╗ ███████╗ ██████╗ ██████╗ ███╗   ██╗███████╗████████╗██████╗  █████╗ 
██╔══██╗██╔════╝██╔════╝██╔═══██╗████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██╔══██╗
██████╔╝█████╗  ██║     ██║   ██║██╔██╗ ██║███████╗   ██║   ██████╔╝███████║
██╔══██╗██╔══╝  ██║     ██║   ██║██║╚██╗██║╚════██║   ██║   ██╔══██╗██╔══██║
██║  ██║███████╗╚██████╗╚██████╔╝██║ ╚████║███████║   ██║   ██║  ██║██║  ██║
╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝
                                                                            author:0xDevraj${clear}"


echo "Enter your target "
read domain

passive_recon(){

mkdir  -p /$domain
mkdir  -p/$domain/content_discovery
mkdir  -p /$domain/urls

 subfinder -d $domain -o $domain/subfinder.txt
 amass enum -passive -norecursive -noalts -d $domain --config /home/dev/Tools/amass/config.ini -o $domain/amass.txt
 assetfinder --subs-only $domain | tee $domain/assetfinder.txt
 sublist3r -d $domain -o $domain/sublist3r.txt 
 crt.sh -d $domain
 cat $domain/subfinder.txt $domain/amass.txt $domain/assetfinder.txt $domain/sublist3r.txt $domain/$domain-sublist.txt > $domain/alltemp.txt
 rm $domain/subfinder.txt $domain/amass.txt $domain/assetfinder.txt $domain/sublist3r.txt
 cat $domain/alltemp.txt | sort -u | tee $domain/All_subs_without_probe.txt
 rm $domain/alltemp.txt
 cat $domain/All_subs_without_probe.txt | httpx | tee $domain/live_$domain.txt
 cat $domain/live_$domain.txt | naabu -top-ports 1000 -o $domain/port-scan.txt
 
}
#Don't forget to call Function
passive_recon

active_recon(){

#Dns bruteforce
puredns bruteforce /home/devraj/wordlists/best-dns-wordlist.txt $domain -r /home/devraj/wordlists/resolvers.txt -w dns_bf.txt
#Permutation
gotator -sub live_$domain.txt -perm /home/devraj/wordlists/Permutation.txt -depth 3 -number 10 -mindup -adv -md > gotator.txt
#resolve 
puredns resolve Permutation.txt -r /home/devraj/wordlists/resolvers.txt | tee $domain/resolve.txt

cat live_$domain.txt $domain/resolve.txt | tee $domain/WorkingSubs.txt

}
#Don't forget to call Function

#Content Discovery
content_discovery(){

cat $domain/WorkingSubs.txt | while read url; do
  dirsearch.py -e php,aspx,asp,txt,bak -u $url | tee $domain/Content_discovery/FuzzResults;
done
}



#Collect urls

url_collect(){

	cat $domain/WorkingSubs.txt | gau | tee gau.txt
	
}

# Don't forget to call Function
