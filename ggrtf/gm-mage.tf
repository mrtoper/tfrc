;;
;; GgrTF::Mage - Brotherhood of Magic guild support @ BatMUD
;; (C) Copyright 2006-2015 Jarkko Vääräniemi (Jeskko) & Matti Hämäläinen (Ggr)
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
/loaded GgrTF::Mage
/test prdefmodule("Mage", "Magical")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdefcbind -s"p1"	-c"Thorn Spray" -q
/prdefcbind -s"p2"	-c"Poison Blast" -q
/prdefcbind -s"p3"	-c"Venom Strike" -q
/prdefcbind -s"p4"	-c"Power Blast" -q
/prdefcbind -s"p5"	-c"Summon Carnal Spores" -q
/prdefcbind -s"pa1"	-c"Poison Spray" -q
/prdefcbind -s"pa2"	-c"Killing Cloud" -q
/prdefcbind -s"a1"	-c"Disruption" -q
/prdefcbind -s"a2"	-c"Acid Wind" -q
/prdefcbind -s"a3"	-c"Acid Arrow" -q
/prdefcbind -s"a4"	-c"Acid Ray" -q
/prdefcbind -s"a5"	-c"Acid Blast" -q
/prdefcbind -s"aa1"	-c"Acid Rain" -q
/prdefcbind -s"aa2"	-c"Acid Storm" -q
/prdefcbind -s"m1"	-c"Magic Missile" -q
/prdefcbind -s"m2"	-c"Summon Lesser Spores" -q
/prdefcbind -s"m3"	-c"Levin Bolt" -q
/prdefcbind -s"m4"	-c"Summon Greater Spores" -q
/prdefcbind -s"m5"	-c"Golden Arrow" -q
/prdefcbind -s"ma1"	-c"Magic Wave" -q
/prdefcbind -s"ma2"	-c"Magic Eruption" -q
/prdefcbind -s"c1"	-c"Chill Touch" -q
/prdefcbind -s"c2"	-c"Flaming Ice" -q
/prdefcbind -s"c3"	-c"Darkfire" -q
/prdefcbind -s"c4"	-c"Icebolt" -q
/prdefcbind -s"c5"	-c"Cold Ray" -q
/prdefcbind -s"ca1"	-c"Cone of Cold" -q
/prdefcbind -s"ca2"	-c"Hailstorm" -q
/prdefcbind -s"s1"	-c"Vacuumbolt" -q
/prdefcbind -s"s2"	-c"Suffocation" -q
/prdefcbind -s"s3"	-c"Chaos Bolt" -q
/prdefcbind -s"s4"	-c"Strangulation" -q
/prdefcbind -s"s5"	-c"Blast Vacuum" -q
/prdefcbind -s"sa1"	-c"Vacuum Ball" -q
/prdefcbind -s"sa2"	-c"Vacuum Globe" -q
/prdefcbind -s"f1"	-c"Flame Arrow" -q
/prdefcbind -s"f2"	-c"Firebolt" -q
/prdefcbind -s"f3"	-c"Fire Blast" -q
/prdefcbind -s"f4"	-c"Meteor Blast" -q
/prdefcbind -s"f5"	-c"Lava Blast" -q
/prdefcbind -s"fa1"	-c"Meteor Swarm" -q
/prdefcbind -s"fa2"	-c"Lava Storm" -q
/prdefcbind -s"e1"	-c"Shocking Grasp" -q
/prdefcbind -s"e2"	-c"Lightning Bolt" -q
/prdefcbind -s"e3"	-c"Blast Lightning" -q
/prdefcbind -s"e4"	-c"Forked Lightning" -q
/prdefcbind -s"e5"	-c"Electrocution" -q
/prdefcbind -s"ea1"	-c"Chain Lightning" -q
/prdefcbind -s"ea2"	-c"Lightning Storm" -q


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Numpad cast bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/eval /gcheck_keybinds

/def -i gdefmagetype =\
	/set mgtype_%{1}_name=%{2}%;\
	/set mgtype_%{1}_bl1=%{3}%;\
	/set mgtype_%{1}_bl2=%{4}%;\
	/set mgtype_%{1}_bl3=%{5}%;\
	/set mgtype_%{1}_bl4=%{6}%;\
	/set mgtype_%{1}_bl5=%{7}%;\
	/set mgtype_%{1}_bla1=%{8}%;\
	/set mgtype_%{1}_bla2=%{9}%;\
	/set mgtype_%{1}_prot1=%{10}%;\
	/set mgtype_%{1}_prot2=%{11}%;\
	/set mgtype_%{1}_conj=%{12}

