STOG=stog.byte
DEST_DIR=/tmp/form-ocaml
BASE_URL_OPTION=
STOG_OPTIONS=-d $(DEST_DIR) $(BASE_URL_OPTION) --package stog-writing --plugin $(PLUGIN) -v

EXERCICES=count_words.cmo \
	count_words_dict.cmo \
	diff_words.cmo \
	exercice_arg.cmo \
	lstmp.cmo \
	mon_module.cmo \
	mon_module2.cmo \
	printenv.cmo \
	words.cmo

PLUGIN=stog_course.cmo

build: $(EXERCICES) $(PLUGIN)
	rm -fr $(DEST_DIR)
	$(STOG) $(STOG_OPTIONS) .
	$(MAKE) style

style:
	lessc less/style.less > $(DEST_DIR)/style.css

test:
	$(MAKE) BASE_URL_OPTION="--site-url file://$(DEST_DIR)" build

.SUFFIXES: .ml .cmo

%.cmo: %.ml
	ocamlfind ocamlc -package stog -rectypes -c $<

installweb: build
	scp -r $(DEST_DIR)/* zoggy@ocamlcore.org:/home/groups/form-ocaml/htdocs/
