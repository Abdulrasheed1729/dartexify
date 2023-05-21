SOURCES=hello-dartexify.tex
PDF_OBJECTS=$(SOURCES:.tex=.pdf)

LATEXMK=latexmk
LATEXMK_OPTIONS=-bibtex -pdf -f

run:
	$(LATEXMK) $(SOURCES) $(LATEXMK_OPTIONS_EXTRA) $(LATEXMK_OPTIONS)

clean:
	-$(LATEXMK) -bibtex -CA
