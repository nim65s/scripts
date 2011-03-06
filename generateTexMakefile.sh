#!/bin/bash

echo -n "all: " >> Makefile
for FILE in *.tex
do
        echo -n "$(echo "$FILE " | grep -v '*' | sed 's/tex/pdf/')" >> Makefile
done
echo >> Makefile
echo >> Makefile

for FILE in *.tex
do
        echo "$( echo $FILE | sed 's/tex/pdf/'): $FILE" >> Makefile
        echo >> Makefile
done

echo '%.pdf: %.tex' >> Makefile
echo '    ( pdflatex $< || ( rm $@ && false ) ) && pdflatex $<' >> Makefile
