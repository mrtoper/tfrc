;;
;; GgrTF::Nun - Sisters of Las guild support @ BatMUD
;; (C) Copyright 2006-2015 Ealoren Pupunen & Matti Hämäläinen (Ggr)
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
/loaded GgrTF::Nun
/test prdefmodule("Nun", "Magical")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bindings & misc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdefcbind -s"pfe"	-c"Protection from Evil"
/prdefcbind -s"sshield"	-c"Soul Shield"
/prdefcbind -s"st"	-c"Saintly Touch"	-q
/prdefcbind -s"hh"	-c"Holy Hand"		-q
/prdefcbind -s"de"	-c"Dispel Evil"		-q
/prdefcbind -s"du"	-c"Dispel Undead"	-q
/prdefcbind -s"how"	-c"Holy Wind"		-q
/prdefcbind -s"flames"	-c"Flames of Righteousness"	-q
/prdefcbind -s"haven"	-c"Celestial Haven"	-n

/prdefprot -i"nprayer"	-n"!PRAYER!"	-l"Nun Guild Prayer Hour" -r -q	-u"^( +Sisters are called for Hour of Prayer\.|DINGG! DONGGG! DIINNGGGG! DOOOONNNGGGG!   ...hour of prayer has started!)$" -d"^(\.+and a sudden REVELATION takes over you as Las responses to your pray\.|DINGG! DONGGG! DIINNGGGG! DOOOONNNGGGG!   ...hour of prayer has ended!)$"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fails & fumbles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdeffail -c -F    -t"Your halo crackles as you fumble the spell."
/prdeffail -k -F -r -t"^OOPS, You should have used a pattern"
/prdeffail -k -f    -t"You fail to channel your god's power."
/prdeffail -k -f    -t"OUCH, you poke yourself with your needle."


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Warnings about turn rate
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set nun_turn_warn=1

; Sudden enlightment takes over you.
; Archangel Zaylie whispers in your ear, 'You should turn more undeads'
; Sudden enlightment takes over you.
; Archangel Falynn speaks to you, 'Las is not pleased. You should turn more
; undeads'
/def -i -ag -mregexp -t"^Archangel .*You should turn more" gnun_turn_more =\
	/if (nun_turn_warn >= 1)\
		/mse should turn more undeads. (Only one warning left!)%;\
		/set nun_turn_warn=0%;\
	/else \
		/mse should turn more undeads NOW.%;\
	/endif

/def -i -ag -mregexp -t"^Angry voice of Las booms from the heavens, 'You have not turned in ages, you" gnun_las_mad =\
	/mse struck down by Las!


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Translate "nun turns" messages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gnun_turns =\
	/set nun_turn_warn=1%;\
	/substitute -p %{1} (@{Cyellow}%{2}@{n}/@{BCgreen}8@{n})

/def -i -mregexp -t"^You should defin[ai]tely turn more undeads.$" gnun_turns0 = /test gnun_turns({*},0)
/def -i -msimple -t"You should turn more undeads." gnun_turns1 = /test gnun_turns({*},1)
/def -i -msimple -t"You should turn some undeads in the near future." gnun_turns2 = /test gnun_turns({*},2)
/def -i -msimple -t"Your turn rate is good, keep up the good work." gnun_turns3 = /test gnun_turns({*},3)
/def -i -msimple -t"Your turn rate is excellent, the Gods are very pleased." gnun_turns4 = /test gnun_turns({*},4)
/def -i -msimple -t"Your devotions in turning is admirable, good work sister!" gnun_turns5 = /test gnun_turns({*},5)
/def -i -msimple -t"You have turned a horde of undeads, Las is pleased." gnun_turns6 = /test gnun_turns({*},6)
/def -i -msimple -t"You have turned many undeads and thus made Las very happy." gnun_turns7 = /test gnun_turns({*},7)
/def -i -msimple -t"You are feared amongst the undeads, thy are in favour of Las." gnun_turns8 = /test gnun_turns({*},8)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Beehive Maintenance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gnun_combmaint =\
	/if (nun_beemaint)\
	@@remove honeycomb from %{1} slot %{2}%;\
	@@extract honey%;@@extract beewax%;\
	@@clean %{1}%;@@insert honeycomb to %{1} slot %{2}%;\
	/endif

/gdef -i -aCyellow -Enun_beemaint -p9999 -mregexp -t"^But honeycomb slot [0-9]+ is empty\." gnun_combend =\
	/set nun_beemaint=0%;\
	/repeat -1 1 @@close %{nun_beehive}

/gdef -i -aCyellow -Enun_beemaint -p9999 -mregexp -t"^You insert the honeycomb in the slot number ([1-9]+)\." gnun_combok =\
	/set nun_bk=$[{P1}+1]%;\
	/if (nun_bk < 9) /repeat -1 1 /test gnun_combmaint(nun_beehive,nun_bk)%;/endif


