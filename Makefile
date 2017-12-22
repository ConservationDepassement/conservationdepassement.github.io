## NOTES ##
# Voir : https://github.com/ResponSySS/responsyss.github.io/wiki/Générer-les-PDFs
# TODO: arranger la partie 'test'
# TODO: how to handle/trap errors?
# TODO: faire une target pour 'ln -s sous_doss/* .' les images d'un texte?

SHELL = /bin/bash
VIM = vim
# Path to scripts
GEN_SCRIPT = ./build_aux/pdc_gen.sh
VIM_SCRIPT = ./build_aux/correct.vim
# Root dir for searching files
ROOT = ./textes/
PDC_ARG = -V documentclass=book -V lang=fr-FR -s
# Templates
TEMPLATE_PDF =  ./build_aux/template.pdf.pandoc
TEMPLATE_EPUB = ./build_aux/template.epub.pandoc
# File for testing
TEST_IN = ./textes/internationale_situationniste/de_la_misère_en_milieu_étudiant.md
ifdef IN
	TEST_IN = $(IN)
endif
TEST_OUT_PDF = /tmp/test.pdf
TEST_OUT_EPUB = /tmp/test.epub
# File for vim correction script
IN =

help:
	@echo "TARGETS"
	@echo "    all              - Build all targets marked with [*]"
	@echo " *  pdf              - Build all PDFs"
	@echo " *  epub             - Build all EPUBs"
	@echo "    test             - Test generation for PDFs and EPUBs and check out result"
	@echo "    test-pdf         - Test generation for PDFs and check out result"
	@echo "    test-epub        - Test generation for EPUBs"
	@echo "    vim-correct      - Trigger vim typographic correction script"
	@echo
	@echo "PARAMETERS"
	@echo "    $(MAKE)  ROOT=/path/to/dir/     [all|pdf|epub]"
	@echo "        Set root dir for searching files to '/path/to/dir/' (defaults to '$(ROOT)')"
	@echo "    $(MAKE)  IN=test_me.md TEST_OUT_PDF=outfile   [test|test-pdf]"
	@echo "        For PDF testing, set intput file to 'test_me.md' (defaults to '$(TEST_IN)')"
	@echo "         and output file to 'outfile' (defaults to '$(TEST_OUT_PDF)')"
	@echo "    $(MAKE)  IN=test_me.md TEST_OUT_EPUB=outfile  [test|test-epub]"
	@echo "        For EPUB testing, set intput file to 'test_me.md' (defaults to '$(TEST_IN)')"
	@echo "         and output file to 'outfile' (defaults to '$(TEST_OUT_EPUB)')"
	@echo "    $(MAKE)  IN=infile              vim-correct"
	@echo "        Set input file for vim correction script to 'infile'"
	@echo
	@echo "EXAMPLES"
	@echo "    $(MAKE) ROOT=./textes/guy_debord/ pdf"
	@echo "        Recursively build PDF files from MD files in ./textes/guy_debord/**"
	@echo "    $(MAKE) TEST_OUT_EPUB=/media/KOBOeReader/test.epub TEST_OUT_PDF=/media/KOBOeReader/test.pdf test"
	@echo "    $(MAKE) IN=./textes/pierre_guillaume/guy_debord.md vim-correct"
	@echo
	@echo "Script used for PDF and EPUB generation: $(GEN_SCRIPT) (see '$(GEN_SCRIPT) --help')"
	@echo "Script used for typographic correction:  $(VIM_SCRIPT)"

all: pdf epub

pdf: $(GEN_SCRIPT) $(TEMPLATE_PDF) $(ROOT)
	$(GEN_SCRIPT) -i md -o pdf  -j 1 -p -a "--template=$(TEMPLATE_PDF) $(PDC_ARG)" $(ROOT)

epub: $(GEN_SCRIPT) $(TEMPLATE_EPUB) $(ROOT)
	$(GEN_SCRIPT) -i md -o epub -j 2    -a "--template=$(TEMPLATE_EPUB) $(PDC_ARG)" $(ROOT)

test: test-pdf test-epub

test-epub: $(TEMPLATE_EPUB) $(TEST_IN)
	pandoc --template="$(TEMPLATE_EPUB)" $(PDC_ARG) -o $(TEST_OUT_EPUB) <$(TEST_IN)
	$(warning :: EPUB: SUCCESS!)
	$(warning :: Output was made to '$(TEST_OUT_EPUB)')
#@xdg-open $(TEST_OUT_EPUB) || echo ":: NO PROGRAM TO OPEN '$(TEST_OUT_EPUB)'"

test-pdf: $(TEMPLATE_PDF) $(TEST_IN)
	pandoc --template="$(TEMPLATE_PDF)"  $(PDC_ARG) -o $(TEST_OUT_PDF)  <$(TEST_IN) 
	$(warning :: PDF: SUCCESS!)
	$(warning :: Output was made to '$(TEST_OUT_PDF)')
	@xdg-open $(TEST_OUT_PDF) || echo ":: NO PROGRAM TO OPEN '$(TEST_OUT_PDF)'"

test-clean: 
	touch $(TEST_OUT_PDF) $(TEST_OUT_EPUB) && rm $(TEST_OUT_PDF) $(TEST_OUT_EPUB)

vim-correct: $(VIM_SCRIPT) $(IN)
ifndef IN
	$(error Please set 'IN' for input file (see 'make help'))
endif
	@[[ -f "$(IN)" ]]
	$(VIM) -c ":e $(IN) | :source $(VIM_SCRIPT)"
