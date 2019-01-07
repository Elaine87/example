#!/bin/sh
total=0
file_name='kaoqin.txt'
echo "" > "result.txt"

# 类型参数类型
function check(){
    local a="$1"
    printf "%d" "$a" &>/dev/null && echo "integer" && return
    printf "%d" "$(echo $a|sed 's/^[+-]\?0\+//')" &>/dev/null && echo "integer" && return
    printf "%f" "$a" &>/dev/null && echo "number" && return
    [ ${#a} -eq 1 ] && echo "char" && return
    echo "string"
}

echo "注意输入时间的格式，要与日志中日期格式一致！"
read -p "输入查询时间段的开始时间（默认20:00:00）:" stime 
read -p "输入查询时间段的结束时间（默认23:59:59）:" etime

# 从awk 向shell 传递变量，eval $(awk xxx)
stimelen=`echo $stime |awk '{print length($0)}'`
etimelen=`echo $etime |awk '{print length($0)}'`


echo '=================开始========================'

echo '$stimelen type is' $(check $stimelen)#integer

echo '=================结束========================'

echo "stimelen is $stimelen"
echo "etimelen is $etimelen"

# 为什么用$stimelen == 0 不可以？？
if [ $stimelen -eq 0 ] 
then
    echo "stime is zero, so use the default time 20:00:00"
    stime="20:00:00"
fi

if [ $etimelen -eq 0 ]
then
    echo "etime is zero,so use the default time 23:59:59"
    etime="23:59:59"
fi


echo "stime is $stime"
# 从外部想awk 传递变量的方式 awk -v, 
awk -v starttime="$stime"  -v endtime="$etime" '
BEGIN {
  FS=" "
  stime=starttime
  etime=endtime
}

$2 > stime && $2 < etime {
  ++total
  print $1 > "result.txt"
}

END {
  print "以下输出考勤时间大于'${stime}'的日期:"
  exit 0
} ' $file_name



echo '=========================================='

uniq  "result.txt"| sed -n '1,$'p 

echo '=========================================='

echo "时间大于${stime}的考勤总数是：`uniq -c "result.txt"|wc -l `"




