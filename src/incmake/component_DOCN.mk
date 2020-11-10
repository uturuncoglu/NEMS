# Location of the ESMF makefile fragment for this component:
docn_mk = $(DOCN_BINDIR)/docn.mk
all_component_mk_files+=$(docn_mk)

# Need this because cmeps_mk is not available at this level
cdeps_mk = $(ROOTDIR)/CDEPS/CDEPS_INSTALL/cdeps.mk

# Location of source code and installation
DOCN_SRCDIR?=$(ROOTDIR)/DOCN
DOCN_BINDIR?=$(ROOTDIR)/DOCN/DOCN_INSTALL
CDEPS_BINDIR?=$(ROOTDIR)/CDEPS/CDEPS_INSTALL

# Make sure we're setting CDEPS=Y if DOCN is enabled:
ifeq (,$(findstring CDEPS,$(COMPONENTS)))
  $(error DOCN requires CDEPS)
endif

# Rule for building this component:
build_DOCN: $(docn_mk)

DOCN_ALL_FLAGS=\
  COMP_SRCDIR="$(DOCN_SRCDIR)" \
  COMP_BINDIR="$(DOCN_BINDIR)"

# Use CMEPS PIO build
PIO_PATH?=$(ROOTDIR)/CMEPS/nems/lib/ParallelIO/install

$(docn_mk): $(cdeps_mk) configure
	mkdir -p $(DOCN_SRCDIR)
	mkdir -p $(DOCN_BINDIR)
	rm -f $(DOCN_BINDIR)/docn.mk
	@echo "# ESMF self-describing build dependency makefile fragment" > $(DOCN_BINDIR)/docn.mk
	@echo "# src location: $(DOCN_SRCDIR)" >> $(DOCN_BINDIR)/docn.mk
	@echo  >> $(DOCN_BINDIR)/docn.mk
	@echo "ESMF_DEP_FRONT     = ocn_comp_nuopc" >> $(DOCN_BINDIR)/docn.mk
	@echo "ESMF_DEP_INCPATH   = " >> $(DOCN_BINDIR)/docn.mk
	@echo "ESMF_DEP_CMPL_OBJS = " >> $(DOCN_BINDIR)/docn.mk
	@echo "ESMF_DEP_LINK_OBJS = -L$(CDEPS_BINDIR)/lib -ldocn -ldshr -lstreams -lcdeps_share -lFoX_dom -lFoX_sax -lFoX_common -lFoX_utils -lFoX_fsys -L$(PIO_PATH)/lib -lpiof -lpioc" >> $(DOCN_BINDIR)/docn.mk

	test -d "$(DOCN_BINDIR)"
	test -s "$(docn_mk)"

# Rule for cleaning the SRCDIR and BINDIR:
clean_DOCN:
	@echo "clean DOCN"

distclean_DOCN: clean_DOCN
	rm -rf $(DOCN_BINDIR) $(docn_mk)

