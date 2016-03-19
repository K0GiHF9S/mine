#!/bin/bash
all="all.txt"
work="work.txt"
tmp="tmp.txt"
err="err.txt"
grep='Depends|Recommends|Pre-Depends|依存|提案|先行依存'
grep='Depends|Recommends|Suggests|Pre-Depends|依存|提案|推奨|先行依存'
if [ -e $all ]; then
	rm $all
fi
if [ -e $work ]; then
	rm $work
fi
if [ -e $tmp ]; then
	rm $tmp
fi
if [ -e $err ]; then
	rm $err
fi
apt-cache depends $1 | grep -E $grep| cut -d ':' -f 2,3 | sed -e s/'<'/''/ -e s/'>'/''/ >> $all
cp $all $work
while [ `wc -l $work | cut -d ' ' -f 1` -gt 0 ]
do
	for list in $(cat $work); do apt-cache depends $list | grep -E $grep | cut -d ':' -f 2,3 | sed -e s/'<'/''/ -e s/'>'/''/ >> $tmp 2>> $err;done
	diff <(cat $all|sort) <(cat $tmp|sort) | grep -E ^\> |uniq -d |sed -e 's/^> //g'> $work
	cat $work >> $all
	rm $tmp
done
sort $all |uniq > $work; mv $work $all
for i in $(cat $all); do apt-get download $i 2>>$err; done

