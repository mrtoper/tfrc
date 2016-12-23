;;
;; GgrTF::Raise - Support for rais/ress/body/reinc spells
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
/loaded GgrTF::Raise
/test prdefmodule("Raise", "Magical")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bindings etc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;@command /acptbell <off|once|persist>
;@desc Bell when someone has accepted raise/ress/reinc/etc from you.
;@desc "Once" means to bell only once, "persist" keeps on belling until all
;@desc current accepts have been dealt with, or the list is cleared.
/prdefsetting -n"acptbell" -d"Bell when someone accepts rais/reinc/etc." -s"off once persist"


;@command /acptpurge <minutes>
;@desc Threshold time in minutes for /acpurge, older accepts than this
;@desc will be purged from the list.
/prdefvalue -n"acptpurge" -d"Purge threshold in minutes for /acpurge"
/set set_acptpurge=30


/prdefgbind -s"cclear"	-c"/acclear"
/prdefgbind -s"acc"	-c"/aclist"
/prdefgbind -s"clast"	-c"/accast"
/prdefgbind -s"cpurge"	-c"/acpurge"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper functions and initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;/set lst_accepted=
/test prlist_insert("event_login", "acpurge")
/test prlist_insert("event_quit_login", "acpurge")


/def -i gacpt_list_add =\
	/gacpt_list_rm_do $[prconvto({1})] %{lst_accepted}%;\
	/msq @{BCyellow}%{1}@{n} accepted @{BCgreen}%{2}@{n}!%;\
	/set lst_accepted=$[prconvto({1})] $[prconvto({2})] $[time()] %{lst_accepted}%;\
	/gacpt_remind
	

