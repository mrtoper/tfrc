;;
;; GgrTF - A TinyFugue script for BatMUD
;; (C) Copyright 2004-2016 Matti Hämäläinen (Ggr Pupunen)
;;
/set ggrtf_ver=0.7.4.0
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
;; For installation instructions, and more information,
;; please refer to GgrTF's homepage and user's manual.
;;
;; http://tnsp.org/~ccr/ggrtf/
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The actual scriptcode starts here: initialize, load prereqs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set warn_curly_re=off
/set warn_status=off
/set status_pad=_
/require map.tf


;; Reset GgrTF internals
;@command /greset
;@desc Reset all skill/spell counters and statistics. Notice that issuing
;@desc this command also requires executing of "/gsave" if you want to save
;@desc the zeroed statistics, otherwise the old saved statistics will be
;@desc loaded on next /gload.
/def -i greset =\
	/prdefivar cnt_date $[time()]%;\
	/prdefivar cnt_casts 0%;\
	/prdefivar cnt_scasts 0%;\
	/prdefivar cnt_icasts 0%;\
	/prdefivar cnt_fcasts 0%;\
	/prdefivar cnt_fucasts 0%;\
	/prdefivar cnt_hastes 0%;\
	/prdefivar cnt_ghastes 0%;\
	/prdefivar cnt_qlips1 0%;\
	/prdefivar cnt_qlips2 0%;\
	/prdefivar cnt_qlips3 0%;\
	/prdefivar cnt_trounds 0%;\
	/prdefivar cnt_damcrits 0%;\
	/prdefivar cnt_dcrit1 0%;\
	/prdefivar cnt_dcrit2 0%;\
	/prdefivar cnt_dcrit3 0%;\
	/prdefivar cnt_dcrit4 0%;\
	/prdefivar cnt_skills 0%;\
	/prdefivar cnt_sskills 0%;\
	/prdefivar cnt_iskills 0%;\
	/prdefivar cnt_fskills 0%;\
	/prdefivar cnt_fuskills 0%;\
	/prdefivar cnt_ctime 0%;\
	/prdefivar cnt_sktime 0%;\
	/prexecfuncs %{lst_resetfuncs}%;\
	/set set_cntinit=1%;\
	/msq Global counters reset.


/def -i ginitialize =\
	/prdefvar -n"status_pad" -v"_" -c"The padding character used in displaying the status area in TF visual mode"%;\
	/prdefvar -n"status_attr" -v"" -c"The attributes used to display the status area in TF visual mode" %;\
	/prdefvar -n"fmt_date" -v"%%%c" -c"ftime() formatting string used for dates"%;\
	/prdefvar -n"opt_lites" -v"on" -c"Enable default lites for various things (cannot be changed during runtime) (on/off)"%;\
	/prdefvar -n"opt_bindings" -v"off" -c"Whether command bindings are loaded/defined in startup (on/off)"%;\
	/prdefvar -n"opt_keybinds" -v"on" -c"If keyboard numpad cast bindings should be used, requires GgrTF::TargettedCast module (on/off)"%;\
	/set battle_target=%;\
	/set battle_st=0%;\
	/set spell_st=off%;\
	/set skill_st=off%;\
	/set stun_st=off%;\
	/set camp_st=1%;\
	/set cast_info=%;\
	/set cast_info_t=%;\
	/set cast_info_n=%;\
	/set opt_verbose=on%;\
	/set set_round=@@scan all%;\
	/set set_ripcommand=@whee%;\
	/set set_peer=embedded%;\
	/set set_gprompt=%%{status_prompt}>%;\
	/set set_roundmin=2%;\
	/set set_sysinit=1%;\
	/msq System variables initialized.


/set cnt_def_fail=0

/set event_battle_rip=ripfunc
/set event_battle_first_round=
/set event_battle_round=
/set event_battle_end=
/set event_sc_printed=
/set event_skill_start=
/set event_skill_done=
/set event_skill_intr=
/set event_skill_stop=
/set event_spell_start=
/set event_spell_done=
/set event_spell_intr=
/set event_spell_stop=
/set event_quit_login=
/set event_login=

/set lst_stats_spell=
/set lst_stats_skill=
/set lst_resetfuncs=

/set lst_modules=
/set gmodule=Main

/set status_hp=
/set status_hpmax=
/set status_sp=
/set status_spmax=
/set status_ep=
/set status_epmax=


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Macros which may be re-defined by user or in other modules
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i msd = /echo -- %*
/def -i msw = /echo -p -- %*
/def -i msq = /echo -p -- @{BCwhite}GgrTF@{n}: %*
/def -i mss = /substitute -p -- %*

/def -i gerror = /set set_errcnt=$[set_errcnt+1]%;/set set_errlast=$[strip_attr({*})]%;/msq @{BCred}ERROR!@{n} %*
/def -i gwarning = /set set_warncnt=$[set_warncnt+1]%;/set set_warnlast=$[strip_attr({*})]%;/msq @{BCred}WARNING!@{n} %*
/def -i gsend = /if (!set_idle) /test send({*})%;/endif

/def -i msk = /if (opt_skspam=~"on") /substitute -p @{BCwhite}GgrTF@{n}: %*%;/endif
/def -i msp = /if (!set_idle & opt_verbose=~"on") /send @@party say %*%;/else /msq %*%;/endif
/def -i mse = /if (!set_idle & opt_verbose=~"on") /send @@party say emote %*%;/else /msq %*%;/endif
/def -i msr_real = /if (!set_idle) /send @@party report %*%;/else /msq %*%;/endif
/def -i msb = /if (set_idle) /msq %*%;/else /send @party report %*%;/endif

/def -i dig_grave = /gsend @@dig grave
/def -i eat_corpse = /gsend @@get corpse%;/gsend @@eat corpse
/def -i get_corpse = /gsend @@get corpse


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Report message queuing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set lst_busy_queue=

/def -i msr =\
	/if (opt_verbose=~"on")\
		/if (camp_st == 2)\
			/gmsg_que %*%;\
		/else \
			/msr_real %*%;\
		/endif%;\
	/else \
		/msq %*%;\
	/endif

/def -i gmsg_que =\
	/set lst_busy_queue=%{lst_busy_queue} $[replace(" ", "§",{*})]

/def -i gmsg_empty_que =\
	/gmsg_empty_do %{lst_busy_queue}%;\
	/unset lst_busy_queue

