#
#	Copyright(c) 96 FRIDU a Free Software Company (Fulup Ar Foll)
#
# File      :   project.mk, project global definition
# Projet    : 	rtWeb
# SubModule :   Makefile configuration
# Auteur    :   Fulup Ar Foll (fulup@iu-vannes.fr)
#
# Last
#      Author      : $Author: fulup $
#      Date        : $Date: 1999/03/08 08:34:17 $
#      Revision    : $Revision: 1.2 $
#      Source      : $Source: /Master/jTcl/Etc/Project.mk,v $
#      State       : $State: Exp $
#
# Modification History
# --------------------
# 01d,31mar98,fulup moved all specifics in arch.mk
# 01c,01Jun97,fulup added Java & moved Runtime dir in default file
# 01b,28feb97,fulup released jTcl
# 01a,20sep97,fulup written
#
# Project Definition can be overrided by $(ARCH).mk
#
# Warning: This file deepely use GNU Make syntaxe, dont use your time trying
# -------  to run it with an ordinary make, you realy have to use gnu Make
# -------  When assigning Variable dont forget := is not equal to =
# -------  if you not sure that := will fit = is slower but works in any case

# Where to install production
# ---------------------------
  ifndef FRIDU_HOME
    FRIDU_HOME  := $(HOME)/pMaster
  endif

  # WARNING: no space after those variables
  PRJ_VERSION   := jTcl-3.06
  INSTALL_DIR   := $(FRIDU_HOME)/$(PRJ_VERSION)

  # Do not use := for project variables
  PRJ_LIBRARIES =  $(DL_LIB)
  PRJ_INCLUDES  =  $(TCL_INCL)
  PRJ_CCOPTIONS =

  VGA_LIBS      = -lvga -lvgagl
  GENVGA_LIB    = -lGenVga
  GENVGAGL_LIB  = -lGenVgaGl
  GENDEVICE_LIB = -lGenMouseKeyboard
  XVGA_LIBS     = -lXVga -lXVgaGl -lXMouseKeyboard
  X11_LIBS      = -L/usr/X11R6/lib -lX11
  X11_INCL      = -I/usr/X11R6/include
  JTIX_LIBS     = -lCore -lEvt

# For demo purpose Java class are kept in dev tree
# ------------------------------------------------
  override CLASSDIR := ../Class

# Global debug/optimization flag
# ------------------------------
# set all flasg for a full debug or oprtimized mode
# -------------------------------------------------
ifeq ($(CCDEBUG),1)
    DEBUGCCFLAGS=$(ARCH_OS_CCDEBUG)
    DEBUGSHFLAGS=$(ARCH_OS_SHDEBUG)
    DEBUGLDFLAGS=$(ARCH_OS_LDDEBUG)
else
    DEBUGCCFLAGS=$(ARCH_OS_CCO2)
    DEBUGSHFLAGS=$(ARCH_OS_SHO2)
    DEBUGLDFLAGS=$(ARCH_OS_LDO2)
endif

