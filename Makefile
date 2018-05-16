## NOTES ##
# Voir : https://github.com/ResponSySS/responsyss.github.io/wiki/Générer-les-PDFs

SHELL = /bin/bash
VIM = vim
# Path to scripts
GEN_SCRIPT = ./build_aux/pdc-gen.sh
VIM_SCRIPT = ./build_aux/correct.vim
# List of dependencies
define DEPS_PKG
	haskell-pandoc-types    [1.17.4.2-1]
	haskell-texmath     	[0.10.1.1-16]
	pandoc     		[2.1.3-11]
	pandoc-citeproc     	[0.13.0.1-52]
	pandoc-crossref     	[0.3.0.3-12]
	texinfo     		[6.5-1]
	texlive-bin 		[2017.44590-11]
	texlive-core     	[2017.46770-1]
	texlive-latexextra     	[2017.46778-1]
	texlive-lang-french 	(on Debian-based OSes)
endef
# Root dir for searching files
SEARCH_PATH = ./textes/
ifdef IN
	SEARCH_PATH = $(IN)
endif
# NOTE: 'fail-if-warnings' fails to fail when images not found for PDF; problem 
# is known among Pandoc folks
PDC_ARG = --fail-if-warnings -V documentclass=book -V lang=fr-FR -s
# Templates
TEMPLATE_PDF =  ./build_aux/template.pdf.pandoc
TEMPLATE_EPUB = ./build_aux/template.epub.pandoc
# File for testing
TEST_IN = ./textes/internationale_situationniste/de_la_misère_en_milieu_étudiant.md
ifdef IN
	TEST_IN = $(IN)
endif
OUT_TEST_PDF = /tmp/test.pdf
OUT_TEST_EPUB = /tmp/test.epub
# File for vim correction script
IN =

help:
	@echo "TARGETS"
	@echo "    all              - Build targets marked with '*'"
	@echo " *  pdf              - Build PDF(s)"
	@echo " *  epub             - Build EPUB(s)"
	@echo "    deps             - List dependencies"
	@echo "    test             - Test generation of a PDF and an EPUB and check out result"
	@echo "    test-pdf         - Test generation of a PDF and check out result"
	@echo "    test-epub        - Test generation of an EPUB"
	@echo "    vim-correct      - Trigger vim typographic correction script"
	@echo "    vim-uncorrect    - Trigger vim uncorrection script for removing non-breakable spaces"
	@echo "    clean            - Remove built PDFs and EPUBs under $(SEARCH_PATH)"
	@echo "    clean-test       - Remove test output files"
	@echo
	@echo "PARAMETERS"
	@echo "    $(MAKE)  IN=/path/to/dir/     {all|pdf|epub}"
	@echo "        Set search path/input file for PDF/EPUB generation (defaults to '$(SEARCH_PATH)')"
	@echo "    $(MAKE)  IN=test_me.md OUT_TEST_PDF=outfile   {test|test-pdf}"
	@echo "        For PDF testing, set intput file to 'test_me.md' (defaults to '$(TEST_IN)')"
	@echo "         and output file to 'outfile' (defaults to '$(OUT_TEST_PDF)')"
	@echo "    $(MAKE)  IN=test_me.md OUT_TEST_EPUB=outfile  {test|test-epub}"
	@echo "        For EPUB testing, set intput file to 'test_me.md' (defaults to '$(TEST_IN)')"
	@echo "         and output file to 'outfile' (defaults to '$(OUT_TEST_EPUB)')"
	@echo "    $(MAKE)  IN=infile.md              vim-[un]correct"
	@echo "        Set input file for vim [un]correction script to 'infile.md'"
	@echo
	@echo "EXAMPLES"
	@echo "    $(MAKE) deps"
	@echo "        Run this first to make sure you have everything it needs"
	@echo "    $(MAKE) IN=./textes/guy_debord/ all"
	@echo "        Recursively build PDF and EPUB files from MD files in ./textes/guy_debord/**"
	@echo "    $(MAKE) IN=./textes/karlos_marakas/allumez_le_feu.md pdf"
	@echo "        Build PDF from ./textes/karlos_marakas/allumez_le_feu.md"
	@echo "    $(MAKE) OUT_TEST_EPUB=/media/KOBOeReader/test.epub OUT_TEST_PDF=/media/KOBOeReader/test.pdf test"
	@echo "    $(MAKE) IN=./textes/guy_debord/notes_sur_la_question_des_immigrés.md test-pdf"
	@echo "    $(MAKE) IN=./textes/pierre_guillaume/guy_debord.md vim-correct"
	@echo
	@echo "Script used for PDF and EPUB generation: $(GEN_SCRIPT) (see '$(GEN_SCRIPT) --help')"
	@echo "Script used for typographic correction:  $(VIM_SCRIPT)"

