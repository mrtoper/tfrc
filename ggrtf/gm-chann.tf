;;
;; GgrTF::Channeller - Channellers guild support @ BatMUD
;; (C) Copyright 2004-2015 Matti Hämäläinen (Ggr)
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
/loaded GgrTF::Channeller
/test prdefmodule("Channeller", "Magical")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fails and fumbles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdeffail -c -F    -t"Oh no! You feel energy TEAR from your soul and spread throughout the world!"
/prdeffail -k -F    -t"Oh hell, you fumbled the skill and lost the salve!"


/def -i -F -ag -mregexp -t"^They can only take ([0-9]+) spell points\.$" gchann_replecap =\
	/msr Replenish capped @ %{P1} sp

/def -i -F -ag -mregexp -t"^Leadership was stolen from you by ([A-Z][a-z]+)\.$" gchann_ldrstolen =\
	/msq @{BCgreen}NOTICE!@{n} @{BCyellow}Leadership was stolen from you by@{n} @{BCred}%{P1}@{n}!


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Blast hits
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; You hurl dozens of globes of sizzling blue fire towards your enemies, which explode on contact!
; You hurl a dozen streaking red fireballs towards your enemies, which explode on contact!
; You hurl four head-sized balls of orange flame towards your enemies, which explode on contact!
; You hurl a handful of fist-sized white-hot fireballs towards your enemies, which explode on contact!
/def -i -F -p9999 -ag -mregexp -t"^You hurl [a-z -]+ towards your enemies, which explode on contact!$" gchann_hit1 =\
	/test prspellhit("channelspray","enemies")


; You send forth a roaring blast of blue magic towards Bench and anything in the way!
; You send forth a thin laser-like red beam towards Bench and anything in the way!
; You send forth a bright stream of golden energy towards Bench and anything in the way!
; You send forth a humming beam of white energy towards Bench and anything in the way!
/def -i -F -p9999 -ag -mregexp -t"^You send forth a [a-z -]+ towards .+ and anything in the way!$" gchann_hit2 =\
	/test prspellhit("channelray",{P1})


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Energy Aura
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Aura weakening
/gdef -i -p9999 -aCred -msimple -t"Your aura is starting to weaken!" rec_auraweak =\
	/set prot_eaura_weak=on%;/set prot_eaura_weak_t=$[time()]%;\
	/gstatus_update%;\
	/msr Energy Aura WEAKENING! $[prgetstime(prot_eaura_t)] / $[prgetstime(prot_eaura_t2)]

;; Aura recharged
/gdef -i -p9999 -aCred -mregexp -t"^(Not all is lost, however, you did just recharge your aura|You try your hardest but cannot focus enough energy|You try to focus more magic energy into your aura but get no useful result).$" rec_aurarecharged =\
	/set prot_eaura_weak=off%;\
	/set prot_eaura_t=$[time()]%;\
	/gstatus_update%;\
	/msr Energy Aura Reloaded! 

;; Aura off
/gdef -i -p9999 -aCred -msimple -t"Your aura of glowing light fades to nothing." rec_auraoff =\
	/set prot_eaura_weak=off%;\
	/gprot_off eaura

;; Aura changes
/gdef -i -p9999 -aCred -msimple -t"You turn your aura down a step from red to gold." rec_aurach1 =\
	/set prot_eaura=1%;/gstatus_update

/gdef -i -p9999 -aCred -msimple -t"You turn your aura down a step from blue to red." rec_aurach2 =\
	/set prot_eaura=2%;/gstatus_update

;; Aura on
/gdef -i -p9999 -aCred -msimple -t"Suddenly a softly glowing aura of yellow light comes into being around you." rec_aura1 =\
	/gprot_on eaura [Yellow]%;\
	/set prot_eaura=1%;\
	/set prot_eaura_weak=off%;\
	/gstatus_update%;\
	/set prot_eaura_t2=%{prot_eaura_t}

/gdef -i -p9999 -aCred -msimple -t"With a burst of energy, your aura changes from soft yellow to bright red." rec_aura2 =\
	/gprot_on eaura [Red]%;\
	/set prot_eaura=2%;\
	/set prot_eaura_weak=off%;\
	/gstatus_update%;\
	/set prot_eaura_t2=%{prot_eaura_t}

/gdef -i -p9999 -aCred -mregexp -t"^Tendrils of lightning flit around you as your aura changes from flame red" rec_aura3 =\
	/gprot_on eaura [Blue]%;\
	/set prot_eaura=3%;\
	/set prot_eaura_weak=off%;\
	/gstatus_update%;\
	/set prot_eaura_t2=%{prot_eaura_t}

