#!/bin/bash

[[ -f Makefile ]] && rm -v Makefile
[[ -f Makefile.quick ]] && rm -v Makefile.quick

[[ $1 == *x* ]] && TEX="xelatex" || TEX="pdflatex"


echo -n "all: " >> Makefile
for FILE in *.tex
do echo -n "$(echo "$FILE " | grep -v '*' | sed 's/\.tex/.pdf/')" >> Makefile
done
echo clean >> Makefile
echo >> Makefile

echo '%.pdf: %.tex' >> Makefile
echo -en "\t" >> Makefile
if [[ $1 != *m* ]] 
then echo "$TEX -shell-escape $<" >> Makefile
else echo "(( $TEX -shell-escape $< || ( rm \$@ && false )) && $TEX -shell-escape $< || ( rm \$@ && false )) && $TEX -shell-escape $<" >> Makefile
fi
echo >> Makefile
echo 'clean:' >> Makefile
echo -en "\t" >> Makefile
echo '-rm -vf *.aux *.log *.nav *.out *.snm *.toc *.tmp *.tns *.pyg *.vrb *~ 2> /dev/null' >> Makefile

[[ $1 == *m* ]] && sed "s/(( $TEX -shell-escape $< || ( rm \$@ && false )) && $TEX -shell-escape $< || ( rm \$@ && false )) && $TEX -shell-escape $</$TEX -shell-escape $</" Makefile > Makefile.quick

echo "---------Makefile---------"
cat Makefile
if [[ $1 == *m* ]]
then
    echo "------Makefile.quick------"
    cat Makefile.quick
fi
