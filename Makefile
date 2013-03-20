STOG=stog
DEST_DIR=/tmp/form-ocaml
BASE_URL_OPTION=
STOG_OPTIONS=--default-lang fr -v -v -d $(DEST_DIR) $(BASE_URL_OPTION) --package stog-writing --plugin $(PLUGIN)
MORE_OPTIONS=

EXERCICES=count_words.cmo \
	count_words_dict.cmo \
	diff_words.cmo \
	exercice_arg.cmo \
	lstmp.cmo \
	mon_module.cmo \
	mon_module2.cmo \
	printenv.cmo \
	words.cmo

PLUGIN=stog_course.cmxs

build: $(EXERCICES) $(BLOG_EXAMPLES) $(PLUGIN)
#	rm -fr $(DEST_DIR)
	$(STOG) $(STOG_OPTIONS) $(MORE_OPTIONS) .  # --only slides/slides
	cp -f slide_arbre*.png $(DEST_DIR)/slides/
	$(MAKE) style

clean:
	rm -f $(PLUGIN)
	rm -f $(BLOG_EXAMPLES)
	rm -f *.cm? posts/*.cm?

style:
	lessc less/style.less > $(DEST_DIR)/style.css

test:
	$(MAKE) BASE_URL_OPTION="--site-url file://$(DEST_DIR)" build

nocache:
	$(MAKE) MORE_OPTIONS=--nocache test

.SUFFIXES: .ml .cmo

%.cmo: %.ml
	ocamlfind ocamlc -package stog -rectypes -c $<

%.cmxs: %.ml
	ocamlfind ocamlopt -shared -package stog -rectypes -o $@  $<

installweb: build
	scp -r $(DEST_DIR)/* zoggy@ocamlcore.org:/home/groups/form-ocaml/htdocs/

blog_examples: $(BLOG_EXAMPLES)
BLOG_EXAMPLES= \
	posts/date_du_jour \
	posts/code_morse

posts/date_du_jour: posts/date_du_jour.ml
	ocamlopt -o $@ unix.cmxa $^
posts/code_morse: posts/code_morse.ml
	ocamlopt -o $@ $^
	