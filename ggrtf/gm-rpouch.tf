;;
;; GgrTF::RegPouch - Reagent pouch management and liting
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
/loaded GgrTF::RegPouch
/test prdefmodule("RegPouch")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bindings and settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdeftoggle -n"reglite"	-d"Lite/prettify reagent pouch"
/set opt_reglite=on

/prdefgbind -s"rpouch"	-c"/rpouch"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper for reagent pouch
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set rpouch_get=0
/set rpouch_regs=

/def -i grpouch_close =\
	/if (rpouch_save!~"" & rpouch_save >= 0)\
		/test tfclose(rpouch_save)%;\
		/set rpouch_save=-1%;\
	/endif

/def -i -F -msimple -t"It is labeled as 'pussi'." grpouch_fgrab =\
	/grpouch_close%;\
	/set rpouch_save=$[tfopen(strcat(HOME,"/public_html/reagents.txt"),"w")]

/def -i grpouch_report =\
	/if (regmatch("^[0-9]+$",{1}))\
		/let _nval=%{1}%;\
	/elseif ({1}=~"One")	/let _nval=1%;\
	/elseif ({1}=~"Two")	/let _nval=2%;\
	/elseif ({1}=~"Three")	/let _nval=3%;\
	/elseif ({1}=~"Four")	/let _nval=4%;\
	/elseif ({1}=~"Five")	/let _nval=5%;\
	/elseif ({1}=~"Six")	/let _nval=6%;\
	/elseif ({1}=~"Seven")	/let _nval=7%;\
	/elseif ({1}=~"Eight")	/let _nval=8%;\
	/elseif ({1}=~"Nine")	/let _nval=9%;\
	/else /gerror Invalid value in '%{1}' in grpouch_report(%{*})%;/break%;/endif%;\
	/set rpouch_total_pwr=$[rpouch_total_pwr + {2}]%;\
	/set rpouch_total_std=$[rpouch_total_std + {3}]%;\
	/set rpouch_total_por=$[rpouch_total_por + {4}]%;\
	/if (rpouch_save!~"" & rpouch_save >= 0)\
		/let _line=%{2}|%{6}%;\
		/test tfwrite(rpouch_save, _line)%;\
	/endif%;\
	/if (rpouch_get)\
		/set rpouch_%{rpouch_name}_%{7}=%{2}%;\
		/substitute -ag%;\
	/else \
		/if (opt_reglite=~"on")\
			/if (regmatch("^(Electrocution|Lava Blast|Golden Arrow|Acid Blast|Cold Ray|Summon Carnal Spores|Blast Vacuum)$", {6}))\
				/let _nmcol=@{BCgreen}%;\
			/elseif (regmatch("^(Lava Storm|Magic Eruption|Lightning Storm|Acid Storm|Hailstorm|Killing Cloud|Vacuum Globe)$", {6}))\
				/let _nmcol=@{Cred}%;\
			/else \
				/let _nmcol=@{BCblue}%;\
			/endif%;\
			/substitute -p @{BCyellow}$[pad(_nval,6)]@{n} | %{_nmcol}$[pad({6},-25)]@{n} (@{BCred}$[pad({2},6)]@{n},@{Cgreen}$[pad({3},5)]@{n},@{Cyellow}$[pad({4},5)]@{n}) @{BCgray}($[prsubstr({8},columns()-55)])@{n}%;\
		/endif%;\
	/endif

/def -i -Erpouch_get -p9999 -F -mregexp -t"^(It looks .*(heavy|weight)\.|This is a large pouch for the storing of reagents|reagents over reboots in this.|Syntax: store <item> in <this>| +extract .amount. <item>| +set_default_reagent|transfer .number. .reagent.|Some commands allow the use of|It is labeled as |The label can be set with |[Ii]t is surrounded by )" grpouch_gag =\
	/set rpouch_st=0%;\
	/substitute -ag

