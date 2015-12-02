#!/bin/bash


ls | grep -q .tex || exit 1

echo -n all: > Makefile

for file in *.tex
do echo -n " ${file/.tex/.pdf}" >> Makefile
done

echo >> Makefile
echo >> Makefile

echo '%.pdf: %.tex' >> Makefile
echo -en "\t" >> Makefile
echo 'latexmk -pdf -pdflatex="$(shell grep -q xunicode $< && echo xe || echo pdf)latex" $<' >> Makefile

echo >> Makefile

echo 'clean:' >> Makefile
echo -en "\t" >> Makefile
echo '-rm -vf *.aux *.log *.nav *.out *.snm *.toc *.tmp *.tns *.pyg *.vrb *~ *.orig *.gnuplot *.table *.fls *.fdb_latexmk *.blg *.bbl 2> /dev/null' >> Makefile

cat Makefile
