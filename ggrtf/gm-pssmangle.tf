;;
;; GgrTF::PSSMangle - 'pss' output parser/mangler
;; (C) Copyright 2005-2015 Matti H‰m‰l‰inen (Ggr) & Jarkko V‰‰r‰niemi (Jeskko)
;;
;; This file (triggerset) is Free Software distributed under
;; GNU General Public License version 2.
;;
;; NOTICE! This file requires GgrTF (version 0.6.15 or later) to be loaded.
;;
/loaded GgrTF::PSSMangle
/test prdefmodule("PSSMangle")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdeftoggle -n"fullparty"	-d"Always show full party formation"
/prdeftoggle -n"prettypss"	-d"Make output of /pss and autopss pretty"
/prdeftoggle -n"diffpss"	-d"Show diff values in prettypss output"
/set opt_prettypss=on


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Output and prettyprinting macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gparty_val =\
	/if (!{1})\
		/let _qtmp=-%;\
	/else \
		/let _qtmp=%{1}%;\
	/endif%;\
	/return "@{$[prgetnlite({1},{2})]}$[pad(_qtmp,4)]@{n}"

/def -i gparty_dval =\
	/let _qtmp=$[{1}-{2}]%;\
	/if (_qtmp < 0)\
		/let _qcol=@{Cred}%;\
	/else \
		/let _qcol=@{Cgreen}%;\
	/endif%;\
	/return "%{_qcol}$[pad(_qtmp,4)]@{n}"

/def -i gparty_get_color =\
	/if ({1}=~"unc")\
		/let _tmpc=BCwhite,BCbgred%;\
	/elseif ({1}=~"stun"|{1}=~"stu")\
		/let _tmpc=BCred%;\
	/elseif ({1}=~"amb")\
		/let _tmpc=BCred%;\
	/elseif ({1}=~"Glaced")\
		/let _tmpc=BCwhite,Cbgblue%;\
	/elseif ({1}=~"form"|{1}=~"mbr")\
		/let _tmpc=Cmagenta%;\
	/elseif ({1}=~"rest")\
		/let _tmpc=Ccyan%;\
	/elseif (_gp_i=~"*")\
		/let _tmpc=BCblack%;\
	/else /let _tmpc=BCwhite%;\
	/endif%;\
	/if ({2})\
		/return _tmpc%;\
	/else \
		/return "@{%{_tmpc}}"%;\
	/endif
	

/def -i gparty_sc =\
	/eval /set _gp_i=$$[gparty_%{1}_%{2}_i]%;\
	/eval /set _gp_s=$$[gparty_%{1}_%{2}_s]%;\
	/eval /set _gp_pl=$$[gparty_%{1}_%{2}_pl]%;\
	/eval /set _gp_pr=$$[gparty_%{1}_%{2}_pr]%;\
	/eval /set _gp_hp=$$[gparty_%{1}_%{2}_hp]%;\
	/eval /set _gp_hpm=$$[gparty_%{1}_%{2}_hpm]%;\
	/eval /set _gp_sp=$$[gparty_%{1}_%{2}_sp]%;\
	/eval /set _gp_spm=$$[gparty_%{1}_%{2}_spm]%;\
	/eval /set _gp_ep=$$[gparty_%{1}_%{2}_ep]%;\
	/eval /set _gp_epm=$$[gparty_%{1}_%{2}_epm]%;\
	/let _tmpc=$[gparty_get_color(_gp_pl)]%;\
	/return "@{BCcyan}$[prsubpad(_gp_pr,1)]@{n}%{_tmpc}$[prsubpad(_gp_s,9)]@{n}@{Cblue}:@{n}$[gparty_val(_gp_hp,_gp_hpm)]@{Cblue}:@{n}$[gparty_val(_gp_sp,_gp_spm)]@{Cblue}:@{n}$[gparty_val(_gp_ep,_gp_epm)]"

/def -i gparty_scd =\
	/eval /set _gp_hp=$$[gparty_%{1}_%{2}_hp]%;\
	/eval /set _gp_ohp=$$[gparty_%{1}_%{2}_ohp]%;\
	/eval /set _gp_sp=$$[gparty_%{1}_%{2}_sp]%;\
	/eval /set _gp_osp=$$[gparty_%{1}_%{2}_osp]%;\
	/eval /set _gp_ep=$$[gparty_%{1}_%{2}_ep]%;\
	/eval /set _gp_oep=$$[gparty_%{1}_%{2}_oep]%;\
	/return " @{BCblack}-------@{n} @{Cblue}:@{n}$[gparty_dval(_gp_hp,_gp_ohp)]@{BCblue}:@{n}$[gparty_dval(_gp_sp,_gp_osp)]@{Cblue}:@{n}$[gparty_dval(_gp_ep,_gp_oep)]"