/def -i -p9999 -F -msimple -t"The pouch contains:" grpouch_start =\
	/set rpouch_st=1%;\
	/set rpouch_total_pwr=0%;\
	/set rpouch_total_std=0%;\
	/set rpouch_total_por=0%;\
	/substitute -ag

/def -i -Erpouch_get -p999 -F -msimple -t"You see nothing special." grpouch_end2 =\
	/set rpouch_st=0%;\
	/set rpouch_get=0%;\
	/msq @{BCred}No such reagent pouch@{n} '@{BCgreen}%{rpouch_target}@{n}'!

/def -i -p999 -F -mregexp -t"^This item is in " grpouch_end =\
	/grpouch_close%;\
	/if (rpouch_st & !rpouch_get)\
		/let _nval=$[rpouch_total_pwr + rpouch_total_std + rpouch_total_por]%;\
		/if (opt_reglite=~"on")\
			/echo -p @{BCyellow}$[pad(_nval,6)]@{n} | @{BCgreen}$[pad("TOTAL",-25)]@{n} (@{BCred}$[pad(rpouch_total_pwr,6)]@{n},@{Cgreen}$[pad(rpouch_total_std,5)]@{n},@{Cyellow}$[pad(rpouch_total_por,5)]@{n})%;\
		/else \
			/echo -p Total: @{BCwhite}%{rpouch_total_pwr} power@{n}, %{rpouch_total_std} standard, %{rpouch_total_por} poor.%;\
		/endif%;\
	/endif%;\
	/set rpouch_st=0%;\
	/if (rpouch_get) /substitute -ag%;/eval /repeat -1 1 /%{rpouch_dest}%;/endif


;; Define reagents and mangler macros
/def -i gdefrpouch =\
	/let _tmps=$[replace(" ","_",tolower({3}))]%;\
	/set rpouch_regs=%{rpouch_regs} %{_tmps}%;\
	/set rpouch_reg_%{_tmps}=%{2}%;\
	/prdefivar rpouch_set_%{_tmps} 0%;\
	/def -i -p9999 -Erpouch_st==1 -mregexp -t"^(One|Two|Three|Four|Five|Six|Seven|Eight|Nine|[0-9]+) (%{1}) \\(([0-9]+) power, ([0-9]+) standard, ([0-9]+) poor\\)$$" grpouch_%{_tmps} =\
		/test grpouch_report({P1},{P3},{P4},{P5},{P2},"%{3}","%{_tmps}","%{2}")


/test gdefrpouch("handfuls? of olivine powder",	"Olivine powder",	"Acid Blast")
/test gdefrpouch("stone cubes?",		"Stone cube",		"Acid Shield")
/test gdefrpouch("pairs? of interlocked bloodstone rings","Interlocked rings",	"Acid Storm")
/test gdefrpouch("small highsteel discs?",	"Highsteel disc",	"Armour of Aether")
/test gdefrpouch("tiny leather bags? \(empty\)","Leather bag",		"Aura of Wind")
/test gdefrpouch("bronze marbles?",		"Bronze marble",	"Blast Vacuum")
/test gdefrpouch("steel arrowheads?",		"Steel arrowhead",	"Cold Ray")
/test gdefrpouch("small pieces? of electrum wire","Electrum wire",	"Electrocution")
/test gdefrpouch("small glass cones?",		"Glass cone",		"Flame Shield")
/test gdefrpouch("grey fur triangles?",		"Fur triangle",		"Frost Shield")
/test gdefrpouch("copper rods?",		"Copper rod",		"Golden Arrow")
/test gdefrpouch("handfuls? of onyx gravel",	"Onyx gravel",		"Hailstorm")
/test gdefrpouch("ebony tubes?",		"Ebony tube",		"Killing Cloud")
/test gdefrpouch("granite spheres?",		"Granite sphere",	"Lava Blast")
/test gdefrpouch("blue cobalt cups? \(empty\)",	"Cobalt cup",		"Lava Storm")
/test gdefrpouch("small iron rods?",		"Iron rod",		"Lightning Shield")
/test gdefrpouch("clusters? of tungsten wires",	"Tungsten wire",	"Lightning Storm")
/test gdefrpouch("tiny platinum hammers?",	"Platinum hammer",	"Magic Eruption")
/test gdefrpouch("quartz prisms?",		"Quartz prism",		"Repulsor Aura")
/test gdefrpouch("tiny amethyst crystals?",	"Amethyst crystal",	"Shield of Detoxification")
/test gdefrpouch("silvery bark chips?",		"Bark chip",		"Summon Carnal Spores")
/test gdefrpouch("small brass fans?",		"Small brass fan",	"Vacuum Globe")


