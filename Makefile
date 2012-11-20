STOG=stog
DEST_DIR=/tmp/form-ocaml
BASE_URL_OPTION=
STOG_OPTIONS=-d $(DEST_DIR) $(BASE_URL_OPTION) --package stog-writing --plugin $(PLUGIN) -v
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

build: $(EXERCICES) $(PLUGIN)
#	rm -fr $(DEST_DIR)
	$(STOG) $(STOG_OPTIONS) $(MORE_OPTIONS) .  # --only slides/slides
	$(MAKE) style

clean:
	rm -f $(PLUGIN)

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
