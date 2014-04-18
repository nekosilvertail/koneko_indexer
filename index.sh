#!/bin/bash 

#this script needs following:
#
# * a data directory for the files, structured as following:
#
# data
# |-folder
# | |-folder
# |   |-file.ext
# |-folder
#   |-file.ext
#
# a data dir, containing folder - no files. 
# folders in data may only contain either files or more folders. do not mix.
# do not use files without extension!
#
# * a file named "shasum" - for determining if there's new files in the data dir
# * a file named "static" - for saving the static generated html code
# * a file named "counter" - for the visitor-counter in the footer, initiate the file with a number! (0 i.e.)
# * a file named "update" - containing the date of the last regeneration of the static base
#
# make sure to make those files writable by everyone.
#
# edit the stylesheet for changing the look and feel
# remove the stylesheet in the html if you want a text-only-version. 
# whole script is GPL. stylesheet is GPL. use at will. 
#
# and don't forget to edit the header and footer functions.
#
# edit these variables to correspond to your setup:
#
# fullpath contains the folder where the script is run from. omit the last /.
fullpath="/var/www/shell"
# data contains the data dir. make sure data is in the folder mentioned under fullpath
datadir="data"
# sitename. just what shows up as page title
sitename="shellneko"
# 
# contact: neko@koneko.at for questions.
#
echo "Content-type: text/html"
echo ""

#counter init
counter=$(echo 1 + `cat counter` | bc)
echo $counter > counter

#dirlevel offset
dirlvl="2"

insFileList(){
	#counts every step a directory is found
	counter=0
	#counts every step, including the end of a line
	counter2=0
	cd $datadir
	genFileList(){
		for i in $(ls -t --group-directories-first)
		do
			
			if [ -d "$i" ]
			then
				counter2=$(($counter2 + 1))
				dirlvl=$(($dirlvl + 1))
				index[$counter]="<div class='idiv$dirlvl'><a href='#$i$counter2'>$i</a></div>"

				counter=$(($counter + 1))
				cd "$i"
				filelist[$counter2]="<div class='div$dirlvl'><br><h$dirlvl id='$i$counter2'>$i</h$dirlvl><br>"
				genFileList
			else
				counter2=$(($counter2 + 1))
				j=$(echo $i | sed s/_/\ /g | sed s/\.[^\.]*$//g)
				i=$(echo `pwd`/$i | sed "s;$fullpath\/;;g")
				filelist[$counter2]=$(echo "<p>[$(stat -c %y $fullpath/$i | cut -d" " -f1 | awk -F"-" {'print "<span class=\047cyear\047>"$1"</span>-<span class=\047cmonth\047>"$2"</span>-<span class=\047cday\047>"$3"</span>"'})] <a href=\"./$i\">"$(echo $j)"</a></p>")
			fi
		done
		counter2=$(($counter2 + 1))
		filelist[$counter2]="</div>"
		dirlvl=$(echo $dirlvl - 1 | bc)
		cd ..
	}
	genFileList
	cd ..
	echo ${index[*]}
	echo "<br><hr>"
	echo ${filelist[*]}
	echo "<br><hr>"
	

}

insHead(){
echo "<!DOCTYPE html>"
echo "<html>"
echo "<!-- minefield project A-XC16, proudly made with bash and html -->"
echo "<!-- (C) 2013 nekosilvertail, cc-sa -->"
echo "<!-- documents: dunno. complaints go to neko@koneko.at -->"
echo "<!-- generated: $(date +%s)U -->"
echo "<head>"
echo "<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>"
echo "<title>$sitename</title>"
echo "<link rel='stylesheet' type='text/css' href='style.css'>"
echo "</head>"
}

insBody(){
echo "<body>"
echo "<div class='body'>"
echo "<h2>Shell script collection</h2>"
echo "<br><hr><br>"

insFileList
}

insFooter(){
echo "<p>anything to add? anything you want to tell me? drop a line: =^__^='~~@koneko.at | Zugriffe -> $(cat $fullpath/counter) | last update -> $(cat $fullpath/update) </p>"
echo "<hr>"

echo "<img src='http://koneko.at/neko/konekomewb.png' class='img' alt='koneko logo, a neko girl with usb tail' />"
echo "</body>"
echo "</html>"
}

chkCurrent(){
	raw=$(ls -R $datadir/)
	sha_neu=$(sha1sum <<< $raw | cut -d"-" -f1)
	sha_alt=$(cat $fullpath/shasum)
	if [ "$sha_neu" == "$sha_alt" ]
	then
		cat $fullpath/static
	else
		echo "$sha_neu" > $fullpath/shasum	
		insHead > $fullpath/static
		insBody >> $fullpath/static
		echo "day: "$(date +%d" month: "%m" year: "%Y", "%s) > $fullpath/update
		cat $fullpath/static
	fi
}

chkCurrent
insFooter
