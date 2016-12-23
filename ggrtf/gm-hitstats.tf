;;
;; GgrTF::HitStats - Weapon hit statistics
;; (C) Copyright 2008-2015 Matti Hämäläinen (Ggr)
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
/loaded GgrTF::HitStats
/test prdefmodule("HitStats")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hit stats
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set hst_types=bash pierce slash shield whip tiger monk unarmed claw bite

;@command /mhits <off|gag|short>
;@desc Change hit message mangling:
;@desc $off$ = no mangling, pass hit message through unaltered;
;@desc $short$ = use short messages, collecting ALL your hit messages into
;@desc one line like "You jab, dodge, parry, CRUELLY TATTER.";
;@desc $gag$ = gag messages completely.
/prdefsetting -n"mhits" -d"Mangle YOUR hit messages" -s"off gag short"

;@command /weapon1 <type>
;@desc Set the weapon types you are using. Currently only two concurrent
;@desc types are supported. Notice, that if you are using several weapons
;@desc of SAME type/class, you only need to set one (separate weapons of
;@desc same type are counted as one.) Use "/weapon1" without arguments to
;@desc see supported types. Use /weapon[2-4] to set the other weapon types, if any.
/eval /prdefsetting -n"weapon1" -d"Wielded weapon #1 type for hitstats" -s"none %{hst_types}"
/eval /prdefsetting -n"weapon2" -d"Wielded weapon #2 type for hitstats" -s"none %{hst_types}"
/eval /prdefsetting -n"weapon3" -d"Wielded weapon #3 type for hitstats" -s"none %{hst_types}"
/eval /prdefsetting -n"weapon4" -d"Wielded weapon #4 type for hitstats" -s"none %{hst_types}"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Gag something according to stats
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i prset =\
	/eval /if (%{1}=~"") /set %{1}=%{2}%%;/endif

/def -i ghitstats_gag =\
	/if (set_mhits=~"gag") \
		/substitute -ag%;\
	/elseif (set_mhits=~"short") \
		/substitute -ag%;\
		/set hst_short=%{hst_short} %{1},%;\
	/endif

