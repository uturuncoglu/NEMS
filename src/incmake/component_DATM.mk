# Location of the ESMF makefile fragment for this component:
datm_mk = $(DATM_BINDIR)/datm.mk
all_component_mk_files+=$(datm_mk)

# Need this because cmeps_mk is not available at this level
cdeps_mk = $(ROOTDIR)/CDEPS/CDEPS_INSTALL/cdeps.mk

# Location of source code and installation
DATM_SRCDIR?=$(ROOTDIR)/DATM
DATM_BINDIR?=$(ROOTDIR)/DATM/DATM_INSTALL
CDEPS_BINDIR?=$(ROOTDIR)/CDEPS/CDEPS_INSTALL

# Make sure we're setting CDEPS=Y if DATM is enabled:
ifeq (,$(findstring CDEPS,$(COMPONENTS)))
  $(error DATM requires CDEPS)
endif

# Rule for building this component:
build_DATM: $(datm_mk)

DATM_ALL_FLAGS=\
  COMP_SRCDIR="$(DATM_SRCDIR)" \
  COMP_BINDIR="$(DATM_BINDIR)"

# Use CMEPS PIO build
PIO_PATH?=$(ROOTDIR)/CMEPS/nems/lib/ParallelIO/install

$(datm_mk): $(cdeps_mk) configure
	mkdir -p $(DATM_SRCDIR)
	mkdir -p $(DATM_BINDIR)
	rm -f $(DATM_BINDIR)/datm.mk
	@echo "# ESMF self-describing build dependency makefile fragment" > $(DATM_BINDIR)/datm.mk
	@echo "# src location: $(DATM_SRCDIR)" >> $(DATM_BINDIR)/datm.mk
	@echo  >> $(DATM_BINDIR)/datm.mk
	@echo "ESMF_DEP_FRONT     = atm_comp_nuopc" >> $(DATM_BINDIR)/datm.mk
	@echo "ESMF_DEP_INCPATH   = " >> $(DATM_BINDIR)/datm.mk
	@echo "ESMF_DEP_CMPL_OBJS = " >> $(DATM_BINDIR)/datm.mk
	@echo "ESMF_DEP_LINK_OBJS = -L$(CDEPS_BINDIR)/lib -ldatm -ldshr -lstreams -lcdeps_share -lFoX_dom -lFoX_sax -lFoX_common -lFoX_utils -lFoX_fsys -L$(PIO_PATH)/lib -lpiof -lpioc" >> $(DATM_BINDIR)/datm.mk

	test -d "$(DATM_BINDIR)"
	test -s "$(datm_mk)"

# Rule for cleaning the SRCDIR and BINDIR:
clean_DATM:
	@echo "clean DATM"

distclean_DATM: clean_DATM
	rm -rf $(DATM_BINDIR) $(datm_mk)