/def -i gmsg_empty_do =\
	/while ({#})\
		/test msr_real(replace("§"," ",{1}))%;\
		/shift%;\
	/done


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Get and check TinyFugue version
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set gtf_version=0
/set gtf_ver_minor=0
/set gtf_ver_major=0
/set gtf_ver_extra=0

/def -i gcheck_tf_version =\
	/if (regmatch("^([0-9]+)\.([0-9]+)", ver()))\
		/set gtf_ver_major=%{P1}%;\
		/set gtf_ver_minor=%{P2}%;\
		/set gtf_version=$[{P1}*10000 + {P2}*100]%;\
	/endif%;\
	/if (regmatch("^([0-9]+)\.([0-9]+) beta ([0-9]+)", ver()))\
		/set gtf_ver_extra=%{P3}%;\
		/set gtf_version=$[gtf_version + {P3}]%;\
	/endif%;\
	/if (gtf_version < 50007)\
		/gerror @{BCwhite}GgrTF requires TinyFugue version 5.0 beta 7 or later!@{n}%;\
	/endif

/gcheck_tf_version


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Module support
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set lst_modules=Main

/def -i prcheckdeps =\
	/if ({1}=~"") /result ""%;/endif%;\
	/let _missing=%;\
	/while ({#})\
		/if (!regmatch(strcat("(^| )",{1},"( |$)"), lst_modules))\
			/if (_missing!~"")\
				/let _missing=%{_missing}, %{1}%;\
			/else \
				/let _missing=%{1}%;\
			/endif%;\
		/endif%;\
		/shift%;\
	/done%;\
	/result _missing


/def -i prdefmodule =\
	/test prlist_insert("lst_modules", {1})%;\
	/set gmodule=%{1}%;\
	/if ({#} > 1)\
		/let _res=$(/prcheckdeps %{-1})%;\
		/if (_res!~"")\
			/gerror @{BCwhite}Module '%{1}' depends on@{n} @{BCyellow}%{_res}@{n} @{BCwhite}to be loaded before it.@{n}%;\
			/repeat -5 1 /msq There were errors loading modules. Please check the full TF/GgrTF init output. %{set_errlast}%;\
			/exit 10%;\
		/endif%;\
	/endif

/def -i gcheck_keybinds =\
	/let _res=$[prcheckdeps("TargettedCast")]%;\
	/if ((opt_keybinds=~"on" | opt_keybinds=~"") & _res!~"")\
		/gerror Keyboard numpad bindings enabled, but '%{_res}' not loaded before '%{gmodule}'.%;\
		/exit 10%;\
	/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper macros/functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i prconvto = /return tolower(replace(" ","_",{1}))
/def -i prconvfrom = /return replace("_"," ",strcat(toupper(substr({1},0,1)),substr({1},1)))
/def -i prconvpm = /return replace("_"," ",{1})
/def -i prgetval = /return eval("/return %{*}",2)

;; Return a string of given value {2} repeated {1} times.
/def -i prrepval_do =\
	/for _i 1 %{1} /echo %{2}

/def -i prrepval =\
	/return "$(/prrepval_do %{1} %{2})"


;; Return ratio of 2 arguments (avoid divide by zero)
/def -i prdiv = /if ({2} != 0) /return {1}/{2}%;/else /return 0%;/endif

;; Return ratio of 2 arguments rounded to two decimals
/def -i prstdiv = /return prround(prdiv({1},{2}),2)


;; Return a substring of given string with specified maxlen, padded to maxlen
/def -i prsubpad = /return pad(substr({1},0,{2}),{2})

/def -i prsubipad = /return pad(substr({1},0,{2}),-{2})


;; Return a string containing a floating point value,
;; truncated to specified number of decimal digits maximum.
/def -i prround =\
	/let _rval=$[{1}*1.0]%;\
	/let _rpos=$[strchr(_rval,".")]%;\
	/if (_rpos >= 0)\
		/if ({2} > 0)\
			/return strcat(substr(_rval,0,_rpos),substr(_rval,_rpos,{2}+1))%;\
		/else \
			/return substr(_rval,0,_rpos)%;\
		/endif%;\
	/else \
		/return _rval%;\
	/endif


;; Return string describing timestamp in "[[??h]??m]??s" format
/def -i prgettime =\
	/if ({1} > 0)\
		/let _jtime=$[trunc({1})]%;\
		/let _jtimeh=$[_jtime/3600]%;\
		/let _jtimeq=$[mod(_jtime,3600)]%;\
		/if (_jtimeh > 0)\
			/let _jstr=%{_jtimeh}h%;\
		/else \
			/let _jstr=%;\
		/endif%;\
		/let _jstr=%{_jstr}$[_jtimeq/60]m$[mod(_jtimeq,60)]s%;\
		/return _jstr%;\
	/else \
		/return ""%;\
	/endif


;; Return given string post-padded to specified length with specified character
;; prpadwith(string,length,char)
/def -i prpadwith =\
	/return strcat({1}, strrep({3}, {2} - strlen({1})))


;; If string is longer than specified max, cut and pad with ellipsis (...)
/def -i prsubstr =\
	/if (strlen({1})>{2})\
		/return "$[substr({1},0,{2}-3)]..."%;\
	/else \
		/return {1}%;\
	/endif


;; Return string describing time elapsed from given timestamp parameter
/def -i prgetstime =\
	/let _tmps=$[prgettime(time()-{1})]%;\
	/if (_tmps!~"") /return "[%{_tmps}]"%;/else /return ""%;/endif


;; Return a color definition based on [n, nmax] (useful for hp/sp/ep lites)
/def -i prgetnlite =\
	/if ({1} < 0) /return "BCwhite,BCbgred"%;/endif%;\
	/if ({1} < {2}*0.16) /return "BCred"%;/endif%;\
	/if ({1} < {2}*0.33) /return "Cred"%;/endif%;\
	/if ({1} < {2}*0.49) /return "Cyellow"%;/endif%;\
	/if ({1} < {2}*0.66) /return "BCyellow"%;/endif%;\
	/if ({1} < {2}*0.85) /return "Cgreen"%;/endif%;\
	/return "BCgreen"


;; Execute macros given as parameters
/def -i prexecfuncs =\
	/while ({#})\
		/eval /%{1}%;\
		/shift%;\
	/done


;; Create prettyprint version of a numeric value
/def -i prprettyvalstr =\
	/let _jval=$[abs({1})]%;\
	/let _jtmp=$[_jval-trunc(_jval)]%;\
	/if (_jtmp > 0)\
		/let _jstr=$[substr(_jtmp,1,3)]%;\
	/else \
		/let _jstr=%;\
	/endif%;\
	/while (_jval >= 1000)\
		/let _jstr=,$[replace(" ","0",pad(mod(_jval, 1000.0),3))]%{_jstr}%;\
		/let _jval=$[trunc(_jval / 1000)]%;\
	/done%;\
	/let _jstr=%{_jval}%{_jstr}%;\
	/if ({1} < 0) /let _jstr=-%{_jstr}%;/endif%;\
	/return _jstr


;; Insert item into list-string variable if it does not exist
;; The item may NOT contain whitespace! (This is by design)
;; /prlist_insert("list variable name", "item")
/def -i prlist_insert =\
	/let _prmatch=$[escape("()|[]^$",{2})]%;\
	/let _prlist= $[eval("/return %{1}",2)] %;\
	/if (regmatch(strcat("(^",_prmatch,"| ",_prmatch," | ",_prmatch,"$)"),_prlist) <= 0)\
		/eval /set %{1}=%{2} %%{%{1}}%;\
		/return 1%;\
	/else \
		/return 0%;\
	/endif


;; Delete item from list-string variable
;; /prlist_delete("list variable name", "item")
/def -i prlist_delete_do =\
	/let _tdname=%{1}%;/shift%;\
	/let _tditem=%{1}%;/shift%;\
	/let _tdlist=%;\
	/while ({#})\
		/if ({1}!~_tditem)\
			/let _tdlist=%{_tdlist} %{1}%;\
		/endif%;\
		/shift%;\
	/done%;\
	/eval /set %{_tdname}=%{_tdlist}


/def -i prlist_delete =\
	/eval /prlist_delete_do %{1} %{2} $$[%{1}]


;; Define a /repeat, but work around the fact that /repeat does NOT
;; return the process id although TF 5.0 beta documentation says so
/def -i grepeat =\
	/repeat %{*}%;\
	/result "$(/last $(/ps -s -r))"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Option, setting and hook definition macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define an togglable option
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set lst_options=
/def -i prdeftoggle =\
	/if (!getopts("n:d:p", "")) /gerror Invalid toggle creation command!%;/break%;/endif%;\
	/if (opt_n=~""|opt_d=~"") /gerror Required arguments not specified!%;/break%;/endif%;\
	/test prlist_insert("lst_options", opt_n)%;\
	/if (opt_p)\
		/set opt_%{opt_n}_pre=1%;\
	/else \
		/set opt_%{opt_n}_pre=0%;\
	/endif%;\
	/set opt_%{opt_n}_d=%{opt_d}%;\
	/eval /def -i %{opt_n} =\
		/if (opt_%{opt_n}=~"on")\
			/set opt_%{opt_n}=off%%%;\
			/let _qstr=@{Cred}OFF@{n}%%%;\
		/else \
			/set opt_%{opt_n}=on%%%;\
			/let _qstr=@{BCgreen}ON@{n}%%%;\
		/endif%%%;\
		/msq @{Cyellow}%{opt_d}@{n} [%%%{_qstr}]%%%;\
		/if (opt_%{opt_n}_pre==1)\
			/msq @{BCwhite}NOTICE!@{n} Changing this setting requires /gsave and restart to take effect.%%%;\
		/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define a value setting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set lst_values=
/def -i prdefvalue =\
	/if (!getopts("n:d:", "")) /gerror Invalid value setting creation command!%;/break%;/endif%;\
	/if (opt_n=~""|opt_d=~"") /gerror Required arguments not specified!%;/break%;/endif%;\
	/test prlist_insert("lst_values", opt_n)%;\
	/set set_%{opt_n}_d=%{opt_d}%;\
	/eval /def -i %{opt_n} =\
		/if ({#}) \
			/if ({1}=~"*") \
				/set set_%{opt_n}=%%%;\
				/msq @{Cyellow}%{opt_d}@{n} : @{BCgreen}Cleared@{n}%%%;\
			/else \
				/set set_%{opt_n}=%%%{*}%%%;\
				/msq @{Cyellow}%{opt_d}@{n} [@{Cgreen}$$$[replace("@","@@",{*})]@{n}]%%%;\
			/endif%%%;\
		/else \
			/msq @{Cyellow}%{opt_d}@{n}: [@{Cgreen}$$$[replace("@","@@",set_%{opt_n})]@{n}]%%%;\
			/msq Use "@{BCyellow}/%{opt_n} *@{n}" to clear.%%%;\
		/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define a setting with legal values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set lst_settings=
/def -i prchksetting =\
	/set _prdeftmp=0%;\
	/let _qvs=%{1}%;\
	/shift%;\
	/while ({#})\
		/if ({1}=~_qvs) /set _prdeftmp=1%;/break%;/endif%;\
		/shift%;\
	/done


/def -i prdefsetting =\
	/if (!getopts("n:d:s:", "")) /gerror Invalid setting creation command!%;/break%;/endif%;\
	/if (opt_n=~""|opt_d=~""|opt_s=~"") /gerror Required arguments not specified!%;/break%;/endif%;\
	/test prlist_insert("lst_settings", opt_n)%;\
	/set set_%{opt_n}_d=%{opt_d}%;\
	/set set_%{opt_n}_s=%{opt_s}%;\
	/eval /def -i %{opt_n} =\
		/if ({#})\
			/prchksetting %%%{1} %%%{set_%{opt_n}_s}%%%;\
			/if (_prdeftmp > 0)\
				/set set_%{opt_n}=%%%{1}%%%;\
				/msq @{Cyellow}%{opt_n}@{n} : Set to [@{BCgreen}%%%{set_%{opt_n}}@{n}]%%%;\
			/else \
				/msq @{Cyellow}%{opt_n}@{n} : @{BCred}Invalid setting@{n} [@{BCgreen}%%%{1}@{n}]!%%%;\
			/endif%%%;\
		/else \
			/msq @{BCred}/%{opt_n}@{n} - @{Cyellow}%{opt_d}@{n} [@{BCgreen}%%%{set_%{opt_n}_s}@{n}]%%%;\
		/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define a function hook setting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set lst_hooks=
/def -i prdefhook =\
	/if (!getopts("n:d:s:h:", "")) /gerror Invalid function hook setting creation command!%;/break%;/endif%;\
	/if (opt_n=~""|opt_d=~""|opt_s=~""|opt_h=~"") /gerror Required arguments not specified!%;/break%;/endif%;\
	/test prlist_insert("lst_hooks", opt_n)%;\
	/set set_%{opt_n}_d=%{opt_d}%;\
	/set set_%{opt_n}_s=%{opt_s}%;\
	/eval /def -i %{opt_n} =\
		/if ({#})\
			/prchksetting %%%{1} %%%{set_%{opt_n}_s}%%%;\
			/if (_prdeftmp > 0)\
				/set set_%{opt_n}=%%%{1}%%%;\
				/msq @{Cyellow}%{opt_n}@{n} : Set to [@{BCgreen}%%%{set_%{opt_n}}@{n}]%%%;\
				/eval /def -i %{opt_h}=/%{opt_h}_%%%{1} %%%%%*%%%;\
			/else \
				/msq @{Cyellow}%{opt_n}@{n} : @{BCred}Invalid setting@{n} [@{BCgreen}%%%{1}@{n}]!%%%;\
			/endif%%%;\
		/else \
			/msq @{BCred}/%{opt_n}@{n} - @{Cyellow}%{opt_d}@{n} [@{BCgreen}%%%{set_%{opt_n}_s}@{n}]%%%;\
		/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variable saving functionality
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define a global, saveable variable
/set lst_savevars=
/def -i prdefvar =\
	/if (!getopts("n:v:c:", "")) /gerror Invalid save variable definition!%;/break%;/endif%;\
	/if (opt_n=~"") /gerror No variable name option specified.%;/break%;/endif%;\
	/if (opt_c!~"") /set comment_%{opt_n}=%{opt_c}%;/endif%;\
	/test prlist_insert("lst_savevars", opt_n)%;\
	/let _dsv=$[prgetval(opt_n)]%;\
	/if (opt_v!~"" & _dsv=~"")\
		/eval /set %{opt_n}=%{opt_v}%;\
	/endif

/set lst_saveivars=
/def -i prdefivar =\
	/if ({#} < 1) /gerror No arguments specified, at least variable name is required!%;/break%;/endif%;\
	/test prlist_insert("lst_saveivars", {1})%;\
	/eval /set %{1}=%{-1}

;; Error reporting
/def -i gsave_fwrite =\
	/let _fresult=$[tfwrite(gsave_file, {1})]%;\
	/if (_fresult < 0)\
		/gerror Error #%{_fresult} writing to file '@{Cyellow}%{gsave_filename}@{n}'!%;\
		/return _fresult%;\
	/else \
		/return 0%;\
	/endif

;; Save given list of variables (set 'gsave_varpref' to prefix)
/def -i gsave_vars =\
	/while ({#})\
		/let _ispre=$[prgetval(strcat(gsave_varpref,{1},"_pre"))]%;\
		/if ((!gsave_onlypre & !_ispre) | (gsave_onlypre & _ispre))\
			/let _gsa=$[prgetval(strcat("comment_", gsave_varpref, {1}))]%;\
			/if (_gsa!~"")\
				/let _gsa=; %{_gsa}%;\
				/if (gsave_fwrite(_gsa) < 0) /return%;/endif%;\
			/endif%;\
			/let _gva=%{gsave_varpref}%{1}%;\
			/let _gsa=/set %{_gva}=$[prgetval(_gva)]%;\
			/if (gsave_fwrite(_gsa) < 0) /return%;/endif%;\
			/if (gsave_fwrite("") < 0) /return%;/endif%;\
		/endif%;\
		/shift%;\
	/done

;; Save given list of hooks
/def -i gsave_hooks =\
	/while ({#})\
		/let _gsa=/%{1} $[prgetval(strcat("set_", {1}))]%;\
		/if (gsave_fwrite(_gsa) < 0) /return%;/endif%;\
		/shift%;\
	/done

;; Save a separator
/def -i gsave_separator =\
	/let _ss=;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;%;\
	/if (gsave_fwrite(_ss) < 0) /return%;/endif

;; Save a header string
/def -i gsave_header =\
	/gsave_separator%;\
	/let _ss=;; GgrTF v%{ggrtf_ver} %{1}-INIT savefile ($[ftime(fmt_date,time())])%;\
	/if (gsave_fwrite(_ss) < 0) /return%;/endif%;\
	/gsave_separator


;; Save status
/def -i gsave_fileopen=\
	/set gsave_filename=$[strcat(set_datapath,set_saveprefix,{2})]%;\
	/set gsave_file=$[tfopen(gsave_filename, "w")]%;\
	/if (gsave_file < 0)\
		/gerror Could not create/open savefile '@{Cyellow}%{gsave_filename}@{n}', err=%{gsave_file}!%;\
	/else \
		/msq @{BCgreen}Saving %{1} settings to@{n} '@{Cyellow}%{gsave_filename}@{n}'%;\
	/endif%;\
	/return gsave_file


;@command /gsave
;@desc Save all GgrTF settings. Refer to <link linkend="usage-general-saves">state saving</link> section for more information.
/def -i gsave =\
	/let _testfile=$[tfopen(strcat(set_datapath, "dirtest"), "w")]%;\
	/if (_testfile < 0)\
		/msq @{Cred}Datapath@{n} '@{Cyellow}%{set_datapath}@{n}' @{Cred}might not exist, trying to create directory.@{n}%;\
		/sys mkdir %{set_datapath}%;\
	/else \
		/test tfclose(_testfile)%;\
	/endif%;\
	/if (gsave_fileopen("pre-init", "pre.tf") < 0)\
		/break%;\
	/else \
		/gsave_header PRE%;\
		/set gsave_onlypre=0%;\
		/set gsave_varpref=%;/gsave_vars %{lst_savevars}%;\
		/gsave_separator%;\
		/set gsave_onlypre=1%;\
		/set gsave_varpref=opt_%;/gsave_vars %{lst_options}%;\
		/test tfclose(gsave_file)%;\
	/endif%;\
	/if (gsave_fileopen("post-init", "post.tf") < 0)\
		/break%;\
	/else \
		/gsave_header POST%;\
		/set gsave_onlypre=0%;\
		/set gsave_varpref=%;/gsave_vars %{lst_saveivars}%;\
		/gsave_separator%;\
		/gsave_hooks %{lst_hooks}%;\
		/gsave_separator%;\
		/set gsave_varpref=set_%;/gsave_vars %{lst_settings}%;\
		/gsave_separator%;\
		/set gsave_varpref=set_%;/gsave_vars %{lst_values}%;\
		/gsave_separator%;\
		/set gsave_varpref=opt_%;/gsave_vars %{lst_options}%;\
		/test tfclose(gsave_file)%;\
	/endif%;\
	/msq @{BCgreen}Done.@{n}%;\


;; Load status
;@command /gload
;@desc Load GgrTF settings. Refer to <link linkend="usage-general-saves">state saving</link> section for more information.
/def -i gload =\
	/let _spostinit=%{set_datapath}%{set_saveprefix}post.tf%;\
	/msq @{BCgreen}Loading post-init settings from@{n} '@{Cyellow}%{_spostinit}@{n}'%;\
	/load -q %{_spostinit}%;\
	/msq @{BCgreen}Done.@{n}%;\


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hooks and bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set lst_bindings=

;; Define a generic command/macro bind
; -s"<name>"	String to bind
; -c"<command>"	Command/macro to be executed
; -n		Does not need/accept arguments
/def -i prdefgbind =\
	/if (opt_bindings!~"on") /break%;/endif%;\
	/if (!getopts("s:c:n", "")) /gerror Invalid bind creation command!%;/break%;/endif%;\
	/if (!prlist_insert("lst_bindings", opt_s)) /gwarning Binding for '%{opt_s}' already defined!%;/endif%;\
	/set bind_%{opt_s}_n=2%;\
	/set bind_%{opt_s}_t=G%;\
	/set bind_%{opt_s}_c=%{opt_c}%;\
	/if (opt_n)\
		/let _qs=%;\
	/else \
		/let _qs= %%%{-1}%;\
	/endif%;\
	/eval /def -i -h"SEND {%{bind_prefix}%{opt_s}}*" bind_%{opt_s} = %{opt_c}%{_qs}


;; Define a skill bind with optional party reporting
; -s"<name>"		String to bind
; -c"<skill name>"	Name of the skill to be executed
; -n			Skill does not use a target
; -d"<message>"		Use non-default message for reporting
; -q			Quiet (no reporting)
/def -i prdefsbind =\
	/if (opt_bindings!~"on") /break%;/endif%;\
	/if (!getopts("s:c:m:d:nq", "")) /gerror Invalid bind creation command!%;/break%;/endif%;\
	/if (!prlist_insert("lst_bindings", opt_s)) /gwarning Binding for '%{opt_s}' already defined!%;/endif%;\
	/set bind_%{opt_s}_t=S%;\
	/set bind_%{opt_s}_c=%{opt_c}%;\
	/let _qs=$[tolower(opt_c)]%;\
	/if (opt_d!~"") /let _qm=%{opt_d}%;/else /let _qm=%{opt_c}%;/endif%;\
	/if (opt_n)\
		/set bind_%{opt_s}_n=0%;\
		/let _qw=%{_qm} ...%;\
	/else \
		/set bind_%{opt_s}_n=1%;\
		/let _qw=%{_qm} -> %%%{-1}%;\
		/let _qs='%{_qs}' %%%{-1}%;\
	/endif%;\
	/if (opt_q)\
		/eval /def -i -h"SEND {%{bind_prefix}%{opt_s}}*" bind_%{opt_s} =\
			@use %{_qs}%;\
	/else \
		/eval /def -i -h"SEND {%{bind_prefix}%{opt_s}}*" bind_%{opt_s} =\
			/msb %{_qw}%%%;@use %{_qs}%;\
	/endif


;; Define a spellcasting (at a target) bind with optional party reporting
; Usage same as with /prdefsbind
/def -i prdefcbind =\
	/if (opt_bindings!~"on") /break%;/endif%;\
	/if (!getopts("s:c:d:nq", "")) /gerror Invalid bind creation command!%;/break%;/endif%;\
	/if (!prlist_insert("lst_bindings", opt_s)) /gwarning Binding for '%{opt_s}' already defined!%;/endif%;\
	/set bind_%{opt_s}_t=C%;\
	/set bind_%{opt_s}_c=%{opt_c}%;\
	/let _qs=$[tolower(opt_c)]%;\
	/if (opt_d!~"") /let _qm=%{opt_d}%;/else /let _qm=%{opt_c}%;/endif%;\
	/if (opt_n)\
		/set bind_%{opt_s}_n=0%;\
		/let _qw=%{_qm} ...%;\
	/else \
		/set bind_%{opt_s}_n=1%;\
		/let _qw=%{_qm} -> %%%{-1}%;\
		/let _qs='%{_qs}' %%%{-1}%;\
	/endif%;\
	/if (opt_q)\
		/eval /def -i -h"SEND {%{bind_prefix}%{opt_s}}*" bind_%{opt_s} =\
			@cast %{_qs}%;\
	/else \
		/eval /def -i -h"SEND {%{bind_prefix}%{opt_s}}*" bind_%{opt_s} =\
			/msb %{_qw}%%%;@cast %{_qs}%;\
	/endif


;; List bindings
/def -i prs = /return {*}

/def -i gbindings_dolist =\
/while ({#})\
	/let _bval_t=$[prgetval(strcat("bind_",{1},"_t"))]%;\
	/let _bval_c=$[prgetval(strcat("bind_",{1},"_c"))]%;\
	/let _bval_n=$[prgetval(strcat("bind_",{1},"_n"))]%;\
	/if (_bval_n==0)        /let _ttc=Cred%;/let _tt=No%;\
	/elseif (_bval_n==1)    /let _ttc=Cgreen%;/let _tt=Yes%;\
	/else                   /let _ttc=Ccyan%;/let _tt=?%;\
	/endif%;\
	/if (_bval_t=~"G")      /let _tc=BCred%;\
	/elseif (_bval_t=~"S")  /let _tc=BCgreen%;\
	/elseif (_bval_t=~"C")  /let _tc=BCcyan%;\
	/else                   /let _tc=%{BCwhite}%;\
	/endif%;\
	/msw | @{BCyellow}$[prsubipad({1},14)]@{n} | @{%{_tc}}%{_bval_t}@{n} | @{BCmagenta}$[prsubipad(_bval_c,40)]@{n} | @{%{_ttc}}$[pad(_tt,3)]@{n} |%;\
	/shift%;\
/done


;@command /binds
;@desc List all currently defined GgrTF command bindings. Refer to
;@desc <link linkend="usage-general-binds">bindings</link> section for
;@desc more information and example output.

/def -i binds =\
/msw ,----------------.%;\
/msw | @{BCgreen}GgrTF@{n} @{Cyellow}Bindings@{n} |%;\
/msw +----------------+----------------------------------------------------.%;\
/gbindings_dolist %{lst_bindings}%;\
/msw `---------------------------------------------------------------------'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Report current statistics
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gsprints =\
	/if ({1}!~"")\
		/msw | $[prpadwith({1},18,".")]: $[pad({2},-47)] |%;\
	/else \
		/msw | $[pad("",-18)]: $[pad({2},-47)] |%;\
	/endif

/def -i gsprintl =\
	/msw |$[prpadwith("",69,"-")]|


;@command /stats
;@desc Display miscellaneous statistics about skills, spells, etc.
/def -i stats =\
/msw ,------------------.%;\
/msw | @{BCgreen}GgrTF@{n} @{Cyellow}Statistics@{n} |%;\
/msw +------------------+--------------------------------------------------.%;\
/test gsprints("Gathered since", "$[ftime(fmt_date,cnt_date)]")%;\
/gsprintl%;\
/test gsprints("Spells", "%{cnt_casts} casts total, %{cnt_scasts} successful.")%;\
/test gsprints("  uncompleted", "%{cnt_fcasts} failed, %{cnt_icasts} interrupted, %{cnt_fucasts} fumbled.")%;\
/test gsprints("  hastes", "%{cnt_hastes} hastes, %{cnt_ghastes} ghastes, %{cnt_trounds} total rounds.")%;\
/test gsprints("  time spent", "$[prgettime(cnt_ctime)] ($[prround(cnt_ctime,2)]s) total, $[prstdiv(cnt_ctime,cnt_trounds)]s/rnd, $[prstdiv(cnt_ctime,cnt_scasts)]s/cast")%;\
/test gsprints("  crits", "%{cnt_damcrits} total, %{cnt_dcrit1} lvl#1, %{cnt_dcrit2} lvl#2, %{cnt_dcrit3} lvl#3")%;\
/test gsprints("", "%{cnt_dcrit4} mage essence")%;\
/prexecfuncs %{lst_stats_spell}%;\
/gsprintl%;\
/test gsprints("Skills", "%{cnt_skills} skills total, %{cnt_sskills} successful.")%;\
/test gsprints("  uncompleted", "%{cnt_fskills} fail, %{cnt_iskills} intr, %{cnt_fuskills} fumbled.")%;\
/test gsprints("  time spent", "$[prgettime(cnt_sktime)] ($[prround(cnt_sktime,2)]s) total, $[prstdiv(cnt_sktime,cnt_sskills)]s/skill")%;\
/prexecfuncs %{lst_stats_skill}%;\
/msw `---------------------------------------------------------------------'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; List available options / settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gopts_dolist =\
/while ({#})\
	/let _bval=$[prgetval(strcat("opt_",{1}))]%;\
	/let _bval_d=$[prgetval(strcat("opt_",{1},"_d"))]%;\
	/if (_bval=~"on")\
		/let _bval_s=@{BCgreen} ON@{n}%;\
	/else \
		/let _bval_s=@{Cred}OFF@{n}%;\
	/endif%;\
	/msw | /@{BCyellow}$[pad({1},-10)]@{n} : $[prsubipad(_bval_d,45)] - [%{_bval_s}]      |%;\
	/shift%;\
/done

/def -i gsettings_dolist =\
/while ({#})\
	/let _bval=$[prgetval(strcat("set_",{1}))]%;\
	/let _bval_d=$[prgetval(strcat("set_",{1},"_d"))]%;\
	/msw | /@{BCyellow}$[pad({1},-10)]@{n} : $[prsubipad(_bval_d,45)] - [@{Cgreen}$[prsubpad(_bval,8)]@{n}] |%;\
	/shift%;\
/done

/def -i gvalues_dolist =\
/while ({#})\
	/let _bval=$[prgetval(strcat("set_",{1}))]%;\
	/let _bval_d=$[prgetval(strcat("set_",{1},"_d"))]%;\
	/msw |--------------------------------------------------------------------------|%;\
	/msw | /@{BCyellow}$[pad({1},-10)]@{n} : $[pad(_bval_d,-58)] |%;\
	/msd |             [$[prsubipad(_bval,58)]] |%;\
	/shift%;\
/done


;@command /opts
;@desc Lists all the run-time changeable settings of GgrTF, with short descriptions and current values.

/def -i opts =\
/msw ,----------------.%;\
/msw | @{BCgreen}GgrTF@{n} @{Cyellow}Settings@{n} |%;\
/msw +----------------+---------------------------------------------------------.%;\
/gopts_dolist %{lst_options}%;\
/gsettings_dolist %{lst_settings}%;\
/gsettings_dolist %{lst_hooks}%;\
/gvalues_dolist %{lst_values}%;\
/msw `--------------------------------------------------------------------------'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define some generic option toggles and settings
;@command /verbose
;@desc Toggle in-MUD verbosity on and off. Off means that some things are
;@desc echoed to client only, aka you. On means that those things are
;@desc reported on party channel, etc.
/prdeftoggle -n"verbose"	-d"Verbose (off = echo to client only)"

;@command /skspam
;@desc Toggle skill/spell start/end liting spam. If disabled, normal
;@desc BatMUD skill and spell start and finish lines are let through unmangled.
/prdeftoggle -n"skspam"		-d"Skill/Spell start/end 'lite' spam"

;@command /rrounds
;@desc Report spell rounds to 'party report' channel. This functionality has
;@desc some minor "intelligence" to report only relevant information, but
;@desc it may be considered spammy and annoying by many people.
/prdeftoggle -n"rrounds"	-d"Report spell/skill rounds"

;@command /roundmin <value>
;@desc Maximum amount of spell rounds left before reporting number of rounds.
;@desc See /rrounds setting.
/prdefvalue -n"roundmin"	-d"Amount of rounds left when to report"

;@command /autopss
;@desc Toggle autopss-functionality on/off. If enabled, /pss macro is executed
;@desc on each battle round flag. By default, /pss is 'party short status', but
;@desc some modules (like <link linkend="usage-pssmangle">PSS-mangler</link>)
;@desc override this to provide additional functionality.
/prdeftoggle -n"autopss"	-d"Auto party short status"

;@command /gagsc
;@desc Toggle gagging of short score ('sc') messages.
/prdeftoggle -n"gagsc"		-d"Gag Short Score ('sc') messages"

;@command /round [commands]
;@desc Sets the BatMUD command(s) to be executed on each battle round.
;@desc The string of commands is sent to the MUD when battle round flag is received.
/prdefvalue -n"round"		-d"Commands to execute on each battle round marker"

;@command /rmisc
;@desc Toggle miscellaneous reporting features.
/prdeftoggle -n"rmisc"		-d"Miscellaneous reporting"
/set opt_rmisc=on

;@command /rcda
;@desc Toggle reporting of Combat Damage Analysis. If set 'off', CDA reports
;@desc are only displayed locally to you, if set 'on', reporting is done to party report channel.
/prdeftoggle -n"rcda"		-d"Combat Damage Analysis reporting"
/set opt_rcda=on

/def -i pss = @@party status short


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define RIP functions and hook
/def -i prdefripfunc =\
	/eval /set set_ripaction_s=%{1} %{set_ripaction_s}%;\
	/eval /def -i ripfunc_%{1} = %{-1}

/prdefripfunc off
/prdefripfunc dig /dig_grave
/prdefripfunc eat /eat_corpse
/prdefripfunc get /get_corpse
/prdefripfunc cmd /eval %%{set_ripcommand}

;@command /ripaction <action>
;@desc Set the action performed at opponent RIP. Possible additional settings
;@desc may be provided by other loaded modules. Functions provided by base GgrTF are:
;@desc <emphasis>off</emphasis> (no special action performed),
;@desc <emphasis>dig</emphasis> (dig grave for corpse),
;@desc <emphasis>eat</emphasis> (get and eat corpse),
;@desc <emphasis>get</emphasis> (get corpse) and
;@desc <emphasis>cmd</emphasis> (execute mud command(s) specified with /ripcommand setting, see /ripcommand)

/prdefhook -n"ripaction" -d"Set the action performed at monster RIP" -h"ripfunc" -s"off dig eat get cmd"
/ripaction off

;; RIP command
;@command /ripcommand [commands]
;@desc Sets the MUD command(s) to be executed if /ripaction is set to "cmd".
;@desc This string is sent "as is" to the MUD at opponent R.I.P, if /ripaction is "cmd".

/prdefvalue -n"ripcommand" -d"Commands to be executed if ripaction = cmd"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LoC-action
;@desc Sets action taken after a Lord of Chaos performs "blood corpse".
;@desc This is useful for automating corpse handling, if you are a LoC
;@desc yourself, or are partying with one.

/prdefsetting -n"locaction" -d"Set action performed after blood corpse" -s"off dig eat get cmd"
/locaction off

;; LoC command
/prdefvalue -n"loccommand" -d"Commands to be executed if locaction = cmd"

/def -i -F -p9999 -mregexp -t"^([A-Z][a-z]+)(| the christmas elf) holds (.+) over the still form of (its|her|his) fallen foe\.$" gloc_blood =\
	/substitute -p @{BCyellow}%{P1}@{n} @{BCwhite}holds@{n} @{Cred}%{P3}@{n} @{BCwhite}over the still form of %{P4} fallen foe.@{n}%;\
	/if (set_locaction=~"dig") /dig_grave%;\
	/elseif (set_locaction=~"eat") /eat_corpse%;\
	/elseif (set_locaction=~"get") /get_corpse%;\
	/elseif (set_locaction=~"cmd") %{set_loccommand}%;/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Lich-action
;@command /lichaction <action>
;@desc Sets action taken after a Lich performs "soul sucking".
/prdefsetting -n"lichaction" -d"Set action performed after lich sucking" -s"off dig eat get"
/lichaction off

/def -i -F -p9999 -mregexp -t"^([A-Z][a-z]+)(| the christmas elf) (chants with an eerie hollow voice some arcane sounding words\.)$" glich_suck =\
	/substitute -p @{BCyellow}%{P1}@{n} @{BCwhite}%{P3}@{n}%;\
	/if (set_lichaction=~"dig") /dig_grave%;\
	/elseif (set_lichaction=~"eat") /eat_corpse%;\
	/elseif (set_lichaction=~"get") /get_corpse%;/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Movement
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Catch movement commands to update the status bar
/def -i -mglob -h'send {n|s|e|w|ne|sw|nw|se|u|d}' prmove_send =\
	/set prmove_last=%*%;\
	/gstatus_update%;\
	/send %*

/set prmove_trans_n=north
/set prmove_trans_s=south
/set prmove_trans_e=east
/set prmove_trans_w=west

/set prmove_trans_ne=northeast
/set prmove_trans_se=southeast
/set prmove_trans_nw=northwest
/set prmove_trans_sw=southwest


;; Normal movement
/def -i prmove_walk = /set prmove_last=%{1}%;/gstatus_update%;\
	@@$[prgetval(strcat("prmove_trans_",{1}))]

;; Autopeering
/def -i prmove_peer =\
	/set prmove_last=%{1}%;/gstatus_update%;\
	@@$[prgetval(strcat("prmove_trans_",{1}))]%;\
	/if 	({1}=~"n" | {1}=~"s") /let pd1=west%;/let pd2=east%;\
	/elseif ({1}=~"w" | {1}=~"e") /let pd1=north%;/let pd2=south%;\
	/else /break%;/endif%;\
	@@grep '(%{set_peer})' peer %{pd1}%;\
	@@grep '(%{set_peer})' peer %{pd2}

;; Main handling macro for binding movemement keys, etc.
;@command /move <type>
;@desc Change the meaning of <link linkend="usage-general-prmove">keyboard movement hooks</link>.
/prdefhook -n"move" -d"Keyboard numpad movement hooks" -h"prmove" -s"walk ship peer"
/move walk

;@command /peer [regexp string]
;@desc View or set regular expression used with autopeering movement mode (/move peer).
/prdefvalue -n"peer" -d"Regular expression used with autopeering"


;; Ship movement
;@command /cruise
;@desc Toggle cruise mode if movement mode is ship (/move ship).
/prdeftoggle -n"cruise" -d"Cruise speed on ship (off = sail)"
/def -i prmove_ship =\
	/set prmove_last=%{1}%;/gstatus_update%;\
	/if ({1}=~"X") @@sail stop%;\
	/elseif (opt_cruise=~"on") @@cruise %{1}%;\
	/else @@sail %{1}%;/endif


;; Ship viewing setting
;@command /shipmove <off|view|map>
;@desc Set what action is performed when ship movement is detected.
/prdefsetting -n"shipmove" -d"Action on ship movement" -s"off view map"
/shipmove off

/def -i -F -mregexp -t"^The ship (sails|cruises) " gship_move =\
	/if (set_shipmove=~"view") @@view%;\
	/elseif (set_shipmove=~"map") @@map%;/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Status bar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; These macros handle the statusbar functionality. Unfortunately
; some things (like channeller energy aura), etc. are hardcoded here,
; due to some complexities in modularizing them.

;; Add value item (hp/sp/ep/etc) to status string
/def -i gstatus_add_val =\
	/set status_w=$[status_w+13]%;\
	/let _val1=status_%{1}%;\
	/let _val2=status_%{1}max%;\
	/let _val1v=$[prgetval(_qtval1)]%;\
	/let _val2v=$[prgetval(_qtval2)]%;\
	/let _vcol=$[prgetnlite(_val1v,_val2v)]%;\
	/set status_pstr=%{status_pstr} "[" "%{2}:":2:BCwhite %{_val1}:-4:%{_vcol} "/" %{_val2}:-4:BCgreen "]"

/def -i gstatus_add_var =\
	/let _vlabel=%{1}%;\
	/let _vstr=$[prgetval({2})]%;\
	/if ({3} > 0) /let _vstr=$[prsubpad(_vstr,{3})]%;/endif%;\
	/set status_w=$[status_w+strlen(_vlabel)+strlen(_vstr)+3]%;\
	/set status_pstr=%{status_pstr} "[" "%{_vlabel}:"::BCwhite "%{_vstr}"::BCcyan "]"

;; Add aura item
/def -i gstatus_add_aura =\
	/if (prot_eaura > 0)\
		/if (prot_eaura == 1) /let _ucol=BCyellow%;/endif%;\
		/if (prot_eaura == 2) /let _ucol=BCred%;/endif%;\
		/if (prot_eaura == 3) /let _ucol=BCblue%;/endif%;\
		/if (prot_eaura_weak=~"on")\
			/let _utime=$[prgettime(time()-prot_eaura_weak_t)]%;\
			/set status_w=$[status_w+8+5+strlen(_utime)]%;\
			/set status_pstr=%{status_pstr} "[" "EAura%{prot_eaura}":5:%{_ucol} "/" "WEAK":4:BCwhite ":" "%{_utime}"::BCwhite "]"%;\
		/else \
			/let _utime=$[prgettime(time()-prot_eaura_t)]%;\
			/set status_w=$[status_w+8+strlen(_utime)]%;\
			/set status_pstr=%{status_pstr} "[" "EAura%{prot_eaura}":5:%{_ucol} ":" "%{_utime}" "]"%;\
		/endif%;\
	/endif

;; Add spider demon
/def -i gstatus_add_demon =\
	/let _qtime=$[spider_next_drain - time()]%;\
	/if (_qtime > 0 & _qtime < spider_timer_t)\
		/let _utime=$[prgettime(_qtime)]%;\
		/set status_w=$[status_w+8+strlen(_utime)]%;\
		/set status_pstr=%{status_pstr} "[" "Drain":5:BCred ":" "%{_utime}" "]"%;\
	/endif

;; Get value
/def -i gstatus_get_val =\
	/if ({1}=~"on") /return "BCwhite"%;/else /return "Cblue"%;/endif

/def -i gstatus_get_camp =\
	/if (camp_st == 1) /return "BCgreen"%;\
	/elseif (camp_st == 2) /return "BCred"%;\
	/else /return "BCyellow"%;/endif

;; Compute updated status string
/def -i gstatus_update_do =\
	/set status_w=12%;\
	/set status_pstr=%;\
	/gstatus_add_val hp H%;\
	/gstatus_add_val sp S%;\
	/gstatus_add_val ep E%;\
	/set status_pstr=%{status_pstr} "[" "%{prmove_last}":2:BCgreen "C":1:$[gstatus_get_val(ceremony_st)] "S":1:$[gstatus_get_val(spell_st)] "K":1:$[gstatus_get_val(skill_st)] "c":1:$[gstatus_get_camp()] "]"%;\
	/test gstatus_add_var("T", "heartbeat_cnt", 2)%;\
	/test gstatus_add_var("S", "heartbeat_subtick", 2)%;\
	/if (battle_st) /test gstatus_add_var("rnd", "battle_round")%;/endif%;\
	/gstatus_add_aura%;\
	/gstatus_add_demon

;; Update statusbar
/def -i gstatus_update =\
	/gstatus_update_do%;\
	/let _qw=$[columns() - status_w]%;\
	/if (_qw > 3) /set status_pstr=%{status_pstr} :1 "%{status_protstr2}":%{_qw}:Cgreen%;/endif%;\
	/set status_fields=%{status_pstr}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Status short score/prompt grabbing triggers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i prgetdiff =\
	/let _ts=%;/let _tv=$[{1} - {2}]%;\
	/if (_tv < 0) /let _ts=@{Cred}%{_tv}@{n}%;\
	/elseif (_tv > 0) /let _ts=@{Cgreen}+%{_tv}@{n}%;/endif%;\
	/return "[%{_ts}]"

/def -i gstatus_scupd =\
	/set status_oldhp=%{status_hp}%;/set status_hp=%{1}%;/set status_hpmax=%{2}%;\
	/set status_oldsp=%{status_sp}%;/set status_sp=%{3}%;/set status_spmax=%{4}%;\
	/set status_oldep=%{status_ep}%;/set status_ep=%{5}%;/set status_epmax=%{6}%;\
	/set status_money=%{7}%;/set status_exp=%{8}%;/set status_qline=%{9}%;\
	/gprots_update%;/gstatus_update%;\
	/prexecfuncs %{event_sc_printed}%;\
	/if (opt_gagsc=~"on") /substitute -ag%;/endif


;; Grab SHORT SCORE (sc)
;; !!!NOTICE!!! BIG FAT NOTICE HERE !!
;; If you decide NOT to use the recommended 'sc' format, instead of changing
;; anything HERE (the gstatus_sc macro below), copy gstatus_sc to your
;; .tfrc and modify and override it there! Thus you'll be spared from most
;; trouble when upgrading to new version of GgrTF.

/def -i -F -p9999 -mregexp -t"^H:(-?[0-9]+)/(-?[0-9]+) \[[+-]?[0-9]*\] S:(-?[0-9]+)/(-?[0-9]+) \[[+-]?[0-9]*\] E:(-?[0-9]+)/(-?[0-9]+) \[[+-]?[0-9]*\] \$:(-?[0-9]+) \[[+-]?[0-9]*\] exp:(-?[0-9]+) \[[+-]?[0-9]*\]$" gstatus_sc =\
	/test gstatus_scupd({P1},{P2},{P3},{P4},{P5},{P6},{P7},{P8},{*})


;; Grab PROMPT
/def -i -p9999 -mregexp -h"PROMPT PROMPT:(.*)>$" gstatus_prompt=\
	/set status_prompt=$[strip_attr({P1})]%;\
	/if (cast_info!~"" & cast_info_n!~"") \
		/if (cast_info_t!~"") \
			/set status_cast=%{cast_info}[%{cast_info_n} -> %{cast_info_t}]%;\
		/else \
			/set status_cast=%{cast_info}[%{cast_info_n}]%;\
		/endif%;\
	/else \
		/set status_cast=%;\
	/endif%;\
	/if (gtf_version < 50008)\
		/eval /prompt $[strip_attr(set_gprompt)]%;\
	/else \
		/eval /prompt -p %{set_gprompt}%;\
	/endif%;\
	/gstatus_update


;@command /gprompt [prompt string]
;@desc Set or change GgrTF's displayed prompt. The setting can contain any
;@desc TinyFugue expressions, such as variable substitutions. Refer to
;@desc <link linkend="usage-general-prompt">prompt settings section</link> for details.
/prdefvalue -n"gprompt" -d"GgrTF prompt string"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Version reporting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set ggrtf_copy=(C) Copyright 2004-2016 Matti Hämäläinen (Ggr Pupunen) and others

;@command /gver
;@desc Prints (or returns, if called as function) a short version string of GgrTF.
/def -i gver = /result "GgrTF %{ggrtf_ver}"

;@command /gversion
;@desc Prints (or returns, if called as function) a long version string of
;@desc GgrTF with copyright- and TinyFugue version information.
/def -i gversion =\
	/result "GgrTF v%{ggrtf_ver} %{ggrtf_copy} on TinyFugue $[ver()]"

/prdeftoggle -n"repver" -d"Report version via 'hopple inquisitively'"
/set opt_repver=on

/set report_ver_t=0
/def -i -E(opt_repver=~"on") -p9999 -mregexp -t"^@?([A-Z][a-z]+) hopples around you inquisitively, all bunny-like\.$" greport_ver =\
	/if (time()-report_ver_t > 10)\
		/set report_ver_t=$[time()]%;\
		@@emoteto %{P1} is using $[gversion()]%;\
	/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Skill/spell fumble / fail definition
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -t"<pattern>" Pattern/string for matching
; -r Use regexp instead of simple matching
; -c Type: Spell
; -k Type: Skill
; -f Fail
; -F Fumble

/def -i prdeffail =\
	/if (!getopts("t:rckfF", "")) /gerror Invalid fail/fumble definition!%;/break%;/endif%;\
	/if (opt_c & opt_k) /gerror Skill and spell options are mutually exclusive!%;/break%;/endif%;\
	/if (opt_f & opt_F) /gerror Fail and fumble options are mutually exclusive!%;/break%;/endif%;\
	/if (opt_t=~"") /gerror Invalid fail/fumble definition! -t not specified or empty.%;/break%;/endif%;\
	/if (opt_r) /let _tmpr=regexp%;/else /let _tmpr=simple%;/endif%;\
	/if (opt_f)\
		/let _tmpt=fail%;\
		/let _tmpa=Cred%;\
	/elseif (opt_F)\
		/let _tmpt=fumble%;\
		/let _tmpa=BCred%;\
	/else \
		/gerror Invalid fail/fumble definition! You MUST specify either -f or -F%;\
		/break%;\
	/endif%;\
	/if (opt_c)\
		/def -i -F -p9999 -m%{_tmpr} -a%{_tmpa} -t"%{opt_t}" gspell_%{_tmpt}%{cnt_def_fail} = /gspell_%{_tmpt}%;\
	/elseif (opt_k)\
		/def -i -F -p9999 -m%{_tmpr} -a%{_tmpa} -t"%{opt_t}" gskill_%{_tmpt}%{cnt_def_fail} = /gskill_%{_tmpt}%;\
	/else \
		/gerror Invalid fail/fumble definition! You must specify either -k or -c%;\
		/break%;\
	/endif%;\
	/set cnt_def_fail=$[cnt_def_fail+1]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Prot triggers and reporting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; List of prots and conjurer prots (cprots list needed for handling/clearing minor prot prereqs)
/set lst_prots=
/set lst_cprots=
/set lst_dmpprots=
/set lst_ripprots=


;; Clear a given list of prot prerequisites
/def -i prclearpreqs =\
	/while ({#})\
		/set prot_%{1}_p=0%;\
		/shift%;\
	/done

/def -i prclearprots =\
	/while ({#})\
		/set prot_%{1}=0%;\
		/set prot_%{1}_p=0%;\
		/shift%;\
	/done


;; Reset prots
;@command /cprots
;@desc This command clears all prots on you. It is meant for those cases where
;@desc GgrTF is either bugging and does not notice a prot dropping, or any other
;@dsec reason when you need to remove all prots at your discretion.
/def -i cprots =\
	/msq @{BCgreen}NOTICE!@{n} @{BCwhite}Clearing status of all prots.@{n}%;\
	/prclearprots %{lst_prots}%;\
	/gprots_update%;/gstatus_update
	

;; Define a conjuprot trigger (function)
/def -i prdefconju =\
	/gdef -i -F -p9999 -aCgreen -msimple -t"%{3}" rec_%{2}_on=\
		/if (prot_%{1}_p==1) /gprot_on %{1}%{4}/endif%%;\
		/set prot_%{1}_p=0

/def -i prdeffolk =\
	/gdef -i -F -p9999 -aCgreen -mregexp -t"%{3}" rec_%{2}_on=/gprot_on %{1}%{4}


;; Clear/setup all variables related to prot
; -i"<name>" Prot unique name (must be unique)
; -n"<shortname>" Short name, shown in /prots output and statusline
; -l"<desc/longname>" Long name, should also be the same as "show effects" output
; -A"<prerequisite regexp #1>" Pre-requisite #1 for prot "up" message
; -B"<prerequisite regexp #2>"
; -C"<prerequisite regexp #3>"
; -u"<up message>"
; -d"<down message>"
; -r Use regexp instead of simple matching in up AND down messages
; -s Stackable prot
; -h Renewable prot (does not stack, but can be renewed)
; -p Conjurer minor typeprot (options -u, -s, -r are meaningless)
; -P Conjurer major typeprot
; -F Folklorist prot
; -q Don't give error on gprot_off if prot is not up
; -m DMP removes this prot (all conju prots are added automatically)
; -M RIP (player's death) removes this prot
; -e Extra counter report (don't ask)
; -z Handicap (curse, or similar)

/def -i prdefprot =\
	/if (!getopts("i:n:l:A:B:C:u:d:srhpPFqmMez", "")) /gerror Invalid prot definition!%;/break%;/endif%;\
	/if (opt_i=~"") /gerror Prot definition missing varname (-i)%;/break%;/endif%;\
	/if (opt_n=~"") /gerror Prot definition '%{opt_i}' missing name (-n)%;/break%;/endif%;\
	/if (opt_l=~"") /gerror Prot definition '%{opt_i}' missing long name (-l)%;/break%;/endif%;\
	/test prlist_insert("lst_prots", opt_i)%;\
	/set prot_%{opt_i}=0%;\
	/set prot_%{opt_i}_t=-1%;\
	/set prot_%{opt_i}_n=%{opt_n}%;\
	/set prot_%{opt_i}_l=%{opt_l}%;\
	/set prot_%{opt_i}_p=0%;\
	/set prot_%{opt_i}_st=0%;\
	/set prot_%{opt_i}_w=0%;\
	/if (opt_z) /set prot_%{opt_i}_hcap=1%;/else /set prot_%{opt_i}_hcap=0%;/endif%;\
	/if (opt_e) /set prot_%{opt_i}_e=1%;/else /set prot_%{opt_i}_e=0%;/endif%;\
	/if (opt_M) /set lst_ripprots=%{opt_i} %{lst_ripprots}%;/endif%;\
	/if (opt_q) /set prot_%{opt_i}_q=0%;/else /set prot_%{opt_i}_q=1%;/endif%;\
	/if (opt_p | opt_P | opt_F)\
		/if (opt_p & opt_P) /gerror Minor and major typeprot options given.%;/break%;/endif%;\
		/if (opt_F & (opt_p | opt_P)) /gerror Folklorist prot and minor or major conju typeprot options given.%;/break%;/endif%;\
		/if (!opt_F & (opt_d=~"" | opt_A=~"")) /gerror Conjurer typeprot definition requires proper -A and -d options!%;/break%;/endif%;\
		/test prlist_insert("lst_cprots", opt_i)%;\
		/let _qmatch=simple%;\
		/let qact1=%%;%;\
		/let qact2= (sticky)%%;/set prot_%{opt_i}_st=1%%;%;\
		/if (opt_P)\
			/gdef -i -F -p9999 -aCyellow -mregexp -t"^([A-Z][a-z]+) utters? the magic words '%{opt_A}'\$" rec_%{opt_i}_A=\
				/prclearpreqs %%{lst_cprots}%%;/set prot_%{opt_i}_p=1%;\
			/test prdefconju(opt_i, opt_i, "You see a %{opt_d} shield fade into existance around you.", qact1)%;\
			/test prdefconju(opt_i, "%{opt_i}_st", "You see an extra %{opt_d} shield fade into existance around you.", qact2)%;\
			/let opt_d=Your %{opt_d} shield fades out.%;\
		/elseif (opt_p)\
			/gdef -i -F -p9999 -aCyellow -mregexp -t"^([A-Z][a-z]+) utters? the magic words '%{opt_A}'\$" rec_%{opt_i}_A=\
				/prclearpreqs %%{lst_cprots}%%;/set prot_%{opt_i}_p=1%;\
			/test prdefconju(opt_i, opt_i, "You sense a powerful protective aura around you.", qact1)%;\
			/test prdefconju(opt_i, "%{opt_i}_st", "You sense an extra powerful protective aura around you.", qact2)%;\
			/let opt_d=A %{opt_d} flash momentarily surrounds you and then vanishes.%;\
		/else \
			/test prdeffolk(opt_i, opt_i, "^You feel %{opt_A}protected%{opt_u}\.\$", qact1)%;\
			/test prdeffolk(opt_i, "%{opt_i}_st", "^You feel extra protected%{opt_u}\.\$", qact2)%;\
			/let opt_d=The %{opt_d} protection fades away.%;\
		/endif%;\
	/else \
		/if (opt_m) /set lst_dmpprots=%{opt_i} %{lst_dmpprots}%;/endif%;\
		/if (opt_s) /set prot_%{opt_i}_stack=1%;/else /set prot_%{opt_i}_stack=0%;/endif%;\
		/if (opt_h) /set prot_%{opt_i}_renew=1%;/else /set prot_%{opt_i}_renew=0%;/endif%;\
		/if (opt_u=~"" | opt_d=~"") /break%;/endif%;\
		/if (opt_r) /let _qmatch=regexp%;/else /let _qmatch=simple%;/endif%;\
		/let pstr=0%;\
		/if (opt_A!~"") /let pstr=1%;/gdef -i -F -p9999 -aCyellow -mregexp -t'%{opt_A}' rec_%{opt_i}_A=/prclearpreqs %%{lst_prots}%%;/set prot_%{opt_i}_p=1%;/endif%;\
		/if (opt_B!~"") /let pstr=2%;/gdef -i -F -p9999 -aCyellow -mregexp -t'%{opt_B}' rec_%{opt_i}_B=/if (prot_%{opt_i}_p == 1) /prclearpreqs %%{lst_prots}%%;/set prot_%{opt_i}_p=2%%;/endif%;/endif%;\
		/if (opt_C!~"") /let pstr=3%;/gdef -i -F -p9999 -aCyellow -mregexp -t'%{opt_C}' rec_%{opt_i}_C=/if (prot_%{opt_i}_p == 2) /prclearpreqs %%{lst_prots}%%;/set prot_%{opt_i}_p=3%%;/endif%;/endif%;\
		/if (pstr > 0)\
			/gdef -i -F -p9999 -aCgreen -m%{_qmatch} -t'%{opt_u}' rec_%{opt_i}_on=/if (prot_%{opt_i}_p==%{pstr})/gprot_on %{opt_i}%%;/endif%%;/set prot_%{opt_i}_p=0%;\
		/else \
			/gdef -i -F -p9999 -aCgreen -m%{_qmatch} -t'%{opt_u}' rec_%{opt_i}_on=/set prot_%{opt_i}_p=0%%;/gprot_on %{opt_i}%;\
		/endif%;\
	/endif%;\
	/gdef -i -F -p9999 -aCgreen -m%{_qmatch} -t'%{opt_d}' rec_%{opt_i}_off=/gprot_off %{opt_i}


;; Turn prot ON
/def -i gprot_on =\
	/if ({#} < 1) /gerror No prot identifier argument defined!%;/break%;/endif%;\
	/let _prot_l=$[prgetval(strcat("prot_",{1},"_l"))]%;\
	/if (_prot_l=~"") /gerror Invalid prot identifier '%{1}'!%;/break%;/endif%;\
	/let _prot_s=$[prgetval(strcat("prot_",{1},"_stack"))]%;\
	/let _prot_h=$[prgetval(strcat("prot_",{1},"_renew"))]%;\
	/let _prot_c=$[prgetval(strcat("prot_",{1}))]%;\
	/if (_prot_c == 0 | (_prot_h == 1 & _prot_s == 0))\
		/if (_prot_c > 0)\
			/let _prot_t=$[prgetval(strcat("prot_",{1},"_t"))]%;\
			/let _tmps=Renewed! $[prgetstime(_prot_t)]%;\
		/else \
			/let _tmps=ON!%;\
		/endif%;\
		/set prot_%{1}=1%;\
	/else \
		/if (_prot_s)\
			/set prot_%{1}=$[_prot_c+1]%;\
			/let _tmps=ON [#$[_prot_c+1]]%;\
		/else \
			/gerror Prot '%{1}' (%{_prot_l}) increased even though not flagged stackable!%;\
			/break%;\
		/endif%;\
	/endif%;\
	/set prot_%{1}_t=$[time()]%;\
	/if ({-1}!~"")\
		/msr %{_prot_l} %{-1} %{_tmps}%;\
	/else \
		/msr %{_prot_l} %{_tmps}%;\
	/endif%;\
	/gprots_update%;/gstatus_update


;; Turn prot OFF
/def -i gprot_off =\
	/if ({#} < 1) /gerror No prot identifier argument defined!%;/break%;/endif%;\
	/let _prot_l=$[prgetval(strcat("prot_",{1},"_l"))]%;\
	/if (_prot_l=~"") /gerror No such prot '%{1}' defined!%;/break%;/endif%;\
	/let _prot_c=$[prgetval(strcat("prot_",{1})) - 1]%;\
	/set prot_%{1}=%{_prot_c}%;\
	/let _prot_s=$[prgetval(strcat("prot_",{1},"_stack"))]%;\
	/let _prot_t=$[prgetval(strcat("prot_",{1},"_t"))]%;\
	/let _prot_h=$[prgetval(strcat("prot_",{1},"_renew"))]%;\
	/let _prot_q=$[prgetval(strcat("prot_",{1},"_q"))]%;\
	/if (_prot_c < 0 & _prot_q) \
		/gwarning '%{1}' (%{_prot_l}) count %{_prot_c} at /gprot_off!%;\
		/set prot_%{1}=0%;\
		/set prot_%{1}_st=0%;\
		/msr %{_prot_l} OFF!%;\
		/break%;\
	/endif%;\
	/if (_prot_s & _prot_c >= 1 & _prot_h == 0) \
		/msr %{_prot_l} Weakened! [#%{_prot_c}] $[prgetstime(_prot_t)]%;\
	/else \
		/set prot_%{1}=0%;\
		/set prot_%{1}_st=0%;\
		/if (!_prot_q & _prot_c < 0)\
			/msr %{_prot_l} OFF!%;\
		/else \
			/msr %{_prot_l} OFF! $[prgetstime(_prot_t)]%;\
		/endif%;\
	/endif%;\
	/gprots_update%;/gstatus_update


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Form the "current prots" strings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gprots_doget =\
/while ({#})\
	/let _prot_on=$[prgetval(strcat("prot_",{1}))]%;\
	/if (_prot_on > 0)\
		/let _prot_t=$[prgetval(strcat("prot_",{1},"_t"))]%;\
		/let _prot_n=$[prgetval(strcat("prot_",{1},"_n"))]%;\
		/let _prot_st=$[prgetval(strcat("prot_",{1},"_st"))]%;\
		/let _prot_e=$[prgetval(strcat("prot_",{1},"_e"))]%;\
		/let _prot_w=$[prgetval(strcat("prot_",{1},"_w"))]%;\
		/let _prot_hcap=$[prgetval(strcat("prot_",{1},"_hcap"))]%;\
		/set cnt_prots=$[cnt_prots + 1]%;\
		/if (_prot_st) /let _qts=+%;/else /let _qts=%;/endif%;\
		/if (_prot_on > 1) /let _qts=(%{_prot_on})%;/endif%;\
		/if (_prot_e & _prot_w > 0) /let _qts=%{_qts}<%{_prot_w}>%;/endif%;\
		/if (_prot_hcap) /let _prot_n=-%{_prot_n}%;/endif%;\
		/let _qss=%{_prot_n}%{_qts}$[prgetstime(_prot_t)]%;\
		/if (status_protstr!~"")\
			/set status_protstr=%{status_protstr} | %{_qss}%;\
			/set status_protstr2=%{status_protstr2}|%{_prot_n}%{_qts}%;\
		/else \
			/set status_protstr=%{_qss}%;\
			/set status_protstr2=%{_prot_n}%{_qts}%;\
		/endif%;\
	/endif%;\
	/shift%;\
/done

/def -i gprots_update =\
	/set status_protstr=%;\
	/set status_protstr2=%;\
	/set cnt_prots=0%;\
	/eval /gprots_doget %{lst_prots}%;\
	/if (cnt_prots > 0)\
		/return status_protstr%;\
	/else \
		/return "No prots."%;\
	/endif


;; Prot reporting
;@command /prots
;@desc Show any currently active prots on you. The output is only echoed
;@desc locally, use BatMUD 'tweak me' emote to list prots to party report-channel.
/def -i prots = /msq $[gprots_update()]

/prdefgbind -s"prots" -c"/prots"

/def -i -p9999 -mregexp -t"^[A-Z][a-z]+ tweaks your nose (mischievously|mischeviously).$" gprot_tweak1 =\
	/msr $[gprots_update()]

/def -i -p9999 -mregexp -t"^You tweak your own nose (mischievously|mischeviously).$" gprot_tweak3 =\
	/msr $[gprots_update()]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Prots which expire on death, DMP or reboot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Death
/def -i gprots_clear_rip =\
	/let _ripstr=%;\
	/while ({#})\
		/let _prot_on=$[prgetval(strcat("prot_",{1}))]%;\
		/if (_prot_on)\
			/let _prot_n=$[prgetval(strcat("prot_",{1},"_n"))]%;\
			/set prot_%{1}=0%;\
			/set prot_%{1}_st=0%;\
			/if (_ripstr!~"") \
				/let _ripstr=%{_ripstr}, %{_prot_n}%;\
			/else \
				/let _ripstr=%{_prot_n}%;\
			/endif%;\
		/endif%;\
		/shift%;\
	/done%;\
	/result _ripstr

/gdef -i -F -p9999 -aCgreen -msimple -t"You can see Death, clad in black, collect your corpse." gprots_rip =\
	/msq @{BCyellow}Various prots expire as you die!@{n}%;\
	/set spell_st=off%;\
	/set skill_st=off%;\
	/let _ripstr=$(/gprots_clear_rip %{lst_ripprots})%;\
	/gprots_update%;/gstatus_update%;\
	/if (_ripstr!~"")\
		/msr R.I.P. removed: %{_ripstr}%;\
	/endif


;; Dispel magical protection (dmp)
/def -i gprots_clear_dmp =\
	/let _dmpstr=%;\
	/while ({#})\
		/let _prot_on=$[prgetval(strcat("prot_",{1}))]%;\
		/let _prot_st=$[prgetval(strcat("prot_",{1},"_st"))]%;\
		/if (_prot_on & _prot_st == 0)\
			/let _prot_n=$[prgetval(strcat("prot_",{1},"_n"))]%;\
			/set prot_%{1}=0%;\
			/if (_dmpstr!~"") \
				/let _dmpstr=%{gdmpstr}, %{_prot_n}%;\
			/else \
				/let _dmpstr=%{_prot_n}%;\
			/endif%;\
		/endif%;\
		/shift%;\
	/done%;\
	/result _dmpstr


/def -i -F -p9999 -ag -mregexp -t"^You feel (unprotected|much more vulnerable)\.$" gprots_dmp =\
	/let _dmpstr=$(/gprots_clear_dmp %{lst_cprots} %{lst_dmpprots})%;\
	/gprots_update%;/gstatus_update%;\
	/if (_dmpstr!~"")\
		/msq @{BCred}Dispel Magical Protection@{n} hit you!%;\
		/msr DMP removed: %{_dmpstr}%;\
	/endif


;; Login after reboot or quit
/gdef -i -F -p9999 -aCgreen -msimple -t"Moving to starting location." gevent_quit_login =\
	/prexecfuncs %{event_quit_login}

/test prlist_insert("event_quit_login", "cprots")

;; Normal relogin from linkdead
/gdef -i -F -p9999 -aCgreen -mregexp -t"^Recovering character\.$" gevent_login =\
	/prexecfuncs %{event_login}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Create regular prots without additional complexities
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdefprot -i"eaura"	-n"EAura"	-l"Energy Aura"	-s -h
/prdefprot -i"pff"	-n"PFF"		-l"Personal Force Field" -r -u"^You surround yourself by a bubble of force.$" -d"^Your field disperses with a soft \*pop\* and is gone\.$"

/prdefprot -i"infra"	-n"Infra" 	-l"Infravision" -h -A"\'demoni on pomoni\'$" -u"You have infravision." -d"Everything no longer seems so red."
/prdefprot -i"ww"	-n"WW" 		-l"Water Walking" -h -A" \'Jeeeeeeeeeeeesuuuuuuuus\'$" -r -u"^(You feel light|Your feet feel lighter than before)\." -d"^You feel heavier\."
/prdefprot -i"float"	-n"Float"	-l"Floating" 	-s -r -u"^You feel light, and rise into the air.$" -d"^(Your old floating spell dissipates|You slowly descend until your feet are on the ground).$"
/prdefprot -i"invis"	-n"Invis"	-l"Invisibility" -r -u"^You (suddenly can\'t see yourself|twist the ring and suddenly you become invisible).$" -d"^You turn visible.$"
/prdefprot -i"godpr"	-n"GodPr"	-l"Godly Presence"
/prdefprot -i"seeinvis"	-n"SeeInv"	-l"See Invisible" -u"You feel you can see more than ever." -d"Your vision is less sensitive now."
/prdefprot -i"seemagic"	-n"SeeMag"	-l"See Magic" -u"You can now see magical things." -d"You are no longer sensitive to magical things."
/prdefprot -i"hw"	-n"HW"		-l"Heavy Weight" -A" \'tonnikalaa\'$" -u"You suddenly feel magically heavier." -d"You feel lighter, but it doesn\'t seem to affect your weight!"

/prdefprot -i"haste"	-n"Haste"	-l"Haste"

/prdefprot -i"erage"	-n"ERage"	-l"Enrage" -r -u"^(You feel mildly enraged.|You are maddened with rage!|You feel your barbarian rage stir up.|Holy CRAP! OH what a RUSH!|You feel TOTALLY ENRAGED and ready to KICK ASS!|YOU FEEL AS IF YOU WERE GROO HIMSELF!|You are ENRAGED! Your body ACHES for action!|You feel the adrenaline BURST into your veins!|Your blood is boiling (of|with) rage!|You tremble uncontrollably and feel completely ENRAGED!)$" -d"^You no longer feel enraged.$"
/prdefprot -i"pthrsh"	-n"PThrsh"	-l"Pain Threshold" -u"You begin to concentrate on pain threshold." -d"Your concentration breaks and you feel less protected from physical damage."
/prdefprot -i"timm"	-n"TImm"	-l"Toxic Immunity" -u"You begin to concentrate on toxic immunity." -d"Your concentration breaks and you feel less protected from poison."
/prdefprot -i"ctol"	-n"CTol"	-l"Cold Tolerance" -u"You begin to concentrate on cold tolerance." -d"Your concentration breaks and you feel less protected from cold."
/prdefprot -i"fwal"	-n"FWal"	-l"Fire Walking" -u"You begin to concentrate on fire walking." -d"Your concentration breaks and you feel less protected from fire."

/prdefprot -i"pbsf"		-n"PbSf"	-l"Protection by Sacrifice" -A" kneels before you and whispers \'With my life I\'ll protect yours\'.$" -r -u"^(She|He|It) stands up with a solemn look on (his|her|its) face\.$" -d"^[A-Z][a-z]+ no longer protects you\.$"
/prdefprot -i"lol"		-n"LoL"		-l"Lift of Load" -u"You feel odd. Not stronger, but..." -d"You feel odd. Not weaker, but..."

/prdefprot -i"eawaren"	-n"EA"		-l"Enhanced Awareness" -u"You feel more aware of your surroundings." -d"You feel your enhanced awareness subside."
/prdefprot -i"searf"	-n"SearF"	-l"Searing Fervor" -r -u"^You feel uncomfortable warmth emanate within the bloodstream from your" -d"^The unnatural warmth evens out and stabilizes back to normal."

/prdefprot -i"glight"	-n"GLight"	-l"Greater Light" -A"^You utter the magic words \'vas ful\'$" -u"A small ball of light starts following you." -d"Your greater light spell flickers briefly and disappears."
/prdefprot -i"gdark"	-n"GDark"	-l"Greater Darkness" -A"^You utter the magic words \'vas na ful\'$" -u"You summon a circle of darkness that absorbs light." -d"Your greater darkness spell dissolves."


;; --- Misc. handicaps ----
/prdefprot -i"forget"	-n"Forget"	-l"Forget" -z -u"You feel rather empty-headed." -d"A fog lifts from your mind. You can remember things clearly now."
/prdefprot -i"supprm"	-n"Suppr"	-l"Suppress Magic" -z -u"You feel excruciating pain in your head." -d"You feel relieved."

; Degen seems not to have any drop message?
;/prdefprot -i"degen"	-n"Degen"	-l"Degenerate Person" -z -u"You suddenly feel feeble and old." -d""

;; ---- Spider ----
/prdefprot -i"stouch"	-n"STouch"	-l"Spider Touch" -z -u"Suddenly you don\'t feel too good. Your blood feels like it is on fire." -d"Your blood does not burn anymore."
/prdefprot -i"qsilver"	-n"QS"		-l"Quicksilver" -u"You feel more agile." -d"You feel less agile."
/prdefprot -i"spwalk"	-n"SWalk"	-l"Spider Walk" -u"For some reason you want to run on the walls for a little while." -d"The walls don\'t look so inviting anymore."

;; ---- Tiger ----
/eval /prdefprot -i"ffist"	-n"FFist"	-l"Flame Fists" -r -h	\
	-u"^Your fists are surrounded by Curath\\'s black flames!$$"	\
	-d"^(Your flaming fists disappear\\.|Your fists are no longer surrounded by Curath\\'s black flames\.|Flames around %{set_plrname}\\'s fists disappear!)$$"

;; ---- Evil priest ----
/prdefprot -i"pfg"	-n"PfG"		-l"Protection from Good" -u"A vile black aura surrounds you." -d"You no longer have a vile black aura around you."
/prdefprot -i"paranoia"	-n"Para"	-l"Paranoia" -z -A" \'noxim delusa\'" -u"You have a bad feeling about this." -d"Everything seems so much more pleasant."
/prdefprot -i"aoh"	-n"AoH" 	-l"Aura of Hate" -r -u"^You feel burning hatred and rage erupt within you!" -d"^You feel your anger and hate of the world recede."

;; ---- Tarmalen ----
/prdefprot -i"unpain"	-n"Unp"		-l"Unpain" -h -r -u"^You feel your will getting stronger.$" -d"^(You feel your will returning to normal\.|You feel your will returning normal\.|Your Unpain spell dissipates|You feel your will getting normal\.|You suffer an acute health change)"
/prdefprot -i"bot"	-n"BoT"		-l"Blessing of Tarmalen" -r -u"^You feel strong - like you could carry( the)? whole flat world on your back!$" -d"^You feel weaker\.$"

/prdefprot -i"lifelnk"	-n"LifeLnk"	-l"Life Link" -r -u"^You (succeed. You create a link to [A-Z][a-z]+\.|create a link to [A-Z][a-z]+\.|feel somehow linked to [A-Z][a-z]+!)$" -d"^You hear a loud snap like sound!$"
/prdefprot -i"evital"	-n"EV"		-l"Enhanced Vitality" -A"\'zoot zoot zoot\'" -r -u"^A bright light extracts from (your|.+\'s) hands covering your skin.$" -d"^Your skin stops glowing.$"
/prdefprot -i"gangel"   -n"GAngel"      -l"Guardian Angel" -u"A guardian angel arrives to protect you!" -d"Your guardian angel cannot stay for longer and flies away."
/prdefprot -i"seelight"	-n"SeeLight"	-l"See the Light" -u"Wow! Suddenly you see the Light!" -d"You no longer see the light!"

;; ---- Nun ----
/prdefprot -i"pfe"	-n"PfE"		-l"Protection from Evil" -M -r -q \
	-u" (you feel more protected against evil|with sheer power as you are surrounded by)" \
	-d"^(Your holy aura prevents you (from turning into a frog|being paralyzed)|You suddenly feel more vulnerable to evil|Your glow fades away and you suddenly feel more vulnerable to evil|The evil in you gives you strength and you shatter the holy aura around you).$"
/prdefprot -i"soulsh"	-n"SoulSh"	-l"Soul Shield" -h -M -r -u"^(Your soul is covered by holy aura.|You spiritually reach out for your soul, protecting it with holy force.|[A-Z][a-z]+ places her hand over you and blesses your soul in the name of Las.)$" -d"^Your soul feels suddenly more vulnerable.$"
/prdefprot -i"hprot"	-n"HProt"	-l"Heavenly Protection" -M -r -u"(glow supernatural light|vibrates under magical pressure|blazes heavenly|flashes uncanny|twinkles|flickers) as you .* dazzling white particles dancing" -d"^Holy particles slow down, rapidly fading away.$"
/prdefprot -i"manash"	-n"ManaSh"	-l"Mana Shield" -s -u"You feel your magical power expanding." -d"Your life force seems weaker."

;; ---- Templar ----
/prdefprot -i"sof"	-n"SoF"		-l"Shield of Faith" -m -u"You are surrounded by divine glow!" -d"Your glow disappears."
/prdefprot -i"bof"	-n"BoF"		-l"Blessing of Faerwon" -r -u"^You feel your conviction to rid the world of evil grow stronger as you" -d"^You can feel the power of Faerwon leaving you\.$"

;; ---- Psionicist ----
/prdefprot -i"levi"	-n"Levi"	-l"Levitation" -u"You slowly rise from the ground and start levitating." -d"You decide that you have levitated enough and slowly descend to the ground."
/prdefprot -i"forcesh"	-n"FSh"		-l"Force Shield" -r \
	-u"^(You form a psionic shield of force around your body|[A-Z][a-z]+ forms a shield of force around you)\.$" \
	-d"^Your armour feels thinner.$"

/prdefprot -i"psish"	-n"PsiSh"	-l"Psionic Shield" -u"Psionic waves surge through your body and mind!" -d"The psionic shield vanishes."
/prdefprot -i"minddev"	-n"MDev"	-l"Mind Development" -s -u"You feel your mind developing." -d"Your brain suddenly seems smaller."
/prdefprot -i"ebeacon"	-n"EBeacon"	-l"Beacon of Enlightenment" -q -s -r -u"^Everything seems clearer under the inspiration of ([A-Z][a-z]+\'s?|your own) magic\.$" -d"^You (no longer feel inspired by ([A-Z][a-z]+\'s?|your) beacon of enlightenment-spell|feel lost as all beacons of enlightenment around you die out)\.$"
;/prdefprot -i"transs"	-n"TSelf"	-l"Transmute Self" -A" \'nihenuak assaam no nek orrek\'$" -u"There is a puff of logic!" -d"You feel like the illusion around you lifted."

;; ---- Druid ----
/prdefprot -i"flexsh"	-n"FlexSh"	-l"Flex Shield" -M -u"You sense a flex shield covering your body like a second skin." -d"Your flex shield wobbles, PINGs and vanishes."
/prdefprot -i"epower"	-n"EPower"	-l"Earth Power" -r -u"^You feel your strength changing\. You flex your? muscles experimentally\.$" -d"^The runic sigla \'% !\^\' fade away\.\. leaving you feeling strange\.$"
/prdefprot -i"eskin"	-n"ESkin"	-l"Earth Skin" -M -s -r -u"^You feel your skin harden\.$" -d"^Your skin (returns to its original texture|feels softer)\.$"
/prdefprot -i"eblood"	-n"EBlood"	-l"Earth Blood" -A" traces? icy blue runes on the ground with" -B" is surrounded by a sudden cloudburst" -u"An icy chill runs through your veins." -d"The runic sigla \'!( *)\' fade away.. leaving you feeling strange."
/prdefprot -i"vmant"	-n"Vmant"	-l"Vine Mantle" -M -r -s -u"^Vines entangle your body\.$" -d"^The vines (around your body shrink|crumble to dust)\.$"
/prdefprot -i"regen"	-n"Regen"	-l"Regeneration" -r -u"^You feel your metabolism speed up\.$" -d"^You no longer have an? active regeneration spell on you\.$"

;; ---- Bard ----
/prdefprot -i"warez"	-n"WarEns"	-l"War Ensemble" -A"\'War is TOTAL massacre, sport the war, war SUPPOORT!!!\'" -u"You feel full of battle rage! Victory is CERTAIN!" -d"The effect of war ensemble wears off."
/prdefprot -i"emelody"	-n"EMelody"	-l"Embracing Melody" -r -u"^(You embrace yourself with your|[A-Z][a-z]+ wraps you into an embracing) melody\.$" -d"^The embracing melody subsides, leaving you longing for more\.$"
/prdefprot -i"afavour"	-n"AFav"	-l"Arches Favour" -u"You feel optimistic about your near future!" -d"You no longer have Arches Favour on you. You feel sad."
/prdefprot -i"cthought"	-n"CT"		-l"Clandestine Thoughts" -u"[clandestine thought]: activated. Snooping activities will be terminated and reported." -d"[clandestine thought]: scanning ended. Shielding from snoopers no longer active."
/prdefprot -i"motma"	-n"MotMA"	-l"Melody of the Misadventurer" -z -A"^The melody sung by .* descends upon you like a weight on your shoulders\.$" -u"You feel miserable." -d"You feel like a weight has been lifted from your mental shoulders."

;; ---- LoC ----
/prdefprot -i"drage"	-n"DRage"	-l"Destructive Rage" -r -A"^A veiled darkness descends over your eyes.  Sounds are oddly distorted" -u"but wreaking havoc on all that stands before you\.$" -d"^Your massive build-up of rage slowly dissipates leaving you drained"

;; ---- Conjurer::Basic Prots ----
/prdefprot -i"sop"	-n"SoP"		-l"Shield of Protection" -A" \'nsiiznau\'$" -u"You feel a slight tingle." -d"You feel more vulnerable now."
/prdefprot -i"bimage"	-n"BImg"	-l"Blurred Image" -A" \'ziiiuuuuns wiz\'$" -u"You feel a powerful aura." -d"You feel less invisible."
/prdefprot -i"disp"	-n"Disp"	-l"Displacement" -A" \'diiiiuuunz aaanziz\'$" -r -u"^You feel a powerful aura\.$" -d"^You(r displacement spell wears off| feel much less invisible)\.$"
/prdefprot -i"iwill"	-n"IWill"	-l"Iron Will" -u"You feel protected from being stunned." -d"You feel no longer protected from being stunned."
/prdefprot -i"rentr"	-n"REntrop"	-l"Resist Entropy" -u"You feel your life force expanding." -d"You feel your hair is getting grayer."
/prdefprot -i"rdisint"	-n"RDisInt"	-l"Resist Disintegrate" -u"You feel very firm." -d"You feel somewhat weaker."
/prdefprot -i"rdisp"	-n"RDisp"	-l"Resist Dispel" -u"You feel extra sticky for protection." -d"You feel less sticky."

;; ---- Conjurer::Minor Typeprots ----
/prdefprot -i"c_phys"	-n"Fabs"	-l"Force Absorption"	-p -A"ztonez des deckers" -d"skin brown"
/prdefprot -i"c_acid"	-n"cAcid"	-l"Corrosion Shield"	-p -A"sulphiraidzik hydrochloodriz gidz zuf" -d"disgusting yellow"
/prdefprot -i"c_poison"	-n"cPois"	-l"Toxic Dilution"	-p -A"morri nam pantoloosa" -d"green"
/prdefprot -i"c_elec"	-n"cElec"	-l"Energy Channeling"	-p -A"kablaaaammmmm bliitz zundfer" -d"crackling blue"
/prdefprot -i"c_asphyx"	-n"cAsph"	-l"Ether Boundary"	-p -A"qor monoliftus" -d"dull black"
/prdefprot -i"c_fire"	-n"cFire"	-l"Heat Reduction"	-p -A"hot hot not zeis daimons" -d"burning red"
/prdefprot -i"c_magic"	-n"cMana"	-l"Magic Dispersion"	-p -A"meke tul magic" -d"golden"
/prdefprot -i"c_psi"	-n"cPsi"	-l"Psychic Sanctuary"	-p -A"toughen da mind reeez un biis" -d"transparent"
/prdefprot -i"c_cold"	-n"cCold"	-l"Frost Insulation"	-p -A"skaki barictos yetz fiil" -d"cold white"

;; ---- Conjurer::Major Typeprots ----
/prdefprot -i"m_phys"	-n"AoA"		-l"Armour of Aether"	-P -A"fooharribah inaminos cantor" -d"crystal clear"
/prdefprot -i"m_acid"	-n"GAcid"	-l"Acid Shield"		-P -A"hfizz hfizz nglurglptz" -d"bubbling yellow"
/prdefprot -i"m_poison"	-n"GPois"	-l"Shield of Detoxification"	-P -A"nyiaha llaimay exchekes ployp" -d"slimy olive green"
/prdefprot -i"m_elec"	-n"GElec"	-l"Lightning Shield"	-P -A"ohm" -d"neon purple"
/prdefprot -i"m_asphyx" -n"GAsph"	-l"Aura of Wind"	-P -A"englobo globo mc\'pop" -d"swirling foggy white"
/prdefprot -i"m_fire"	-n"GFire"	-l"Flame Shield"	-P -A"huppa huppa tiki tiki" -d"crackling red-orange"
/prdefprot -i"m_magic"	-n"GMana"	-l"Repulsor Aura"	-P -A"shamarubu incixtes delfo" -d"flickering golden"
/prdefprot -i"m_psi"	-n"GPsi"	-l"Psionic Phalanx"	-P -A"all for one, gather around me" -d"misty pale blue"
/prdefprot -i"m_cold"	-n"GCold"	-l"Frost Shield"	-P -A"nbarrimon zfettix roi" -d"frosty blue-white"

;; ---- Folklorist ----
/prdefprot -i"minprot"	-n"MinorP"	-l"Minor Protection"			-u"You feel slightly protected." -d"The minor protection fades away."
/prdefprot -i"zooprot"	-n"ZooP"	-l"Zoological Protection"		-F -u" from animals" -d"zoological"
/prdefprot -i"cryzprot"	-n"CrypZP"	-l"Cryptozoological Protection"	-F -u" from mythical creatures" -d"cryptozoological"
/prdefprot -i"kineprot"	-n"KineP"	-l"Kinemortological Protection"	-F -u" from undead creatures" -d"kinemortological"
/prdefprot -i"raciprot"	-n"RacP"	-l"Racial Protection"			-h -F -u" from [a-z -]+s" -d"racial"

;; ---- Lunar Defender ---
;/prdefprot -i"lunshield"	-n"LunS"	-l"Lunacy Shield"	-u"A translucent shield appears around you, flashes multiple colours, then vanishes." -d""

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Unstun (NS)
/prdefprot -i"unstun"	-n"Uns"	-l"Unstun" -h -q -e

/gdef -i -F -aCgreen -mregexp -t"^[A-Z][a-z]+\'s chanting appears to do absolutely nothing.$" rec_unstun_on =\
	/gprot_on unstun%;/set prot_unstun_w=0

/gdef -i -F -aCgreen -msimple -t"You are STUNNED." rec_stun_start =\
	/set stun_st=on%;/gprot_off unstun

/gdef -i -F -aCgreen -mregexp -t" paralyzes you with its mind\.$" rec_paralyzed_start =\
	/gspell_interrupt%;/gskill_interrupt%;/set stun_st=on%;/gprot_off unstun

/gdef -i -F -aCgreen -msimple -t"You are no longer stunned." rec_stun_end =\
	/set stun_st=off%;/msr No longer stunned

/gdef -i -F -aCgreen -msimple -t"It doesn't hurt as much as it normally does!" rec_unstun_off =\
	/gprot_off unstun

/gdef -i -F -aCgreen -msimple -t"It doesn't hurt at all!" rec_unstun_notall =\
	/gspell_interrupt%;/gskill_interrupt%;\
	/set prot_unstun_w=$[prot_unstun_w+1]%;\
	/msr Unstun weakened [#%{prot_unstun_w}]%;\
	/gstatus_update


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mesmeric Threshold (NS)
/prdefprot -i"mthresh"	-n"MesmTh"	-l"Mesmeric Threshold" -h -q -e

/gdef -i -F -aCgreen -msimple -t"You feel too mesmerized to know pain as a supernatural trance takes over you." rec_mthresh_on =\
	/gprot_on mthresh%;/set prot_mthresh_w=0

/gdef -i -F -aCgreen -msimple -t"The dreamlike feeling improving your concentration subsides." rec_mthresh_off =\
	/gprot_off mthresh

/gdef -i -F -aCgreen -msimple -t"You get hit HARD, but continue your actions under a supernatural trance." rec_mthresh_weak =\
	/set prot_mthresh_w=$[prot_mthresh_w+1]%;\
	/msr Mesmeric Threshold weakened [#%{prot_mthresh_w}]%;\
	/gstatus_update


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Special curse tracking timers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set lst_cursed=
/prdeftoggle -n"cursewarn"	-d"Warn about soon expiring curses"

;; Clear curse prerequisites
/def -i prclearcurses =\
	/while ({#})\
		/set curse_%{1}_p=0%;\
		/shift%;\
	/done

;; Define a curse
; -i"<idname>" Unique identifier
; -n"<short name>" Curse short name
; -l"<long name>" Long name
; -u"<up message>" Up message (regexp)
; -d"<down message>" Optional down message (regexp)
; -A"<prerequisite #1>" Optional curse "up" prerequisite #1 (regexp)
; -B"<prerequisite #2>"
; -C"<prerequisite #3>"
; -U# Up message regexp subexpression index for curse target name
; -D# Down message regexp subexpression index for curse target name
; -t# Final expiration time in seconds (e.g. absolute maximum time the curse may be up)

/def -i prdefcurse =\
	/if (!getopts("i:n:l:A:B:C:u:d:t#U#D#", "")) /gerror Invalid curse definition!%;/break%;/endif%;\
	/if (opt_i=~"") /gerror Missing curse vardef (-i) in definition.%;/break%;/endif%;\
	/if (opt_n=~"") /gerror Missing curse name (-n) in '%{opt_i}' definition.%;/break%;/endif%;\
	/if (opt_l=~"") /gerror Missing curse long desc (-l) in '%{opt_i}' definition.%;/break%;/endif%;\
	/if (opt_u!~"" & !opt_U) /gerror Missing -Ux from curse '%{opt_i}' definition.%;/break%;/endif%;\
	/if (opt_d!~"" & !opt_D) /gerror Missing -Dx from curse '%{opt_i}' definition.%;/break%;/endif%;\
	/if (opt_w > opt_t) /gerror Curse '%{opt_i}' (%{opt_n}) has expiration warning longer than max duration (-w > -t)!%;/break%;/endif%;\
	/test prlist_insert("lst_curses", opt_i)%;\
	/set curse_%{opt_i}_n=%{opt_n}%;\
	/set curse_%{opt_i}_l=%{opt_l}%;\
	/set curse_%{opt_i}_p=0%;\
	/if (opt_t)\
		/set curse_%{opt_i}_m=%{opt_t}%;\
	/else \
		/set curse_%{opt_i}_m=-1%;\
	/endif%;\
	/let _plevel=0%;\
	/if (opt_A!~"") /let _plevel=1%;/def -i -F -p9999 -mregexp -t'%{opt_A}' rec_%{opt_i}_A=/prclearcurses %%{lst_curses}%%;/set curse_%{opt_i}_p=1%;/endif%;\
	/if (opt_B!~"") /let _plevel=2%;/def -i -F -p9999 -mregexp -t'%{opt_B}' rec_%{opt_i}_B=/if (curse_%{opt_i}_p == 1) /prclearcurses %%{lst_curses}%%;/set curse_%{opt_i}_p=2%%;/endif%;/endif%;\
	/if (opt_C!~"") /let _plevel=3%;/def -i -F -p9999 -mregexp -t'%{opt_C}' rec_%{opt_i}_C=/if (curse_%{opt_i}_p == 2) /prclearcurses %%{lst_curses}%%;/set curse_%{opt_i}_p=3%%;/endif%;/endif%;\
	/if (_plevel > 0)\
		/def -i -F -p9999 -mregexp -t'%{opt_u}' gcurse_%{opt_i}_on=\
			/if (curse_%{opt_i}_p==%{_plevel})\
				/test gcurse_on("%{opt_i}",{P%{opt_U}})%%;\
			/endif%%;\
			/set curse_%{opt_i}_p=0%;\
	/else \
		/def -i -F -p9999 -mregexp -t'%{opt_u}' gcurse_%{opt_i}_on=\
			/set curse_%{opt_i}_p=0%%;\
			/test gcurse_on("%{opt_i}",{P%{opt_U}})%;\
	/endif%;\
	/if (opt_d!~"")\
		/def -i -F -p9999 -mregexp -t'%{opt_d}' gcurse_%{opt_i}_off=\
			/test gcurse_off("%{opt_i}",{P%{opt_D}})%;\
	/endif

;; Check if given curse ID is still existing
/def -i gcurse_check =\
	/return regmatch(strcat("(^| )",replace("|","\|",{1}),"( |$$)"), lst_cursed)

;; Expiration macro
/def -i gcurse_expire =\
	/let _cid=%{2}%;/let _ctgt=%{1}%;/let _cinfo=%{3}%;\
	/if (gcurse_check(_cinfo))\
		/test prlist_delete("lst_cursed", _cinfo)%;\
		/let _clong=$[prgetval(strcat("curse_",_cid,"_n"))]%;\
		/msr %{_clong} on %{_ctgt} expired!%;\
	/endif

;; Delete matching curses
/def -i gcurse_delete =\
	/let _cid=%{1}%;/shift%;\
	/let _ctgt=%{1}%;/shift%;\
	/let _ctmp=%;\
	/while ({#})\
		/if (!regmatch(strcat("^",_ctgt,"\|",_cid,"\|"),{1}))\
			/let _ctmp=%{1} %{_ctmp}%;\
		/endif%;\
		/shift%;\
	/done%;\
	/result _ctmp

;; Expiration warning
/def -i gcurse_warn =\
	/if (opt_cursewarn!~"on") /break%;/endif%;\
	/let _cid=%{2}%;/let _ctgt=%{1}%;\
	/let _ctime=%{3}%;/let _cinfo=%{4}%;\
	/if (gcurse_check(_cinfo))\
		/let _clong=$[prgetval(strcat("curse_",_cid,"_n"))]%;\
		/msr %{_clong} on %{_ctgt} expiring in %{_ctime} seconds!%;\
	/endif

;; Turn a curse "on", with some sanity checking
/def -i gcurse_on =\
	/let _cid=%{1}%;\
	/let _ctgt=%{2}%;\
	/let _ccmp=(^| )%{_ctgt}( |$$)%;\
	/let _clong=$[prgetval(strcat("curse_",_cid,"_l"))]%;\
	/if (_clong=~"") /gerror Invalid curse ID '%{_cid}'%;/break%;/endif%;\
	/if (!regmatch(_ccmp, gparty_members))\
		/let _ctmp=$[replace(" ","§",_ctgt)]%;\
		/set lst_cursed=$(/gcurse_delete %{_cid} %{_ctmp} %{lst_cursed})%;\
		/let _cexpire=$[prgetval(strcat("curse_",_cid,"_m"))]%;\
		/let _cwarn=$[prgetval(strcat("curse_",_cid,"_w"))]%;\
		/let _cinfo=$[strcat(_ctmp,"|",_cid,"|",time())]%;\
		/test prlist_insert("lst_cursed", _cinfo)%;\
		/msr %{_ctgt} has been %{_clong}!%;\
		/eval /repeat -%{_cexpire} 1 /test gcurse_expire("%{_ctgt}", "%{_cid}", "%{_cinfo}")%;\
		/if (opt_cursewarn=~"on")\
			/let _cwarn=$[trunc(_cexpire * 0.20)]%;\
			/eval /repeat -$[_cexpire - _cwarn] 1 /test gcurse_warn("%{_ctgt}", "%{_cid}", %{_cwarn}, "%{_cinfo}")%;\
		/endif%;\
	/else \
		/msq Ignoring partymember %{_ctgt} being %{_clong}.%;\
	/endif
	
/def -i gcurses_do_get =\
	/let _ctime=$[time()]%;\
	/let _cursestr=%;\
	/while ({#})\
		/let _ctmp=%{1}%;\
		/if (regmatch("^(.+?)\|([a-z][a-z0-9]+)\|([0-9.]+)$",_ctmp))\
			/let _ctmp=$[prgetval(strcat("curse_",{P2},"_n"))] @ $[replace("§"," ",{P1})] ($[prgettime(_ctime - {P3})])%;\
			/if (_cursestr!~"") /let _cursestr=%{_cursestr} | %{_ctmp}%;/else /let _cursestr=%{_ctmp}%;/endif%;\
		/else \
			/gerror Invalid curse entry '%{_ctmp}'. Internal error.%;\
		/endif%;\
		/shift%;\
	/done%;\
	/result _cursestr

/def -i gcurses_get =\
	/let _ctmp=$(/gcurses_do_get %{lst_cursed})%;\
	/if (_ctmp!~"")\
		/return _ctmp%;\
	/else \
		/return "No curses tracked."%;\
	/endif


;; Curse reporting
/def -i curses = /msq Curses: $[gcurses_get()]

/prdefgbind -s"curses" -c"/curses"

/def -i -p9999 -mregexp -t"^(You twirl before yourself|[A-Z][a-z]+ twirls before you)\.$" gcurses_twirl =\
	/msr $[gcurses_get()]


;; Curse definitions
/prdefcurse -i"touch" -n"STouch" -l"spider touched" -t600	\
	-U1 -u"^(.+) turns very pale and shivers as if (he|she|it) had just been poisoned\.$"

/prdefcurse -i"cot" -n"CoT" -l"cursed/cotted" -t600		\
	-A" utters? the magic words \'nilaehz temnahecne neg\'"	\
	-U1 -u"^(.+) turns very pale!$"

/prdefcurse -i"degen" -n"Degen" -l"degenerated" -t600		\
	-A" utters? the magic words \'kewa dan dol rae hout\'"	\
	-U1 -u"^(.+) appears weakened!$"



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Skill and skill-status reporting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; skill_t	- timestamp of when skill started
; skill_st	- 'on' during skill "concentration" phase, off when skill goes off
; skill_st2	- 'off' during "concentration", on when skill goes off
;
; cast_info	- empty for no cast/skill going on, 'SP' for spells, 'SK' for skills
; cast_info_n	- name of skill/spell currently going on
; cast_info_t	- target of skill/spell (empty if no target)


;; Display information about current skill/spell
/def -i gshow_info =\
	/if (cast_info_t!~"")\
		/msq '%{cast_info_n}' -> %{cast_info_t}%;\
	/else \
		/if (battle_target!~"")\
			/msq '%{cast_info_n}' -> (%{battle_target})%;\
		/else \
			/msq '%{cast_info_n}'%;\
		/endif%;\
	/endif

;; Start of skill
/def -i -p9999 -msimple -t"You start concentrating on the skill." gskill_start =\
	/set skill_t=$[time()]%;\
	/set cnt_skills=$[cnt_skills+1]%;\
	/set skill_st=on%;\
	/set skill_st2=off%;\
	/set cast_info=SK%;/set cast_info_n=%;/set cast_info_t=%;@@cast info%;\
	/msk @{BCyellow} ---- SKILL START ---- @{n} (@{Cyellow}%{cnt_skills}@{n})%;\
	/gstatus_update%;/prexecfuncs %{event_skill_start}


;; Skill done
/def -i -p9999 -msimple -t"You are prepared to do the skill." gskill_end =\
	/set cnt_sskills=$[cnt_sskills+1]%;\
	/set skill_st=off%;\
	/set skill_st2=on%;\
	/set cast_info=%;\
	/set cnt_sktime=$[cnt_sktime+time() - skill_t]%;\
	/msk @{Cbggreen} ---- SKILL DONE ---- @{n} @{Cyellow}$[prgetstime(skill_t)]@{n}%;\
	/gstatus_update%;/prexecfuncs %{event_skill_done}


;; Cast info
/def -i -p9999 -ag -mregexp -t"^You are using \'([a-z ]+)\'.$" gskill_info1 =\
	/set cast_info_n=%{P1}%;/set cast_info_t=%;/gshow_info%;\
	/if (opt_rskills=~"on") @@emote is using '%{P1}'%;/endif

/def -i -p9999 -ag -mregexp -t"^You are using \'([a-z ]+)\' at \'(.+?)\'.$" gskill_info2 =\
	/set cast_info_n=%{P1}%;/set cast_info_t=%{P2}%;/gshow_info%;\
	/if (opt_rskills=~"on") @@emote is using '%{P1}' -> '%{P2}'%;/endif


;; Skill fumbled
/def -i gskill_fumble =\
	/if (skill_st2=~"on")\
		/set cnt_sskills=$[cnt_sskills - 1]%;\
		/set cnt_fuskills=$[cnt_fuskills+1]%;\
		/set skill_st2=off%;\
	/endif


;; Skill failed
/def -i gskill_fail =\
	/if (skill_st2=~"on")\
		/set cnt_sskills=$[cnt_sskills - 1]%;\
		/set cnt_fskills=$[cnt_fskills+1]%;\
		/set skill_st2=off%;\
	/endif


;; Skill interrupted
/def -i gskill_interrupt =\
	/if (skill_st=~"on")\
		/msq @{Cbgred} ---- SKILL INTERRUPTED ---- @{n}%;\
		/set cnt_iskills=$[cnt_iskills+1]%;\
		/set skill_st=off%;\
		/set cast_info=%;\
		/gstatus_update%;\
		/prexecfuncs %{event_skill_intr}%;\
	/endif

;; Skill stopped
/def -i gskill_stopped =\
	/if (skill_st=~"on")\
		/msq @{Cbgred} ---- SKILL STOPPED ---- @{n}%;\
		/set cnt_iskills=$[cnt_iskills+1]%;\
		/set skill_st=off%;\
		/set cast_info=%;\
		/gstatus_update%;\
		/prexecfuncs %{event_skill_stop}%;\
	/endif

/def -i -p9999 -ag -mregexp -t"^(Your movement prevents you from doing the skill|You lose your concentration and cannot do the skill)\.$" gskill_interrupt1 =\
	/set skill_st2=on%;/gskill_interrupt

/def -i -p9999 -ag -mregexp -t"^You (decide to change the skill to (a )?new one|stop concentrating on the skill and begin searching for a proper place to rest)\.$" gskill_stopped1 =\
	/set skill_st2=off%;/gskill_stopped

/def -i -p9999 -ag -mregexp -t"^You break your skill attempt\.$" gskill_stopped2 =\
	/set skill_st2=on%;/gskill_stopped


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ceremony
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdefgbind -s"cere"	-c"/ceremony"		-n

/def -i -p9999 -mregexp -t"^You (perform the ceremony|feel your staff touching your mind)\.$" gceremony_on =\
	/set ceremony_st=on%;/gstatus_update

/def -i -p9999 -ag -msimple -t"You have an unusual feeling as you cast the spell." gceremony_off =\
	/set ceremony_st=off%;/set ceremony_st2=on

;@command /ceremony
;@desc Perform skill 'ceremony', but only if ceremony is not already "active".
/def -i ceremony =\
	/if (ceremony_st=~"on")\
		/msq @{BCwhite}Ceremony@{n} @{Cyellow}already in effect!@{n}%;\
	/else \
		@@use ceremony%;\
	/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Battle, enemy shape
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Report shape
;@command /shape
;@desc Reports the last catched shape of a opponent (monster) in battle.
;@desc This does not work too well if you were fighting more than one opponents.
/def -i shape =\
	/if (battle_target!~"")\
		/msr %{battle_shape} (%{battle_target})%;\
	/else \
		/msr %{battle_shape}%;\
	/endif%;\

;; Define shape formatting string
/prdefvar -n"fmt_shape" \
	-v"@{Cgreen}%%{4} %%{5}@{n} [@{%%{1}}%%{2}@{n}] (@{%%{1}}%%{3}%%%@{n})" \
	-c"Format string for shape reporting. %{1}=shape colour, %{2}=shape short name, %{3}=percentage, %{4}=target name, %{5}=shape long name"

;; Update/set new shape
/eval /def -i gbattle_ss =\
	/substitute -p %{fmt_shape}%%;\
	/if (battle_st)\
		/set battle_pshape=%%{battle_shape}%%;\
		/set battle_shape=%%{2}%%;\
	/endif

;; (Re)initialize battle
/def -i gbattle_init =\
	/set battle_round=1%;\
	/set battle_shape=es%;\
	/set battle_pshape=es%;\
	/set battle_st=1%;\
	/prexecfuncs %{event_battle_first_round}

/def -i gbattle_end =\
	/if (battle_st)\
		/set battle_st=0%;\
		/set battle_target=%;\
		/prexecfuncs %{event_battle_end}%;\
	/endif

;; New round
/def -i gbattle_round =\
	/set battle_round=$[battle_round+1]%;\
	/set battle_round_t=$[time()]%;\
	/if (!battle_st) /gbattle_init%;/endif%;\
	/if (set_round!~"") %{set_round}%;/endif%;\
	/if (opt_autopss=~"on") /pss%;/endif%;\
	/prexecfuncs %{event_battle_round}%;\
	/gstatus_update

/def -i -F -mregexp -t"^\*{10,25} (Round \d+|Round \d+ \(\d+\)) \*{10,25}$" gbattle_round1 =\
	/gbattle_round

/def -i -F -msimple -t"*****************************************************" gbattle_round2 =\
	/gbattle_round


;; Grab target via several methods
/def -i -F -p9999 -mregexp -t"^You are now targetting ([A-Za-z ,.'-]+)\.$" gbattle_target3 =\
	/msk @{BCyellow}Targetting@{n} -> @{BCred}%{P1}@{n}%;\
	/set battle_target=%{1}

;; Get shape
/def -i -F -p9999 -mregexp -t"^([A-Za-z ,.'-]+) is (in (a )?)?(excellent shape|good shape|slightly hurt|noticeably hurt|not in a good shape|bad shape|very bad shape|near death)\.$" gbattle_shape1 =\
	/if ({P4}=~"excellent shape") /test gbattle_ss("BCgreen","es","90-100",{P1},{P4})%;\
	/elseif ({P4}=~"good shape") /test gbattle_ss("Cgreen","gs","80-90",{P1},{P4})%;\
	/elseif ({P4}=~"slightly hurt") /test gbattle_ss("BCcyan","sh","65-80",{P1},{P4})%;\
	/elseif ({P4}=~"noticeably hurt") /test gbattle_ss("Ccyan","nh","50-65",{P1},{P4})%;\
	/elseif ({P4}=~"not in a good shape") /test gbattle_ss("BCyellow","nigs","35-50",{P1},{P4})%;\
	/elseif ({P4}=~"bad shape") /test gbattle_ss("Cyellow","bs","20-35",{P1},{P4})%;\
	/elseif ({P4}=~"very bad shape") /test gbattle_ss("BCred","vbs","10-20",{P1},{P4})%;\
	/elseif ({P4}=~"near death") /test gbattle_ss("Cred","nd","0-10",{P1},{P4})%;/endif

/def -i -F -p9999 -mregexp -t"^([A-Za-z ,.'-]+) is (in (a )?)?(excellent shape|good shape|slightly hurt|noticeably hurt|not in a good shape|bad shape|very bad shape|near death) \(([0-9]+).\)\.$" gbattle_shape2 =\
	/if ({P4}=~"excellent shape") /test gbattle_ss("BCgreen","es",{P5},{P1},{P4})%;\
	/elseif ({P4}=~"good shape") /test gbattle_ss("Cgreen","gs",{P5},{P1},{P4})%;\
	/elseif ({P4}=~"slightly hurt") /test gbattle_ss("BCcyan","sh",{P5},{P1},{P4})%;\
	/elseif ({P4}=~"noticeably hurt") /test gbattle_ss("Ccyan","nh",{P5},{P1},{P4})%;\
	/elseif ({P4}=~"not in a good shape") /test gbattle_ss("BCyellow","nigs",{P5},{P1},{P4})%;\
	/elseif ({P4}=~"bad shape") /test gbattle_ss("Cyellow","bs",{P5},{P1},{P4})%;\
	/elseif ({P4}=~"very bad shape") /test gbattle_ss("BCred","vbs",{P5},{P1},{P4})%;\
	/elseif ({P4}=~"near death") /test gbattle_ss("Cred","nd",{P5},{P1},{P4})%;/endif

;; Monster RIP does not necessarily end battle, but let's reset
;; the target at least.
/gdef -i -p9999 -aCgreen -mregexp -t"^[A-Za-z ,.'-]+ is DEAD, R.I.P.$" gbattle_rip =\
	/set battle_target=%;\
	/prexecfuncs %{event_battle_rip}

;; End of battle, probably. We trust here that the last 'scan' (if any)
;; occurs after monster has died. If this is not the case, the heartbeat
;; function should take care of it eventually.
/gdef -i -p9999 -aCyellow -msimple -t"You are not in combat right now." gbattle_nocombat =\
	/gbattle_end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EXPERIMENTAL heartbeat / tick / timed battle end handling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set heartbeat_res=0.05
/set heartbeat_last=-1
/set heartbeat_last_real=-1
/set heartbeat_tick_t=-1
/set heartbeat_jitter=0.5
/set heartbeat_avg=3
/set heartbeat_avg_last=3 3 3 3 3

;; Check given value against heartbeat average and jitter bounds
/def -i ghbjitter =\
	/return ({1} >= heartbeat_jitter & {1} >= heartbeat_avg - heartbeat_jitter & {1} <= heartbeat_avg + heartbeat_jitter)

;; Return all but first values of given arguments
/def -i prnth = /result "%{-1}"

;; Compute simple average of given argument values
/def -i praverage =\
	/let _vsum=0.0%;/let _vnum=%{#}%;\
	/while ({#}) /let _vsum=$[_vsum+{1}]%;/shift%;/done%;\
	/result (_vsum / _vnum)


/def -i gheartbeat_timer =\
	/if (battle_st & time() - battle_round_t > 5)\
		/gbattle_end%;\
	/endif%;\
	/if (time() - heartbeat_last >= heartbeat_avg + 2 * heartbeat_res)\
		/gheartbeat_do force%;\
	/endif%;\
	/if (heartbeat_cnt >= 10)\
		/set heartbeat_discard=0%;\
		/gheartbeat_tick FORCE%;\
	/endif

/def -i gheartbeat_tick =\
	/let _tdelta=$[time() - heartbeat_tick_t]%;\
	/if (hb_debug)/msq TICK %{1} (cnt=%{heartbeat_cnt}, delta=%{_tdelta})%;/endif%;\
	/set heartbeat_tick_t=$[time()]%;\
	/set heartbeat_cnt=0%;\
	/gstatus_update


/def -i gheartbeat_do =\
	/let _hbtime=$[time()]%;\
	/if ({1}=~"real")\
		/let _hblast=%{heartbeat_last_real}%;\
		/set heartbeat_last_real=%{_hbtime}%;\
		/set heartbeat_last=%{_hbtime}%;\
		/let _hbdelta=$[_hbtime - _hblast]%;\
		/if (_hblast > 0 & ghbjitter(_hbdelta))\
			/set heartbeat_avg_last=$(/prnth %{heartbeat_avg_last} %{_hbdelta})%;\
			/set heartbeat_avg=$(/praverage %{heartbeat_avg_last})%;\
		/endif%;\
		/set heartbeat_cnt=$[heartbeat_cnt+1]%;\
		/if (hb_debug) /msq HB_DO[%{1}]: %{_hbdelta} / %{heartbeat_avg} avgs={%{heartbeat_avg_last}}%;/endif%;\
		/gstatus_update%;\
	/else \
		/let _hbdelta=$[_hbtime - heartbeat_last]%;\
		/set heartbeat_last=%{_hbtime}%;\
		/if (hb_debug) /msq HB_DO[%{1}]: %{_hbdelta} / %{heartbeat_avg}%;/endif%;\
		/if (ghbjitter(_hbdelta))\
			/set heartbeat_cnt=$[heartbeat_cnt+1]%;\
			/gstatus_update%;\
		/endif%;\
	/endif


/def -i gheartbeat_subtick =\
	/gstatus_update%;\
	/set heartbeat_subtick=$[heartbeat_subtick + 1]


/def -i -ag -msimple -t"Dunk dunk" gheartbeat_dunk =\
	/gheartbeat_do real%;\
	/set heartbeat_subtick=0%;\
	/set heartbeat_pid=$(/grepeat -n -1 3 /gheartbeat_subtick)


/def -i gheartbeat_sc =\
	/if (heartbeat_discard)\
		/set heartbeat_discard=0%;\
		/return%;\
	/endif%;\
	/if (status_sp - status_oldsp > 30 | status_ep - status_oldep > 5)\
		/substitute -p %{status_qline} @{Cgreen}[%{heartbeat_cnt}]@{n}%;\
		/gheartbeat_tick NORMAL%;\
	/endif


;; Detect certain events that cause potentially "false" ticks to occur.
;; Of course, sometimes these also contain the real tick, but can't help that.
/def -i -F -mregexp -t"^(Your blow impacts with chaotic force...|You feel like .+? healed you a bit\.|The crystal throbs faintly, healing some of your wounds\.|The fire.s warmth soothes you\.|The fire.s warmth feels especially soothing\.|The shimmering blue forcefield.s safety soothes you\.)$" gheartbeat_discard =\
	/set heartbeat_discard=1%;\
	/if (hb_debug)/msq Discarding next sc%;/endif


/test prlist_insert("event_sc_printed", "gheartbeat_sc")
/test prlist_insert("event_spell_done", "gheartbeat_do")
/test prlist_insert("event_skill_done", "gheartbeat_do")
/test prlist_insert("event_spell_round", "gheartbeat_do")
/eval /if (!heartbeat_timer) /repeat -%{heartbeat_res} i /gheartbeat_timer%;/endif
/set heartbeat_timer=1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Consider reporting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i -mregexp -t"^You take a close look at (.*) in comparison to yourself\.$" gconsider_rep0 =\
	/set cons_st=1%;/set cons_pr=%;/set cons_exp=%;/set cons_name=%{P1}

/def -i -Econs_st -ag -mregexp -t"^You would get (.*) experience for " gconsider_rep1 =\
	/set cons_exp=%{P1}

/def -i gdefconspr =\
	/def -i -Econs_st -ag -mregexp -t"^[A-Za-z<> ,.'-]+ %{2}$$" gconsider_pr%{1} =\
		/set cons_pr=%{3}

/test gdefconspr(1, "has a soft skin.", "soft", 0)
/test gdefconspr(2, "seems to have a bit hardened skin.", "bit hardened", 0)
/test gdefconspr(3, "has somewhat hardened skin.", "somewhat hardened", 0)
/test gdefconspr(4, "skin could fold up a rapier!", "could fold up a rapier!", 0)
/test gdefconspr(5, "skin seems to be virtually impenetrable!", "impenetrable!", 0)

/def -i -ag -mregexp -t"^The final estimation is that (.*)$" gconsider_final =\
	/if (cons_st) \
		/let cons_val=%{P1}%;\
		/if (regmatch("doesn't look", cons_val)) /set cons_opp=dlvd%;\
		/elseif (regmatch("fair opponent", cons_val)) /set cons_opp=fair%;\
		/elseif (regmatch("nearly equal", cons_val)) /set cons_opp=equal%;\
		/elseif (regmatch("quite skilled", cons_val)) /set cons_opp=skilled%;\
		/elseif (regmatch("much stronger", cons_val)) /set cons_opp=much stronger%;\
		/elseif (regmatch("has such bulging", cons_val)) /set cons_opp=DANGEROUS%;\
		/else /set cons_opp=%{cons_val}%;/endif%;\
		/if (cons_exp!~"") /let _ctmps=%{cons_exp} exp%;/else /let _ctmps=%;/endif%;\
		/if (cons_opp!~"")\
			/if (_ctmps!~"")\
				/let _ctmps=%{_ctmps}, %{cons_opp}%;\
			/else \
				/let _ctmps=%{cons_opp}%;\
			/endif%;\
		/endif%;\
		/if (cons_pr!~"") /let _ctmps=%{_ctmps} (PR: %{cons_pr})%;/endif%;\
		/msr [$[substr(cons_name,0,15)]]: %{_ctmps}%;\
	/endif%;\
	/set cons_st=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Combat damage analysis
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gcda_report =\
	/if (opt_rcda=~"on")\
		/msr [%{1}]: %{2}%% resist against %{3}%;\
	/else \
		/msq [@{Cgreen}%{1}@{n}]: @{BCcyan}%{2}@{n}%% resist against @{BCyellow}%{3}@{n}%;\
	/endif

/def -i -p9999 -ag -mregexp -t"^([A-Za-z ,.'-]+) is defenseless against ([a-zA-Z]+) damage\.$" gcda_resist0 =\
	/test gcda_report({P1},0,{P2})

/def -i -p9999 -ag -mregexp -t"^([A-Za-z ,.'-]+) seems to be almost defenseless against ([a-zA-Z]+) damage\.$" gcda_resist20 =\
	/test gcda_report({P1},20,{P2})

/def -i -p9999 -ag -mregexp -t"^([A-Za-z ,.'-]+) has some resistance against ([a-zA-Z]+) damage\.$" gcda_resist40 =\
	/test gcda_report({P1},40,{P2})

/def -i -p9999 -ag -mregexp -t"^([A-Za-z ,.'-]+) seems to be moderately resistant against ([a-zA-Z]+) damage\.$" gcda_resist60 =\
	/test gcda_report({P1},60,{P2})

/def -i -p9999 -ag -mregexp -t"^([A-Za-z ,.'-]+) has good resistance against ([a-zA-Z]+) damage\.$" gcda_resist80 =\
	/test gcda_report({P1},80,{P2})

/def -i -p9999 -ag -mregexp -t"^([A-Za-z ,.'-]+) seems almost immune against ([a-zA-Z]+) damage\.$" gcda_resist100 =\
	/test gcda_report({P1},100,{P2})


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Some special hilites and miscellaneous
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i msm = /if (opt_rmisc=~"on") /msr %*%;/endif

;; Highlite open containers, doors etc.
/glite -P2BCred -mregexp -t" (safe|chest|crate|vault|box|closet|money-box|coffer|scroll cabinet).* (\(open\))" glite_open
/glite -P2BCgreen -mregexp -t" (safe|chest|crate|vault|box|closet|money-box|coffer|scroll cabinet).* (\(closed\))" glite_closed

/gdef -i -F -p9999 -aBCred -mregexp -t"^This monster looks somehow familiar" glite_rapeprot =\
	/msr I have a rapeprot!

;; Lite skills/spells you can train with current exp
/def -i -F -p9999 -mregexp -t"^\| ([A-Z][A-Za-z ]+) +\| +([0-9]+) \| +([0-9]+) \| +([0-9]+) \| +([0-9]+) \|$" glite_trainexp =\
	/if ({P5} <= status_exp)\
		/if ({P2} < {P3})\
			/let _tcs=Cgreen%;\
		/else \
			/let _tcs=Cyellow%;\
		/endif%;\
	/else \
		/let _tcs=n%;\
	/endif%;\
	/substitute -p | @{%{_tcs}}%{P1}@{n} | @{%{_tcs}}$[pad({P2},3)]@{n} | @{%{_tcs}}$[pad({P3},3)]@{n} | @{%{_tcs}}$[pad({P4},3)]@{n} | @{%{_tcs}}$[pad({P5},11)]@{n} |


;; Ambush
/set ambush_t=0
/gdef -i -F -p9999 -aCred -msimple -t"You cannot leave, you have been AMBUSHED." gmisc_ambush1 =\
	/if (time()-ambush_t > 5)\
		/set ambush_t=$[time()]%;\
		/msm AMBUSHED!%;\
	/endif

;; Gained percentage in skill
/gdef -i -F -p9999 -aCgreen -mregexp -t"^You feel like you just got slightly better in (.*)$" gmisc_improved =\
	/mse improved in %{P1}

;; Floating disc
/gdef -i -F -p9999 -msimple -t"Your disc wavers dangerously." gmisc_fdweak =\
	/msm Disc falling!

/gdef -i -F -p9999 -msimple -t"You reload magical energy to the disc that is floating in the air." gmisc_fdreload =\
	/msm Disc reloaded.

;; Party leadership
/gdef -i -F -p9999 -aCred -msimple -t"You are the new leader of the party." gmisc_pleader =\
	@@party forcefollow all%;/msm Leading!

;; Poison removed
/gdef -i -F -p9999 -aCred -msimple -t"You feel the poison leaving your veins!" gmisc_poisonrm =\
	/msm Poison removed!

;; Uncon
/gdef -i -F -p9999 -ag -mregexp -t"^([A-Z][a-z]+) lapses into unconsciousness from severe loss of blood.$" gmisc_uncon =\
	/msq @{BCred}!!!@{n} @{BCwhite}%{P1}@{n} is @{BCgreen}UNCON@{n} @{BCred}!!!@{n}%;\
	/msm %{P1} is UNCON!


;; Warn about changes in party formation
/gdef -i -F -p9999 -ag -mregexp -t"^([A-Z][a-z]+) is now in the 1st row.$" gmisc_firstrow =\
	/msq @{BCred}!!!@{n} @{BCwhite}%{P1}@{n} @{BCyellow}is now in 1st row@{n} @{BCred}!!!@{n}%;\
	/if ({P1}=~set_plrname) /msm %{P1} is now in 1st row!%;/endif


;; Multicolored Demons (event)
/gdef -i -F -p9999 -aCred -mregexp -t"^A Nasty Multicolored Demon arrives with (a |)puff of red smoke\.$|^You suddenly have a terrible sensation about your moneypurse\.|^An odd looking cloud appears in the sky\. It looks just like \$\$\$\.|^For a while you thought you saw a grinning face of a leprechaun in the sky over |^You hear a booming voice from the sky: \'Go get them my beautiful demons\!\'" gmisc_mcdemon =\
	/msq @{BCwhite}*@{n} @{BCgreen}---@{n} @{BCred}MC DEMONS  EVENT!@{n} @{BCgreen}---@{n} @{BCwhite}*@{n}

;; Robin Hood
; Robin Hood took Ring of the Medusa labeled as (Ggr) <red glow> from Ggr.
/gdef -i -F -p9999 -aCred -mregexp -t"^Robin Hood arrives from " gmisc_robin1 =\
	/msq @{BCwhite}*@{n} @{BCgreen}---@{n} @{BCred}ROBIN HOOD EVENT!@{n} @{BCgreen}---@{n} @{BCwhite}*@{n}


;; Warn about invis tells and emotes
/def -i -F -p9999 -mregexp -t"^You tell ([^']*)" gmisc_invtell =\
	/if (opt_rmisc=~"on" & prot_invis > 0 & !regmatch("(monster)", {P1}))\
		/gwarning You are using 'tell' while INVISIBLE!%;\
	/endif

/def -i -F -p9999 -mregexp -t"^You emote to " gmisc_invemote =\
	/if (opt_rmisc=~"on" & prot_invis > 0)\
		/gwarning You are using 'emote' while INVISIBLE!%;\
	/endif

;; Etc
/prdeffail -k -f    -t"You fail to start the fire."

/def -i -ag -mregexp -t"^Your ([A-Za-z ]+) gets damaged; it's now in ([a-z]+) condition.$" gmisc_eqdamage =\
	/msq @{BCred}!!!@{n} @{BCwhite}%{P1}@{n} @{BCyellow}got damaged!@{n} (@{BCgreen}%{P2}@{n}) @{BCred}!!!@{n}%;\
	/msm NOTICE! %{P1} got damaged! (%{P2})

;; Resist curses and drains
/gdef -i -F -p1 -aCred -mregexp -t"^You (are not affected by|successfully resist a|successfully resist the) ([a-z ]+)\.$" gmisc_curseres =\
	/msm Resisted %{P2}!

/gdef -i -F -p1 -aCred -msimple -t"You feel as if you caught something, but don't feel worse at all." gmisc_curseres_nr =\
	/msm Resisted curse! (with NR)

;; Resist poison
/gdef -i -F -p1 -aCred -msimple -t"You SAVE against POISON." gmisc_poisonres =\
	/msm Saved against poison!

;; Psi scanning warnings
/gdef -i -F -ag -msimple -t"You get the feeling that someone is looking over your shoulder." gmisc_mglance =\
	/gwarning @{BCwhite}Mental Glance@{n} detected!

;; All-seeing eye
/gdef -i -F -ag -msimple -t"You have a feeling that somebody is watching you." gmisc_alleye =\
	/gwarning @{BCwhite}All-seeing eye@{n} detected!


;; Breaking equipment
/gdef -i -F -ab -p1 -F -mregexp -t"^Your (.+) breaks into zillions of pieces\.$" gmisc_break_eq =\
	/gwarning @{BCgreen}ALARM!@{n} @{BCred}HALB!@{n} @{BCyellow}ABUA!@{n} [ @{BCwhite}%{P1}@{n} ] @{BCred}broken!@{n}%;\
	/msm ALARM! HALB! ABUA! My %{P1} broke into pieces!


;; Banishment
/gdef -i -F -aBCred -mregexp -t"^You feel that (.+) doesn\'t enjoy your presence\.$" gmisc_banish0 =\
	/set mbanish_st=1

/def -i -F -ag -msimple -Embanish_st -t"Suddenly your eyes close and when you open them you see:" gmisc_banish1 =\
	/msr Got banished!%;/set mbanish_st=0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper for money purse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gpurse_add =\
	/if (regmatch(strcat("([0-9]+) ",{1}),gpursec_match))\
		/set gpursec_total=$[gpursec_total + ({P1} * {2})]%;\
		/let mptmp=@{BCwhite}$[prprettyvalstr({P1})]@{n} @{%{3}}%{1}@{n}%;\
		/if (gpursec_str!~"")\
			/set gpursec_str=%{gpursec_str}, %{mptmp}%;\
		/else \
			/set gpursec_str=%{mptmp}%;\
		/endif%;\
	/endif

/def -i gpurse_report =\
	/set gpursec_str=%;/set gpursec_total=0%;\
	/test gpurse_add("mithril",	500,	"BCgreen")%;\
	/test gpurse_add("batium",	100,	"Cgreen")%;\
	/test gpurse_add("anipium",	50,	"BCyellow")%;\
	/test gpurse_add("platinum",	10,	"Cyellow")%;\
	/test gpurse_add("gold",	1,	"Cwhite")%;\
	/test gpurse_add("silver",	0.6,	"BCcyan")%;\
	/test gpurse_add("bronze",	0.4,	"Ccyan")%;\
	/test gpurse_add("copper",	0.2,	"BCmagenta")%;\
	/test gpurse_add("tin",		0.1,	"Cmagenta")%;\
	/test gpurse_add("zinc",	0.05,	"Cred")%;\
	/test gpurse_add("mowgles",	0.01,	"BCred")%;\
	/msw It contains %{gpursec_str} (Total: @{BCwhite}$[prprettyvalstr(gpursec_total)]@{n} in @{BCyellow}gold@{n})

/def -i -ag -mregexp -t"^It contains ([a-z0-9 ,]+) coins\.$" gpurse_rep1 =\
	/set gpursec_match=%{P1}%;/gpurse_report

/def -i -ag -mregexp -t"^It contains ([a-z0-9 ,]+)$" gpurse_rep2 =\
	/set gpursec_st=1%;/set gpursec_match=%{P1}

/def -i -ag -Egpursec_st -mregexp -t"^([a-z0-9 ,]*)coins\.$" gpurse_rep3 =\
	/set gpursec_st=0%;/set gpursec_match=%{gpursec_match} %{P1}%;/gpurse_report


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Alignment value mangler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set galign_regex=
/def -i galign_clean =\
	/return replace(" ","_",replace("'","_",replace("-","_",tolower({1}))))

/def -i gdefalign =\
	/let _val=%{1}%;\
	/let _name=%{2}%;\
	/eval /set galign_$[galign_clean(_name)]=%{_val}%;\
	/if (galign_regex=~"")\
		/set galign_regex=%{_name}%;\
	/else \
		/set galign_regex=%{galign_regex}|%{_name}%;\
	/endif

/test gdefalign(-7, "Draen-Dalar's love child")
/test gdefalign(-6, "nefariously evil to the core")
/test gdefalign(-5, "morally bankrupt")
/test gdefalign(-4, "a malignant growth on the face of society")
/test gdefalign(-3, "a malevolent fiend")
/test gdefalign(-2, "a spiteful bastard")
/test gdefalign(-1, "an unwholesome rogue")
/test gdefalign( 0, "neutral")
/test gdefalign( 1, "good and the gods smile on you")
/test gdefalign( 2, "a beneficent being")
/test gdefalign( 3, "irreproachably kind")
/test gdefalign( 4, "pure at heart")
/test gdefalign( 5, "a blessing to the world")
/test gdefalign( 6, "Aveallis's gift to mankind")
/test gdefalign( 7, "an angel in disguise")


/eval /def -i -mregexp -t"^You are (%{galign_regex})\.$$" galign_mangle =\
	/let _name=$$[strcat("galign_",galign_clean({P1}))]%%;\
	/let _val=$$[prgetval(_name)]%%;\
	/if (_val < -4) /let _col=BCred%%;\
	/elseif (_val < 0) /let _col=Cred%%;\
	/elseif (_val > 4) /let _col=BCgreen%%;\
	/elseif (_val > 0) /let _col=Cgreen%%;\
	/else /let _col=Cwhite%%;/endif%%;\
	/substitute -p You are @{%%{_col}}%%{P1}@{n} -- @{BCyellow}[ %%{_val} ]@{n} in scale @{BCred}-7 (max evil)@{n} .. @{BCgreen}+7 (max good)@{n}.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Camping / lullaby / etc.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gdef -i -F -p9999 -aCgreen -mregexp -t"^You (are in a mood for a bit of lounging again|stretch yourself and consider about camping|feel a bit tired|feel like camping a little)" gcamp_ready =\
	/set camp_st=1%;\
	/gstatus_update%;\
	/msr Can camp again

/gdef -i -F -p9999 -aCgreen -mregexp -t"^You lie down and begin to rest for a while\.$|^You look around and find a suitable spot on the ground to do some lounging\!$|^You lie down for a short rest, soothed by the lullaby sung by " gcamp_start =\
	/set camp_st=2%;\
	/gstatus_update%;\
	/set camp_hp=%{status_hp}%;\
	/set camp_sp=%{status_sp}%;\
	/set camp_ep=%{status_ep}%;\
	/set camp_time=$[time()]

/gdef -i -F -p9999 -aCgreen -mregexp -t"^You awaken from your short rest, and feel slightly better\.$|^You are done with your lounging for now, you feel better\!$" gcamp_end =\
	/if (camp_st == 2)\
		/set camp_st=0%;\
		/gstatus_update%;\
		@@sc%;\
		/def -p1 -n1 -mregexp -t"^H:" gcamp_awake =\
		/msr Awake - $$[status_hp - camp_hp]hp, $$[status_sp - camp_sp]sp, $$[status_ep - camp_ep]ep $[prgetstime(camp_time)]%%;\
		/gmsg_empty_que%;\
	/endif

/gdef -i -F -p9999 -aCgreen -msimple -t"You wake up!" gcamp_interrupt =\
	/if (camp_st == 2)\
		/set camp_st=0%;\
		/gstatus_update%;\
		/msr Camping interrupted!%;\
	/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Path compression
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i prcomptoken =\
	/if ({1} > 1)\
		/let _qa=%{1} %{2}%;\
	/else \
		/let _qa=%{2}%;\
	/endif%;\
	/if (qtzst=~"")\
		/set qtzst=%{_qa}%;\
	/else \
		/set qtzst=%{qtzst};%{_qa}%;\
	/endif

/def -i prcomppath =\
	/set qtzst=%;/let _qp=%;/let _qi=1%;/let _qc=1%;\
	/while ({#})\
		/if ({1}=~_qp & _qc < 15)\
			/let _qc=$[_qc+1]%;\
		/else \
			/prcomptoken %{_qc} %{_qp}%;\
			/let _qc=1%;\
		/endif%;\
		/let _qp=%{1}%;\
		/shift%;\
	/done%;\
	/prcomptoken %{_qc} %{_qp}

/def -i prreversepath =\
	/set qtzst=%;\
	/while ({#})\
		/if	({1}=~"n")	/let _qp=s%;\
		/elseif ({1}=~"s")	/let _qp=n%;\
		/elseif ({1}=~"w")	/let _qp=e%;\
		/elseif ({1}=~"e")	/let _qp=w%;\
		/elseif ({1}=~"nw")	/let _qp=se%;\
		/elseif ({1}=~"ne")	/let _qp=sw%;\
		/elseif ({1}=~"sw")	/let _qp=ne%;\
		/elseif ({1}=~"se")	/let _qp=nw%;\
		/elseif ({1}=~"u")	/let _qp=d%;\
		/elseif ({1}=~"d")	/let _qp=u%;\
		/elseif	({1}=~"N")	/let _qp=S%;\
		/elseif ({1}=~"S")	/let _qp=N%;\
		/elseif ({1}=~"W")	/let _qp=E%;\
		/elseif ({1}=~"E")	/let _qp=W%;\
		/elseif ({1}=~"NW")	/let _qp=SE%;\
		/elseif ({1}=~"NE")	/let _qp=SW%;\
		/elseif ({1}=~"SW")	/let _qp=NE%;\
		/elseif ({1}=~"SE")	/let _qp=NW%;\
		/elseif ({1}=~"U")	/let _qp=D%;\
		/elseif ({1}=~"D")	/let _qp=U%;/endif%;\
		/set qtzst=%{_qp} %{qtzst}%;\
		/shift%;\
	/done

/def -i comppath = /prcomppath %{path}%;/echo Compressed Path: %{qtzst}
/def -i csavepath = /prcomppath %{path}%;/test send(strcat("@@", "command ", {1}, " ", qtzst))
/def -i reversepath = /prreversepath %{path}%;/set path=%{qtzst}%;/echo Reversed Path: %{qtzst}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Slots mangler
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FIXME: What if torso is not the last slot listed? How to elegantly print
;; the bottom of the table?

/def -i -F -p9999 -msimple -t"Your current armour status is:" gslots_mangle1 =\
	/substitute -ag%;\
	/set slots_st=1%;\
	/set slots_ftotal=0%;\
	/msw ,-------------------------.%;\
	/msw | Free  | Slot            |%;\
	/msw +-------+-----------------+

/def -i gslots_output =\
	/let _tslot=%{1}%;\
	/let _titem=%{3}%;\
	/if     ({2}=~"no")     /let _tnum=0%;\
	/elseif ({2}=~"one")    /let _tnum=1%;\
	/elseif ({2}=~"two")    /let _tnum=2%;\
	/elseif ({2}=~"three")  /let _tnum=3%;\
	/elseif ({2}=~"four")   /let _tnum=4%;\
	/elseif ({2}=~"five")   /let _tnum=5%;\
	/elseif ({2}=~"six")    /let _tnum=6%;\
	/elseif ({2}=~"seven")  /let _tnum=7%;\
	/elseif ({2}=~"eight")  /let _tnum=8%;\
	/elseif ({2}=~"nine")   /let _tnum=9%;\
	/else                   /let _tnum=-1%;\
	/endif%;\
	/if (_tnum < 0)\
		/let _tcol=Cyellow%;/let _tnum=%{P1}%;\
	/elseif (_tnum > 0)\
		/set slots_ftotal=$[slots_ftotal+_tnum]%;\
		/if (_tnum > 1)\
			/let _tcol=BCgreen%;\
		/else \
			/let _tcol=Cgreen%;\
		/endif%;\
	/else \
		/let _tcol=BCred%;\
	/endif%;\
	/mss | @{%{_tcol}}$[pad(_tnum,5)]@{n} | $[pad(_tslot,-15)] | @{Cyellow}%{_titem}@{n}

/def -i -F -Eslots_st -p9999 -mregexp -t"^  You have (.*) free ([a-z]*) slots?\.?$" gslots_mangle2 =\
	/test gslots_output({P2},{P1},"")

/def -i -F -Eslots_st -p9999 -mregexp -t"^  You have (.*) free ([a-z]*) slots? \[(.*)\]$" gslots_mangle3 =\
	/test gslots_output({P2},{P1},{P3})

/def -i -F -Eslots_st -p9999 -mregexp -t"^$" gslots_mangle4 =\
	/set slots_st=0%;\
	/msw +-------------------------+%;\
	/msw | Total free: @{BCgreen}$[pad(slots_ftotal,-11)]@{n} |%;\
	/msw `-------------------------'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Support for certain toys with timers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 25 min * 60s = 1500
/set toy_sleeves_wait=1500
/set toy_sleeves_diff=350
/set toy_sleeves_min=100

/def -i gtoy_sleeves_msg =\
	/set toy_sleeves_pid=%;\
	/if (toy_sleeves_on==1)\
		/msq @{BCgreen}Alexandra sleeves recharged@{n}, @{BCwhite}Use /balance for 'safe' balancing.@{n}%;\
	/endif

/def -i gtoy_sleeves_timer =\
	/set toy_sleeves_t=$[time()]%;\
	/if (toy_sleeves_pid!~"") /kill %{toy_sleeves_pid}%;/endif%;\
	/set toy_sleeves_pid=$(/grepeat -%{toy_sleeves_wait} 1 /gtoy_sleeves_msg)

/def -i -F -p9999 -mregexp -t"^You wear .*?a pair of pure white flowing sleeves" gtoy_sleeves_wear =\
	/set toy_sleeves_on=1%;\
	/gtoy_sleeves_timer

/def -i -F -p9999 -mregexp -t"^You remove .*?a pair of pure white flowing sleeves" gtoy_sleeves_rm =\
	/set toy_sleeves_on=0

/def -i -p9999 -msimple -t"You feel balanced." gtoy_sleeves_bal =\
	/set toy_sleeves_on=1%;\
	/set toy_sleeves_bal=1%;\
	/gtoy_sleeves_timer

/def -i gbalance_timeleft =\
	/let _left=$[time() - toy_sleeves_t]%;\
	/if (toy_sleeves_bal==1)\
		/msq Last balance: @{BCwhite}$[prgettime(_left)]@{n} ago.%;\
	/endif%;\
	/if (_left < toy_sleeves_wait)\
		/msq Time left until balance available: @{BCwhite}$[prgettime(toy_sleeves_wait - _left)]@{n}.%;\
		/return 0%;\
	/else \
		/return -1%;\
	/endif

/def -i -F -p9999 -msimple -t"The sleeves seem unable to grant balance at the time." gtoy_sleeves_no =\
	/if (toy_sleeves_on==1)\
		/if (gbalance_timeleft() < 0)\
			/msq Sleeves SHOULD be charged, internal inconsistency!%;\
		/endif%;\
	/else \
		/msq @{BCred}Sleeve wear time not known.@{n}%;\
	/endif

/def -i gbalance_do =\
	/if (gbalance_timeleft()==0)\
		/return%;\
	/endif%;\
	/let _diff=$[status_hp - status_sp]%;\
	/if (_diff < toy_sleeves_diff & _diff > toy_sleeves_min)\
		/msq @{BCgreen}HP - SP diff (%{_diff}) < %{toy_sleeves_diff} limit, balancing ...@{n}%;\
		/send @@balance%;\
	/else \
		/msq @{BCred}HP - SP diff (%{_diff}) > %{toy_sleeves_diff} limit, NOT BALANCING!@{n} (Use @{BCwhite}@@@@balance@{n} to force this action.)%;\
	/endif

;;@command /balance
;;@desc Perform Alexandra sleeves 'balance', but only if the current HP - SP difference is favorable.
/def -i balance =\
	/if (toy_sleeves_on==1)\
		/send @@sc%;\
		/repeat -0.2 1 /gbalance_do%;\
	/else \
		/msq Sleeves possibly not worn. If you are certain that they are, use @{BCwhite}@@@@balance@{n} to force action.%;\
	/endif

;;@command /chkbalance
;;@desc Check and report the status of Alexandra sleeve 'balance' without actually performing 'balance'.
/def -i chkbalance =\
	/if (toy_sleeves_on==1)\
		/if (gbalance_timeleft()==0)\
			/return%;\
		/endif%;\
		/let _diff=$[status_hp - status_sp]%;\
		/if (_diff < toy_sleeves_diff & _diff > toy_sleeves_min)\
			/msq @{BCgreen}HP - SP diff = %{_diff}, OK TO BALANCE ...@{n}%;\
		/else \
			/msq @{BCred}HP - SP diff (%{_diff}) > %{toy_sleeves_diff} limit, balance not favorable!@{n}%;\
		/endif%;\
	/else \
		/msq Sleeves possibly not worn. If you are certain that they are, use @{BCwhite}@@@@balance@{n} to force action.%;\
	/endif
	

/prdefgbind -s"balance" -c"/balance"
/prdefgbind -s"cbalance" -c"/chkbalance"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global script initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/eval /if (set_wasinit != 1)\
	/greset%;\
	/ginitialize%;\
	/set set_wasinit=1%;\
/endif