/def -i ghitstats_mangle =\
	/if (set_mhits=~"short" & hst_short!~"")\
		/let _htmp=$[substr(hst_short,1,-1)]%;\
		/echo -p @{BCwhite}You %{_htmp}.@{n}%;\
		/set hst_short=%;\
	/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i ghitstats_init_do =\
	/while ({#})\
		/set lst_%{1}_hits=%;\
		/shift%;\
	/done

/def -i ghitstats_init =\
	/prset set_mhits off%;\
	/prset set_weapon1 none%;\
	/prset set_weapon2 none%;\
	/prset set_weapon3 none%;\
	/prset set_weapon4 none%;\
	/set lst_special=%;\
	/set hst_crithit=0%;\
	/set lst_special=%;\
	/test prlist_insert("event_battle_round", "ghitstats_mangle")%;\
	/ghitstats_init_do %{hst_types}

/ghitstats_init


;; Reset the statistics
/def -i ghitstats_reset_special =\
	/while ({#})\
		/set hst_%{1}=0%;\
		/shift%;\
	/done

/def -i ghitstats_reset_do =\
	/let _hname=%{1}%;/shift%;\
	/while ({#})\
		/set hst_%{_hname}_%{1}=0%;\
		/set hst_c%{_hname}_%{1}=0%;\
		/shift%;\
	/done

/def -i ghitstats_reset =\
	/while ({#})\
		/set hst_%{1}_total=0%;\
		/set hst_%{1}_crits=0%;\
		/eval /ghitstats_reset_do %{1} %%{lst_%{1}_hits}%;\
		/shift%;\
	/done

;@command /hstreset
;@desc Reset and clear current hit-statistics.
/def -i hstreset =\
	/msq @{BCgreen}Resetting hit statistics!@{n}%;\
	/set hst_special=0%;\
	/ghitstats_reset %{hst_types}%;\
	/ghitstats_reset_special %{lst_special}



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i prgetshort =\
	/let _tpos=$[strchr({1}," ")]%;\
	/if (_tpos >= 0)\
		/return strcat(substr({1},0,3),"_",substr({1},_tpos+1))%;\
	/else \
		/return {1}%;\
	/endif


;; Define a special message (for misses, parries, etc.)
/def -i prdefhitspec =\
	/if (!getopts("s:n:t:r", "")) /gerror Invalid prdefhitspec definition!%;/break%;/endif%;\
	/if (opt_s=~""|opt_n=~""|opt_t=~"") /gerror Required arguments not specified!%;/break%;/endif%;\
	/if (opt_r) /let _ttype=regexp%;/else /let _ttype=simple%;/endif%;\
	/test prlist_insert("lst_special", opt_n)%;\
	/def -i -p99999 -F -m%{_ttype} -t"%{opt_t}" ghitstats_%{opt_n} =\
		/ghitstats_gag %{opt_s}%%;\
		/set hst_special=$$[hst_special+1]%%;\
		/set hst_%{opt_n}=$$[hst_%{opt_n}+1]


;; Detect critical hits
/def -i -mregexp -t"^You score a \*?CRITICAL\*? hit!$" ghitstats_crit =\
	/set hst_crithit=1

;; Define a hit message
/def -i prdefhit =\
	/let _hname=%{1}_%{2}%;\
	/let _yname=$[prgetshort({3})]%;\
	/test prlist_insert("lst_%{1}_hits", {2})%;\
	/set hst_name_%{_hname}=%{3}%;\
	/def -i -p99999 -F -mregexp -t"^(You|(Cackling|Smiling|Grinning) (demonically|devilishly|diabolically) you) %{3} (.*)$$" ghitstats_%{_hname} =\
		/if (regmatch("^(your|on) ", {P4})) /break%%;/endif%%;\
		/ghitstats_gag %{_yname}%%;\
		/set hst_%{1}_total=$$[hst_%{1}_total+1]%%;\
		/if (hst_crithit==1) \
			/set hst_%{1}_crits=$$[hst_%{1}_crits+1]%%;\
			/set hst_c%{_hname}=$$[hst_c%{_hname}+1]%%;\
		/else \
			/set hst_%{_hname}=$$[hst_%{_hname}+1]%%;\
		/endif%%;\
		/set hst_crithit=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hit message definitions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Specials
/prdefhitspec -n"misses" -t"^You miss(\.$| )" -r -s"miss"
/prdefhitspec -n"dodges" -t"^You (successfully dodge |dodge\.$)" -r -s"dodge"
/prdefhitspec -n"parries" -t"^(You parry\.|You successfully parry )" -r -s"parry"
/prdefhitspec -n"ripostes" -t"...AND riposte." -s"riposte"
/prdefhitspec -n"tumbles" -t"^You tumble .+?'s dodge\.$" -r -s"tumble"
/prdefhitspec -n"stuns" -t"^You STUN |WHO avoids being stunned with" -r -s"STUN"
/prdefhitspec -n"stunmanos" -t"^LAA LAALIS PASKI ASTUSTA TULLUT ROU" -r -s"stunmano"


;; Bash hit messages
/set hst_name_bash=Bash/Bludgeons
/test prdefhit("bash",  1, "lightly jostle")
/test prdefhit("bash",  2, "jostle")
/test prdefhit("bash",  3, "butt")
/test prdefhit("bash",  4, "bump")
/test prdefhit("bash",  5, "thump")
/test prdefhit("bash",  6, "stroke")
/test prdefhit("bash",  7, "thrust")
/test prdefhit("bash",  8, "jab")
/test prdefhit("bash",  9, "bash")
/test prdefhit("bash", 10, "strike")
/test prdefhit("bash", 11, "sock")
/test prdefhit("bash", 12, "cuff")
/test prdefhit("bash", 13, "knock")
/test prdefhit("bash", 14, "flail")
/test prdefhit("bash", 15, "whack")
/test prdefhit("bash", 16, "beat")
/test prdefhit("bash", 17, "smash")
/test prdefhit("bash", 18, "cruelly beat")
/test prdefhit("bash", 19, "badly smash")
/test prdefhit("bash", 20, "horribly thrust")
/test prdefhit("bash", 21, "savagely sock")
/test prdefhit("bash", 22, "savagely strike")
/test prdefhit("bash", 23, "REALLY WHACK")
/test prdefhit("bash", 24, "BRUTALLY BEAT")
/test prdefhit("bash", 25, "CRUELLY CUFF")
/test prdefhit("bash", 26, "BARBARICALLY BASH")


;; Pierce hit messages
/set hst_name_pierce=Pierce/Poles+Sblades
/test prdefhit("pierce",  1, "barely scratch")
/test prdefhit("pierce",  2, "scratch")
/test prdefhit("pierce",  3, "slightly pierce")
/test prdefhit("pierce",  4, "pierce")
/test prdefhit("pierce",  5, "puncture")
/test prdefhit("pierce",  6, "sink")
/test prdefhit("pierce",  7, "bore")
/test prdefhit("pierce",  8, "crater")
/test prdefhit("pierce",  9, "cavitate")
/test prdefhit("pierce", 10, "shaft")
/test prdefhit("pierce", 11, "gorge")
/test prdefhit("pierce", 12, "really poke")
/test prdefhit("pierce", 13, "riddle")
/test prdefhit("pierce", 14, "dig into")
/test prdefhit("pierce", 15, "dig through")
/test prdefhit("pierce", 16, "chasm")
/test prdefhit("pierce", 17, "drill")
/test prdefhit("pierce", 18, "powerfully perforate")
/test prdefhit("pierce", 19, "powerfully pierce")
/test prdefhit("pierce", 20, "cruelly crater")
/test prdefhit("pierce", 21, "savagely shaft")
/test prdefhit("pierce", 22, "uncontrollably dig through")
/test prdefhit("pierce", 23, "REALLY DRILL")
/test prdefhit("pierce", 24, "CRUELLY RIDDLE ")
/test prdefhit("pierce", 25, "BRUTALLY BORE")
/test prdefhit("pierce", 26, "BARBARICALLY PIERCE")


;; Shield hit messages
/set hst_name_shield=Shield Bash
/test prdefhit("shield",  1, "lightly shove")
/test prdefhit("shield",  2, "lightly batter")
/test prdefhit("shield",  3, "lightly push")
/test prdefhit("shield",  4, "lightly bash")
/test prdefhit("shield",  5, "lightly slam")
/test prdefhit("shield",  6, "lightly crush")
/test prdefhit("shield",  7, "heavily shove")
/test prdefhit("shield",  8, "batter")
/test prdefhit("shield",  9, "heavily push")
/test prdefhit("shield", 10, "heavily bash")
/test prdefhit("shield", 11, "slam")
/test prdefhit("shield", 12, "crush")
/test prdefhit("shield", 13, "really shove")
/test prdefhit("shield", 14, "really batter")
/test prdefhit("shield", 15, "really push")
/test prdefhit("shield", 16, "really bash")
/test prdefhit("shield", 17, "really slam")
/test prdefhit("shield", 18, "really crush")
/test prdefhit("shield", 19, "cruelly shove")
/test prdefhit("shield", 20, "cruelly batter")
/test prdefhit("shield", 21, "cruelly push")
/test prdefhit("shield", 22, "cruelly bash")
/test prdefhit("shield", 23, "REALLY SLAM")
/test prdefhit("shield", 24, "REALLY CRUSH")
/test prdefhit("shield", 25, "BRUTALLY CRUSH")
/test prdefhit("shield", 26, "BARBARICALLY SLAM")


;; Slash hit messages
/set hst_name_slash=Slash/Lblades+Axes
/test prdefhit("slash",  1, "barely graze")
/test prdefhit("slash",  2, "solidly slash")
/test prdefhit("slash",  3, "gash")
/test prdefhit("slash",  4, "lightly cut")
/test prdefhit("slash",  5, "cut")
/test prdefhit("slash",  6, "tear")
/test prdefhit("slash",  7, "incise")
/test prdefhit("slash",  8, "shred")
/test prdefhit("slash",  9, "horribly shred")
/test prdefhit("slash", 10, "slash")
/test prdefhit("slash", 11, "incisively cut")
/test prdefhit("slash", 12, "incisively tear")
/test prdefhit("slash", 13, "slit")
/test prdefhit("slash", 14, "cruelly tatter")
/test prdefhit("slash", 15, "savagely shave")
/test prdefhit("slash", 16, "rive")
/test prdefhit("slash", 17, "cruelly slash")
/test prdefhit("slash", 18, "uncontrollably slash")
/test prdefhit("slash", 19, "quickly cut")
/test prdefhit("slash", 20, "savagely rip")
/test prdefhit("slash", 21, "BRUTALLY TEAR")
/test prdefhit("slash", 22, "SAVAGELY SHRED")
/test prdefhit("slash", 23, "CRUELLY REND")
/test prdefhit("slash", 24, "BARBARICALLY REND")
/test prdefhit("slash", 25, "DISMEMBER")
/test prdefhit("slash", 26, "CRUELLY DISMEMBER")


;; Tiger martial arts hit messages
/set hst_name_tiger=Tiger martial arts
/test prdefhit("tiger",  1, "tickle")
/test prdefhit("tiger",  2, "step on")
/test prdefhit("tiger",  3, "grasp")
/test prdefhit("tiger",  4, "toe-kick")
/test prdefhit("tiger",  5, "knee")
/test prdefhit("tiger",  6, "elbow")
/test prdefhit("tiger",  7, "elbow-smash")
/test prdefhit("tiger",  8, "stomp-kick")
/test prdefhit("tiger",  9, "foot-step")
/test prdefhit("tiger", 10, "twist and throw")
/test prdefhit("tiger", 11, "finger-jab")
/test prdefhit("tiger", 12, "joint-twist")
/test prdefhit("tiger", 13, "back kick")
/test prdefhit("tiger", 14, "spinning back kick")
/test prdefhit("tiger", 15, "phoenix-eye punch")
/test prdefhit("tiger", 16, "spinning backfist")
/test prdefhit("tiger", 17, "jump up and side-kick")
/test prdefhit("tiger", 18, "dragon-claw")
/test prdefhit("tiger", 19, "feint high and then cruelly groin-rip")
/test prdefhit("tiger", 20, "snake-strike, blocking the chi of")
/test prdefhit("tiger", 21, "pummel, with dozens of chain punches,")
/test prdefhit("tiger", 22, "leap, spin, and swallow-tail KICK")
/test prdefhit("tiger", 23, "DEVASTATE, with a thrusting blow,")
/test prdefhit("tiger", 24, "BRUTALLY THROAT RIP")
/test prdefhit("tiger", 25, "SAVAGELY BELLY SMASH")
/test prdefhit("tiger", 26, "CRUELLY TIGER STRIKE")


;; Monk martial arts hit messages
/set hst_name_monk=Monk martial arts
/test prdefhit("monk",  1, "slap")
/test prdefhit("monk",  2, "push")
/test prdefhit("monk",  3, "shove")
/test prdefhit("monk",  4, "grab")
/test prdefhit("monk",  5, "punch")
/test prdefhit("monk",  6, "foot-sweep")
/test prdefhit("monk",  7, "evade, and then reverse")
/test prdefhit("monk",  8, "grab and shoulder-toss")
/test prdefhit("monk",  9, "snap-kick")
/test prdefhit("monk", 10, "joint-lock")
/test prdefhit("monk", 11, "unbalance, then expertly throw")
/test prdefhit("monk", 12, "stop-kick")
/test prdefhit("monk", 13, "reverse spin-kick")
/test prdefhit("monk", 14, "pull, then cruelly throat chop")
/test prdefhit("monk", 15, "trip and head-stomp")
/test prdefhit("monk", 16, "savagely hammerfist")
/test prdefhit("monk", 17, "craftily feint and then grab and flip")
/test prdefhit("monk", 18, "fluidly evade, duck under and spine-chop")
/test prdefhit("monk", 19, "nerve-grab, causing unendurable pain to")
/test prdefhit("monk", 20, "perform a lightning fast punch and throw combo on")
/test prdefhit("monk", 21, "grab, headbutt, then NECK-SNAP")
/test prdefhit("monk", 22, "masterfully evade then JUMP-KICK")
/test prdefhit("monk", 23, "DEVASTATINGLY HEAD-THROW")
/test prdefhit("monk", 24, "HORRIBLY DOUBLE-KICK")
/test prdefhit("monk", 25, "MASTERFULLY POWER-THROW")
/test prdefhit("monk", 26, "DEVASTATINGLY SNAP-KICK")


;; Unarmed hit messages
/set hst_name_unarmed=Unarmed
/test prdefhit("unarmed",  1, "pat")
/test prdefhit("unarmed",  2, "spank")
/test prdefhit("unarmed",  3, "smack")
/test prdefhit("unarmed",  4, "bitchslap")
/test prdefhit("unarmed",  5, "lightly strike")
/test prdefhit("unarmed",  6, "boot")
/test prdefhit("unarmed",  7, "kick")
/test prdefhit("unarmed",  8, "suckerpunch")
/test prdefhit("unarmed",  9, "ankle-stomp")
/test prdefhit("unarmed", 10, "stomp")
/test prdefhit("unarmed", 11, "knee-kick")
/test prdefhit("unarmed", 12, "badly kick")
/test prdefhit("unarmed", 13, "jump-kick")
/test prdefhit("unarmed", 14, "uppercut")
/test prdefhit("unarmed", 15, "kidneypunch")
/test prdefhit("unarmed", 16, "spin-kick")
/test prdefhit("unarmed", 17, "headbutt")
/test prdefhit("unarmed", 18, "cruelly headbutt")
/test prdefhit("unarmed", 19, "dragon-punch")
/test prdefhit("unarmed", 20, "savagely triple-kick")
/test prdefhit("unarmed", 21, "roundhouse")
/test prdefhit("unarmed", 22, "bodyslam")
/test prdefhit("unarmed", 23, "run into")
/test prdefhit("unarmed", 24, "REALLY SMASH")
/test prdefhit("unarmed", 25, "BRUTALLY BOOT")
/test prdefhit("unarmed", 26, "BARBARICALLY BEAT")

;; Whip hit messages
/set hst_name_whip=Whip
/test prdefhit("whip",  1, "lash")
/test prdefhit("whip",  2, "lightly lash")
/test prdefhit("whip",  3, "lightly flog")
/test prdefhit("whip",  4, "slightly slash")
/test prdefhit("whip",  5, "flog")
/test prdefhit("whip",  6, "slice")
/test prdefhit("whip",  7, "sharply slice")
/test prdefhit("whip",  8, "lightly flick")
/test prdefhit("whip",  9, "flick")
/test prdefhit("whip", 10, "whip")
/test prdefhit("whip", 11, "wantonly whip")
/test prdefhit("whip", 12, "welt")
/test prdefhit("whip", 13, "lightly blister")
/test prdefhit("whip", 14, "blister")
/test prdefhit("whip", 15, "badly flog")
/test prdefhit("whip", 16, "slightly gash")
/test prdefhit("whip", 17, "savagely cut")
/test prdefhit("whip", 18, "sharply cut")
/test prdefhit("whip", 19, "thrash")
/test prdefhit("whip", 20, "cruelly thrash")
/test prdefhit("whip", 21, "slightly slit")
/test prdefhit("whip", 22, "strap")
/test prdefhit("whip", 23, "lather")
/test prdefhit("whip", 24, "SADISTICALLY SLASH")
/test prdefhit("whip", 25, "MADLY THRASH")
/test prdefhit("whip", 26, "WILDLY WHIP")


;; Claw hit messages
/set hst_name_claw=Claw
/test prdefhit("claw",  1, "lightly claw")
/test prdefhit("claw",  2, "claw")
/test prdefhit("claw",  3, "barely scrape")
/test prdefhit("claw",  4, "scrape")
/test prdefhit("claw",  5, "prick")
/test prdefhit("claw",  6, "stick")
/test prdefhit("claw",  7, "lacerate")
/test prdefhit("claw",  8, "perforate")
/test prdefhit("claw",  9, "badly perforate")
/test prdefhit("claw", 10, "wound")
/test prdefhit("claw", 11, "badly wound")
/test prdefhit("claw", 12, "savagely claw")
/test prdefhit("claw", 13, "cruelly perforate")
/test prdefhit("claw", 14, "plunge")
/test prdefhit("claw", 15, "lightly eviscerate")
/test prdefhit("claw", 16, "ram")
/test prdefhit("claw", 17, "clash")
/test prdefhit("claw", 18, "savagely strike")
/test prdefhit("claw", 19, "eviscerate")
/test prdefhit("claw", 20, "cruelly rip")
/test prdefhit("claw", 21, "nastily plunge")
/test prdefhit("claw", 22, "cruelly ram")
/test prdefhit("claw", 23, "WHACK")
/test prdefhit("claw", 24, "RELENTLESSLY RAM")
/test prdefhit("claw", 25, "CRUELLY CLAW")
/test prdefhit("claw", 26, "BARBARICALLY LACERATE")


;; Bite hit messages
/set hst_name_bite=Bite
/test prdefhit("bite",  1, "sample")
/test prdefhit("bite",  2, "morsel")
/test prdefhit("bite",  3, "nibble")
/test prdefhit("bite",  4, "taste")
/test prdefhit("bite",  5, "bite")
/test prdefhit("bite",  6, "nip")
/test prdefhit("bite",  7, "really taste")
/test prdefhit("bite",  8, "snap")
/test prdefhit("bite",  9, "munch")
/test prdefhit("bite", 10, "chomp")
/test prdefhit("bite", 11, "gnaw")
/test prdefhit("bite", 12, "split")
/test prdefhit("bite", 13, "masticate")
/test prdefhit("bite", 14, "badly chomp")
/test prdefhit("bite", 15, "chew")
/test prdefhit("bite", 16, "rip")
/test prdefhit("bite", 17, "cruelly gnaw")
/test prdefhit("bite", 18, "cruelly chomp")
/test prdefhit("bite", 19, "savagely snap")
/test prdefhit("bite", 20, "brutally bite")
/test prdefhit("bite", 21, "meanly munch")
/test prdefhit("bite", 22, "really chew")
/test prdefhit("bite", 23, "horribly munch")
/test prdefhit("bite", 24, "SAVAGELY CHEW")
/test prdefhit("bite", 25, "UNCONTROLLABLY GNAW")
/test prdefhit("bite", 26, "BARBARICALLY BITE")



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Output helper functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gline_add =\
	/eval /set hst_str_%{hst_line}=%%{hst_str_%{hst_line}}%{1}%;\
	/set hst_line=$[hst_line+1]

/def -i gline_clear =\
	/let _line=0%;\
	/while (_line <= {1})\
		/eval /unset hst_str_%{_line}%;\
		/let _line=$[_line+1]%;\
	/done

/def -i gline_print =\
	/let _line=1%;\
	/while (_line <= {1})\
		/let _line_s=$[prgetval(strcat("hst_str_",_line))]%;\
		/if (_line_s!~"") /msw %{_line_s}|%;/endif%;\
		/let _line=$[_line+1]%;\
	/done

/def -i ghitstats_print =\
	/let _nlines=%{3}%;\
	/let _hst_name=$[prgetval(strcat("hst_name_",{1},"_",{2}))]%;\
	/let _hst_hits=$[prgetval(strcat("hst_",{1},"_",{2}))]%;\
	/let _hst_crits=$[prgetval(strcat("hst_c",{1},"_",{2}))]%;\
	/if (_hst_hits > 0 | _hst_crits > 0)\
		/if (hst_noprint==1)\
			/set hst_total=$[hst_total + _hst_hits]%;\
			/set hst_crits=$[hst_crits + _hst_crits]%;\
			/set hst_count=$[hst_count + 1]%;\
			/set hst_line=$[hst_line+1]%;\
		/else \
			/if (hst_total > 0)\
				/let _htmp=$[trunc((100 * _hst_hits) / hst_total)]%;\
			/else \
				/let _htmp=0%;\
			/endif%;\
			/if (hst_crits > 0)\
				/let _ctmp=$[trunc((100 * _hst_crits) / hst_crits)]%;\
			/else \
				/let _ctmp=0%;\
			/endif%;\
			/test gline_add("|$[pad(substr(_hst_name,0,20),-20)]: @{Cgreen}$[pad(_hst_hits, 6)]@{n} (@{BCgreen}$[pad(_htmp,3)]\\%@{n}):@{Cred}$[pad(_hst_crits, 6)]@{n} (@{BCred}$[pad(_ctmp,3)]\\%@{n})")%;\
		/endif%;\
	/else \
		/if (hst_noprint==0 & hst_line >= _nlines)\
			/test gline_add("|                                               ")%;\
		/endif%;\
	/endif


/def -i ghitstats_dolist =\
	/let _thn=%{1}%;/shift%;\
	/let _thc=%{1}%;/shift%;\
	/while ({#}) /test ghitstats_print(_thn,{1},_thc)%;/shift%;/done

/def -i ghitstats_list =\
	/set hst_column=$[hst_column+1]%;\
	/set hst_line=0%;\
	/test gline_add("-----------------------------------------------")%;\
	/let _hst_name=$[prgetval(strcat("hst_name_",{1}))]%;\
	/test gline_add("+-| @{BCgreen}$[pad(_hst_name,-20)]@{n} |----------------------")%;\
	/eval /ghitstats_dolist %{1} %%{hst_nlines%{hst_column}} %%{lst_%{2}_hits}



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main stats output macro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;@command /hstats
;@desc Print out hit statistics in a pretty table (see the warning above
;@desc about the terminal width, though.)

/def -i hstats =\
/set hst_count=0%;\
/set hst_total=0%;\
/set hst_crits=0%;\
/msw ,----------------------.%;\
/msw | @{BCgreen}GgrTF@{n} @{Cyellow}Hit Statistics@{n} |%;\
\
/set hst_column=0%;\
/set hst_noprint=1%;\
/if (set_weapon1!~"none") /ghitstats_list %{set_weapon1} %{set_weapon1}%;/endif%;\
/set hst_nlines1=%{hst_line}%;\
/if (set_weapon2!~"none") /ghitstats_list %{set_weapon2} %{set_weapon2}%;/endif%;\
/set hst_nlines2=%{hst_line}%;\
/if (hst_nlines1 >= hst_nlines2)\
	/set hst_nlines=%{hst_nlines1}%;\
	/set hst_list=%{set_weapon1}%;\
/else \
	/set hst_nlines=%{hst_nlines2}%;\
	/set hst_list=%{set_weapon2}%;\
/endif%;\
/gline_clear %{hst_nlines}%;\
/set hst_column=0%;\
/set hst_noprint=0%;\
/if (set_weapon1!~"none") /ghitstats_list %{set_weapon1} %{hst_list}%;/endif%;\
/if (set_weapon2!~"none") /set hst_str_0=%{hst_str_0}-%;/ghitstats_list %{set_weapon2} %{hst_list}%;/endif%;\
/if (hst_str_0!~"") /msw +%{hst_str_0}.%;/endif%;\
/gline_print $[hst_nlines]%;\
/if (hst_str_0!~"") /msw +%{hst_str_0}+%;/endif%;\
/gline_clear %{hst_nlines}%;\
\
\
/set hst_column=0%;\
/set hst_noprint=1%;\
/if (set_weapon3!~"none") /ghitstats_list %{set_weapon3} %{set_weapon3}%;/endif%;\
/set hst_nlines1=%{hst_line}%;\
/if (set_weapon4!~"none") /ghitstats_list %{set_weapon4} %{set_weapon4}%;/endif%;\
/set hst_nlines2=%{hst_line}%;\
/if (hst_nlines3 >= hst_nlines4)\
	/set hst_nlines=%{hst_nlines1}%;\
	/set hst_list=%{set_weapon1}%;\
/else \
	/set hst_nlines=%{hst_nlines2}%;\
	/set hst_list=%{set_weapon2}%;\
/endif%;\
/gline_clear %{hst_nlines}%;\
/set hst_column=0%;\
/set hst_noprint=0%;\
/if (set_weapon3!~"none") /ghitstats_list %{set_weapon3} %{hst_list}%;/endif%;\
/if (set_weapon4!~"none") /set hst_str_0=%{hst_str_0}-%;/ghitstats_list %{set_weapon4} %{hst_list}%;/endif%;\
/if (hst_str_0!~"") /msw +%{hst_str_0}.%;/endif%;\
/gline_print $[hst_nlines]%;\
/if (hst_str_0!~"") /msw +%{hst_str_0}+%;/endif%;\
/gline_clear %{hst_nlines}%;\
\
/msw +-| @{BCred}Totals@{n} |-------------------------------------------+%;\
/let _qtmp=$[hst_total + hst_misses]%;\
/if (_qtmp != 0) \
	/let _qtmp1=$[trunc((100 * hst_total) / _qtmp)]%;\
	/let _qtmp2=$[trunc((100 * hst_misses) / _qtmp)]%;\
	/let _qtmp3=$[trunc((100 * hst_crits)  / _qtmp)]%;\
/else \
	/let _qtmp1=0%;\
	/let _qtmp2=0%;\
	/let _qtmp3=0%;\
/endif%;\
/msw | Hits..: @{Cgreen}$[pad(hst_total,-10)]@{n} (@{BCgreen}$[pad(_qtmp1,3)]\%@{n}) | Crits: @{Cred}$[pad(hst_crits,-10)]@{n} (@{BCred}$[pad(_qtmp3,3)]\%@{n}) |%;\
/msw | Misses: @{Cyellow}$[pad(hst_misses,-10)]@{n} (@{BCyellow}$[pad(_qtmp2,3)]\%@{n}) | Total hit types: @{BCwhite}$[pad(hst_count,-7)]@{n} |%;\
/msw +------------------------------------------------------+%;\
/msw | Dodges.....: @{BCmagenta}$[pad(hst_dodges,-12)]@{n} | Parries...: @{BCyellow}$[pad(hst_parries,-12)]@{n} |%;\
/msw | Tumbles....: @{BCgreen}$[pad(hst_tumbles, -12)]@{n} | Stuns.....: @{BCred}$[pad(hst_stuns,-12)]@{n} |%;\
/msw | Ripostes...: @{BCgreen}$[pad(hst_ripostes,-12)]@{n} | Stun mano.: @{BCred}$[pad(hst_stunmanos,-12)]@{n} |%;\
/msw `------------------------------------------------------'
