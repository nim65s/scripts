#!/bin/bash
# option : "-r" => remove
# option : "-d" => ne pas creer de dossier
# option : "-h" => aide
#TODO : si plus de 5 charactères sont similaires sur des fichiers différents => dans le meme dossier
#TODO : if exist *.zip do for ZIP... DONE... Ou presque
#TODO : si il n'y a qu'un dossier dans l'archive => ne pas créer de dossier
#TODO : bug avec des parentheses, notamment dans un rar ?
IFS=$'\n'

case $1 in
  h | -h | help | --help)
    echo "help";
    ;;
  d | -d)
    if [ `echo *.zip | grep -v *.zip | wc -l` -gt 0 ]
      then
	for ZIP in `ls *.zip`
	  do
	    unzip $ZIP
	  done
      fi
    if [ `echo *.rar | grep -v *.rar | wc -l` -gt 0 ]
      then
	for RAR in `ls *.rar`
	  do
	    unrar x $RAR
	  done
      fi
    if [ `echo *.tar | grep -v *.tar | wc -l` -gt 0 ]
      then
	for TAR in `ls *.tar`
	  do
	    tar -xvf $TAR
	  done
      fi
    if [ `echo *.tar.gz | grep -v *.tar.gz | wc -l` -gt 0 ]
      then
	for TGZ in `ls *.tar.gz`
	  do
	    tar -zxvf $TAR
	  done
      fi
    if [ `echo *.tar.bz2 | grep -v *.tar.bz2 | wc -l` -gt 0 ]
      then
	for TBZ in `ls *.tar.bz2`
	  do
	    tar -jxvf $TBZ
	  done
      fi
    if [ `echo *.7z | grep -v *.7z | wc -l` -gt 0 ]
      then
	for PSZ in `ls *.7z`
	  do
	    7z e $PSZ
	  done
      fi
    if [ `echo *.bz2 | grep -v *.bz2 | wc -l` -gt 0 ]
      then
	for BZ in `ls *.bz2`
	  do
	    bunzip2 $BZ
	  done
      fi
    if [ `echo *.gz | grep -v *.gz | wc -l` -gt 0 ]
      then
	for GZ in `ls *.gz`
	  do
	    7z e $GZ
	  done
      fi
    ;;
  dr | rd | -dr | -rd)
    if [ `echo *.zip | grep -v *.zip | wc -l` -gt 0 ]
      then
	for ZIP in `ls *.zip`
	  do
	    unzip $ZIP
	    rm $ZIP
	  done
      fi
    if [ `echo *.rar | grep -v *.rar | wc -l` -gt 0 ]
      then
	for RAR in `ls *.rar`
	  do
	    unrar x $RAR
	    rm $RAR
	  done
      fi
    if [ `echo *.tar | grep -v *.tar | wc -l` -gt 0 ]
      then
	for TAR in `ls *.tar`
	  do
	    tar -xvf $TAR
	    rm $TAR
	  done
      fi
    if [ `echo *.tar.gz | grep -v *.tar.gz | wc -l` -gt 0 ]
      then
	for TGZ in `ls *.tar.gz`
	  do
	    tar -zxvf $TAR
	    rm $TGZ
	  done
      fi
    if [ `echo *.tar.bz2 | grep -v *.tar.bz2 | wc -l` -gt 0 ]
      then
	for TBZ in `ls *.tar.bz2`
	  do
	    tar -jxvf $TBZ
	    rm $TBZ
	  done
      fi
    if [ `echo *.7z | grep -v *.7z | wc -l` -gt 0 ]
      then
	for PSZ in `ls *.7z`
	  do
	    7z e $PSZ
	    rm $PSZ
	  done
      fi
    if [ `echo *.bz2 | grep -v *.bz2 | wc -l` -gt 0 ]
      then
	for BZ in `ls *.bz2`
	  do
	    bunzip2 $BZ
	    rm $BZ
	  done
      fi
    if [ `echo *.gz | grep -v *.gz | wc -l` -gt 0 ]
      then
	for GZ in `ls *.gz`
	  do
	    7z e $GZ
	    rm $GZ
	  done
      fi
    ;;
  *)
    if [ `echo *.zip | grep -v *.zip | wc -l` -gt 0 ]
      then
	for ZIP in `ls *.zip | sed 's/.zip//'`
		do
			mkdir $ZIP
			mv $ZIP.zip $ZIP/
			cd $ZIP
			unzip $ZIP
			if [[ "$1" == "-r" ]]
				then
					rm $ZIP.zip
				fi
			cd ../
		done
      fi
    if [ `echo *.rar | grep -v *.rar | wc -l` -gt 0 ]
      then
	for RAR in `ls *.rar | sed 's/.rar//'`
		do
			mkdir $RAR
			mv $RAR.rar $RAR/
			cd $RAR
			unrar x $RAR
			if [[ "$1" == "-r" ]]
				then
					rm $RAR.rar
				fi
			cd ../
		done
      fi
    if [ `echo *.tar | grep -v *.tar | wc -l` -gt 0 ]
      then
	for TAR in `ls *.tar | sed 's/.tar//'`
		do
			mkdir $TAR
			mv $TAR.tar $TAR/
			cd $TAR
			tar -xvf $TAR.tar
			if [[ "$1" == "-r" ]]
				then
					rm $TAR.tar
				fi
			cd ../
		done
      fi
    if [ `echo *.tar.gz | grep -v *.tar.gz | wc -l` -gt 0 ]
      then
	for TGZ in `ls *.tar.gz | sed 's/.tar.gz//'`
		do
			mkdir $TGZ
			mv $TGZ.tar.gz $TGZ/
			cd $TGZ/
			tar -zxvf $TAR.tar.gz
			if [[ "$1" == "-r" ]]
				then
					rm $TGZ.tar.gz
				fi
			cd ../
		done
      fi
    if [ `echo *.tar.bz2 | grep -v *.tar.bz2 | wc -l` -gt 0 ]
      then
	for TBZ in `ls *.tar.bz2 | sed 's/.tar.bz2//'`
		do
			mkdir $TBZ
			mv $TBZ.tar.bz2 $TBZ/
			cd $TBZ/
			tar -jxvf $TBZ.tar.bz2
			if [[ "$1" == "-r" ]]
				then
					rm $TBZ.tar.bz2
				fi
			cd ../
		done
      fi
    if [ `echo *.7z | grep -v *.7z | wc -l` -gt 0 ]
      then
	for PSZ in `ls *.7z | sed 's/.7z//'`
		do
			mkdir $PSZ
			mv $PSZ.7z $PSZ/
			cd $PSZ/
			7z e $PSZ.7z
			if [[ "$1" == "-r" ]]
				then
					rm $PSZ.7z
				fi
			cd ../
		done
      fi
    if [ `echo *.bz2 | grep -v *.bz2 | wc -l` -gt 0 ]
      then
	for BZ in `ls *.bz2 | sed 's/.bz2//'`
		do
			mkdir $BZ
			mv $BZ.bz2 $BZ/
			cd $BZ/
			bunzip2 $BZ.bz2
			if [[ "$1" == "-r" ]]
				then
					rm $BZ.bz2
				fi
			cd ../
		done
      fi
    if [ `echo *.gz | grep -v *.gz | wc -l` -gt 0 ]
      then
	for GZ in `ls *.gz | sed 's/.gz//'`
		do
			mkdir $GZ
			mv $GZ.gz $GZ/
			cd $GZ/
			7z e $GZ.gz
			if [[ "$1" == "-r" ]]
				then
					rm $GZ.gz
				fi
			cd ../
		done
      fi
    ;;
  esac
exit
