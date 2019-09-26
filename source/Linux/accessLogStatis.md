

linux统计某个文件内容的 每个值出现的次数
> last | cut -d ' ' -f 1 | sort | uniq -c | sort -t ' ' -k 1 -n -r

标记不连续的记录
> cat 499099733461.csv | sort -t $'\t' -k 2 -n | awk -F $'\t' '{ if(pre+1!=$2){print $1 "," $2 "," $3 ",0" }else{print $1 "," $2 "," $3 ",1";} pre=$2;}' >497.csv

日志中找出502的记录
> tail -3333 /home/wwwlogs/access.log | awk 'BEGIN{FS=" "}; {if(504== $9){print $0}}'

日志中统计PV，去除spider的html页面访问量
> less access_160920.log | awk '{if($7 ~ /\.html/){print $0}}' | awk 'BEGIN {FS="\""}; {if($6 !~ /(spider|bot)/){ print $0}}' | wc

日志中统计IP 
> less access_160918.log | awk '{if($7 ~ /\.html/){print $0}}' | awk 'BEGIN {FS="\""}; {if($6 !~ /(spider|bot)/){ print $0}}' | awk '{print $1}' | sort | uniq -c | sort -t ' ' -k 1 -n -r | wc
> less access_160920.log | awk '{if($7 ~ /\.html/){print $0}}' | awk 'BEGIN {FS="\""}; {if($6 !~ /(spider|bot)/){ print $0}}' | awk '{ip[$1] ++ }END{for(k in ip){ print ip[k],k}}' | sort -rn | head -3


日志中统计每个URL的PV数
> less access_160919.log | awk '{if($7 ~ /^\/[a-z0-9_-]+\/[0-9]+\.html/){print $0}}' | awk 'BEGIN {FS="\""}; {if($6 !~ /(spider|bot)/){ print $0}}' | awk '{print $7}' | awk -F '/' '{print $2}' | sort | uniq -c | sort -t ' ' -k 1 -n -r | awk '{print "2016-09-19," $2 "," $1}' > pv-919.csv

日志中统计每个URL的IP数
> less access_160920.log | awk '{if($7 ~ /\.html/){print $0}}' | awk 'BEGIN {FS="\""}; {if($6 !~ /(spider|bot)/){ print $0}}' | awk '{print $1 $7}' |awk -F '/' '{ip[$2][$1] ++ }END{for(k in ip){ print asort(ip[k]),k}}' | sort -rn | head -3

关联项目日志和nginx日志进行查询
> grep error /data/projlogs/shop/_all/201711/05/21 | cut -d ',' -f 3 | cut -d ']' -f 1 | xargs -I {} grep {}  /data/nginxlogs/shop.gate.panda.tv/201711/05/access_21.log --color