/def -i grpouch_list =\
	/msw ,---------------,%;\
	/msw | @{BCgreen}GgrTF@{n} @{Cyellow}RP List@{n} |%;\
	/msw +---------------+----------------------------------+--------.%;\
	/msw | @{BCgreen}Spell name@{n}                | @{BCyellow}Reagent@{n}              |  @{BCwhite}Stock@{n} |%;\
	/msw +---------------------------+----------------------+--------+%;\
	/let _rp_total=0%;\
	/while ({#})\
		/let _rp_name=$[prgetval(strcat("rpouch_reg_",{1}))]%;\
		/let _rp_num=$[prgetval(strcat("rpouch_set_",{1}))]%;\
		/let _rp_rname=$[replace("_"," ",{1})]%;\
		/let _rp_total=$[_rp_total + _rp_num]%;\
		/msw | @{Cgreen}$[prsubipad(_rp_rname,25)]@{n} | @{Cyellow}$[prsubipad(_rp_name,20)]@{n} | $[pad(_rp_num,6)] |%;\
		/shift%;\
	/done%;\
	/msw +--------------------------------------------------+--------+%;\
	/msw | Total reagents to be stocked ................... | @{BCgreen}$[pad(_rp_total,6)]@{n} |%;\
	/msw `--------------------------------------------------+--------'


/def -i grpouch_adjust =\
	/let _rval=%{1}%;/shift%;\
	/let _rnum=0%;\
	/while ({#})\
		/let _rp_nset=$[prgetval(strcat("rpouch_set_",{1}))]%;\
		/if (_rp_nset > 0)\
			/set rpouch_set_%{1}=%{_rval}%;\
			/let _rnum=$[_rnum+1]%;\
		/endif%;\
		/shift%;\
	/done%;\
	/msq Adjusted @{BCgreen}%{_rnum}@{n} set pouch reagents to @{BCwhite}%{_rval}@{n}%;\


/def -i grpouch_clear =\
	/let _rval=%{1}%;/shift%;\
	/while ({#})\
		/set rpouch_%{_rval}_%{1}=0%;\
		/shift%;\
	/done


/def -i grpouch_set_all =\
	/let _rval=%{1}%;/shift%;\
	/msq Setting all reagents to %{_rval}%;\
	/while ({#})\
		/set rpouch_set_%{1}=%{_rval}%;\
		/shift%;\
	/done


;; Contents of "from" pouch got, now get contents of "to" pouch
/def -i grpouch_fill1 =\
	/set rpouch_dest=grpouch_fill2%;\
	/set rpouch_name=to%;\
	/set rpouch_target=%{rpouch_to}%;\
	@@look at %{rpouch_to}


;; We now have contents of both pouches .. start moving.
/def -i grpouch_fill2 =\
	/set rpouch_get=0%;\
	/set rpouch_dest=%;\
	/grpouch_move %{rpouch_regs}


/def -i grpouch_move =\
	/if (rpouch_mode=~"check")\
	/msw ,-----------------------------.                                    ,---------.%;\
	/msw | Would transfer following... |                                    |  Needs  |%;\
	/msw +----------------------+-------------------------------------------+---------+%;\
	/else \
	/msq Moving reagents ...%;\
	/endif%;\
	/let _rnum=0%;\
	/while ({#})\
		/let _rp_name=$[tolower(prgetval(strcat("rpouch_reg_",{1})))]%;\
		/let _rp_nfrom=$[prgetval(strcat("rpouch_from_",{1}))]%;\
		/let _rp_nto=$[prgetval(strcat("rpouch_to_",{1}))]%;\
		/let _rp_nset=$[prgetval(strcat("rpouch_set_",{1}))]%;\
		/if (rpouch_mode=~"move")\
			/if (_rp_nfrom > 0)\
				/msq Transferring all '%{_rp_name}'%;\
				@@transfer all %{_rp_name} from %{rpouch_from} to %{rpouch_to} take power%;\
			/endif%;\
		/else \
		/let _rwant=$[_rp_nset - _rp_nto]%;\
		/if (_rwant > 0)\
			/let _vbuy=$[_rwant - _rp_nfrom]%;\
			/if (_vbuy > 0)\
				/let _vmove=%{_rp_nfrom}%;\
				/let _vcol=BCred%;\
				/let _vstr=Contains %{_rp_nto}, %{_rp_nset} wanted (%{_rp_nfrom} avail)%;\
			/else \
				/let _vbuy=0%;\
				/let _vmove=%{_rwant}%;\
				/let _vcol=BCgreen%;\
				/let _vstr=Moving %{_rwant} of %{_rp_nfrom}%;\
			/endif%;\
			/if (rpouch_mode=~"check")\
				/msw | @{Cyellow}$[prsubipad(_rp_name,20)]@{n} | @{%{_vcol}}$[prsubipad(_vstr,41)]@{n} | @{%{_vcol}}$[pad(_vbuy,7)]@{n} |%;\
			/else \
				/if (_vmove > 0)\
					/msq Transferring %{_vmove} x '%{_rp_name}' (wanted %{_rwant})%;\
					@@transfer %{_vmove} %{_rp_name} from %{rpouch_from} to %{rpouch_to} take power%;\
				/endif%;\
			/endif%;\
			/let _rnum=$[_rnum+1]%;\
		/endif%;\
		/endif%;\
		/shift%;\
	/done%;\
	/if (rpouch_mode=~"check")\
	/msw +-------------------+--+-------------------------------------------+---------'%;\
	/msw | @{BCwhite}$[pad(_rnum,5)]@{n} types total |%;\
	/msw `-------------------'%;\
	/else \
	/msq Done.%;\
	/endif


;@command /rpouch
;@desc Prints a short help text with basic syntaxes of the commands.

;@command /rpouch check <dst pouch> from <src pouch> [in <container>]
;@desc Checks and shows a list of reagents to be stocked into "dst pouch"
;@desc from "src pouch" with current settings. Source pouch can optionally be
;@desc in container (such as a chest).

;@command /rpouch fill &lt;dst pouch&gt; from &lt;src pouch&gt; [in &lt;container&gt;]
;@desc Like 'check' but instead of a list, moves reagents to "dst pouch"
;@desc to match the current settings.

;@command /rpouch move &lt;dst pouch&gt; from &lt;src pouch&gt; [in &lt;container&gt;]
;@desc Moves ALL power reagents from "src pouch" to "dst pouch".

;@command /rpouch set &lt;spell&gt; &lt;amount&gt;
;@desc Set amount of reagents to stock for given spell. (Like "rset",
;@desc but takes spell name instead.)

;@command /rpouch rset &lt;reagent&gt; &lt;amount&gt;
;@desc Set amount of given reagent to be stocked. (Like "set", but takes
;@desc reagent name instead.)

;@command /rpouch adjust &lt;amount&gt;
;@desc ???

;@command /rpouch all &lt;amount&gt;
;@desc Unconditionally sets number of ALL reagents to be stocked to
;@desc given amount.

;@command /rpouch list
;@desc Shows a list of current settings (e.g. how many of each reagent to stock.)


;; Main command interface
/def -i rpouch =\
	/let _args=$[tolower({*})]%;\
	/if (regmatch("^(fill|check|move) +([A-Za-z0-9_-][A-Za-z0-9_ -]+) +from +([A-Za-z0-9_][A-Za-z0-9_ -]+)$", _args))\
		/set rpouch_mode=%{P1}%;\
		/set rpouch_to=%{P2}%;\
		/set rpouch_from=%{P3}%;\
		/if (rpouch_mode=~"fill")\
			/msq @{BCwhite}Filling reagents from@{n} '@{BCgreen}%{rpouch_from}@{n}' @{BCwhite}to@{n} '@{BCred}%{rpouch_to}@{n}'%;\
		/elseif (rpouch_mode=~"check")\
			/msq @{BCwhite}Checking reagents in@{n} '@{BCgreen}%{rpouch_from}@{n}' @{BCwhite}<->@{n} '@{BCred}%{rpouch_to}@{n}'%;\
		/else \
			/msq @{BCwhite}Moving ALL reagents from@{n} '@{BCgreen}%{rpouch_from}@{n}' @{BCwhite}to@{n} '@{BCred}%{rpouch_to}@{n}'%;\
		/endif%;\
		/msq Getting pouch contents, please wait...%;\
		/grpouch_clear to %{rpouch_regs}%;\
		/grpouch_clear from %{rpouch_regs}%;\
		/set rpouch_get=1%;\
		/set rpouch_dest=grpouch_fill1%;\
		/set rpouch_name=from%;\
		/set rpouch_target=%{rpouch_from}%;\
		@@look at %{rpouch_from}%;\
	/elseif (regmatch("^(rset|set) +([A-Za-z][A-Za-z ]+) ([0-9]+)", _args))\
		/if ({P1}=~"set")\
			/let _tmps=$[replace(" ","_",tolower({P2}))]%;\
			/let _rpas=$[prgetval(strcat("rpouch_reg_",_tmps))]%;\
			/if (_rpas!~"")\
				/msq Reagent '@{Cgreen}%{_tmps}@{n}' (@{Cyellow}%{_rpas}@{n}) set to @{BCwhite}%{P3}@{n}%;\
				/set rpouch_set_%{_tmps}=%{P3}%;\
			/else \
				/msq @{BCred}No such spell@{n} '@{BCwhite}%{P2}@{n}'!%;\
			/endif%;\
		/else \
			/gerror This setting does not work yet!%;\
		/endif%;\
	/elseif (regmatch("^adjust +([0-9]+)", _args))\
		/grpouch_adjust %{P1} %{rpouch_regs}%;\
	/elseif (regmatch("^all +([0-9]+)", _args))\
		/grpouch_set_all %{P1} %{rpouch_regs}%;\
	/elseif (_args=~"list")\
		/grpouch_list %{rpouch_regs}%;\
	/else \
		/msw ,-------------------------------.%;\
		/msw | @{BCgreen}GgrTF@{n} - @{Cyellow}Reagent Pouch Manager@{n} |%;\
		/msw +-------------------------------+------------------------------------------.%;\
		/msw | /rpouch @{BCwhite}(fill|check|move)@{n} @{Cgreen}<to pouch>@{n} [@{BCwhite}in@{n} @{Cyellow}<A>@{n}] @{BCwhite}from@{n} @{Cred}<from pouch>@{n} [@{BCwhite}in@{n} @{Cyellow}<B>@{n}] |%;\
		/msw | /rpouch @{BCwhite}set@{n} @{Cgreen}<spell>@{n} <amount>                                             |%;\
		/msw | /rpouch @{BCwhite}rset@{n} @{Cgreen}<reagent>@{n} <amount>                                          |%;\
		/msw | /rpouch @{BCwhite}adjust@{n} @{Cgreen}<amount>@{n}                                                  |%;\
		/msw | /rpouch @{BCwhite}all@{n} @{Cgreen}<amount>@{n}                                                     |%;\
		/msw | /rpouch @{BCwhite}list@{n}                                                             |%;\
		/msw `--------------------------------------------------------------------------'%;\
	/endif