/def -i prtype =\
	/let _typen=$[prgetval(strcat("mgtype_",{1},"_name"))]%;\
	/msq @{Cyellow}Cast Type@{n} -> @{BCwhite}%{_typen}@{n}%;\
	/set mgcast_type=%{1}

/def -i prblast =\
	/let _spelln=$[prgetval(strcat("mgtype_",mgcast_type,"_bl",{1}))]%;\
	/prcastn %{_spelln}

/prdeftoggle -n"rconj" -d"Report keybinded conju prots"

/def -i prprot =\
	/let _spelln=$[prgetval(strcat("mgtype_",mgcast_type,"_prot",{1}))]%;\
	/if (opt_rconj=~"on") /msr %{_spelln} -> %{cast_target} %;/endif%;\
	/prcast %{_spelln}

/def -i prconj =\
	/let _elementn=$[prgetval(strcat("mgtype_",mgcast_type,"_conj"))]%;\
	@@cast 'conjure element' %{_elementn}

;; Types and respective spells and elemental names

/test gdefmagetype("1","Acid","disruption","acid wind","acid arrow","acid ray","acid blast","acid rain","acid storm","corrosion shield","acid shield","acid")
/test gdefmagetype("2","Asphyxiation","vacuumbolt","suffocation","chaos bolt","strangulation","blast vacuum","vacuum ball","vacuum globe","ether boundary","aura of wind")
/test gdefmagetype("3","Cold","chill touch","flaming ice","darkfire","icebolt","cold ray","cone of cold","hailstorm","frost insulation","frost shield","cold")
/test gdefmagetype("4","Electricity","shocking grasp","lightning bolt","blast lightning","forked lightning","electrocution","chain lightning","lightning storm","energy channeling","lightning shield","electric")
/test gdefmagetype("5","Fire","flame arrow","firebolt","fire blast","meteor blast","lava blast","meteor swarm","lava storm","heat reduction","flame shield","fire")
/test gdefmagetype("6","Magical","magic missile","summon lesser spores","levin bolt","summon greater spores","golden arrow","magic wave","magic eruption","magic dispersion","repulsor aura","magic")
/test gdefmagetype("7","Poison","thorn spray","poison blast","venom strike","power blast","summon carnal spores","poison spray","killing cloud","toxic dilution","shield of detoxification","poison")

;; @keybind Meta/Alt + [qwertyu] = Blast type selection (acid, asphyxiation, cold, electricity, fire, magical, poison)

/def -i -b'^[q' = /prtype 1
/def -i -b'^[w' = /prtype 2
/def -i -b'^[e' = /prtype 3
/def -i -b'^[r' = /prtype 4
/def -i -b'^[t' = /prtype 5
/def -i -b'^[y' = /prtype 6
/def -i -b'^[u' = /prtype 7

;; @keybind Meta/Alt + [asdfghj] = Cast blasts (from smallest to biggest, then areas)

/def -i -b'^[a' = /prblast 1
/def -i -b'^[s' = /prblast 2
/def -i -b'^[d' = /prblast 3
/def -i -b'^[f' = /prblast 4
/def -i -b'^[g' = /prblast 5
/def -i -b'^[h' = /prblast a1
/def -i -b'^[j' = /prblast a2

;; @keybind Meta/Alt + z = Stop casting

/def -i -b'^[z' = @@cast stop

;; @keybind Meta/Alt + [xcvbn] = Cast conjurer prots

/def -i -b'^[x' = \
	/if (opt_rconj=~"on") /msr Force Absorption -> %{cast_target} %;/endif%;\
	/prcast force absorption
/def -i -b'^[c' = \
	/if (opt_rconj=~"on") /msr Armour of Aether -> %{cast_target} %;/endif%;\
	/prcast armour of aether
/def -i -b'^[v' = /prprot 1
/def -i -b'^[b' = /prprot 2
/def -i -b'^[n' = /prconj

;; @keybind Numpad Ins = /pss (show party status)
/def -i -b'^[Op' = /pss

/def -i key_nkp, = @show effects %{cast_target}