;@command /beemaint [hive number]
;@desc Performs beehive maintenance, extract honey and wax from honeycombs
;@desc and clean up the beehive.
/def -i beemaint =\
	/if ({#} > 0)\
		/set nun_beehive=beehive %{1}%;\
	/else \
		/set nun_beehive=beehive%;\
	/endif%;\
	/msq Maintaining beehive: @{BCgreen}%{nun_beehive}@{n}%;\
	/set nun_beemaint=1%;\
	@@open %{nun_beehive}%;\
	/test gnun_combmaint(nun_beehive, 1)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Got purity
/def -i -F -p9999 -msimple -t"You feel more pure and closer to Las." gnun_purity =\
	 /mse gains purity! All hail Las!

;; Lite 'list' at taskmaster
/def -i -p9999 -msimple -t"  | Task name                                    | Stats               |" gnun_list1 =\
	/set nun_list_st=1%;\
	/set nun_list_comp=0%;\
	/set nun_list_notcomp=0

/def -i -Enun_list_st==1 -p9999 -msimple -t"  |          [ :) ] / [ :( ] = Completed / Not Completed               |" gnun_list2 =\
	/set nun_list_st=0%;\
	/test substitute("  |               @{Cgreen}Completed@{n}: @{BCgreen}$[pad(nun_list_comp,-3)]@{n}    /    @{Cred}Not Completed@{n}: @{BCred}$[pad(nun_list_notcomp)]@{n}              |","",1)

/def -i -Enun_list_st==1 -p9999 -mregexp -t"\| \[ :([()]) \]" gnun_list3 =\
	/if ({P1}=~"(")\
		/set nun_list_notcomp=$[nun_list_notcomp+1]%;\
		/let _tc=red%;\
	/else \
		/set nun_list_comp=$[nun_list_comp+1]%;\
		/let _tc=green%;\
	/endif%;\
	/substitute -p @{n}%{PL}| [ @{C%{_tc}}:%{P1}@{n} ]%{PR}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Blast resists
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; It seems that many messages from nun blasts depends on relic
;;; used. Please, let me know (Ealoren Pupunen) what relic and what
;;; messages you get and I'll add those here.

;;; Now testing with:
;;;   Held: A shappy maple cross (holy) aka Newbie Cross
;;;   Held: a vial containing the tears of Oxtoth (holy) aka tears of Oxtoth

; Disabled, because the messages actually represent the damage rather
; than the resists directly... -- Ggr
/def -i gnun_defde = /test 1
;	/eval /def -i -p9999 -mregexp -t"^(Air crackles|Magical mist swirls|White light tangles) around you as dazzling flash erupts from your [A-Za-z ]+ and strikes %{2} upon ([A-Za-z ,.'-]+)." gnun_de_hit%{1} =\
;		/test prspellhit("dispel evil", {P2})%%%;\
;		/test prspresist(%{3}, {P2})

;; Dispel evil 7th best (worst..)
/test gnun_defde(7, "hard", 6)

;; Dispel evil 6th best
/test gnun_defde(6, "mightily", 5)

;; Dispel evil 5th best
/test gnun_defde(5, "with purifying glow", 4)

;; Dispel evil 4th best
/test gnun_defde(4, "with blazing rage", 3)

;; Dispel evil 3th best
/test gnun_defde(3, "with sheer force", 2)

;; Dispel evil 2nd best
/test gnun_defde(2, "with terrific force", 1)

;; Dispel evil the best
/test gnun_defde(1, "with immense power", 1)


/def -i gnun_defst =\
	/eval /def -i -p9999 -mregexp -t"^Your [A-Za-z ]+ (flashes enchantedly|hums celestial tunes) as a %{2} symbol of purify appears into the forehead of ([A-Za-z ,.'-]+)\." gnun_st_hit%{1} =\
		/test prspellhit("saintly touch", {P2})%%%;\
		/test prspresist(%{3}, {P2})

;; Saintly touch worst (compares to DE "strikes hard")
/test gnun_defst(7, "ashy", 6)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Task timer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FIXME! make these variables saved
/set nun_task_n=
/set nun_task_t=0
/set nun_task_c=0

;@command /ntask
;@desc Show currently active/started nun task.
/def -i ntask =\
	/if (nun_task_t > 0)\
		/msq @{BCgreen}Nun task@{n} '@{Ccyan}%{nun_task_n}@{n}' running. Time spent: @{Cyellow}$[prgetstime(nun_task_t)]@{n} (@{Cred}%{nun_task_c}@{n} to complete)%;\
	/else \
		/msq @{BCgreen}No task started!@{n}%;\
	/endif

/def -i -p9999 -mregexp -t"^\* YOU STARTED TASK '([A-Za-z' ]+)', TIME TO COMPLETE: ([a-z0-9 ]+) \*$" gnun_task_started =\
	/set nun_task_n=%{P1}%;/set nun_task_t=$[time()]%;/set nun_task_c=%{P2}

/def -i -p9999 -mregexp -t"^\* CONGRATULATIONS! You have completed nun task '([A-Za-z' ]+)'\*$" gnun_task_completed =\
	/msq @{BCgreen}Completed nun task@{n} '@{Ccyan}%{nun_task_n}@{n}'. Time spent: @{Cyellow}$[prgetstime(nun_task_t)]@{n}%;\
	/set nun_task_n=%;/set nun_task_t=0%;/set nun_task_c=0

/def -i -p9999 -mregexp -t"^\* You have FAILED task '([A-Za-z' ]+)' \*" gnun_task_failed =\
	/if ({P1}=~nun_task_n)\
		/msq @{BCgreen}Failed nun task@{n} '@{Ccyan}%{nun_task_n}@{n}'. Time spent: @{Cyellow}$[prgetstime(nun_task_t)]@{n}%;\
	/else \
		/msq @{BCgreen}Failed nun task@{n} '@{Ccyan}%{P1}@{n}'.%;\
	/endif%;\
	/set nun_task_n=%;/set nun_task_t=0%;/set nun_task_c=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; /np command to @@npray each partymember
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i -P1BCgreen;2Cgreen -mregexp -t"^You make a quick prayer for ([A-Z][a-z]+), (who is a good example to others)\.$" gnun_pray_good
/def -i -P1BCred;2Cred -mregexp -t"^You make a quick prayer for ([A-Z][a-z]+)'s soul, (but it's a lost cause)\.$" gnun_pray_evil

/def -i gnun_npray =\
	/while ({#})\
		/if ({1}!~set_plrname)\
			/send @@npray %{1}%;\
		/endif%;\
		/shift%;\
	/done

;@command /np
;@desc Use 'npray' on every member of your party. This requires GgrTF::PSSMangle module.
/def -i np =\
	/gnun_npray %{gparty_members}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Identify relic translator
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gnun_id_relic =\
	/let _tpower=$[tolower({1})]%;\
	/if (regmatch("(Adelice|Zilvia|Lisandra|Elonore)",{2})) /let _ttype=Holy Power%;\
	/elseif (regmatch("(Dagmar|Malkah|Octavia|Samaria)",{2})) /let _ttype=Dispel Power%;\
	/elseif (regmatch("(Trenna|Dorelle|Brandais|Wilona)",{2})) /let _ttype=Protective Power%;\
	/else /let _ttype=St. %{2}%;/endif%;\
	/substitute -p @{BCyellow}$[pad(_ttype,20)]@{n} @{BCred}==>@{n} @{BCgreen}%{_tpower}@{n}

/def -i -p9999 -mregexp -t"^Dazzling white fume takes over relic as ([A-Za-z-]+) might of St. ([A-Z][a-z]+) reveals itself\.$" gnun_id_relic0 =\
	/test gnun_id_relic({P1},{P2})

/def -i -p9999 -mregexp -t"^([A-Za-z-]+) power of St. ([A-Z][a-z]+) is bind to it\.$" gnun_id_relic1 =\
	/test gnun_id_relic({P1},{P2})

/def -i -p9999 -mregexp -t"^([A-Za-z-]+) aura of St. ([A-Z][a-z]+)'s features enfolds it\.$" gnun_id_relic2 =\
	/test gnun_id_relic({P1},{P2})

/def -i -p9999 -mregexp -t"^The ([A-Za-z-]+) magic of St. ([A-Z][a-z]+) streams through your hands\.$" gnun_id_relic3 =\
	/test gnun_id_relic({P1},{P2})

/def -i -p9999 -mregexp -t"^Twinkling white glow with ([A-Za-z-]+) essence of St. ([A-Z][a-z]+) is bind to this holy artifact\.$" gnun_id_relic4 =\
	/test gnun_id_relic({P1},{P2})

/def -i -p9999 -mregexp -t"^([A-Za-z-]+) zilvery force of St. ([A-Z][a-z]+) radiates from it\.$" gnun_id_relic5 =\
	/test gnun_id_relic({P1},{P2})

/def -i -p9999 -mregexp -t"^Warmth of St. ([A-Z][a-z]+) rushes from relic in form of ([A-Za-z-]+) sparkles\.$" gnun_id_relic6 =\
	/test gnun_id_relic({P2},{P1})

/def -i -p9999 -mregexp -t"^You sense ([A-Za-z-]+) glow of St. ([A-Z][a-z]+)\.$" gnun_id_relic7 =\
	/test gnun_id_relic({P1},{P2})

/def -i -p9999 -mregexp -t"^([A-Za-z-]+) warmth belonging to St. ([A-Z][a-z]+) pulsates beneath the surface\.$" gnun_id_relic8 =\
	/test gnun_id_relic({P1},{P2})

/def -i -p9999 -mregexp -t"^St. ([A-Z][a-z]+)'s spirit is ([A-Za-z-]+) with this artifact\.$" gnun_id_relic9 =\
	/test gnun_id_relic({P2},{P1})

/def -i -p9999 -mregexp -t"^([A-Za-z-]+) strenght of St. ([A-Z][a-z]+) gushes from the core of relic\.$" gnun_id_relic10 =\
	/test gnun_id_relic({P1},{P2})

;/def -i -p9999 -mregexp -t"^\.$" gnun_id_relic8 =\
;	/test gnun_id_relic({P1},{P2})

