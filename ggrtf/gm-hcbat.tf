;;
;; GgrTF::HC - Hardcore BatMUD support module
;; (C) Copyright 2005-2009 Matti Hämäläinen (Ggr)
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
/loaded GgrTF:HC
/test prdefmodule("HC")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper functions, etc.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def msq = /echo -p @{BCred}HC@{n}: %*

/def msr = /if (opt_verbose=~"on") @@party say %*%;/else /msq %*%;/endif
/def msp = /if (opt_verbose=~"on") @@party say %*%;/else /msq %*%;/endif
/def mse = /if (opt_verbose=~"on") @@party say emote %*%;/else /msq %*%;/endif
/def msb = @@party say %*

/def dig_grave = @dig grave
/def eat_corpse = @get corpse;eat corpse
/def get_corpse = @get corpse


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; HCBat-specific short score handling
/def -i prgetqd =\
	/return "@{$[prgetnlite({1},{2})]}%{1}@{n}/%{2} $[prgetdiff({1},{3})]"

/def -i -F -p9999 -mregexp -t"^H:(-?[0-9]+)/(-?[0-9]+) S:(-?[0-9]+)/(-?[0-9]+) E:(-?[0-9]+)/(-?[0-9]+) \$:(-?[0-9]+) exp:(-?[0-9]+)$" gstatus_sc =\
	/if (opt_gagsc=~"on")\
		/substitute -ag%;\
	/else \
		/mss H:$[prgetqd({P1},{P2},status_oldhp)] S:$[prgetqd({P3},{P4},status_oldsp)] E:$[prgetqd({P5},{P6},status_oldep)] \$:%{P7} $[prgetdiff({P7},status_money)] exp:%{P8} $[prgetdiff({P8},status_exp)]%;\
	/endif%;\
	/test gstatus_scupd({P1},{P2},{P3},{P4},{P5},{P6},{P7},{P8})


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Lite skills/spells you can train with current exp
/def -i -F -p9999 -mregexp -t"^\| ([A-Z][A-Za-z ]+) +\| +([0-9]+) \| +([0-9]+) \| +([0-9]+) \|$" glite_trainexp =\
	/if ({P4} <= status_qexp)\
		/let _tcs=Cgreen%;\
	/else \
		/let _tcs=n%;\
	/endif%;\
	/substitute -p | @{%{_tcs}}%{P1}@{n} | @{%{_tcs}}$[pad({P2},3)]@{n} | @{%{_tcs}}$[pad({P3},3)]@{n} | @{%{_tcs}}$[pad({P4},8)]@{n} |


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Looting and burning (for barb-module hcbat compat)
/def lootburn =\
	/set burn_st=1%;\
	/msr Burning corpses!%;\
	@@light torch%;\
	@@use looting and burning%;\
	/repeat -3 1 /gburn_drop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Unstun (NS)

/gdef -i -F -aCgreen -mregexp -t"^[A-Z][A-Za-z]+\'s chanting appears to do absolutely nothing.$" rec_unstun_on =\
	/gprot_on unstun%;/set prot_unstun_w=0

/gdef -i -F -aCgreen -msimple -t"You are STUNNED." rec_stun_start =\
	/set stun_st=on

/gdef -i -F -aCgreen -mregexp -t"\.\.\.BUT you break it off" rec_stun_mano =\
	/set stun_st=off

/gdef -i -F -aCgreen -mregexp -t" paralyzes you with its mind\.$" rec_paralyzed_start =\
	/gspell_interrupt%;/gskill_interrupt%;/set stun_st=on%;/gprot_off unstun

/gdef -i -F -aCgreen -msimple -t"You are no longer stunned." rec_stun_end =\
	/set stun_st=off%;/msr No longer stunned

/gdef -i -F -aCgreen -msimple -t"It doesn't hurt as much as it normally does!" rec_unstun_off =\
	/gprot_off unstun

/gdef -i -F -aCgreen -msimple -t"It doesn't hurt at all!" rec_unstun_notall =\
	/gspell_interrupt%;/gskill_interrupt%;\
	/set prot_unstun_w=$[prot_unstun_w+1]%;\
	/msr Unstun weakened [#%{prot_unstun_w}]%;\
	/gstatus_update

