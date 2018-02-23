STOG=./my-stog
STOG_SERVER=./my-stog-server
PACKAGES=stog-writing,stog.disqus,stog.multi-doc,stog.dot,stog-rdf
DEST_DIR=/tmp/form-ocaml
BASE_URL_OPTION=
ROOT:=`pwd`
OCAML_SESSION=$(ROOT)/my-ocaml-session -w -3 -safe-string `echo \`ocamlfind query -i-format inspect kaputt functory parmap lwt\` -ppx ppx_lwt`
STOG_OPTIONS=--stog-ocaml-session "$(OCAML_SESSION)" --default-lang fr -v -d $(DEST_DIR) $(BASE_URL_OPTION)
MORE_OPTIONS=

EXERCICES=

PLUGIN=stog_course.cmxs

build: my-ocaml-session $(STOG) $(EXERCICES) $(BLOG_EXAMPLES) $(PLUGIN)
#	rm -fr $(DEST_DIR)
	$(STOG) $(STOG_OPTIONS) $(MORE_OPTIONS) .  # --only slides/slides
	cp -f slide_arbre*.png $(DEST_DIR)/slides/
	$(MAKE) style

my-ocaml-session:
	mk-stog-ocaml-session -package inspect,kaputt,functory,parmap,lwt.unix,unix -linkall -o $@

$(STOG):$(PLUGIN:.cmxs=.cmx)
	mk-stog -o $@ -package $(PACKAGES) $^

$(STOG_SERVER):$(PLUGIN:.cmxs=.cmx)
	mk-stog -o $@ -package $(PACKAGES),stog.server -linkall -thread $^

run-server: $(STOG_SERVER)
	$(STOG_SERVER) $(STOG_OPTIONS) .

clean:
	rm -f $(STOG) $(STOG_SERVER)
	rm -f $(PLUGIN) my-ocaml-session
	rm -f $(BLOG_EXAMPLES)
	rm -f *.cm? posts/*.cm? codes/*.cm? *.cmxs codes/*/*.cm*
	rm -f *.o posts/*.o codes/*.o codes/*/*.o
	(cd codes && rm -f \
		imperative/myecho \
		stdlib/myprintenv \
		stdlib/lstmp \
		para/lwt-commands \
		para/lwt-grep \
		para/thread-print \
		para/file*.txt \
		fstclassmod/exemple \
		progmod/mon_programme)
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
	rsync  --checksum -r --delete $(DEST_DIR)/ pi:/var/www-formation-ocaml/
#	rsync  --checksum -r --delete $(DEST_DIR)/ zoggy@ssh.ocamlcore.org:/home/groups/form-ocaml/htdocs/
	#scp -r $(DEST_DIR)/* zoggy@ocamlcore.org:/home/groups/form-ocaml/htdocs/

blog_examples: $(BLOG_EXAMPLES)
BLOG_EXAMPLES= \
	posts/date_du_jour \
	posts/code_morse

posts/date_du_jour: posts/date_du_jour.ml
	ocamlopt -o $@ unix.cmxa $^

posts/code_morse: posts/code_morse.ml
	ocamlopt -o $@ $^

