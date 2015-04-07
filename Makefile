STOG=./my-stog
STOG_SERVER=./my-stog-server
PACKAGES=stog-writing,stog.disqus,stog.multi-doc,stog.dot,stog-rdf
DEST_DIR=/tmp/form-ocaml
BASE_URL_OPTION=
OCAML_SESSION=./my-ocaml-session -w -3 `echo \`ocamlfind query -i-format inspect kaputt functory parmap lwt\``
STOG_OPTIONS=--stog-ocaml-session "$(OCAML_SESSION)" --default-lang fr -v -d $(DEST_DIR) $(BASE_URL_OPTION)
MORE_OPTIONS=

EXERCICES=codes/count_words.cmo \
	codes/count_words_dict.cmo \
	codes/diff_words.cmo \
	codes/exercice_arg.cmo \
	codes/findpar \
	codes/findseq \
	codes/lstmp.cmo \
	codes/lwt-commands \
	codes/lwt-grep \
	codes/mon_module.cmo \
	codes/mon_module2.cmo \
	codes/printenv.cmo \
	codes/thread-print \
	codes/words.cmo \

PLUGIN=stog_course.cmxs

build: my-ocaml-session $(STOG) $(EXERCICES) $(BLOG_EXAMPLES) $(PLUGIN)
#	rm -fr $(DEST_DIR)
	ln -sf codes/mon_module.cmo
	ln -sf codes/mon_module2.cmo
	$(STOG) $(STOG_OPTIONS) $(MORE_OPTIONS) .  # --only slides/slides
	cp -f slide_arbre*.png $(DEST_DIR)/slides/
	$(MAKE) style

my-ocaml-session:
	mk-stog-ocaml-session -package inspect,kaputt,functory,parmap,lwt.unix -linkall -o $@

$(STOG):$(PLUGIN:.cmxs=.cmx)
	mk-stog -o $@ -package $(PACKAGES) $^

$(STOG_SERVER):$(PLUGIN:.cmxs=.cmx)
	mk-stog -o $@ -package $(PACKAGES),stog-server $^

run-server:
	$(STOG_SERVER) $(STOG_OPTIONS) .

clean:
	rm -f $(STOG) $(STOG_SERVER)
	rm -f $(PLUGIN) my-ocaml-session
	rm -f $(BLOG_EXAMPLES)
	rm -f *.cm? posts/*.cm? codes/*.cm? *.cmxs
	rm -f *.o posts/*.o codes/*.o
	rm -fr .stog/cache

style:
	lessc less/style.less > $(DEST_DIR)/style.css

test:
	$(MAKE) BASE_URL_OPTION="--site-url file://$(DEST_DIR)" build

nocache:
	$(MAKE) MORE_OPTIONS=--nocache test

.SUFFIXES: .ml .cmo

%.cmo: %.ml
	ocamlfind ocamlc -package threads,stog -thread -rectypes -c $<

%.cmxs: %.ml
	ocamlfind ocamlopt -shared -package stog -rectypes -o $@  $<

%.cmx: %.ml
	ocamlfind ocamlopt -c -package stog -rectypes  $<

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

codes/thread-print: codes/thread_print.ml
	ocamlopt -thread -o $@ unix.cmxa threads.cmxa $^

codes/findseq: codes/findseq.ml
	ocamlopt -thread -o $@ unix.cmxa $^

codes/findpar: codes/findpar.ml
	ocamlfind ocamlopt -o $@ -package lwt.unix -linkpkg $^

codes/lwt-commands: codes/lwt_commands.mli codes/lwt_commands.ml codes/lwt_commands_test.ml
	ocamlfind ocamlopt -c -package lwt.unix codes/lwt_commands.mli
	ocamlfind ocamlopt -o $@ -I codes -package lwt.unix -linkpkg codes/lwt_commands.ml codes/lwt_commands_test.ml


codes/lwt-grep: codes/lwt_grep.ml
	ocamlfind ocamlopt -rectypes -o $@ -I codes -package lwt.unix,str -linkpkg codes/lwt_grep.ml

