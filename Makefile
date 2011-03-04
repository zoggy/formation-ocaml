LATEX=pdflatex
BIBTEX=bibtex
HEVEA=hevea
HACHA=hacha
OCAML=ocaml
OCAMLC=ocamlc.opt -dtypes
HIGHLIGHT=highlight

PDF=formation_ocaml.pdf
HTML=$(PDF:.pdf=.html)
SKEL_TEX=$(PDF:.pdf=.tex)
TEX=formation.tex
XML=$(TEX:.tex=.xml)

RM=rm -f
MKDIR=mkdir -p

GEN_TEX=gen_tex.x

pdf: $(PDF)
all: pdf html
html: $(HTML)

$(PDF): $(SKEL_TEX) $(TEX)
	$(LATEX) $<
	$(LATEX) $<
	$(LATEX) $<

$(TEX): $(XML) $(GEN_TEX)
	./$(GEN_TEX) $< | grep -v "mbox{}" > $@

$(HTML): $(SKEL_TEX) $(TEX)
	$(HEVEA) $<
	$(HEVEA) $<
	$(HACHA) -tocbis $@
	rpl "<BODY >" "<BODY><CENTER><DIV class=\"contents\">" *.html
	rpl "</BODY>" "</DIV></CENTER><BODY>" *.html
	$(MKDIR) html
	mv *.html html/
	cp images/warning.png images/expand_collapse.png images/draft.png images/*.gif *.gif html/
	cp ocaml.png fond.png html/
	cp style.css html/

CAMLSRCDIR=/home/guesdon/devel/ocaml-3.12
$(GEN_TEX): gen_tex.ml mon_module.cmo mon_module2.cmo
	$(OCAMLC) -o $@ \
	`ocamlfind query -i-format pcre` \
	-I $(CAMLSRCDIR)/parsing \
	-I $(CAMLSRCDIR)/driver \
	-linkall \
	unix.cma str.cma toplevellib.cma pcre.cma xml-light.cma $<

clean:
	$(RM) *.cm* $(GEN_TEX) *.annot *.o
	$(RM) $(TEX) $(PDF) $(HTML) *.html *.htoc *.toc *.log *.haux *.aux

mon_module.cmo: mon_module.ml
	$(OCAMLC) -c $<

mon_module2.cmo: mon_module2.ml
	$(OCAMLC) -c $<

# install web page
installweb: all
	scp -r web/index.html web/style.css html formation_ocaml.pdf \
	zoggy@ocamlcore.org:/home/groups/form-ocaml/htdocs/
