;;
;; GgrTF::Magical - Module for generic magical stuff @ BatMUD
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
/loaded GgrTF::Magical
/test prdefmodule("Magical")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdefcbind -s"seemagic" -c"See Magic"
/prdefcbind -s"seeinvis" -c"See Invisible"
/prdefcbind -s"ww"       -c"Water Walking"
/prdefcbind -s"float"    -c"Floating"
/prdefcbind -s"invis"    -c"Invisibility"
/prdefcbind -s"ad"       -c"Aura Detection"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialization and options
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdeftoggle -n"spshort" -d"Shorten spellname in round report"
/prdeftoggle -n"rmagic" -d"General magic reporting spam"
/prdeftoggle -n"rresist" -d"Report blast resists"

/prdefvar -n"cmd_rmagic" -v"@@emote" -c"Command/macro used for general magic reporting spam"
/prdefvar -n"cmd_rresist" -v"/msr" -c"Command/macro used for reporting blast resists"

/eval /def -i mrmagic = /if (opt_rmagic=~"on") %{cmd_rmagic} %%*%%;/endif
/eval /def -i mrresist = /if (opt_rresist=~"on") %{cmd_rresist} %%*%%;/endif

/def -i prgetinitials =\
	/if ({#} <= 1) /result "%{*}"%;/endif%;\
	/let _sres=%;\
	/while ({#})\
		/let _sres=%{_sres}$[substr({1},0,1)]%;\
		/shift%;\
	/done%;\
	/result _sres

;; NOTICE! The regmatch here is used to filter out gagged spells from
;; spell round reporting. It is VERY important that this works, because
;; otherwise things like spider demon names will get reported.
/def -i mrrounds =\
	/if (opt_rrounds!~"on" | regmatch(strcat("^(",gspell_gag,")$"),cast_info_n)) /return%;/endif%;\
	/if (spell_rleft <= set_roundmin)\
		/if (opt_spshort=~"on")\
			/let _ctmp=$(/prgetinitials %{cast_info_n})%;\
		/else \
			/let _ctmp=%{cast_info_n}%;\
		/endif%;\
		/if (cast_info_t!~"")\
			/msr %{_ctmp} -> %{cast_info_t} @ %{spell_rleft}%;\
		/else \
			/msr %{_ctmp} @ %{spell_rleft}%;\
		/endif%;\
	/endif


;; Spell names to be ignored/gagged from reporting
/set gspell_gag=spider demon conjuration


;; Spell names per type (for blast damage analysis and reporting)
/set gspell_type_mana=aneurysm|banish demons|cause critical wounds|cause light wounds|cause serious wounds|channelball|channelray|cleanse heathen|dispel evil|dispel good|dispel undead|drain enemy|earthquake|energy vortex|flames of righteousness|golden arrow|harm body|hemorrhage|holy bolt|holy hand|holy wind|levin bolt|magic eruption|magic missile|magic wave|saintly touch|star light|summon greater spores|summon lesser spores|wither flesh|word of apocalypse|word of blasting|word of destruction|word of genocide|word of oblivion|word of slaughter|word of spite
/set gspell_type_elec=blast lightning|chain lightning|channelbolt|electrocution|forked lightning|lightning bolt|lightning storm|rune of warding|shocking grasp
/set gspell_type_fire=channelburn|channelspray|con fioco|fire blast|firebolt|flame arrow|gem fire|lava blast|lava storm|meteor blast|meteor swarm

/set gspell_type_asphyx=black hole|blast vacuum|chaos bolt|strangulation|suffocation|vacuum ball|vacuumbolt|vacuum globe
/set gspell_type_poison=killing cloud|poison blast|poison spray|power blast|summon carnal spores|thorn spray|venom strike
/set gspell_type_cold=chill touch|cold ray|cone of cold|darkfire|flaming ice|hailstorm|hoar frost|icebolt|summon storm

/set gspell_type_acid=acid arrow|acid blast|acid rain|acid ray|acid storm|acid wind|disruption
/set gspell_type_psi=mind blast|mind disruption|noituloves deathlore|psi blast|psibolt|psychic crush|psychic shout|psychic storm|mindseize
/set gspell_type_phys=destroy water|noituloves dischord|uncontrollable mosh


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fails and fumbles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdeffail -c -F -r -t"^You falter and fumble the spell. Amazingly it fires upon "

/prdeffail -c -F    -t"You fumble the spell."


/prdeffail -c -f -r -t"^You (fail miserably in your|stutter the magic words and fail the) spell.$"

/prdeffail -c -f -r -t"^You .* (spell misfires|spell fizzles).$"

/prdeffail -c -f    -t"You stumble and lose your concentration."

/prdeffail -c -f -r -t"^Your (spell just sputters|concentration fails and so does your spell|mind plays a trick with you and you fail in your spell|concentration drifts away as you think you feel a malignant aura)."

/prdeffail -c -f    -t"Something touches you and spoils your concentration ruining the spell."

/prdeffail -c -f    -t"The spell fails."


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spellcasting and spell-status reporting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Okay, so you're asking "how does this pile of junk work?"
; It's pretty simple (and somewhat vulnerable, admittably). We track status of
; spellcasting by setting few variables here and there and check their states
; in various places. Here are meanings for some of them:
;
; spell_t	- timestamp of when casting started
; spell_rfirst	- 1 if first round (or rounds, if your essence eye is bad)
; spell_st	- 'on' during cast, 'off' when cast is finished
; spell_st2	- 'off' during cast, 'on' when cast is finished
;		these two variables let us know when chant has been done
;		and it is time to check for fails/fumbles.
; spell_hastes,
; spell_ghastes	- counters for hastes/ghastes for current cast
;
; cast_info	- empty for no cast/skill going on, 'SP' for spells, 'SK' for skills
; cast_info_n	- name of skill/spell currently going on
; cast_info_t	- target of skill/spell (empty if no target)

;; Start of spell


/def -i -F -p9999 -msimple -t"You start chanting." gspell_start =\
	/if (ceremony_st2=~"on")/let _cere=[@{BCgreen}CERE@{n}]%;/else /let _cere=%;/endif%;\
	/set ceremony_st2=off%;\
	/set ceremony_st=off%;\
	/set spell_t=$[time()]%;\
	/set cnt_casts=$[cnt_casts+1]%;\
	/set spell_rfirst=1%;\
	/set spell_rcount=0%;\
	/set spell_st=on%;\
	/set spell_st2=off%;\
	/set spell_hastes=0%;\
	/set spell_ghastes=0%;\
	/set cast_info=SP%;/set cast_info_n=%;/set cast_info_t=%;@@cast info%;\
	/msk @{BCyellow} ---- SPELL START ---- @{n} (@{Cyellow}%{cnt_casts}@{n}) %{_cere}%;\
	/gstatus_update%;/prexecfuncs %{event_spell_start}


;; Spell done
/def -i -F -p9999 -msimple -t"You are done with the chant." gspell_end =\
	/set cnt_trounds=$[cnt_trounds+spell_rcount]%;\
	/set cnt_scasts=$[cnt_scasts+1]%;\
	/set spell_st=off%;\
	/set spell_st2=on%;\
	/set cast_info=%;\
	/set cnt_ctime=$[cnt_ctime+time()-spell_t]%;\
	/msk @{Cbggreen} ---- SPELL DONE ---- @{n} in [@{BCred}%{spell_rcount}@{n}] @{BCgreen}rounds!@{n} @{Cyellow}$[prgetstime(spell_t)]@{n}%;\
	/gstatus_update%;/prexecfuncs %{event_spell_done}


;; Cast info
/def -i -F -p9999 -ag -mregexp -t"^You are casting \'([a-z ]+)\'.$" gspell_info1 =\
	/set cast_info_n=%{P1}%;\
	/set cast_info_t=%;\
	/gshow_info

/def -i -F -p9999 -ag -mregexp -t"^You are casting \'([a-z ]+)\' at \'([A-Za-z0-9_ ,.'-]+)\'.$" gspell_info2 =\
	/set cast_info_n=%{P1}%;\
	/set cast_info_t=%{P2}%;\
	/gshow_info


;; Spell failed
/def -i gspell_fail =\
	/if (spell_st2=~"on")\
		/set cnt_scasts=$[cnt_scasts-1]%;\
		/set cnt_fcasts=$[cnt_fcasts+1]%;\
		/set spell_st2=off%;\
	/endif

;; Spell fumbled
/def -i gspell_fumble =\
	/if (spell_st2=~"on")\
		/set cnt_scasts=$[cnt_scasts-1]%;\
		/set cnt_fucasts=$[cnt_fucasts+1]%;\
		/set spell_st2=off%;\
	/endif

;; Spell interrupted
/def -i gspell_interrupt =\
	/if (spell_st=~"on")\
		/msq @{Cbgred} ---- SPELL INTERRUPTED ---- @{n}%;\
		/set cnt_icasts=$[cnt_icasts+1]%;\
		/set spell_st=off%;\
		/set cast_info=%;\
		/gstatus_update%;\
		/prexecfuncs %{event_spell_intr}%;\
	/endif

/def -i gspell_stopped =\
	/if (spell_st=~"on")\
		/msq @{Cbgred} ---- SPELL STOPPED ---- @{n}%;\
		/set cnt_icasts=$[cnt_icasts+1]%;\
		/set spell_st=off%;\
		/set cast_info=%;\
		/gstatus_update%;\
		/prexecfuncs %{event_spell_stop}%;\
	/endif

/def -i -F -p9999 -ag -mregexp -t"^You(r movement prevents you from casting| have insufficient strength to cast| lose your concentration and cannot cast) the spell.$" gspell_interrupt1 =\
	/gspell_interrupt

/def -i -F -p9999 -ag -mregexp -t"^You (get hit SO HARD that you have to stop your spell|lose your concentration and stop your spell casting|massage your wounds and forget your spell).$" gspell_interrupt2 =\
	/gspell_interrupt

/def -i -F -p9999 -ag -msimple -t"The ground shakes violently! EARTHQUAKE!" gspell_interrupt3 =\
	/gspell_interrupt

/def -i -F -p9999 -ag -mregexp -t"^You interrupt the (spell|chant in order to start a new chant)\.$" gspell_stopped1 =\
	/gspell_stopped

/def -i -F -p9999 -ag -mregexp -t"^You stop concentrating on the spell and begin searching for a proper place to rest\.$" gspell_stopped2 =\
	/gspell_stopped


;; Spell rounds
/def -i -F -p9999 -mregexp -t"^([A-Z][a-z ]+): (#+)$" gspell_round =\
	/set spell_rleft=$[strlen({P2})]%;\
	/set cast_info_n=$[tolower({P1})]%;\
	/if (opt_skspam=~"on") /substitute -p @{Cyellow}%{P1}: %{P2}@{n} [@{BCgreen}%{spell_rleft}@{n}]%;/endif%;\
	/prexecfuncs %{event_spell_round}%;\
	/if (spell_rfirst)\
		/set spell_rfirst=0%;\
		/set spell_rcount=%{spell_rleft}%;\
		/if (battle_st != 0) /mrrounds%;/endif%;\
	/else \
		/mrrounds%;\
	/endif


;; Cast burden/slow
/gdef -i -F -p9999 -aCgreen -msimple -t"Your heavy burden slows down your casting." gspell_burden =\
	/set spell_rleft=$[spell_rleft+1]%;\
	/set spell_rcount=$[spell_rcount+1]%;\
	/mrrounds%;/mrmagic slows down


;; Cast haste
/gdef -i -F -p9999 -aCgreen -msimple -t"You skillfully cast the spell with haste." gspell_haste =\
	/set spell_rleft=$[spell_rleft-1]%;\
	/set spell_rcount=$[spell_rcount-1]%;\
	/set cnt_hastes=$[cnt_hastes+1]%;\
	/mrrounds%;/mrmagic hastes


;; Cast greater haste
/gdef -i -F -p9999 -aCgreen -msimple -t"You skillfully cast the spell with greater haste." gspell_ghaste =\
	/set spell_rleft=$[spell_rleft-2]%;\
	/set spell_rcount=$[spell_rcount-2]%;\
	/set cnt_ghastes=$[cnt_ghastes+1]%;\
	/mrrounds%;/mrmagic ghastes

;; Cast quick lips
/gdef -i -F -p9999 -aCgreen -msimple -t"ASDFZ." gspell_qlips1 =\
	/set spell_rleft=$[spell_rleft-2]%;\
	/set spell_rcount=$[spell_rcount-2]%;\
	/set cnt_qlips1=$[cnt_qlips1+1]%;\
	/mrrounds%;/mrmagic ghastes


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Battle targetting and resistances
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This code has potential "logic hole", as we have to trust what the MUD
; tells us is happening, when a blast spell hits target or targets.
;
; - Spell name is gotten from hit message, then it is transformed to
;   damage type.
; - Area spells produce multiple resistance messages (one per monster),
;   thus we have to "blindly" assume that it was the previously
;   assumed spell. This should be the case, unless someone is fucking us up.
; - The above is mainly the reason we do not check for equivalent
;   target names. Also, some spells do not give target names at blast hit.
; - Basically this system can be only confused by feeding arbitrary
;   invalid input to it, thus a wizard (or player descs etc) could achieve
;   such effect.
;
/eval /def -i prgetspelltype =\
	/if (regmatch("^(%{gspell_type_mana})$$",{1})) /return "mana"%%;\
	/elseif (regmatch("^(%{gspell_type_elec})$$",{1})) /return "elec"%%;\
	/elseif (regmatch("^(%{gspell_type_fire})$$",{1})) /return "fire"%%;\
	/elseif (regmatch("^(%{gspell_type_asphyx})$$",{1})) /return "asphyx"%%;\
	/elseif (regmatch("^(%{gspell_type_poison})$$",{1})) /return "poison"%%;\
	/elseif (regmatch("^(%{gspell_type_cold})$$",{1})) /return "cold"%%;\
	/elseif (regmatch("^(%{gspell_type_acid})$$",{1})) /return "acid"%%;\
	/elseif (regmatch("^(%{gspell_type_psi})$$",{1})) /return "psi"%%;\
	/elseif (regmatch("^(%{gspell_type_phys})$$",{1})) /return "phys"%%;\
	/else /return "???"%%;/endif

/def -i prspellhit=\
	/set resist_spell=%{1}%;/set battle_target=%{2}%;\
	/msw Your @{Cred}%{1}@{n} hits @{BCgreen}%{2}@{n}.


/def -i prspresist =\
	/if ({1}==1)	/let resist_str=screams%;	/let resist_val=0%;	/let resist_col=@{BCgreen}%;\
	/elseif ({1}==2)/let resist_str=writhes%;	/let resist_val=20%;	/let resist_col=@{Cgreen}%;\
	/elseif ({1}==3)/let resist_str=shudders%;	/let resist_val=40%;	/let resist_col=@{BCyellow}%;\
	/elseif ({1}==4)/let resist_str=grunts%;	/let resist_val=60%;	/let resist_col=@{Cyellow}%;\
	/elseif ({1}==5)/let resist_str=winces%;	/let resist_val=80%;	/let resist_col=@{Cred}%;\
	/elseif ({1}==6)/let resist_str=shrugs%;	/let resist_val=100%;	/let resist_col=@{BCred}%;\
	/else		/let resist_str=???%;		/let resist_val=???%;	/let resist_col=@{Cwhite}%;\
	/endif%;\
	/let resist_type=$[prgetspelltype(resist_spell)]%;\
	/substitute -p @{Cgreen}%{2}@{n} %{resist_col}%{resist_str}@{n} @{BCwhite}%{resist_type}@{n} (@{BCwhite}%{resist_val}%%@{n} resist)%;\
	/mrresist [%{2}] %{resist_val}%% %{resist_type} resist

/def -i -p9999 -ag -mregexp -t"^([A-Za-z ,.'-]+) screams in pain\.$" gspell_resist1 = /test prspresist(1,{P1})
/def -i -p9999 -ag -mregexp -t"^([A-Za-z ,.'-]+) writhes in agony\.$" gspell_resist2 = /test prspresist(2,{P1})
/def -i -p9999 -ag -mregexp -t"^([A-Za-z ,.'-]+) shudders from the force of the attack\.$" gspell_resist3 = /test prspresist(3,{P1})
/def -i -p9999 -ag -mregexp -t"^([A-Za-z ,.'-]+) grunts from the pain\.$" gspell_resist4 = /test prspresist(4,{P1})
/def -i -p9999 -ag -mregexp -t"^([A-Za-z ,.'-]+) winces a little from the pain\.$" gspell_resist5 = /test prspresist(5,{P1})
/def -i -p9999 -ag -mregexp -t"^([A-Za-z ,.'-]+) shrugs off the attack\.$" gspell_resist6 = /test prspresist(6,{P1})


/def -i -F -p9999 -mregexp -t"^You watch with self-?pride as your ([a-z ]+) hits (.+)\.$" gspell_hit1 =\
	/test prspellhit({P1},{P2})

/def -i -F -p9999 -mregexp -t"^You crush (.+)\'s mind with your psychic attack!$" gspell_hit2 =\
	/test prspellhit("psychic crush",{P1})

/def -i -F -p9999 -mregexp -t"^You focus on the mind of (.+)\.$" gspell_hit3 =\
	/test prspellhit("mindseize",{P1})


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Damage criticality
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gdef -i -F -p9999 -aCgreen -msimple -t"You feel like your spell gained additional power." gspell_dcrit1 =\
	/set cnt_damcrits=$[cnt_damcrits+1]%;\
	/set cnt_dcrit1=$[cnt_dcrit1+1]%;\
	/msr Damcrit (1)

/gdef -i -F -p9999 -aCgreen -msimple -t"You feel like you managed to channel additional POWER to your spell." gspell_dcrit2 =\
	/set cnt_damcrits=$[cnt_damcrits+1]%;\
	/set cnt_dcrit2=$[cnt_dcrit2+1]%;\
	/msr Damcrit (2)

/gdef -i -F -p9999 -aCgreen -msimple -t"Your fingertips are surrounded with swirling ENERGY as you cast the spell." gspell_dcrit3 =\
	/set cnt_damcrits=$[cnt_damcrits+1]%;\
	/set cnt_dcrit3=$[cnt_dcrit3+1]%;\
	/msr Damcrit (3)

/gdef -i -F -p9999 -aCgreen -mregexp -t"^You feel in contact with the essence of ([a-z]+).$" gspell_ecrit1 =\
	/set cnt_damcrits=$[cnt_damcrits+1]%;\
	/set cnt_dcrit4=$[cnt_dcrit4+1]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gdef -i -F -p9999 -aCgreen -msimple -t"You sizzle with magical energy." gmagic_sizzle =\
	/mrmagic vibrates noisily.

/gdef -i -F -p9999 -aCgreen -msimple -t"You surreptitiously conceal your spell casting." gmagic_conceal =\
	/mrmagic conceals ...

/gdef -i -F -p9999 -aCgreen -msimple -t"You feel your skills in handling elemental forces improve." gmagic_essence =\
	/mrmagic gains essence!
