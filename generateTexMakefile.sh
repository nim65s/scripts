#!/bin/bash

[[ -f Makefile ]] && rm -v Makefile

echo -n "all: " >> Makefile
for FILE in *.tex
do
        echo -n "$(echo "$FILE " | grep -v '*' | sed 's/tex/pdf/')" >> Makefile
done
echo clean >> Makefile
echo >> Makefile

echo '%.pdf: %.tex' >> Makefile
echo -en "\t" >> Makefile
echo '( ( pdflatex -shell-escape $< || ( rm $@ && false ) ) && pdflatex -shell-escape $< || ( rm $@ && false ) ) && pdflatex -shell-escape $<' >> Makefile
echo >> Makefile
echo 'clean:' >> Makefile
echo -en "\t" >> Makefile
echo '-rm -vf *.aux *.log *.nav *.out *.snm *.toc *.tmp *~ 2> /dev/null' >> Makefile


sed 's/( ( pdflatex -shell-escape $< || ( rm $@ && false ) ) && pdflatex -shell-escape $< || ( rm $@ && false ) ) && pdflatex -shell-escape $</pdflatex -shell-escape $</' Makefile > Makefile.quick

chmod +x Makefile Makefile.quick

echo "---------Makefile---------"
cat Makefile
echo "------Makefile.quick------"
cat Makefile.quick
