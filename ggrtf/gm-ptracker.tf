;;
;; GgrTF::ProtTracker - Party-wide prot tracker
;; (C) Copyright 2007-2015 Matti Hämäläinen (Ggr)
;; Originally based on ideas by Aloysha
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
/loaded GgrTF::ProtTracker
/test prdefmodule("ProtTracker", "PSSMangle")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;@command /effects
;@desc Toggle support for using output of 'show effects' command in
;@desc party prots tracker. Enabling this will disable tracking
;@desc of prot up/down messages reported by party members and makes
;@desc the tracker to use 'show effects' output only. This also means
;@desc that the shown times in this mode are "time remaining", not
;@desc "time elapsed". Requires /gsave and restart of TF to work.
;@desc (If you are not using the GgrTF statesaving system, you can
;@desc /set opt_effects=on in your .tfrc before loading this module.)

/prdeftoggle -p -n"effects"	-d"Enable 'show effects' support in ptracker"

/prdefgbind -s"pprots" -c"/pprots"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utility functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/def -i gpprot_getn_do =\
	/while ({#})\
		/let _tz=^($[prgetval(strcat("pprot_",{1},"_A"))])$$%;\
		/if (regmatch(_tz,_pprot_fs)) /return {1}%;/endif%;\
		/shift%;\
	/done%;\
	/return ""

/def -i gpprot_getn =\
	/set _pprot_fs=$[tolower({*})]%;\
	/gpprot_getn_do %{lst_pprots}

/def -i gpprot_gete_do =\
	/while ({#})\
		/let _tz=$[tolower(prgetval(strcat("prot_",{1},"_l")))]%;\
		/if (_tz=~_pprot_fs) /return {1}%;/endif%;\
		/shift%;\
	/done%;\
	/return ""

/def -i gpprot_gete =\
	/set _pprot_fs=$[tolower({*})]%;\
	/gpprot_gete_do %{lst_pprots}

/def -i gpprot_parse_time =\
	/let _time=%{1}%;\
	/if (regmatch("^([0-9]+)h and ([0-9]+)min",_time))\
		/return {P1}*60*60 + {P2}*60%;\
	/elseif (regmatch("^([0-9]+)min and ([0-9]+)s",_time))\
		/return {P1}*60 + {P2}%;\
	/elseif (regmatch("^([0-9]+)min",_time))\
		/return {P1}*60%;\
	/elseif (regmatch("^([0-9]+)s",_time))\
		/return {P1}%;\
	/else /return -1%;/endif

/def -i gpprot_get_time =\
	/let _jtime=%{1}%;\
	/let _jtimeh=$[_jtime/3600]%;\
	/let _jtimeq=$[mod(_jtime,3600)]%;\
	/let _jtimem=$[_jtimeq/60]%;\
	/let _jtimes=$[mod(_jtimeq,60)]%;\
	/if (_jtimeh > 0)\
		/let _jstr=%{_jtimeh}:%;\
	/else \
		/let _jstr=%;\
	/endif%;\
	/if (_jtimes < 10)\
		/let _jtimespre=0%;\
	/else \
		/let _jtimespre=%;\
	/endif%;\
		/let _jstr=%{_jstr}$[_jtimeq/60]:%{_jtimespre}$[mod(_jtimeq,60)]%;\
	/return _jstr%;\


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Support code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; The reason we have several triggers with complex patterns here is
;; because of TF's apparent bug(s) in the regexp handling and TF4's
;; somewhat inferior support for regexp options.

/def -i gpprot_defines =\
/if (opt_effects!~"on")\
/def -i -p9999 -F -mregexp -t"^([A-Z][a-z]+) .(party|report).: +[(<>]? *([A-Za-z _-]+) *[>)]? (on|\\+on\\+|\\(on\\)|\\[On\\]|\\[ON\\]|up|active|activat|ON|UP|ACTIVE|ACTIVAT|On|Up|Active|Activat|Renewed|refresh)" gpprot_on1 =\
	/test gpprot_on({P1},{P3})%;\
\
/def -i -p9999 -F -mregexp -t"^([A-Z][a-z]+) .(party|report).: +[(<>]? *([A-Za-z _-]+) *[>)]? (off|-off-|OFF|Off|\\(off\\)|\\[Off\\]|\\[OFF\\]|DOWN|Down|down|Expires|Expired|expires|expired|gone|Gone|was destroyed)" gpprot_off1 =\
	/test gpprot_off({P1},{P3})%;\
\
/def -i -p9999 -F -mregexp -t"^([A-Z][a-z]+) .(party|report).: - ([A-Za-z _-]+) (UP|up|Up)" gpprot_on2 =\
	/test gpprot_on({P1},{P3})%;\
\
/def -i -p9999 -F -mregexp -t"^([A-Z][a-z]+) .(party|report).: - ([A-Za-z _-]+) (DOWN|down|Down)" gpprot_off2 =\
	/test gpprot_off({P1},{P3})%;\
\
/def -i -p9999 -F -mregexp -t"^([A-Z][a-z]+) .(party|report).: \\[ ([A-Za-z _-]+) (UP|up|Up|active)" gpprot_on3 =\
	/test gpprot_on({P1},{P3})%;\
\
/def -i -p9999 -F -mregexp -t"^([A-Z][a-z]+) .(party|report).: \\[ ([A-Za-z _-]+) (DOWN|down|Down)" gpprot_off3 =\
	/test gpprot_off({P1},{P3})%;\
/else \
	/undef gpprot_on1%;/undef gpprot_off1%;\
	/undef gpprot_on2%;/undef gpprot_off2%;\
	/undef gpprot_on3%;/undef gpprot_off3%;\
/endif

/def -i gpprot_on =\
	/let _pname=$[gpprot_getn({2})]%;\
	/if (_pname!~"")\
		/test prlist_insert("lst_members",{1})%;\
		/set pprot_%{1}_%{_pname}=1%;\
		/set pprot_%{1}_%{_pname}_t=$[time()]%;\
	/endif

/def -i gpprot_off =\
	/let _pname=$[gpprot_getn({2})]%;\
	/if (_pname!~"")\
		/set pprot_%{1}_%{_pname}=0%;\
		/set pprot_%{1}_%{_pname}_t=0%;\
	/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Prot definitions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set lst_pprots=
/set lst_members=

/def -i prdefpartyprot =\
	/if (!getopts("i:A:m#","")) /gerror Invalid prot tracker definition!%;/break%;/endif%;\
	/if (opt_i=~"") /gerror Prot tracker definition missing identifier (-i)%;/break%;/endif%;\
	/let _short=$[prgetval(strcat("prot_",opt_i,"_n"))]%;\
	/if (_short=~"") /gerror Prot tracker definition '%{opt_i}' has no matching prot system definition.%;/break%;/endif%;\
	/set lst_pprots=%{lst_pprots} %{opt_i}%;\
	/set pprot_%{opt_i}_A=$[tolower(opt_A)]%;\
	/if (opt_m > 0)\
		/set pprot_%{opt_i}_m=%{opt_m}%;\
	/else \
		/set pprot_%{opt_i}_m=-1%;\
	/endif

;	test prlist_insert("lst_pprots", opt_i)%;\


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main functions for tracking
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gpprots_clear_member =\
	/let _zplr=%{1}%;/shift%;\
	/while ({#})\
		/eval /unset pprot_%{_zplr}_%{1}%;\
		/eval /unset pprot_%{_zplr}_%{1}_t%;\
		/shift%;\
	/done

/def -i gpprots_clear =\
	/while ({#})\
		/gpprots_clear_member %{1} %{lst_pprots}%;\
		/shift%;\
	/done

;@command /cpprots
;@desc Clears ALL the currently tracked prots and all other related
;@desc data. Using this may be useful if some prots erraneously "linger".
/def -i cpprots =\
	/msq @{BCgreen}NOTICE!@{n} @{BCwhite}Clearing all tracked prots!@{n}%;\
	/gpprots_clear %{lst_members}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/def -i gpprots_update_member =\
	/let _zplr=%{1}%;/shift%;\
	/while ({#})\
		/let _zta=$[prgetval(strcat("pprot_",_zplr,"_",{1}))]%;\
		/let _ztt=$[prgetval(strcat("pprot_",_zplr,"_",{1},"_t"))]%;\
		/let _ztm=$[prgetval(strcat("pprot_",{1},"_m"))]%;\
		/if (_zta > 0)\
			/if (_ztm > 0 & (time() - _ztt) >= (_ztm + 10))\
				/set pprot_%{_zplr}_%{1}=0%;\
			/else \
				/test prlist_insert("lst_pactive",{1})%;\
			/endif%;\
		/endif%;\
		/shift%;\
	/done

/def -i gpprots_update_active =\
	/set lst_pactive=%;\
	/while ({#})\
		/gpprots_update_member %{1} %{lst_pprots}%;\
		/shift%;\
	/done
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Show effects handlers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i -F -p9999 -Egpp_eff -mregexp -t"^(,-----------------------------------------+\.|\|=========================================+\||\| Effects \([A-Z][a-z]+\) *\| Lasts *\|)$" gpprots_eff0 =\
	/substitute -ag

/def -i -F -p99 -Egpp_eff -mregexp -t"^(`-----------------------------------------+.|No effects to show. \([A-Z][a-z]+\)|Target not present!|No such player in party\.)$" gpprots_eff2 =\
	/substitute -ag%;\
	/gpprots_get_effects

/def -i -F -p9999 -Egpp_eff -mregexp -t"^\| ([A-Z][A-Za-z ]*?) *\| (For now|[0-9minshand ]+?) *\|$" gpprots_eff3 =\
	/let _tmpn=%{P1}%;/let _tmpt=%{P2}%;\
	/let _ptime=$[gpprot_parse_time(_tmpt)]%;\
	/let _pname=$[gpprot_getn(_tmpn)]%;\
	/if (_pname!~"")\
		/test prlist_insert("lst_members",gpp_name)%;\
		/set pprot_%{_pname}=1%;\
		/set pprot_%{gpp_name}_%{_pname}=1%;\
		/set pprot_%{gpp_name}_%{_pname}_t=%{_ptime}%;\
	/endif%;\
	/substitute -ag

/def -i gpprots_get_pactive =\
	/set lst_pactive=%;\
	/while ({#})\
		/let _pon=$[prgetval(strcat("pprot_",{1}))]%;\
		/set pprot_%{1}=0%;\
		/if (_pon)\
			/set lst_pactive=%{lst_pactive} %{1}%;\
		/endif%;\
		/shift%;\
	/done

/def -i gpprots_get_effects =\
	/set gpp_member=$[gpp_member + 1]%;\
	/set gpp_name=$(/nth %{gpp_member} %{_zpmembers})%;\
	/if (gpp_name!~"")\
		/test send(strcat("@@show effects ",gpp_name))%;\
	/else \
		/set gpp_eff=0%;\
		/gpprots_get_pactive %{lst_pprots}%;\
		/gpprots_do_print%;\
	/endif

/def -i gpprots_show_effects =\
	/set gpp_eff=1%;\
	/set gpp_member=0%;\
	/gpprots_get_effects


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Output helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gpprot_getrmtime =\
        /if ({1} >= 0)\
                /return gpprot_get_time({1})%;\
        /else \
                /return " X "%;\
        /endif

/def -i gpprot_getstime =\
        /if ({1} >= 0)\
                /return gpprot_get_time(trunc(time() - {1}))%;\
        /else \
                /return " X "%;\
        /endif

/def -i gpprots_print_header =\
	/let _pprot_nam=%;\
	/set _pprot_div=%;\
	/while ({#})\
		/let _pn=$[prgetval(strcat("prot_",{1},"_n"))]%;\
		/let _pprot_nam=%{_pprot_nam}%{_pprot_col_name}$[prsubpad(_pn,5)]%{_pprot_col_n}|%;\
		/set _pprot_div=%{_pprot_div}-----+%;\
		/shift%;\
	/done%;\
	/eval %{_pprot_cmd} .------------+%%{_pprot_div}%;\
	/eval %{_pprot_cmd} |            |%%{_pprot_nam}%;\
	/eval %{_pprot_cmd} +------------+%%{_pprot_div}
	

/def -i gpprots_print_player =\
	/let _pplr=%{1}%;/shift%;\
	/let _pres=|%{_pprot_col_pname}$[pad(_pplr,-12)]%{_pprot_col_n}|%;\
	/while ({#})\
		/let _pm=$[prgetval(strcat("pprot_",_pplr,"_",{1}))]%;\
		/let _pt=$[prgetval(strcat("pprot_",_pplr,"_",{1},"_t"))]%;\
		/if (_pm)\
			/if (opt_effects=~"on")\
				/let _pr=$[gpprot_getrmtime(_pt)]%;\
			/else \
				/let _pr=$[gpprot_getstime(_pt)]%;\
			/endif%;\
		/else \
			/let _pr=%;\
		/endif%;\
		/let _pres=%{_pres}$[pad(_pr,5)]|%;\
		/shift%;\
	/done%;\
	/eval %{_pprot_cmd} %%{_pres}


/def -i gpprots_print_members =\
	/while ({#})\
		/gpprots_print_player %{1} %{lst_pactive}%;\
		/shift%;\
		/if ({#})\
			/gpprots_print_player %{1} %{lst_pactive}%;\
			/shift%;\
			/if ({#})\
				/gpprots_print_player %{1} %{lst_pactive}%;\
				/shift%;\
				/eval %{_pprot_cmd} +------------+%%{_pprot_div}%;\
			/endif%;\
		/endif%;\
	/done


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Show prots
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;@command /pprots [command]
;@desc Shows currently tracked prots in the party. Optional macro or MUD
;@desc command argument can be given, to feed the output through it.
;@desc For example "/pprots emote" would use BatMUD emote to show the data
;@desc people present in the same room.

/def -i gpprots_do_print =\
	/if (gparty_members=~"" | lst_pactive=~"")\
		/eval %{_pprot_cmd} %{_pprot_col_name}No party prots tracked%{_pprot_col_n}.%;\
	/else \
		/gpprots_print_header %{lst_pactive}%;\
		/gpprots_print_members %{_zpmembers}%;\
		/eval %{_pprot_cmd} `------------+%{_pprot_div}%;\
	/endif

/def -i pprots =\
	/if ({#} > 0)\
		/set _pprot_cmd=%{*}%;\
		/set _pprot_col_n=%;\
		/set _pprot_col_name=%;\
		/set _pprot_col_pname=%;\
	/else \
		/set _pprot_cmd=/echo -p%;\
		/set _pprot_col_n=@{n}%;\
		/set _pprot_col_name=@{BCwhite}%;\
		/set _pprot_col_pname=@{Cgreen}%;\
	/endif%;\
	/if (gpprots_members!~"")\
		/if (gpprots_members!~gparty_members)\
			/msq Party formation not same as saved prot formation. Use /protform if update is needed.%;\
		/endif%;\
		/set _zpmembers=%{gpprots_members}%;\
	/else \
		/set _zpmembers=%{gparty_members}%;\
	/endif%;\
	/if (opt_effects=~"on")\
		/gpprots_clear %{_zpmembers}%;\
		/gpprots_show_effects%;\
	/else \
		/gpprots_update_active %{_zpmembers}%;\
		/gpprots_do_print%;\
	/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Saving of prot formation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gpprots_protform =\
	/if (gparty_members!~"")\
		/set gpprots_members=%{gparty_members}%;\
		/msq Prot formation set to: %{gpprots_members}%;\
	/else \
		/msq Party member list empty, possibly not in a party.%;\
	/endif

;@command /protform
;@desc Save current party formation (members and their order) into separate
;@desc prot formation. This is useful, because the current captured party
;@desc formation can become jumbled due to fleeing, deaths etc. and thus
;@desc would change the prot tracker's output making things more confusing.
;@desc NOTICE! This saved setting is completely SEPARATE from saved form
;@desc of the party placer module.
/def -i protform =\
	/set gparty_grab=1%;\
	/set event_pss_once=gpprots_protform%;\
	@@party status short


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define prots and patterns
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Misc
/prdefpartyprot -i"unstun"	-A"Unstun|uns"
/prdefpartyprot -i"hw"		-A"heavy *weight|hw"
/prdefpartyprot -i"unpain"	-A"Unpain|unp" 			-m900
/prdefpartyprot -i"pfg"		-A"protection from good|pfg"	-m1200
/prdefpartyprot -i"flexsh"	-A"flex shield|flex"
/prdefpartyprot -i"vmant"	-A"vine mantle|vmantle"
/prdefpartyprot -i"eskin"	-A"earth skin|eskin"
/prdefpartyprot -i"eblood"	-A"earth blood|eblood"
/prdefpartyprot -i"supprm"	-A"suppress magic|magic suppression|suppress"
/prdefpartyprot -i"ebeacon"	-A"beacon of enlightenment"

;; Folklorist
/prdefpartyprot -i"minprot"	-A"minor protection"
/prdefpartyprot -i"raciprot"	-A"racial protection"

;; Psionicist
/prdefpartyprot -i"forcesh"	-A"Force Shield|fsh|fshield"	-m1800

;; Bard
/prdefpartyprot -i"warez"	-A"War Ens[ae]mble|warez|war"	-m1000
/prdefpartyprot -i"emelody"	-A"Embracing melody|melodical embracement|melody"

;; Conjurer
/prdefpartyprot -i"m_phys"	-A"Armour of Aether|AoA|aether armour|Armor of Aether|GPhys"
/prdefpartyprot -i"m_acid"	-A"Acid Shield|GAcid"		-m1000
/prdefpartyprot -i"m_poison"	-A"Shield of detoxification|poison prot|detox|GPoison"		-m1000
/prdefpartyprot -i"m_elec"	-A"Lighti?ning Shield|GElec"	-m1000
/prdefpartyprot -i"m_asphyx"	-A"Aura of Wind|GAsph"		-m1000
/prdefpartyprot -i"m_fire"	-A"Flame Shield|GFire"		-m1000
/prdefpartyprot -i"m_magic"	-A"Repulsor Aura|GMana"		-m1000
/prdefpartyprot -i"m_psi"	-A"Psionic Phalanx"		-m1000
/prdefpartyprot -i"m_cold"	-A"Frost Shield|GCold"		-m1000

/prdefpartyprot -i"c_phys"	-A"Force Absorption|fabs|force absorbsion" -m1000
/prdefpartyprot -i"sop"		-A"Shield of protection|sop"	-m450
/prdefpartyprot -i"rdisp"	-A"Resist Dispel"		-m200

/prdefpartyprot -i"iwill"	-A"iron will|iw"		-m1000

;; Evil priest
/prdefpartyprot -i"aoh"		-A"aura of hate|aoh"

;; Templar
/prdefpartyprot -i"sof"		-A"shield of faith|sof"

;; Nun
/prdefpartyprot -i"soulsh"	-A"soul shield|soul_shield|soulshield" -m900
/prdefpartyprot -i"pfe"		-A"protection from evil|pfe"	-m1200
/prdefpartyprot -i"hprot"	-A"heavenly protection|hprot"	-m900
/prdefpartyprot -i"manash"	-A"mana shield"	-m1000
