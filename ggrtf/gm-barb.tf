;;
;; GgrTF::Barbarian - Barbarian guild support @ BatMUD
;; (C) Copyright 2005-2015 Jarkko V‰‰r‰niemi (Jeskko) & Matti H‰m‰l‰inen (Ggr)
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
;; NOTICE! This file requires GgrTF (version 0.6.14 or later) to be loaded.
;;
/loaded GgrTF::Barbarian
/test prdefmodule("Barbarian")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdefgbind -s"repu"	-c"/showrep"		-n
/prdefgbind -s"lb"	-c"/lootburn"		-n
/prdefgbind -s"burn"	-c"/lootburn"		-n
/prdefsbind -s"er"	-c"Enrage"		-n
/prdefsbind -s"fa"	-c"First Aid"
/prdefsbind -s"bcry" 	-c"Battlecry"
/prdefsbind -s"lure"	-c"Lure"
/prdefsbind -s"pain"	-c"Pain Threshold"	-n
/prdefsbind -s"toxi"	-c"Toxic Immunity"	-n
/prdefsbind -s"fwal"	-c"Fire Walking"	-n
/prdefsbind -s"ctol"	-c"Cold Tolerance"	-n
/prdefsbind -s"camp"	-c"Camping"		-n


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fails and fumbles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdeffail -k -f -r -t"^You jump up and begin dancing, but you"
/prdeffail -k -F -r -t"^You jump up and begin dancing, but after"
/prdeffail -k -f -r -t"^You fail to start the fire."


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reputation bar translator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/test prlist_insert("lst_resetfuncs", "gbarbrep_reset")

/def -i gbarbrep_reset =\
	/prdefivar barbrep_cur 0%;\
	/prdefivar barbrep_old 0


/def -i -ag -msimple -t"Reputation bar:" gbarbrep_get1

/def -i -mregexp -t"^\[(X*)(@*)(#*)(:*)(\.*)\]$" gbarbrep_get2 =\
	/let _repval=$[(strlen({P1})*10000) + (strlen({P2})*1000) + (strlen({P3})*100) + (strlen({P4})*10) + strlen({P5})]%;\
	/if (barbrep_gag)\
		/set barbrep_gag=0%;\
		/set barbrep_old=%{barbrep_cur}%;\
		/set barbrep_cur=%{_repval}%;\
 		/mss Reputation: @{BCwhite}%{barbrep_cur}@{n} $[prgetdiff(barbrep_cur,barbrep_old)]%;\
	/else \
		/mss Reputation: @{BCwhite}%{_repval}@{n} [@{BCred}%{P1}@{nBCgreen}$[replace("@","@@",{P2})]@{nCgreen}%{P3}@{nBCyellow}%{P4}@{nCyellow}%{P5}@{n}]%;\
	/endif

/def -i showrep =\
	/set barbrep_gag=1%;\
	@@grep '[[]' barbarian binfo %{set_plrname}%;\


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Looting and burning
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/test prlist_insert("event_skill_intr", "gburn_intr")

/prdefsetting -n"burnaction" -d"What items are dropped after burn" -s"off cash noeq"
/burnaction off

/def -i -mregexp -t"^You (join [A-Z][a-z]+ in (his|her|its) looting and burning|run around the room, waving your torch about)" gburn_done =\
	/showrep%;\
	@@extinguish torch%;\
	/if (set_burnaction=~"cash") @drop copper;drop tin;drop zinc;drop mowgles;drop bronze;drop silver%;/endif%;\
	/if (set_burnaction=~"noeq") @drop noeq;drop copper;drop tin;drop zinc;drop mowgles;drop bronze;drop silver%;/endif

/def -i gburn_intr =\
	/if (burn_st & skill_st2=~"on")\
		@@extinguish torch%;\
		/set burn_st=0%;\
	/endif

/def -i gburn_drop =\
	/if (burn_st)\
		/set burn_st=0%;\
		@@drop all corpse%;\
	/endif

/def -i lootburn =\
	/set burn_st=1%;\
	/msr Burning corpses!%;\
	@@light torch%;\
	/gburn_drop%;\
	@@barbburn

;; Define a new RIP function for looting and burning
/prdefripfunc lb /lootburn


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Lure translator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;/def -i glure_report =\
;	@@emote %{glure_match}

;/def -i -ag -mregexp -t"^You valiantly strike back at (.+)$" glure_get1 =\
;	/set glure_match=%{P1}%;/set glure_st=1

;/def -i -ag -Eglure_st==1 -mregexp -t"^(.+) gets knocked down to the ground\.$" glure_get2 =\
;	/set glure_st=0%;/set glure_match=%{glure_match} %{P1}%;/glure_report