all: pdf epub

pdf: $(GEN_SCRIPT) $(TEMPLATE_PDF) $(SEARCH_PATH)
	$(GEN_SCRIPT) -i md -o pdf  -j 1 -p -a "--template=$(TEMPLATE_PDF) $(PDC_ARG)" $(SEARCH_PATH)

epub: $(GEN_SCRIPT) $(TEMPLATE_EPUB) $(SEARCH_PATH)
	$(GEN_SCRIPT) -i md -o epub -j 2    -a "--template=$(TEMPLATE_EPUB) $(PDC_ARG)" $(SEARCH_PATH)

# Export variables to echo multiline bash variables from outside this Makefile
export DEPS_PKG
deps:
	@echo "[MAKE] Required dependencies:"
	@echo "$$DEPS_PKG"
	@[[ "`latex --version | head -1 | cut -d' ' -f2- | cut -d'.' -f1`"  = "3" ]] && echo ":: Successful version check for 'latex/pdftex'"   || echo ":: ERROR: please update texlive/latex to v3.0 or higher"
	@[[ "`pandoc --version | head -1 | cut -d' ' -f2- | cut -d'.' -f1`" = "2" ]] && echo ":: Successful version check for 'pandoc'"         || echo ":: ERROR: please update 'pandoc' to v2.0.0 or higher"

test: test-pdf test-epub

test-epub: $(TEMPLATE_EPUB) $(TEST_IN)
	pandoc --template="$(TEMPLATE_EPUB)" $(PDC_ARG) --resource-path=`dirname $(TEST_IN)` -o $(OUT_TEST_EPUB) <$(TEST_IN)
	@echo "[MAKE] EPUB: SUCCESS!"
	@echo "[MAKE] Output was made to '$(OUT_TEST_EPUB)'"
#@xdg-open $(OUT_TEST_EPUB) || echo ":: NO PROGRAM TO OPEN '$(OUT_TEST_EPUB)'"

test-pdf: $(TEMPLATE_PDF) $(TEST_IN)
	pandoc --template="$(TEMPLATE_PDF)"  $(PDC_ARG) --resource-path=`dirname $(TEST_IN)` -o $(OUT_TEST_PDF)  <$(TEST_IN) 
	@echo "[MAKE] PDF: SUCCESS!"
	@echo "[MAKE] Output was made to '$(OUT_TEST_PDF)'"
	@xdg-open $(OUT_TEST_PDF) || echo "[MAKE] NO PROGRAM TO OPEN '$(OUT_TEST_PDF)'"

clean:
	find $(SEARCH_PATH) -type f -iregex ".*[.]\(pdf\|epub\)" -ok rm -v '{}' ';'

clean-test: 
	touch $(OUT_TEST_PDF) $(OUT_TEST_EPUB) && rm -v $(OUT_TEST_PDF) $(OUT_TEST_EPUB)

vim-correct: $(VIM_SCRIPT) $(IN)
ifndef IN
	$(error [MAKE] Please set 'IN' for input file (see 'make help'))
endif
	$(VIM) -c ":e $(IN) | :source $(VIM_SCRIPT)"

vim-uncorrect: $(IN)
ifndef IN
	$(error [MAKE] Please set 'IN' for input file (see 'make help'))
endif
	$(VIM) -c ":e $(IN) | :%s/&nbsp;/ /gc"
