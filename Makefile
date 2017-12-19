## NOTES ##
# Voir : https://github.com/ResponSySS/responsyss.github.io/wiki/Générer-les-PDFs
# TODO: arranger la partie 'test'
# TODO: how to handle/trap errors?
# TODO: faire une target pour 'ln -s sous_doss/* .' les images d'un texte?

SHELL = /bin/bash
# Path to script
GEN_SCRIPT = ./pdc_gen/pdc_gen.sh
# Root dir for searching files
ROOT = ./textes/
PDC_ARG = -V documentclass=book
# Templates
TEMPLATE_PDF =  ./pdc_gen/template.pdf.pandoc
TEMPLATE_EPUB = ./pdc_gen/template.epub.pandoc
# File for testing
TEST_IN = ./textes/internationale_situationniste/de_la_misère_en_milieu_étudiant.md
TEST_OUT_PDF = /tmp/test.pdf
TEST_OUT_EPUB = /tmp/test.epub

help:
	@echo "Targets:"
	@echo "    test   - Test generation of PDFs and EPUBs and check out result"
	@echo "    all    - Build all targets marked with [*]"
	@echo " *  pdf    - Build all PDFs"
	@echo " *  epub   - Build all EPUBs"
	@echo
	@echo "$(MAKE) ROOT=/path/to/dir/ [TARGET(S)]"
	@echo "    Set root dir for searching files to '/path/to/dir/' (defaults to '$(ROOT)')"
	@echo
	@echo "Examples:"
	@echo "    $(MAKE) ROOT=./textes/guy_debord/ pdf"
	@echo "        Recursively build PDF files from MD files in ./textes/guy_debord/**"
	@echo
	@echo "For further info, see '$(GEN_SCRIPT) --help'"

all: pdf epub

test: $(TEMPLATE_PDF) $(TEMPLATE_EPUB) $(TEST_IN)
	pandoc --template="$(TEMPLATE_PDF)"  $(PDC_ARG) -o $(TEST_OUT_PDF)  <$(TEST_IN) 
	@echo ":: PDF: SUCCESS!"
	pandoc --template="$(TEMPLATE_EPUB)" $(PDC_ARG) -o $(TEST_OUT_EPUB) <$(TEST_IN)
	@echo ":: EPUB: SUCCESS!"
	@xdg-open $(TEST_OUT_PDF) || echo ":: NO PROGRAM TO OPEN '$(TEST_OUT_PDF)'"
	#@xdg-open $(TEST_OUT_EPUB) || echo ":: NO PROGRAM TO OPEN '$(TEST_OUT_EPUB)'"

pdf: $(GEN_SCRIPT) $(TEMPLATE_PDF) $(ROOT)
	$(GEN_SCRIPT) -i md -o pdf  -j 1 -p -a "--template=$(TEMPLATE_PDF) $(PDC_ARG)" $(ROOT)

epub: $(GEN_SCRIPT) $(TEMPLATE_EPUB) $(ROOT)
	$(GEN_SCRIPT) -i md -o epub -j 2    -a "--template=$(TEMPLATE_EPUB) $(PDC_ARG)" $(ROOT)
