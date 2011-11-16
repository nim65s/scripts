all: rapport.pdf clean

%.pdf: %.tex
	( ( xelatex -shell-escape $< || ( rm $@ && false ) ) && xelatex -shell-escape $< || ( rm $@ && false ) ) && xelatex -shell-escape $<

clean:
	-rm -vf *.aux *.log *.nav *.out *.snm *.toc *.tmp *~ 2> /dev/null
