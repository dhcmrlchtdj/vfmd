OCB_FLAGS := \
	-tag 'color(always)' \
	-tag safe_string \
	-tag short_paths \
	-tag strict_sequence \
	-tag keep_locs \
	-tag keep_docs \
	-tag bin_annot \
	-tag principal \
	-tag nopervasives \
	-use-ocamlfind \
	-pkg batteries \
	-pkg re \
	-tags 'warn(+a-4),warn_error(-a+31)'
OCB := ocamlbuild $(OCB_FLAGS)

mlis := $(patsubst %.ml,%,$(wildcard src/*.ml))

.PHONY: main
main: native

.PHONY: byte
byte: $(mlis)
	@$(OCB) src/main.byte

.PHONY: native
native: $(mlis)
	@$(OCB) src/main.native

.PHONY: jsoo
jsoo: byte
	js_of_ocaml --opt=3 --pretty +nat.js ./main.byte

.PHONY: $(mlis)
$(mlis):
	-@$(OCB) $@.inferred.mli

.PHONY: clean
clean:
	@ocamlbuild -clean
	@rm -f ./main.js

.PHONY: fmt
fmt:
	@ocamlformat -i src/*.ml
	@ocp-indent -i src/*.ml

.PHONY: test
test: native
	echo '# header\nThe **`ls` command** [_lists_ files](/ls-cmd).' | ./main.native -
