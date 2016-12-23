;;
;; GgrTF::Alchemist - Alchemist guild support and utility macros
;; (C) Copyright 2012 Matti Hämäläinen (Ggr)
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
/loaded GgrTF:Bard
/test prdefmodule("Bard")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General settings and data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set gbard_spells=Achromatic eyes|Campfire tune|Catchy singalong|Clandestine thoughts|Con fioco|Dancing blades|Jesters trivia|Kings feast|Melodical embracement|Melody of the misadventurer|Musicians alm|Noituloves deathlore|Noituloves dischord|Pathfinder|Singing shepherd|Soothing sounds|Sounds of silence|Strength in unity|Sweet lullaby|Uncontrollable mosh|Venturers way|Vigilant melody|War ensemble
/set gbard_masters=Zinbaf Gilian Endek Dria Yomototh Vahearun Sineyole Derevan Zantus Forsimnetu Cyarus Noitulove Stringbreaker Zord Tinebring Otharus Aline Malecketh Razmatag Patricia Holm Fyanna Talos
/eval /set gbard_list_spells=$[replace("|"," ",replace(" ","_",gbard_spells))]


/def -i prlist_get_idx_do =\
	/let _name=%{1}%;/shift%;\
	/let _idx=0%;\
	/while ({#})\
		/let _idx=$[_idx+1]%;\
		/if ({1}=~_name) /result _idx%;/endif%;\
		/shift%;\
	/done%;\
	/result -1

/def -i prlist_get_idx =\
	/let _item=$[tolower(replace(" ","_",{2}))]%;\
	/let _list=$[tolower(eval("/return %{1}",2))]%;\
	/return $(/prlist_get_idx_do %{_item} %{_list})

/def -i gbard_get_master =\
	/let _idx=$[prlist_get_idx("gbard_list_spells", {1})]%;\
	/if (_idx > 0)\
		/return "$(/nth %{_idx} %{gbard_masters})"%;\
	/else \
		/return ""%;\
	/endif


/eval /def -i -F -p9999 -mregexp -t"^ (%{gbard_spells}) +(.+?)  +(known by heart|not in memory|currently in memory|once heard, barely in memory)$$" gbard_score =\
	/let _col1=Cyellow%%;\
	/if ({P3}=~"known by heart") /let _col3=Cgreen%%;/let _col1=Cgreen%%;/let _status=KBH%%;\
	/elseif ({P3}=~"currently in memory") /let _col3=Cyellow%%;/let _status=memory%%;\
	/else /let _col3=Cred%%;/let _status=-%%;/endif%%;\
	/let _master=$$[gbard_get_master({P1})]%%;\
	/substitute -p @{%%{_col1}} $$[prsubipad({P1},23)]@{n} | $$[prsubipad({P2},25)] | @{%%{_col3}}$$[prsubipad(_status,7)]@{n} | %%{_master}


/def -i getmaster =\
	/let _master=$[gbard_get_master({*})]%;\
	/if (_master!~"")\
		/msq Songmaster for spell '%{*}' is %{_master}.%;\
		/send @@bgreet $[tolower(_master)]%;\
	/else \
		/msq No such bard spellsong '%{*}'.%;\
	/endif

