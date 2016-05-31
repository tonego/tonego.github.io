title: Mysql 函数分类整理
id: 162
categories:
  - mysql
date: 2014-12-23 11:28:29
tags:
---

<div></div>
<div>MySQL字符串函数、数学函数、时间函数 分类总结：</div>
<div></div>
<div></div>
<div>
<div>MySQL函数，来源于手册：</div>
</div>
<div>        比较函数：coalesce、greatest、least、interval、</div>
<div>        流程控制：case、when、then、if、else、infnull、nullif</div>
<div></div>
<div></div>
<div>*************************************************************************************</div>
<div></div>
<div>MySQL字符串函数，分类总结：</div>
<div>        charset(str)</div>
<div>        char(ascii('a'),ascii('b')) = char(97,98) = 'ab' ;</div>
<div>        ord(S) = ascii(S) ;</div>
<div>        export_set(bits,1,0,'',N)  =  conv(N,10,2)  =  bin(N) ;</div>
<div>        oct(N) = conv(N,10,8) ;</div>
<div>        hex    :    hex(N) = conv(N,10,16)     hex('abc') = hex(0x616263) = 616263     unhex;</div>
<div>        compress    uncompress    uncompress_length ;</div>
length    octet_length    char_length    character_length    bit_length ;
<div>        concat    concat_ws ;</div>
<div>        coalesce    greatest    least    interval    make_set ;</div>
elt、field、find_in_set    instr    locate    position    substring_index    substring    mid    format    ;
<div>        reverse    replace    repeat    quote    space    insert</div>
<div>
<div>        lpad    rpad ;</div>
<div>        upper    lower    ucase    lcase ;</div>
<div>        left    right ;</div>
<div>        ltrim    rtrim    trim ;</div>
<div>        regexp    not regexp    like    not like    rlike    strcmp    soundex    sounds like    ;</div>
<div></div>
<div>*************************************************************************************</div>
<div></div>
<div>MySQL数学函数，分类总结：</div>
<div>        acos    sin    asin    atan    atan2    cos    cot    degrees    radians    exp    ln    log    log2    long10    pi</div>
<div>        abs    ceiling    ceil    round    floor    format    mod    div    pow    sqrt     rand    sign    truncate    crc32</div>
<div></div>
<div>*************************************************************************************</div>
<div></div>
<div>MySQL时间函数，分类总结：</div>
<div>        now() = current_timestamp = current_timestamp() = localtimestamp = localtimestamp() = localtime = localtime() = sysdate() = utc_timestamp ;</div>
<div>        curdate() = current_date = current_date() = utc_date() ;</div>
<div>        curtime() = current_time = current_time() = utc_time() ;</div>
<div>        date()    time()    year()    quarter()    mouth()    week()    day()    hour()    minute()    second()    microsecond()    extract()    dayname()    monthname()</div>
<div>        dayofyear()    dayofmonth()    dayofweek()    weekday()    weekofyear(now()) = week(now(),3)        yearweek(now()) = year(now()) + week(now())</div>
<div>        last_day() : day(last_day(now()))     convert_tz() ;</div>
<div>        date_add()    adddate()    addtime()    date_sub()     subdate()    subtime()    period_add()    period_diff()    datediff()    timediff()</div>
<div>        time_to_sec()    sec_to_time()    to_days()    from_days()    str_to_date()    date_format()    time_format()    get_format()    makedate()    maketime()</div>
<div>        unix_timestamp()    from_unixtime()    timestamp()    timestampadd()    timestampdiff()</div>
<div></div>
<div>        date_add(now(),interval -8 hour) = date_sub(now(),interval 8 hour) = timestampadd(hour, -8, now()) ;</div>
<div></div>
<div>
<div>*********************************************************************************</div>
<div></div>
<div></div>
<div></div>
<div></div>
<div></div>
</div>
</div>