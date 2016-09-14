

linux统计某个文件内容的 每个值出现的次数
> last | cut -d ' ' -f 1 | sort | uniq -c | sort -t ' ' -k 1 -n -r

找出502的记录
> tail -3333 /home/wwwlogs/access.log | awk 'BEGIN{FS=" "}; {if(504== $9){print $0}}'

标记不连续的记录
> cat 499099733461.csv | sort -t $'\t' -k 2 -n | awk -F $'\t' '{ if(pre+1!=$2){print $1 "," $2 "," $3 ",0" }else{print $1 "," $2 "," $3 ",1";} pre=$2;}' >497.csv


