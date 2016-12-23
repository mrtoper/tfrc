;;
;; GgrTF::TargettedCast - Numpad controlled targetting
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
/loaded GgrTF::TargettedCast
/test prdefmodule("TargettedCast", "PSSMangle", "Magical")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/test prlist_insert("set_move_s", "cast")
/set ncast_tgt=
/set ncast_spell=

/prdeftoggle -p -n"keybinds" -d"Keyboard numpad cast bindings"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Numpad-targetted spellcasting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cast spell without target
/def -i prcastn =\
	/if (spell_st!~"on" | {*}!~ncast_spell)\
		/set ncast_tgt=%;\
		/set ncast_spell=%{*}%;\
		@@cast '%{*}'%;\
	/endif

;; Cast a spell at current target
/def -i prcast =\
	/if (cast_target!~"")\
		/if (spell_st!~"on" | cast_target!~ncast_tgt | {*}!~ncast_spell)\
			/set ncast_tgt=%{cast_target}%;\
			/set ncast_spell=%{*}%;\
			@@cast '%{*}' %{cast_target}%;\
		/endif%;\
	/else \
		/msq @{BCred}No target set!@{n}%;\
	/endif


;; When "/move cast" mode is selected, /prmove macro is redirected
;; to this macro, which translates directions (assumed to be 3x3 matrix
;; like the normal PC keyboard numpad is) into party places for
;; targetting of spells.

/def -i prmove_cast =\
	/if	({1}=~"nw")	/let _t=1_1%;\
	/elseif ({1}=~"n")	/let _t=1_2%;\
	/elseif ({1}=~"ne")	/let _t=1_3%;\
	/elseif ({1}=~"w")	/let _t=2_1%;\
	/elseif ({1}=~"X")	/let _t=2_2%;\
	/elseif ({1}=~"e")	/let _t=2_3%;\
	/elseif ({1}=~"sw")	/let _t=3_1%;\
	/elseif ({1}=~"s")	/let _t=3_2%;\
	/elseif ({1}=~"se")	/let _t=3_3%;\
	/else /set cast_target=%;/break%;/endif%;\
	/set cast_target=$[prgetval(strcat("gparty_",_t,"_s"))]%;\
	/msq @{Cyellow}Cast Target@{n} -> @{BCwhite}%{cast_target}@{n}
