# Check Tcl Interpretor
# \
echo "### ERROR: this shell should be start with wish/tclsh ###";exit
#
#
#  Copyright(c) 1996-98 FRIDU a Free Software Company [fridu@fridu.bzh]
#
# File      :   demoIt.tcl Entry point for demonstration files
# Projet    :   Fridu a Realtime Booster
# SubModule :   tcl/jTcl/demo
# Auteur    :   Fulup Ar Foll [fulup@fridu.bzh]
#
# Last
#      Author      : $Author: fulup $
#      Date        : $Date: 1999/03/08 08:34:19 $
#      Revision    : $Revision: 1.2 $
#      Source      : $Source: /Master/jTcl/zDemo/HowTo/demoIt.tcl,v $
#      State       : $State: Exp $
#
# Modification History
# --------------------
# 01l,07jul98,fulup changed and simplified to module versionning
# 01k,19mar98,fulup adapted to new package strategy
# 01j,27jan98,fulup added wish command auto search for W95
# 01i,23jan98,fulup added IcClient as an external process
# 01h,02dec97,fulup Adapted to jTcl-3.x and W95
# 01g,26oct97,fulup Adapted to new jTcl tree
# 01f,17jun97,fulup Added Tk version
# 01e,01jun97,fulup Added auto mkindex when dir content change
# 01d,21may97,fulup adapted to new demo directory tree and tclindex
# 01c,28mar97,fulup change for explice file source list
# 01b,28feb97,fulup released jTcl
# 01a,20sep97,fulup written
#

# ----------------------------------------------------------------------------
# This file start all demos from demo/TCL directory
# It has no interest by itself and just source all files from demo dir
# 1) Set  env(TOP) environement variable
# 2) Wait for user input
# 3) Add  demo and start at user input & try command
# ----------------------------------------------------------------------------

