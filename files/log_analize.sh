#!/bin/bash

lockfile=/tmp/localfile

if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null;
then
	trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
	x=4 # число IP адресов с наибольшим количеством запросов
	y=5 # число запрашиваемых адресов с наибольшим количеством запросов
	path1=~/files/ # расположение лога
	email=mashchensky@ya.ru

	function getnum {
		awk '{print '"$"$1'}' $path1"tmp.log" | sort | uniq -c | sort -t " " -n -r
	}

	log_path=$(find $path1 -name 'access*.log' | head -1)
	touch $log_path.old
	ntime=$(date)
	touch $log_path.time
	otime=$(cat $log_path.time)
	echo "Отчет с $otime по $ntime" > mail.txt
	echo $ntime > $log_path.time 
	grep -F -v -f $log_path.old $log_path > $path1"tmp.log"
	echo "IP с наибольшим числом запросов" >> mail.txt
	getnum 1 | head -$x >> mail.txt
	echo "Самые часто используемые адреса запросов" >> mail.txt
	getnum 7 | head -$y >> mail.txt
	echo "Коды запросов" >> mail.txt
	getnum 9 >> mail.txt
	echo "Коды ошибок" >> mail.txt
	awk '{print $9}' $path1"tmp.log" | sort | uniq | grep [3-5][0-9][0-9] >> mail.txt
	rm -f $path1"tmp.log"
	mail -s "log stats" $email < mail.txt
	rm -f mail.txt
   	ls -ld ${lockfile}
	cat $log_path > $log_path.old
	rm -f "$lockfile"
	trap - INT TERM EXIT
else
	echo "Failed to acquire lockfile: $lockfile."
fi

