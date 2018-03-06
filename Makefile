## NOTES ##
# Voir : https://github.com/ResponSySS/responsyss.github.io/wiki/Générer-les-PDFs

SHELL = /bin/bash
VIM = vim
# Path to scripts
GEN_SCRIPT = ./build_aux/pdc_gen.sh
VIM_SCRIPT = ./build_aux/correct.vim
# Root dir for searching files
SEARCH_PATH = ./textes/
ifdef IN
	SEARCH_PATH = $(IN)
endif
# TODO: fail-if-warnings fails to fail when images not found for PDF!
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
	@echo "    all              - Build all targets marked with '*'"
	@echo " *  pdf              - Build all PDFs"
	@echo " *  epub             - Build all EPUBs"
	@echo "    test             - Test generation for PDFs and EPUBs and check out result"
	@echo "    test-pdf         - Test generation for PDFs and check out result"
	@echo "    test-epub        - Test generation for EPUBs"
	@echo "    vim-correct      - Trigger vim typographic correction script"
	@echo "    vim-uncorrect    - Trigger vim uncorrection script for removing non-breakable spaces"
	@echo
	@echo "PARAMETERS"
	@echo "    $(MAKE)  IN=/path/to/dir/     {all|pdf|epub}"
	@echo "        Set root dir for searching files to '/path/to/dir/' (defaults to '$(SEARCH_PATH)')"
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
	@echo "    $(MAKE) IN=./textes/guy_debord/ pdf"
	@echo "        Recursively build PDF files from MD files in ./textes/guy_debord/**"
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

test: test-pdf test-epub

test-epub: $(TEMPLATE_EPUB) $(TEST_IN)
	pandoc --template="$(TEMPLATE_EPUB)" $(PDC_ARG) --resource-path=`dirname $(TEST_IN)` -o $(OUT_TEST_EPUB) <$(TEST_IN)
	@echo ":: EPUB: SUCCESS!"
	@echo ":: Output was made to '$(OUT_TEST_EPUB)'"
#@xdg-open $(OUT_TEST_EPUB) || echo ":: NO PROGRAM TO OPEN '$(OUT_TEST_EPUB)'"

test-pdf: $(TEMPLATE_PDF) $(TEST_IN)
	pandoc --template="$(TEMPLATE_PDF)"  $(PDC_ARG) --resource-path=`dirname $(TEST_IN)` -o $(OUT_TEST_PDF)  <$(TEST_IN) 
	@echo ":: PDF: SUCCESS!"
	@echo ":: Output was made to '$(OUT_TEST_PDF)'"
	@xdg-open $(OUT_TEST_PDF) || echo ":: NO PROGRAM TO OPEN '$(OUT_TEST_PDF)'"

clean-test: 
	touch $(OUT_TEST_PDF) $(OUT_TEST_EPUB) && rm $(OUT_TEST_PDF) $(OUT_TEST_EPUB)

vim-correct: $(VIM_SCRIPT) $(IN)
ifndef IN
	$(error Please set 'IN' for input file (see 'make help'))
endif
	$(VIM) -c ":e $(IN) | :source $(VIM_SCRIPT)"

vim-uncorrect: $(IN)
ifndef IN
	$(error Please set 'IN' for input file (see 'make help'))
endif
	$(VIM) -c ":e $(IN) | :%s/&nbsp;/ /gc"
