# Copyright(c) 1996-98 FRIDU a Free Software Company [fridu@fridu.bzh]
#
# File      :   pkgIndex.tcl tcl package interface to jTcl jClassImport mecanism
# Projet    :   Fridu a Realtime Booster
# SubModule :   jTcl Tcl package handler
# Auteur    :   Fulup Ar Foll [fulup@fridu.bzh]
#
# Last
#      Author      : $Author. fulup $
#      Date        : $Date. 1997/02/01 17.29.30 $
#      Revision    : $Revision. 1.2 $
#      Source      : $Source. /Master/config/header/header.sh,v $
#
# Modification History
# --------------------
# 01e,05mar99,fulup added jClassLang in default sourced file
# 01d,05mar99,fulup make default path to be printed in debug mode only
# 01c,20sep98,philld pached path because lappend in env var fail (tcl bug?)
# 01b,07jul98,philld adapted to moddule versioning
# 01a,15mar98,fulup written
#

## --
# This proc sources as soone as tcl is started
# it will look for jTcl package as soon as
# package requierer jTcl is entered.
# <p>
# It will look in JTCL_PATH and then in JTCl_HOME
# for searchPkgLang file
## --

proc jTclSearchPackage {DIR} {
 global env
 global PKG_STATE
 global PKG_DIR

 # From now we search production tree
 set PKG_STATE prod

 # If No JTCL Patch create a default one
 if {![info exists env(JTCL_PATH)]} {

   # Save current dir
   set CURRENT [pwd]

   if {![info exists env(JTCL_HOME)]} {
     cd    $DIR/../..
     set   env(JTCL_HOME) [pwd]
   }

   # Add JTCL file in version reverse order
   if [catch {lsort -decreasing [glob $env(JTCL_HOME)/*/lib/*/Etc/Package.jTcl]} REP] {
        puts "ERROR: Can't find JTCL in default location set JTCL_HOME or JTCL_PATH"
        puts "ERR=$REP"
        exit
   } else {
       # remove trailing Etc/Package.jTcl from JTCL_PATH
       foreach SLOT $REP {
	   set LIST [file split $SLOT]
           set LEN  [expr [llength $LIST] -3]
	   set LIST [lrange $LIST 0 $LEN]
	   lappend  JTCL_PATH [eval file join [lrange $LIST 0 $LEN]]
       }
       set env(JTCL_PATH) $JTCL_PATH
   }

   # come back to original current dir
   cd $CURRENT
   if [info exist env(JTCL_DEBUG)] {
     puts "Warning: JTCL_PATH defaulted to $env(JTCL_PATH)"
   }
 }

 # Now loop on JTCL_PATH for Etc/Package.jTcl files
 foreach DIR $env(JTCL_PATH) {
   if [file exists $DIR/Tcl/searchPkgLang.jTcl] {
     set PKG_DIR $DIR
     if [info exists env(JTCL_DEBUG)] {puts "sourcing $DIR/Tcl/searchPkgLang.jTcl"}
     uplevel #0 source $DIR/Tcl/searchPkgLang.jTcl
     if [info exists env(JTCL_DEBUG)] {puts "sourcing $DIR/Tcl/jClassLang.jTcl"}
     uplevel #0 source $DIR/Tcl/jClassLang.jTcl
     break
   }
 } ;# end foreach JTCL_PATH

 # start package database load from JTCL_PATH
 searchPkgLang

} ;# end proc jTclSearchPackage


# This command will be find with package command when scanning env(TCLLIBPATH)
package ifneeded jTcl 3.03 [list jTclSearchPackage $dir]




