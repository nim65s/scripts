#!/bin/bash

cd 
	>1null.torrent
	mv *.torrent /home/nim/leech
	cp .rtorrent.rc.leech .rtorrent.rc

cd Documents
	> 2null.torrent
	mv *.torrent /home/nim/leech

cd ../down
	> 3null.torrent
	mv *.torrent /home/nim/leech

cd ../leech
	rm *null.torrent

rtorrent

exit
