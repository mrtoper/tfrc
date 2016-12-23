;;
;; GgrTF::Spider - Spider guild support @ BatMUD
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
/loaded GgrTF::Spider
/test prdefmodule("Spider")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialization and options
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set spider_pid=0
/set spider_timer_t=35
/set spider_warn_t=15
/set spider_avgn_min=60
/set spider_avgq_min=80

/def -i gspider_reset =\
	/set spider_drain_t=0%;\
	/set spider_ctrl_t=0%;\
	/set spider_drains=0%;\
	/set spider_easy=0%;\
	/set spider_easy_n=0%;\
	/set spider_type=0

/def -i gspider_reset_extra =\
	/set spider_avgn_val=$[prrepval(5, spider_avgn_min)]%;\
	/set spider_avgq_val=$[prrepval(5, spider_avgq_min)]

/gspider_reset
/gspider_reset_extra


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Spider related lites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spiderservant
/glite -mregexp -t'^([a-zA-Z0-9_ ]+)( the spider whispers )\'(.*)\'$' gservant_whisper =\
	/substitute -p @{Cred}%{P1}@{n}%{P2}@{Cyellow}'%{P3}'@{n}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gspider_drain =\
	/if (spider_easy)\
		/set spider_easy_n=$[spider_easy_n+1]%;\
	/endif%;\
	/set spider_drain_t=$[time()]%;\
	/set spider_drains=$[spider_drains+1]%;\
	/set spider_easy=0


/def -i gspider_inform =\
	/set spider_pid=0%;\
	/msq @{Cgreen}Upcoming spider demon drain in %{spider_warn_t}s.@{n}


/def -i gspider_stop_timer =\
	/if (spider_pid > 0)\
		/kill %{spider_pid}%;\
		/set spider_pid=0%;\
		/set spider_next_drain=0%;\
	/endif

/def -i gspider_setup_timer =\
	/if ({1} > spider_warn_t)\
		/gspider_stop_timer%;\
		/set spider_next_drain=$[time() + {1}]%;\
		/set spider_pid=$(/grepeat -$[{1} - spider_warn_t] 1 /gspider_inform)%;\
	/endif


/def -i gspider_control =\
	/msq @{BCgreen}Demon controlled.@{n}%;\
	/set spider_ctrl_t=$[time()]%;\
	/set spider_type=0%;\
	/set spider_drains=0%;\
	/let _dtime=$(/praverage %{spider_avgn_val})%;\
	/test gspider_setup_timer(_dtime)


/def -i gspider_drain_queen =\
	/mss @{BCgreen}The Spider Queen is smiling, demon battlechannelled.@{n}%;\
	/if (spider_ctrl_t > 0)\
		/let _ddelta=$[time() - spider_ctrl_t]%;\
		/set spider_avgq_val=$(/prnth %{spider_avgq_val} %{_ddelta})%;\
		/let _dtime=$(/praverage %{spider_avgq_val})%;\
		/test gspider_setup_timer(_dtime)%;\
	/endif%;\
	/gspider_drain%;\
	/set spider_ctrl_t=$[time()]%;\
	/set spider_type=1


/def -i gspider_drain_normal =\
	/if (spider_easy)\
		/mss @{BCgreen}Demon channelled with points.@{n}%;\
	/else \
		/mss @{BCred}Demon channelled without points!!@{n}%;\
	/endif%;\
	/if (spider_ctrl_t > 0)\
		/let _ddelta=$[time() - spider_ctrl_t]%;\
		/set spider_avgn_val=$(/prnth %{spider_avgn_val} %{_ddelta})%;\
	/endif%;\
	/gspider_drain


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spider demon control
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/eval /def -i -F -p9999 -ag -msimple -t"You feed %{set_plrname}'s spider demon's hunger with your ritual." gspider_ctrl =\
	/gspider_control

;; Point(s) used or not?
/eval /def -i -F -p9999 -ag -msimple -t"%{set_plrname}'s demon feels easier to control than usual." gspider_easydrain =\
	/set spider_easy=1

;; Spider demon channelling message
/eval /def -i -F -p9999 -msimple -t"%{set_plrname}'s spider demon draws power from you." gspider_normaldrain =\
	/gspider_drain_normal

;; Channelling with help from queen
/def -i -F -p9999 -msimple -t"Spider Queen smiles upon you and helps you control the demon." gspider_queendrain =\
	/gspider_drain_queen

;; Demon banished
/def -i -F -p9999 -msimple -t"You feel your mind returning back to normal." gspider_banished =\
	/gspider_reset

;; Banish failure
/def -i -F -p9999 -msimple -t"Alien thoughts invade your mind! Your body no longer is yours alone!" gspider_banishfail =\
	/msr HAAALP demon is doing mean things!! Need banish or channel!!


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;@command /spidstatus
;;@desc Prints time elapsed since last demon control, demon drains
;;@desc (and possibly other demon status information in future).
/def -i spidstatus =\
	/if (spider_ctrl_t > 0)\
		/if (spider_type)\
			/let _extra=@{Cred}battle/queen@{n}%;\
		/else \
			/let _extra=normal%;\
		/endif%;\
		/msq @{BCyellow}Time since last control:@{n} @{BCwhite}$[prgetstime(spider_ctrl_t)]@{n} (%{_extra} control)%;\
	/else \
		/msq @{BCred}No demon controls registered yet.@{n}%;\
	/endif%;\
	/if (spider_drains > 0)\
		/if (spider_easy_n > 0)\
			/let _extra=(@{BCwhite}%{spider_easy_n}@{n} easy)%;\
		/else \
			/let _extra=%;\
		/endif%;\
		/msq @{BCgreen}Drains:@{n} @{BCwhite}%{spider_drains}@{n}, $[prgetstime(spider_drain_t)] ago. %{_extra}@{n}%;\
	/else \
		/msq @{BCgreen}No drains happened yet!@{n}%;\
	/endif
