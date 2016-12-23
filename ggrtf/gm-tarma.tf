;;
;; GgrTF::Tarmalen - The Followers of Tarmalen guild support @ BatMUD
;; (C) Copyright 2006-2015 Matti Hämäläinen (Ggr)
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
/loaded GgrTF::Tarmalen
/test prdefmodule("Tarmalen", "Magical")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdefcbind -s"uns"	-c"Unstun"
/prdefcbind -s"unp"	-c"Unpain"
/prdefcbind -s"bot"	-c"Blessing of Tarmalen"
/prdefcbind -s"rp"	-c"Remove Poison"
/prdefcbind -s"da"	-c"Detect Alignment"
/prdefcbind -s"cp"	-c"Cure Player"
/prdefcbind -s"clw"	-c"Cure Light Wounds"		-q
/prdefcbind -s"csw"	-c"Cure Serious Wounds"		-q
/prdefcbind -s"ccw"	-c"Cure Critical Wounds"	-q
/prdefcbind -s"mih"	-c"Minor Heal"			-q
/prdefcbind -s"mah"	-c"Major Heal"			-q
/prdefcbind -s"th"	-c"True Heal"			-q
/prdefcbind -s"miph"	-c"Minor Party Heal"		-q	-n
/prdefcbind -s"maph"	-c"Major Party Heal"		-q	-n
/prdefcbind -s"tph"	-c"True Party Heal"		-q	-n


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Heal all tracking
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set healall_n=
/set healall_t=0

;@command /lastheal
;@desc Show latest detected heal all.

/def lastheal =\
	/if (healall_t > 0)\
		/msq @{BCgreen}Latest heal all@{n} (@{Ccyan}%{healall_n}@{n}): @{Cyellow}$[prgetstime(healall_t)]@{n}%;\
	/else \
		/msq @{BCgreen}No heal alls detected!@{n}%;\
	/endif

/gdef -i -p9999 -aCyellow -mregexp -t"^You feel like ([A-Z][a-z]+)(| the christmas [a-z]+) healed you a bit\.$" ghealall_got =\
	/set healall_n=%{P1}%;/set healall_t=$[time()]

/gdef -i -p9999 -aCyellow -mregexp -t"^You feel like you healed ([0-9]+ players|one player)\.$" ghealall_heal =\
	/set healall_n=%{set_plrname}%;/set healall_t=$[time()]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Numpad healing bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/eval /gcheck_keybinds

;; @keybind Meta/Alt + [asd] = Party heals (minor, major, true)
/def -i -b'^[a' = /prcastn minor party heal
/def -i -b'^[s' = /prcastn major party heal
/def -i -b'^[d' = /prcastn true party heal

;; @keybind Meta/Alt + [qwer] = Single, targetted heals (cure light, serious, critical, major heal, true heal)
/def -i -b'^[q' = /prcast cure light wounds
/def -i -b'^[w' = /prcast cure serious wounds
/def -i -b'^[e' = /prcast cure critical wounds
/def -i -b'^[r' = /prcast major heal
/def -i -b'^[t' = /prcast true heal

;; @keybind Meta/Alt + [zxc] = Cast deaths door, unstun, unpain
/def -i -b'^[z' = /prcast deaths door
/def -i -b'^[x' = /prcast unstun
/def -i -b'^[c' = /prcast unpain

;; @keybind Meta/Alt + f = Stop casting/skills
/def -i -b'^[f' = @@cast stop

;; @keybind Numpad Ins = /pss (show party status)
/def -i -b'^[Op' = /pss