# demo GLOBAL flag
# ---------------
  set DEMO_IT true
  set _doIt_count 0

  # build PATH from demoIt.tcl command location
  set   DIR [file dirname $argv0]
  cd    $DIR/../..
  set   env(JTCL_HOME) [pwd]

   # Add JTCL file in version reverse order
   if [catch {lsort -decreasing [glob $env(JTCL_HOME)/*/bin/pkgIndex.tcl]} REP] {
        puts "ERROR: Can't find JTCL in default location set JTCL_HOME or JTCL_PATH"
        puts "ERR=$REP"
        exit
   } else {
       # remove trailing Etc/Package.jTcl from JTCL_PATH
       foreach SLOT $REP {
           set dir  [file dirname $SLOT]
	   uplevel #0 source $SLOT
       }
  }

# search wish command for sub process
# -----------------------------------
if [info exist tk_library] {
  set TK_DIR  [file split $tk_library]
  set TK_DIR  [lrange $TK_DIR 0 [expr [llength $TK_DIR] - 3]]
    set TK_DIR  [eval file join $TK_DIR bin wish]
    set TK_CMD  [lindex [glob $TK_DIR\[0-9\]*] 0]

  if {![file exist $TK_CMD]} {

     puts "WARNING: wish ($TK_CMD) command not found use default path"
     set  TK_CMD wish
  }
}

# Import full package search fonctionnality
# ------------------------------------------
if [catch {package require jTcl} ERR] {
  puts "ERROR: $ERR\ncheck TCLLIBPATH or JTCL_PATH"
  exit
}

jClassImport {lang.debug.*}
jClassImport {lang.search.*}

# Parse command line and start asked demo
# ---------------------------------------
proc demoIt.start {args} \
{
  global env
  global tk_library

    jClassImport "demo.[lindex $args 0].*"
    set COMMAND "demo.[lindex $args 0].start [lrange $args 1 end]"
    set RET [uplevel #0 $COMMAND]

  # return result in order trapping log
  return $RET
} ;# end demoIt.start


# If command line is not empty check for debug level and asked demo
# -----------------------------------------------------------------
if {[lindex $argv 1] != ""} \
{
# compute debug level NOTE: we don't trap error in debug mode
  if [regexp -- {--debug=([0-9]+)} [lrange $argv 1 end] x env(JTCL_DEBUG)] \
  {
    # shift argv command line list
    set argv [lrange $argv 2 end]
  }

  # When command line is set use it
  # ---------------------------------
  if {[llength $argv] > 1} \
  {
    eval demoIt.start $argv
    exit
  }
}

# Draw a scale taken from tk demo widget
# -----------------------------------------------
proc demoIt.scale {w varname label default max} \
{
 frame $w

 label $w.msg -text $label
 pack $w.msg -side top


 frame $w.frame
 pack $w.frame -side top -fill x

 canvas $w.frame.canvas -width 50 -height 50 -bd 0 -highlightthickness 0
 $w.frame.canvas create polygon 0 0 1 1 2 2 -fill DeepSkyBlue3 -tags poly
 $w.frame.canvas create line 0 0 1 1 2 2 0 0 -fill black -tags line
 scale $w.frame.scale -orient horizontal -length 600 -from 0 -to $max \
	-command "demoIt.setWidth $w.frame.canvas $varname $max" -tickinterval [expr $max / 6]
 pack $w.frame.canvas -side top -expand yes -anchor s -fill x  -padx 15
 pack $w.frame.scale -side bottom -expand yes -anchor n
 $w.frame.scale set $default

 return $w
} ;# end demoIt.scale

# Drwan arrow and return selected value to application
# -----------------------------------------------------
proc demoIt.setWidth {w varname max width} {
    # Update data information
    global env
    set env($varname) $width

    set width [expr $width * 500 / $max]
    # display arrow
    incr width 21
    set x2 [expr $width - 30]
    if {$x2 < 21} {
	set x2 21
    }
    $w coords poly 20 15 20 35 $x2 35 $x2 45 $width 25 $x2 5 $x2 15 20 15
    $w coords line 20 15 20 35 $x2 35 $x2 45 $width 25 $x2 5 $x2 15 20 15
} ;# end demoIt.setWidth

# showCode --
# This procedure creates a toplevel window that displays the code for
# a demonstration and allows it to be edited and reinvoked.
# ----------------------------------------------------------------------
proc demoIt.showcode cmd {
 global tk_library
 global auto_index

    # get filename from autopath
    set file [jClassName "demo.$cmd.*"]

    if ![winfo exists .code] {
	toplevel .code
	frame .code.buttons
	pack .code.buttons -side bottom -fill x
	button .code.buttons.dismiss -text Dismiss \
            -command "destroy .code"
	pack .code.buttons.dismiss -side left \
	    -expand 1 -pady 2
	frame .code.frame
	pack  .code.frame -expand yes -fill both -padx 1 -pady 1
	text .code.text -height 40 -wrap word\
	    -xscrollcommand ".code.xscroll set" \
	    -yscrollcommand ".code.yscroll set" \
	    -setgrid 1 -highlightthickness 0 -pady 2 -padx 3
	scrollbar .code.xscroll -command ".code.text xview" \
	    -highlightthickness 0 -orient horizontal
	scrollbar .code.yscroll -command ".code.text yview" \
	    -highlightthickness 0 -orient vertical

	grid .code.text -in .code.frame -padx 1 -pady 1 \
	    -row 0 -column 0 -rowspan 1 -columnspan 1 -sticky news
	grid .code.yscroll -in .code.frame -padx 1 -pady 1 \
	    -row 0 -column 1 -rowspan 1 -columnspan 1 -sticky news
	grid rowconfig    .code.frame 0 -weight 1 -minsize 0
	grid columnconfig .code.frame 0 -weight 1 -minsize 0
    } else {
	wm deiconify .code
	raise .code
    }
    wm title .code "Demo code: $file"
    wm iconname .code $file
    set id [open $file]
    .code.text delete 1.0 end
    .code.text insert 1.0 [read $id]
    .code.text mark set insert 1.0
    close $id
} ;# end demoIt.showcode

# Call back for log display onto console
# ---------------------------------------
proc demoIt.putConsole {tag console args} \
{
  # if console as been deleted just return
  if {![winfo exists $console]} {return}
  $console insert end "$args\n" $tag
  $console yview moveto 1.0
} ;# end demoIt.putConsole

# Clean up procedure free check objet still exists and free it
# ------------------------------------------------------------
proc demoIt.cleanup {ID} \
{
  upvar #0 $ID OBJ

  if [info exists OBJ] {free $ID}
}

# Start a commmand as an external process
# ---------------------------------------
proc demoIt.exec {cmd port} \
{
global _doIt_count
global TK_CMD
global env

    set PROC_NAME [jClassName "demo.$cmd.*"]
    if [catch {exec $TK_CMD $PROC_NAME $port &} ERR] {
      # create top level window
      set w .top$_doIt_count
      catch {destroy $w}
      toplevel $w
      wm title $w $cmd
      wm iconname $w $cmd
      wm geometry $w +300+300

      # create text and scroll bar
      frame $w.buttons
      pack $w.buttons -side bottom -fill x -pady 2m
      button $w.buttons.dismiss -text Dismiss
      button $w.buttons.code -text "See Code"
      pack $w.buttons.dismiss $w.buttons.code -side left -expand 1

      text $w.text -yscrollcommand "$w.scroll set" -setgrid true \
        -width 70 -height 15 -wrap word
        scrollbar $w.scroll -command "$w.text yview"
      pack $w.scroll -side right -fill y
      pack $w.text -expand yes -fill both

      # configure default error
      $w.text tag configure error -foreground red
      $w.text tag configure debug -foreground black
      $w.text tag configure log   -foreground blue

      # start command inside text widget
      $w.text insert end "ERROR : exec $TK_CMD \\ \n"
      $w.text insert end "        $WRAPPER  \\ \n"
      $w.text insert end "        $PROC_NAME $port &\n"
      $w.text insert end "STATUS: $ERR\n" error
      $w.text insert end "\nwish is probabelly not in your path"


      $w.buttons.code configure -command "demoIt.showcode $cmd"
      $w.buttons.dismiss configure -command "destroy $w"
    }
}

# Start a demo and display widget in dedicated widow
# --------------------------------------------------
proc demoIt.console {cmd port} \
{
 global _doIt_count

  # Increment counter for toplevel widget name
  incr _doIt_count

  # create top level window
  set w .top$_doIt_count
  catch {destroy $w}
  toplevel $w
  wm title $w $cmd
  wm iconname $w $cmd
  wm geometry $w +300+300

  # create text and scroll bar
  frame $w.buttons
  pack $w.buttons -side bottom -fill x -pady 2m
  button $w.buttons.dismiss -text Dismiss
  button $w.buttons.code -text "See Code"
  pack $w.buttons.dismiss $w.buttons.code -side left -expand 1

  text $w.text -yscrollcommand "$w.scroll set" -setgrid true \
	-width 70 -height 15 -wrap word
  scrollbar $w.scroll -command "$w.text yview"
  pack $w.scroll -side right -fill y
  pack $w.text -expand yes -fill both

  # configure default error
  $w.text tag configure error -foreground red
  $w.text tag configure debug -foreground black
  $w.text tag configure log   -foreground blue
  $w.buttons.code configure -command "demoIt.showcode $cmd"

  # start command inside text widget
  if [catch {eval demoIt.start $cmd $port} RET] \
  {
    $w.text insert 0.0 "ERROR: $cmd $port status=$RET" error
  } else {
    # change channel log destination
    $w.text insert 0.0 "Tcp $cmd waiting client on socket=$port\n" debug
    $RET set clog "demoIt.putConsole log $w.text"
    bind $w <Destroy> "demoIt.cleanup $RET"
  }
  $w.buttons.dismiss configure -command "destroy $w"

} ;# end demoIt.console {

# display a selectable text for demoselection
# -------------------------------------------
proc demoIt.select {w} \
{
 set bold "-relief raised -borderwidth 2"
 set normal "-relief flat"

 frame $w

 text $w.text -yscrollcommand "$w.scroll set" -setgrid true -wrap word
 scrollbar $w.scroll -command "$w.text yview"
 pack $w.scroll -side right -fill y
 pack $w.text -expand yes -fill both

 # Set up display styles.

 if {[winfo depth $w] > 1} {
    set bold "-background #43ce80 -relief raised -borderwidth 1"
    set normal "-background {} -relief flat"
 } else {
    set bold "-foreground white -background black"
    set normal "-foreground {} -background {}"
 }

 # Add text to widget.

 $w.text insert 0.0 {\
   jTcl demoIt
   } verybig

 $w.text insert end "\n Fulup Ar Foll (fulup@fridu.bzh)\n\n " italic

 # Server entry
 # ------------
 $w.text insert end \
  {Echo server:} tcp.echoSv

 $w.text insert end \
 {Wait onto a TCP socket for a client input, return same string prefixed with (echo->).
 } info

 # fileSv entry
 # ------------
 $w.text insert end \
  {Mini remote file server:} tcp.fileSv

 $w.text insert end \
 {Process small file request commands, and either return asked file onto client socket or write onto server disk input lines into target file.
 } info

 # chat entry
 # ------------
 $w.text insert end \
  {Chat server:} tcp.chatSv

 $w.text insert end \
 {Mini chat server, recevieved inputed message from a TCP socket and broadcast it to any connected client.
 } info

 # httpd entry
 # ------------
 $w.text insert end \
  {Httpd server:} web.httpd

 $w.text insert end \
 {A standard HTTPD server, connect onto it with your prefered browser and load any *.html,*.gif,*.class file.
 } info

 # rpc Httpd
 # ------------
 $w.text insert end \
  {Remote procedure compilant HTTPD server:} adr.server

 $w.text insert end \
 {A derivated HTTPD server that support user session, After being login user can execute transaction program attached to his HTML form in a private TCL slave interpretor.
 } info

 # Ic Httpd
 # ------------
 $w.text insert end \
  {Rule server:} ic.server

 $w.text insert end \
 {Start a rule server that wait for Ic client to connect. \
  This server Will instanciate a new rule engine for each incomming client.\
  Ic client should be start by hand with "jTk clientIcDemo.jTcl".  \
  This demo is not finish yet and does not use jTcl serialisation \
  mecanism.
 } info

 # Ic Client
 # ------------
 $w.text insert end \
  {Rule client:} ic.client

 $w.text insert end \
 {Start a rule client that should connect on a previousely started IC server.\
  This client will received all information form it server. Current valid \
  value for LANG are "fr" for french and "us" for english, LANG environment \
  variable should be set before starting demoIt.tcl. Ecach client is started \
  as an external process.
 } info

 # Bind hypertext action
 # ----------------------
 foreach CMD  [list  tcp.echoSv tcp.fileSv tcp.chatSv    \
       web.httpd  adr.server    \
       ic.server ]     \
 {
   # "attach an action to each tag"
   $w.text tag bind $CMD <Any-Enter> "$w.text tag configure $CMD $bold"
   $w.text tag bind $CMD <Any-Leave> "$w.text tag configure $CMD $normal"

   $w.text tag bind $CMD <Button-1> "demoIt.console $CMD \$env(PORT)"
   $w.text tag configure $CMD -foreground blue
 }

 # Bind hyper external process
 foreach CMD [list ic.client] \
 {
   $w.text tag bind $CMD <Any-Enter> "$w.text tag configure $CMD $bold"
   $w.text tag bind $CMD <Any-Leave> "$w.text tag configure $CMD $normal"

   $w.text tag bind $CMD <Button-1> "demoIt.exec $CMD \$env(PORT)"
   $w.text tag configure $CMD -foreground blue
 }

 # Insert final note
 $w.text insert end {

Note: When starting a server, you should connect onto it with a client \
(usualy telnet or Netscape). Only rule server use a TK client.

------- WARNING -------- WARNING -------- WARNING ---------

1) Only one server can be started on a fixed socket port, if you want more \
than one server to be actived at a time, select a different socket for \
each one.
2) Browser like Netscape have a local cache if you start a new WEB server \
without changing socket press SHITF key when clicking on reload, this will \
force Netscape to ignore it cache and effectivelly load HTML page from your \
running server.
3) Some port can be used or reserved, if a port does \
not work just try an other one, usually port 1 to 1024 are reserved.
4) For some strange raisons Window telnet needs local echo to be set \
in order to work with chat, fileSv and echo server demo.

I unfortunatelly cannot test all configurations, if you have any troubles \
and/or remark with/on this demo let me know. It should work with any tcl-8.x \
avoid alpha version on W95.

I hope you will enjoy.

Fulup
} italic

 $w.text tag configure big     -font {Courier 14 bold}
 $w.text tag configure verybig -font {Helvetica 24 bold} -justify center
 $w.text tag configure italic  -font {Courier 12 italic}
 $w.text tag configure info    -lmargin2 12m
 return $w
} ;# end demoIt.select

# Draw Tk demoIt panel
# --------------------
proc demoIt.tk {} \
{
 global FOREVER
 global env

    # set default port attribute
    # --------------------------
    set env(PORT) 1234

    # create demo1.tk frame
    # ---------------------
    set w .demoIt
    frame $w

    # drawn demo selection text widget
    # --------------------------------
    set select [demoIt.select $w.select]

    # draw socket scale
    # ----------------
    set sock [demoIt.scale $w.socket PORT \
             "Socket connection port number" 1234 3000]

    # Pack all widget
    # ----------------
    pack $w $select $sock
    tkwait window .demoIt

} ;# end demoIt

 # try to use tkCon facility
 if [catch {package require Tk} ERR] {
   puts "WARNING: can't start tkConsole |$ERR| will use stdout/stderr"
 } else {
   demoIt.tk
   puts "Tk demoIt normal End"
   return
 }

# Interactive mode Tk dis not start
# ----------------------------------
  while 1 \
  {
    puts "Choose a demo:"
    puts " - tcp.simpleCl      \[portNum\] \[host\] default 23 localhost"
    puts " - tcp.echoSv        \[portNum\]  default 1234"
    puts " - tcp.fileSv        \[portNum\]  default 1234"
    puts " - tcp.chatSv        \[portNum\]  default 1234"
    puts " - web.httpd         \[portNum\]  default 1234"
    puts " - adr.server        \[portNum\]  default 1234"
    puts " - ic.server         \[portNum\]  default 1234"
    puts ""
    puts "In order starting a demo type in a demo ex:demoIt.start httpd"

    # try out command and print return status
    eval demoIt.start [gets stdin]
  } ;# end while 1
