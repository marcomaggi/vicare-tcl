## dependencies.make --
#
# Automatically built.

EXTRA_DIST +=  \
	lib/vicare/languages/tcl/constants.vicare.sls.in

lib/vicare/languages/tcl.fasl: \
		lib/vicare/languages/tcl.vicare.sls \
		lib/vicare/languages/tcl/constants.fasl \
		lib/vicare/languages/tcl/unsafe-capi.fasl \
		$(FASL_PREREQUISITES)
	$(VICARE_COMPILE_RUN) --output $@ --compile-library $<

lib_vicare_languages_tcl_fasldir = $(bundledlibsdir)/vicare/languages
lib_vicare_languages_tcl_vicare_slsdir  = $(bundledlibsdir)/vicare/languages
nodist_lib_vicare_languages_tcl_fasl_DATA = lib/vicare/languages/tcl.fasl
if WANT_INSTALL_SOURCES
dist_lib_vicare_languages_tcl_vicare_sls_DATA = lib/vicare/languages/tcl.vicare.sls
endif
EXTRA_DIST += lib/vicare/languages/tcl.vicare.sls
CLEANFILES += lib/vicare/languages/tcl.fasl

lib/vicare/languages/tcl/constants.fasl: \
		lib/vicare/languages/tcl/constants.vicare.sls \
		$(FASL_PREREQUISITES)
	$(VICARE_COMPILE_RUN) --output $@ --compile-library $<

lib_vicare_languages_tcl_constants_fasldir = $(bundledlibsdir)/vicare/languages/tcl
lib_vicare_languages_tcl_constants_vicare_slsdir  = $(bundledlibsdir)/vicare/languages/tcl
nodist_lib_vicare_languages_tcl_constants_fasl_DATA = lib/vicare/languages/tcl/constants.fasl
if WANT_INSTALL_SOURCES
dist_lib_vicare_languages_tcl_constants_vicare_sls_DATA = lib/vicare/languages/tcl/constants.vicare.sls
endif
CLEANFILES += lib/vicare/languages/tcl/constants.fasl

lib/vicare/languages/tcl/unsafe-capi.fasl: \
		lib/vicare/languages/tcl/unsafe-capi.vicare.sls \
		$(FASL_PREREQUISITES)
	$(VICARE_COMPILE_RUN) --output $@ --compile-library $<

lib_vicare_languages_tcl_unsafe_capi_fasldir = $(bundledlibsdir)/vicare/languages/tcl
lib_vicare_languages_tcl_unsafe_capi_vicare_slsdir  = $(bundledlibsdir)/vicare/languages/tcl
nodist_lib_vicare_languages_tcl_unsafe_capi_fasl_DATA = lib/vicare/languages/tcl/unsafe-capi.fasl
if WANT_INSTALL_SOURCES
dist_lib_vicare_languages_tcl_unsafe_capi_vicare_sls_DATA = lib/vicare/languages/tcl/unsafe-capi.vicare.sls
endif
EXTRA_DIST += lib/vicare/languages/tcl/unsafe-capi.vicare.sls
CLEANFILES += lib/vicare/languages/tcl/unsafe-capi.fasl

lib/vicare/languages/tcl/features.fasl: \
		lib/vicare/languages/tcl/features.vicare.sls \
		$(FASL_PREREQUISITES)
	$(VICARE_COMPILE_RUN) --output $@ --compile-library $<

lib_vicare_languages_tcl_features_fasldir = $(bundledlibsdir)/vicare/languages/tcl
lib_vicare_languages_tcl_features_vicare_slsdir  = $(bundledlibsdir)/vicare/languages/tcl
nodist_lib_vicare_languages_tcl_features_fasl_DATA = lib/vicare/languages/tcl/features.fasl
if WANT_INSTALL_SOURCES
dist_lib_vicare_languages_tcl_features_vicare_sls_DATA = lib/vicare/languages/tcl/features.vicare.sls
endif
CLEANFILES += lib/vicare/languages/tcl/features.fasl


### end of file
# Local Variables:
# mode: makefile-automake
# End:
