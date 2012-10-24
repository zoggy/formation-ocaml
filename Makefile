STOG=stog.byte
DEST_DIR=/tmp/form-ocaml
BASE_URL_OPTION=
STOG_OPTIONS=-d $(DEST_DIR) $(BASE_URL_OPTION) --package stog-writing -v

build:
	rm -fr $(DEST_DIR)
	$(STOG) $(STOG_OPTIONS) .
	$(MAKE) style

style:
	lessc less/style.less > $(DEST_DIR)/style.css

test:
	$(MAKE) BASE_URL_OPTION="--site-url file://$(DEST_DIR)" build

#install: build
#	scp $(DEST_DIR)/* yquem.inria.fr:public_html/
#
#installhtml: build
#	scp $(DEST_DIR)/*.html yquem.inria.fr:public_html/
