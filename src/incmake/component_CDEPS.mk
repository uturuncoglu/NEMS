# Location of the ESMF makefile fragment for this component:
cdeps_mk = $(CDEPS_BINDIR)/cdeps.mk
all_component_mk_files+=$(cdeps_mk)

# Location of source code and installation
CDEPS_SRCDIR?=$(ROOTDIR)/CDEPS
CDEPS_BLDDIR?=$(ROOTDIR)/CDEPS/CDEPS_BUILD
CDEPS_BINDIR?=$(ROOTDIR)/CDEPS/CDEPS_INSTALL

# Make sure the expected directories exist and are non-empty:
$(call require_dir,$(CDEPS_SRCDIR),CDEPS source directory)

ifndef CONFIGURE_NEMS_FILE
$(error CONFIGURE_NEMS_FILE not set.)
endif

include $(CONFIGURE_NEMS_FILE)

# Rule for building this component:
#build_CDEPS: $(cdeps_mk)
build_CDEPS: all 

CDEPS_ALL_OPTS=\
  COMP_SRCDIR="$(CDEPS_SRCDIR)" \
  COMP_BINDIR="$(CDEPS_BINDIR)" \
  MACHINE_ID="$(MACHINE_ID)" \
  FC="$(FC)" \
  CC="$(CC)" \
  CXX="$(CXX)"

#PIO_PATH?=$(ROOTDIR)/CMEPS/nems/lib/ParallelIO/install
PIO_PATH?=/work/noaa/nems/tufuk/progs/pio-2.5.2/install

# Rule for creating ESMF build dependency makefile fragment
all:
	rm -f $(CDEPS_BINDIR)/cdeps.mk
	@echo "# ESMF self-describing build dependency makefile fragment" > $(CDEPS_BINDIR)/cdeps.mk
	@echo "# src location: $(CDEPS_SRCDIR)" >> $(CDEPS_BINDIR)/cdeps.mk
	@echo  >> $(CDEPS_BINDIR)/cdeps.mk
	@echo "ESMF_DEP_FRONT     = MED" >> $(CDEPS_BINDIR)/cdeps.mk
	@echo "ESMF_DEP_INCPATH   = $(CDEPS_BINDIR)/include" >> $(CDEPS_BINDIR)/cdeps.mk
	@echo "ESMF_DEP_CMPL_OBJS = " >> $(CDEPS_BINDIR)/cdeps.mk
	@echo "ESMF_DEP_LINK_OBJS = $(CDEPS_BINDIR)/lib/libdshr.a $(CDEPS_BINDIR)/lib/libstreams.a \
	$(CDEPS_BINDIR)/lib/libdatm.a $(CDEPS_BINDIR)/lib/libdocn.a \
	$(PIO_PATH)/lib/libpioc.a $(PIO_PATH)/lib/libpiof.a" >> $(CDEPS_BINDIR)/cdeps.mk

$(cdeps_mk): configure
	$(MODULE_LOGIC); export $(CDEPS_ALL_OPTS); \
	set -e; $(MODULE_LOGIC); mkdir -p $(CDEPS_BLDDIR); \
	cd $(CDEPS_BLDDIR); \
        exec cmake -DCMAKE_BUILD_TYPE=Release \
	-DBLD_STANDALONE=ON \
	-DCMAKE_INSTALL_PREFIX=$(CDEPS_BINDIR) \
        -DPIO_Fortran_LIBRARY=$(PIO_PATH)/lib \
	-DPIO_Fortran_INCLUDE_DIR=$(PIO_PATH)/include \
	-DPIO_C_LIBRARY=$(PIO_PATH)/lib \
	-DPIO_C_INCLUDE_DIR=$(PIO_PATH)/include ../
	
	$(MODULE_LOGIC); export $(CDEPS_ALL_OPTS); \
	set -e; $(MODULE_LOGIC) ; cd $(CDEPS_BLDDIR); \
	exec $(MAKE) -j 1  $(CDEPS_ALL_OPTS) install VERBOSE=1
	
	$(MODULE_LOGIC); export $(CDEPS_ALL_OPTS); \
	set -e; \
	exec cp $(CDEPS_BLDDIR)/datm/libdatm.a $(CDEPS_BINDIR)/lib/libdatm.a
	
	$(MODULE_LOGIC); export $(CDEPS_ALL_OPTS); \
	set -e; \
	exec cp $(CDEPS_BLDDIR)/docn/libdocn.a $(CDEPS_BINDIR)/lib/libdocn.a
	
	test -d "$(CDEPS_BINDIR)"
	test -s "$(cdeps_mk)"

# Rule for cleaning the SRCDIR and BINDIR:
clean_CDEPS: 
	cp -n $(MODULE_DIR)/$(CHOSEN_MODULE) $(CONFDIR)/modules.nems ; \
	$(MODULE_LOGIC); export $(CDEPS_ALL_OPTS); \
	set -e; \
	cd $(CDEPS_BLDDIR); \
	exec $(MAKE) clean

distclean_CDEPS: clean_CDEPS
	rm -rf $(CDEPS_BINDIR)
	rm -f $(cdeps_mk)
