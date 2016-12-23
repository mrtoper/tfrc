;;
;; GgrTF::Beastmaster - Beastmaster guild support @ BatMUD
;; (C) Copyright 2010 Matti Hämäläinen (Ggr)
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
/loaded GgrTF::Beastmaster
/test prdefmodule("Beastmaster")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fails and fumbles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mount handling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gbmaster_getmount =\
	/if ({#} > 0 & {1}!~"")\
		/let _mount=%{*}%;\
	/elseif (bmount_curr!~"")\
		/let _mount=%{bmount_curr}%;\
	/else \
		/let _mount=%{bmount_last}%;\
	/endif%;\
	/return gbmaster_short(_mount)

/def -i gbmaster_short =\
	/let _mount=%{*}%;\
	/if (regmatch("^([A-Za-z ]+) [0-9]+$", _mount))\
		/let _mount=%{P1}%;\
	/endif%;\
	/return _mount

/def -i -p1 -mregexp -t"^(.+?) gives you a big slobbery lick\.$" gbmaster_arrives =\
	/let _mount=%{P1}%;\
	/if (_mount =~ gbmaster_short(bmount_curr))\
		/test gbmaster_ride(_mount)%;\
	/else \
		/test gbmaster_lead(_mount)%;\
	/endif

/def -i gbmaster_lead =\
	/set bmount_last=$[gbmaster_getmount({1})]%;\
	/if (bmount_last =~ gbmaster_short(bmount_curr))\
		@@dismount%;\
	/endif%;\
	@@lead %{bmount_last}

/def -i gbmaster_ride =\
	/set bmount_last=$[gbmaster_getmount({1})]%;\
	/let _short=$[gbmaster_short(bmount_curr)]%;\
	/if (bmount_last =~ _short)\
		@@release%;\
	/endif%;\
	@@ride %{bmount_last}

/def -i gbmaster_heel =\
	/if ({#} > 0 & {1}!~"")\
		/let _mount=%{*}%;\
	/elseif (bmount_curr!~"")\
		/let _mount=%{bmount_curr}%;\
	/endif%;\
	/set bmount_last=%{_mount}%;\
	@@use heel at %{_mount}

;; Remount or lead
/def -i gbmaster_remount =\
	/let _mount=$[gbmaster_short(bmount_curr)]%;\
	@@ride %{_mount}%;\
	@@lead %{_mount}



;; Heel mount
/def -i -mregexp -t" seems to perk up. It will now respond to:$|^This animal already responds to your call with the syntax:$" gbmaster_get_heel1 =\
	/set bmount_flag=1
	
/def -i -ag -Ebmount_flag -mregexp -t"^use heel at (.+)$" gbmaster_get_heel2 =\
	/set bmount_flag=0%;\
	/set bmount_curr=%{P1}%;\
	/msq @{BCwhite}Mount heel id@{n}: '@{BCgreen}%{bmount_curr}@{n}'.


;; Auto remount
/def -i -mregexp -t"^(You are knocked off your mount!|Your mount throws you!|Your annoyed mount throws you!)$" gbmaster_dismount =\
	/msr Thrown off mount!%;\
	/repeat -0.5 1 /gbmaster_remount


/def -i ride = @@release $[gbmaster_short(bmount_curr)]%;/test gbmaster_ride({*})
/def -i rele = @@release $[gbmaster_getmount({*})]
/def -i lead = /test gbmaster_lead({*})
/def -i heel = /test gbmaster_heel({*})
/def -i dis = @@dismount%;@@lead $[gbmaster_short(bmount_curr)]
/def -i store = @@dismount%;@@release%;@@store $[gbmaster_getmount({*})]

/def -i rug =\
	/set bmount_last=$[gbmaster_getmount({*})]%;\
	@@party report Ride underground -> %{bmount_last}%;\
	@@use ride underground at %{bmount_last}