/def -i gacpt_list_rm_do =\
	/let _atmp=%{1}%;/shift%;\
	/set lst_accepted=%;\
	/while ({#})\
		/if ({1}!~_atmp)\
			/set lst_accepted=%{1} %{2} %{3} %{lst_accepted}%;\
		/endif%;\
		/shift%;/shift%;/shift%;\
	/done

/def -i gacpt_list_rm =\
	/msq Removing @{BCyellow}%{1}@{n} from list ...%;\
	/gacpt_list_rm_do $[prconvto({1})] %{lst_accepted}


/def -i gacpt_list_purge_do =\
	/let _atime=$[time() - (set_acptpurge * 60)]%;\
	/set lst_accepted=%;\
	/while ({#})\
		/if ({3} >= _atime)\
			/set lst_accepted=%{1} %{2} %{3} %{lst_accepted}%;\
		/endif%;\
		/shift%;/shift%;/shift%;\
	/done


/def -i gacpt_list_get =\
	/let _atmp=$[tolower({1})]%;/shift%;\
	/set acc_name=%;/set acc_method=%;/set acc_time=%;\
	/while ({#})\
		/if ({1}=~_atmp)\
			/set acc_name=$[prconvfrom({1})]%;\
			/set acc_method=$[prconvpm({2})]%;\
			/set acc_time=%{3}%;\
			/break%;\
		/endif%;\
		/shift%;/shift%;/shift%;\
	/done


/def -i gacpt_list_getfirst =\
	/if ({#})\
		/set acc_name=$[prconvfrom({1})]%;\
		/set acc_method=$[prconvpm({2})]%;\
		/set acc_time=%{3}%;\
	/else \
		/set acc_name=%;\
		/set acc_method=%;\
		/set acc_time=%;\
	/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Implement actual commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i acpurge =\
	/msq Purging accepts older than @{BCwhite}%{set_acptpurge} minutes@{n} from list ...%;\
	/gacpt_list_purge_do %{lst_accepted}


/def -i acclear =\
	/msq Clearing accepted list ...%;\
	/set lst_accepted=


/def -i gacpt_list_print =\
	/while ({#})\
		/msw | @{BCyellow}$[prsubipad(prconvfrom({1}),15)]@{n} | @{BCgreen}$[prsubpad(prconvpm({2}),20)]@{n} | $[prsubpad(prgetstime({3}),10)] |%;\
		/shift%;/shift%;/shift%;\
	/done

/def -i aclist =\
	/if (lst_accepted!~"")\
		/msw ,-----------------.%;\
		/msw | Latest accepted |%;\
		/msw +-----------------+-----------------------------------.%;\
		/gacpt_list_print %{lst_accepted}%;\
		/msw `-----------------------------------------------------'%;\
	/else \
		/msq Nobody has accepted from you!%;\
	/endif


/def -i accast =\
	/if (lst_accepted!~"")\
		/if ({#} > 0)\
			/gacpt_list_get %{1} %{lst_accepted}%;\
		/else \
			/gacpt_list_getfirst %{lst_accepted}%;\
		/endif%;\
		/if (acc_name!~"")\
			/msq Casting @{BCgreen}%{acc_method}@{n} at @{BCyellow}%{acc_name}@{n}.%;\
			@tell %{acc_name} Casting %{acc_method} ...%;\
			@cast %{acc_method} at %{acc_name}%;\
		/else \
			/msq Internal error! (lst_accepted not empty, but could not get name for last anyway)%;\
		/endif%;\
	/else \
		/msq Nobody has accepted from you!%;\
	/endif


;; Succesful resurrection, raise dead and new body
/def -i -F -p9999 -mregexp -t"^You resurrect ([A-Z][a-z]+)\.$" gacpt_succ1 =\
	/test gacpt_list_rm({P1})

/def -i -F -p9999 -mregexp -t"^You raise ([A-Z][a-z]+) from the dead\.$" gacpt_succ2 =\
	/test gacpt_list_rm({P1})

/def -i -F -p9999 -mregexp -t"^You create a new body for ([A-Z][a-z]+)\.$" gacpt_succ3 =\
	/test gacpt_list_rm({P1})


;; Reincarnation
/def -i -F -p9999 -mregexp -t"^You trace misty green runes on a water lily flower " gacpt_succA =\
	/set gacpt_st=1

/def -i -F -p9999 -Egacpt_st -mregexp -t"^Your druidstaff is surrounded by a sudden cloudburst, and you glory" gacpt_succB =\
	/set gacpt_st=0%;/test gacpt_list_rm(cast_info_t)

;/def -i -F -p9999 -mregexp -Eacpt_st -t"^With a green shimmering flash, the water lily flower disappears\." gacpt_succB =\
;	/set gacpt_st=0%;/test gacpt_list_rm(cast_info_t)


;; Reanimation
/def -i -F -p9999 -Egacpt_st -mregexp -t"^Bright blue rays of power shoot from your fingers to the corpse as you scream the words of reanimation. The corpse shakes violently and then opens its eyes just before it pops out of existance." gacpt_succE =\
	/set gacpt_st=0%;/test gacpt_list_rm(cast_info_t)


;; Accepts and cancels
/def -i -F -p9999 -ag -mregexp -t"^([A-Z][a-z]+) accepts (raise dead|resurrect|new body|reincarnation|reanimation) from you\.$" gacpt_you =\
	/test gacpt_list_add({P1},{P2})

/def -i -F -p9999 -ag -mregexp -t"^([A-Z][a-z]+) accepted from someone else\.$" gacpt_off =\
	/msq @{BCgreen}%{P1}@{n} @{BCwhite}accepted from someone else!@{n}%;\
	/test gacpt_list_rm({P1})


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reminder bell functionality
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gacpt_dobell =\
	/set acpt_counter=$[acpt_counter + 1]%;\
	/if (lst_accepted!~"" & acpt_counter < 15)\
		/if (mod(acpt_counter, 2) == 1)\
			/msq @{b}@{BCwhite}You have pending raises/resses/reincs/etc!@{n}%;\
		/else \
			/echo -p @{b}%;\
		/endif%;\
	/else \
		/kill %{acpt_pid}%;\
		/set acpt_pid=-1%;\
	/endif


/def -i gacpt_remind =\
	/if (set_acptbell=~"once")\
		/gacpt_dobell%;\
	/elseif (set_acptbell=~"persist")\
		/set acpt_counter=0%;\
		/gacpt_dobell%;\
		/if (acpt_pid > 0)\
		/else \
			/set acpt_pid=$(/grepeat -30 i /gacpt_dobell)%;\
		/endif%;\
	/endif
