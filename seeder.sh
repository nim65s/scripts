#!/bin/bash

cd 
	>1null.torrent
	mv *.torrent /media/320/Downloads/rtorrent
	cp .rtorrent.rc.seed .rtorrent.rc

cd Documents
	> 2null.torrent
	mv *.torrent /media/320/Downloads/rtorrent

cd ../down
	> 3null.torrent
	mv *.torrent /media/320/Downloads/rtorrent

cd ../leech
	> 4null.torrent
	mv *.torrent /media/320/Downloads/rtorrent
	> 5null.torrent
	mv * /media/320/Downloads

cd ../dccrecv
	> 6null.torrent
	mv * /media/320/Downloads

cd /media/320/Downloads
	rm *null.torrent
cd rtorrent/
	rm *null.torrent

rtorrent

exit