/def -i gparty_show_souls =\
	/if ({#} <= 0) /return%;/endif%;\
	/let _tmps=%;\
	/let _souls=0%;\
	/while ({#})\
		/eval /set _gp_pl=$$[gparty_%{1}_sl_pl]%;\
		/eval /set _gp_hp=$$[gparty_%{1}_sl_hp]%;\
		/if (_gp_pl=~"") /set _gp_pl=@{BCblue}   ?@{n}%;/endif%;\
		/let _tmpc=$[gparty_get_color(_gp_pl)]%;\
		/let _tmps=%{_tmps}$[prsubpad({1},10)]@{Cblue}:@{n}%{_tmpc}%{_gp_pl}@{n}@{Cblue}:@{n}$[gparty_val(_gp_hp,100)]@{Cblue}:@{n}    |%;\
		/shift%;\
		/if (mod(++_souls,3) == 0)\
			/msw |%{_tmps}%;\
			/let _tmps=%;\
		/endif%;\
	/done%;\
	/while (mod(_souls,3) != 0)\
		/let _tmps=%{_tmps}                         |%;\
		/let _souls=$[_souls+1]%;\
	/done%;\
	/if (_tmps!~"")\
		/msw |%{_tmps}%;\
	/endif%;\
	/echo `-------------------------+-------------------------+-------------------------'
	
/def -i gparty_show =\
	/echo ,-----------------------------------------------------------------------------.%;\
	/msw |$[gparty_sc(1,1)]|$[gparty_sc(1,2)]|$[gparty_sc(1,3)]|%;\
	/if (opt_diffpss=~"on")	/msw |$[gparty_scd(1,1)]|$[gparty_scd(1,2)]|$[gparty_scd(1,3)]|%;/endif%;\
	/if (gparty_row2 | gparty_row3 | opt_fullparty=~"on")\
	/msw |$[gparty_sc(2,1)]|$[gparty_sc(2,2)]|$[gparty_sc(2,3)]|%;\
	/if (opt_diffpss=~"on")	/msw |$[gparty_scd(2,1)]|$[gparty_scd(2,2)]|$[gparty_scd(2,3)]|%;/endif%;\
	/if (gparty_row3 | opt_fullparty=~"on")\
	/msw |$[gparty_sc(3,1)]|$[gparty_sc(3,2)]|$[gparty_sc(3,3)]|%;\
	/if (opt_diffpss=~"on")	/msw |$[gparty_scd(3,1)]|$[gparty_scd(3,2)]|$[gparty_scd(3,3)]|%;/endif%;\
	/endif%;\
	/endif%;\
	/echo `-----------------------------------------------------------------------------'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TF5 status line PSS
;; NOTE: This is not finished and probably does not work.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gparty_pc =\
	/eval /set _gp_i=$$[gparty_%{1}_%{2}_i]%;\
	/eval /set _gp_s=$$[gparty_%{1}_%{2}_s]%;\
	/eval /set _gp_pl=$$[gparty_%{1}_%{2}_pl]%;\
	/eval /set _gp_hp=$$[gparty_%{1}_%{2}_hp]%;\
	/eval /set _gp_hpm=$$[gparty_%{1}_%{2}_hpm]%;\
	/eval /set _gp_sp=$$[gparty_%{1}_%{2}_sp]%;\
	/eval /set _gp_spm=$$[gparty_%{1}_%{2}_spm]%;\
	/eval /set _gp_ep=$$[gparty_%{1}_%{2}_ep]%;\
	/eval /set _gp_epm=$$[gparty_%{1}_%{2}_epm]%;\
	/let _tmpc=$[gparty_get_color(_gp_pl,1)]%;\
	/let _tmps="$[prsubpad(_gp_s,9)]"::%{_tmpc} ":"::Cblue "%{_gp_hp}":4:$[prgetnlite(_gp_hp,_gp_hpm)] ":"::Cblue "%{_gp_sp}":4:$[prgetnlite(_gp_sp,_gp_spm)] ":"::Cblue "%{_gp_ep}":4:$[prgetnlite(_gp_ep,_gp_epm)]%;\
	/return _tmps

/def -i gparty_status =\
	/eval /status_add -c -s1 -r2 "[" $[gparty_pc(1,1)] "|" $[gparty_pc(1,2)] "|" $[gparty_pc(1,3)] "]"%;\
	/eval /status_add -c -s1 -r3 "[" $[gparty_pc(2,1)] "|" $[gparty_pc(2,2)] "|" $[gparty_pc(2,3)] "]"%;\
	/eval /status_add -c -s1 -r4 "[" $[gparty_pc(3,1)] "|" $[gparty_pc(3,2)] "|" $[gparty_pc(3,3)] "]"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utility and grabbing triggers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set gparty_grab=0
/undef pss
/def -i pss = /set gparty_grab=1%;@@party status short

/def -i gparty_set =\
	/if (regmatch("^(Glaced) ([A-Z][a-z]+)",{2}))\
		/let _gpn=%{P2}%;\
		/let _gpl=%{P1}%;\
	/elseif (regmatch("^([A-Z][a-z]+)",{2}))\
		/let _gpn=%{P1}%;\
		/let _gpl=%{3}%;\
	/else \
		/let _gpn=%{2}%;\
		/let _gpl=%{3}%;\
	/endif%;\
	/if (regmatch("^([a-z]+)\|([0-9]+)$",{3}))\
		/let _gpl=%{P1}%;\
		/let _gpr=%{P2}%;\
	/else \
		/let _gpr=%;\
	/endif%;\
	/set gparty_mtmp=%{gparty_mtmp} %{_gpn}%;\
	/if (!regmatch("^([1-3])\.([1-3])$",{1})) /break%;/endif%;\
	/if ({2}!~"") /set gparty_row%{P1}=1%;/endif%;\
	/let _gps=$[replace(".","_",{1})]%;\
	/set gparty_%{_gps}_i=%{10}%;\
	/set gparty_%{_gps}_s=%{_gpn}%;\
	/set gparty_%{_gps}_pl=%{_gpl}%;\
	/set gparty_%{_gps}_pr=%{_gpr}%;\
	/set gparty_%{_gps}_hp=%{4}%;\
	/set gparty_%{_gps}_hpm=%{5}%;\
	/set gparty_%{_gps}_sp=%{6}%;\
	/set gparty_%{_gps}_spm=%{7}%;\
	/set gparty_%{_gps}_ep=%{8}%;\
	/set gparty_%{_gps}_epm=%{9}

/def -i gparty_set_familiar =\
	/if (regmatch("^ *([A-Za-z][A-Za-z ]+[A-Za-z]) *$",{3}))\
		/let _tmps=%{P1}%;\
	/else \
		/let _tmps=%{3}%;\
	/endif%;\
	/if     (_tmps=~"VERY low")   /let _ghp=15%;\
	/elseif (_tmps=~"very low")   /let _ghp=30%;\
	/elseif (_tmps=~"low")        /let _ghp=45%;\
	/elseif (_tmps=~"medium")     /let _ghp=60%;\
	/elseif (_tmps=~"high")       /let _ghp=75%;\
	/elseif (_tmps=~"VERY high"|_tmps=~"V. high")  /let _ghp=90%;\
	/elseif (_tmps=~"full")       /let _ghp=100%;\
	/elseif (_tmps=~"superb")     /let _ghp=100+%;\
	/elseif (_tmps=~"negative")   /let _ghp=neg%;\
	/elseif (_tmps=~"none")       /let _ghp=0!%;\
	/else /let _ghp=??%;/endif%;\
	/set gparty_grab=-2%;\
	/set gparty_souls=%{gparty_souls} %{1}%;\
	/set gparty_%{1}_sl_pl=%{2}%;\
	/set gparty_%{1}_sl_hp=%{_ghp}%;\

/def -i gparty_cset =\
	/eval /set gparty_%{1}_is=$$[gparty_%{1}_i]%;\
	/eval /set gparty_%{1}_os=$$[gparty_%{1}_s]%;\
	/eval /set gparty_%{1}_opl=$$[gparty_%{1}_pl]%;\
	/eval /set gparty_%{1}_ohp=$$[gparty_%{1}_hp]%;\
	/eval /set gparty_%{1}_ohpm=$$[gparty_%{1}_hpm]%;\
	/eval /set gparty_%{1}_osp=$$[gparty_%{1}_sp]%;\
	/eval /set gparty_%{1}_ospm=$$[gparty_%{1}_spm]%;\
	/eval /set gparty_%{1}_oep=$$[gparty_%{1}_ep]%;\
	/eval /set gparty_%{1}_oepm=$$[gparty_%{1}_epm]%;\
	/set gparty_%{1}_i=%;\
	/set gparty_%{1}_s=%;\
	/set gparty_%{1}_pl=%;\
	/set gparty_%{1}_pr=%;\
	/set gparty_%{1}_hp=%;\
	/set gparty_%{1}_hpm=%;\
	/set gparty_%{1}_sp=%;\
	/set gparty_%{1}_spm=%;\
	/set gparty_%{1}_ep=%;\
	/set gparty_%{1}_epm=


/def -i gparty_clear =\
	/set gparty_mtmp=%;\
	/set gparty_souls=%;\
	/for _crow 1 3  /set gparty_row%%{_crow}=0%;\
	/for _ccol 1 3 \
	/for _crow 1 3 \
		/gparty_cset %%%{_crow}_%%%{_ccol}


/def -i -F -Egparty_grab>0 -p9999 -msimple -t',-----------------------------------------------------------------------------.' gpss_getbegin =\
	/if (opt_prettypss=~"on") /substitute -ag%;/endif%;\
	/gparty_clear


/def -i -F -Egparty_grab>0 -p999 -mregexp -t"^\|(.)([1-3?]\.[1-3?]) +([A-Z][A-Za-z ][A-Za-z ]?[A-Za-z ]?[A-Za-z ]?[A-Za-z ]?[A-Za-z ]?[A-Za-z ]?[A-Za-z ]?[A-Za-z ]?[A-Za-z ]?[A-Za-z]?) +(ld|ldr|fol|mbr|form|unc|amb|dead|rest|stun|unc\|[0-9]+|stu\|[0-9]+) +([0-9-]+)\( *([0-9-]+)\) +([0-9-]+)\( *([0-9-]+)\) +([0-9-]+)\( *([0-9-]+)\)" gpss_getps =\
	/if (opt_prettypss=~"on") /substitute -ag%;/endif%;\
	/test gparty_set({P2},{P3},{P4},{P5},{P6},{P7},{P8},{P9},{P10},{P1})

/def -i -F -Egparty_grab<0 -p999 -mregexp -t"^\| ([A-Z][a-z]+)'s? soul\ {1,8}( fol|form|    |stun) (.........)" gpss_getps2 =\
	/if (opt_prettypss=~"on") /substitute -ag%;/endif%;\
	/test gparty_set_familiar({P1},{P2},{P3})

/def -i -F -Egparty_grab>0 -p999 -mregexp -t"^\|(.)([1-3?]\.[1-3?]) +\+([A-Z][A-Za-z ][A-Za-z ]?[A-Za-z ]?[A-Za-z ]?[A-Za-z ]?[A-Za-z ]?[A-Za-z ]?[A-Za-z ]?[A-Za-z ]?[A-Za-z ]?[A-Za-z]?) +(ld|ldr|fol|mbr|form|unc|amb|dead|rest|stun|unc\|[0-9]+|stu\|[0-9]+) +([0-9-]+)\( *([0-9-]+)\) " gpss_getps3 =\
	/if (opt_prettypss=~"on") /substitute -ag%;/endif%;\
	/test gparty_set({P2},{P3},{P4},{P5})



/def -i -F -Egparty_grab -p99 -msimple -t'`-----------------------------------------------------------------------------\'' gpss_getend =\
	/if (gparty_grab > 0)\
		/set gparty_grab=-1%;\
		/set gparty_members=%{gparty_mtmp}%;\
		/if (opt_statuspss=~"on") /gparty_status%;/endif%;\
		/if (opt_prettypss=~"on") /substitute -ag%;/gparty_show%;/endif%;\
		/prexecfuncs %{event_pss_once}%;\
		/set event_pss_once=%;\
	/elseif (gparty_grab < -1)\
		/set gparty_grab=0%;\
		/if (opt_prettypss=~"on") /substitute -ag%;/gparty_show_souls %{gparty_souls}%;/endif%;\
	/endif

/def -i -F -p9999 -msimple -t"You are not in a party." gpss_noparty =\
	/set gparty_grab=0%;\
	/set event_pss_once=

