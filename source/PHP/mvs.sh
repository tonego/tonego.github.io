#!/bin/bash
#从wp导出的文章导入hexo，文件名会变为不可人读的16进制,此脚本用于修改文件名

a=`ls`
for row in $a ; do 
    if [ "$row" = 'mvs.sh' ]; then
        continue;
    fi

    c=`head -1 $row`
    c=${c//\ /_}
    c=${c//title:_/_}
    c=${c/_/}
    c=${c//\'/}
    c=${c//\n/}
    echo $c".md"
    echo $row
    #mv $row $c".md" 
done





