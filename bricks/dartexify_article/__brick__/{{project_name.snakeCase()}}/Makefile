PROJECTNAME={{project_name.paramCase()}}
BUILDDIR=build

.PHONY: $(PROJECTNAME).pdf all clean

all: $(PROJECTNAME).pdf

$(PROJECTNAME).pdf: $(PROJECTNAME).tex
	latexmk -pdf -synctex=1 -verbose -bibtex -interaction=nonstopmode -file-line-error -output-directory=$(BUILDDIR) $<

clean:
	latexmk -output-directory=$(BUILDDIR) -c && rm -rf build/*