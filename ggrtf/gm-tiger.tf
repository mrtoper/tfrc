;;
;; GgrTF::Tiger - The Brotherhood of the Black Tiger guild support @ BatMUD
;; (C) Copyright 2006-2015 Jutom & Matti Hämäläinen (Ggr)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; version 2 as published by the Free Software Foundation.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; file "COPYING.txt" for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
;; MA 02110-1301 USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; NOTICE! This file requires GgrTF (version 0.6.15 or later) to be loaded.
;;
/loaded GgrTF::Tiger
/test prdefmodule("Tiger")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialization and options
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdeftoggle -n"rtiger" -d"Report Tiger Claw etc."

/prdefvar -n"cmd_rtiger" -v"/msr" -c"Command/macro used for reporting Tiger guild things (claw)"
/eval /def -i mrtiger = /if (opt_rtiger=~"on") %{cmd_rtiger} %%*%%;/endif

;@command /rtiger
;@desc Toggle reporting of tiger-module related things.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Claw messages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gdef -i -F -mregexp -aCgreen -t"^As .+ drops to (his|her|its) knees you leap in for the kill!$" gtiger_claw_hit =\
	/mrtiger Claw in!

/gdef -i -F -mregexp -aCred -t"^.+ manages to resist your claws!$" gtiger_claw_resist =\
	/mrtiger Claw resisted.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gdef -i -F -mregexp -aCcyan -t"^You feel how you fracture several of (.+) bones with your attack!" gtiger_claw_damage =\
	/if (opt_rtiger=~"on") @@cackle%;/endif

/glite -msimple -aCyellow -t"You feel more connected to Curath than ever before!" gtiger_claw_repu

/glite -msimple -aCyellow -t"You learn to focus power from the deepest core of your being!" gtiger_mak_repu

