;;
;; GgrTF::Identify - Identify output mangler
;; (C) Copyright 2009-2015 Matti Hämäläinen (Ggr)
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
/loaded GgrTF:Identify
/test prdefmodule("Identify", "Magical")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gidentify_print =\
	/let _res=$[prpadwith({1},8,".")]: %;/shift%;\
	/while ({#})\
		/let _rlen=$[strlen(_res)+1]%;\
		/if (_rlen >= idc_width-2 | _rlen+strlen({1}) >= idc_width)\
			/test msw(strcat("| ", pad(_res, - idc_width), " |"))%;\
			/let _res=          %{1}%;\
		/else \
			/let _res=%{_res} %{1}%;\
		/endif%;\
		/shift%;\
	/done%;\
	/test msw(strcat("| ", pad(_res, - idc_width), " |"))

/def -i gidentify_maxcond =\
	/if ({1}=~"it's BRAND NEW")			/return "AWESOME"%;\
	/elseif ({1}=~"have been used just a few times")/return "incredible"%;\
	/elseif ({1}=~"as good as new")			/return "superb"%;\
	/elseif ({1}=~"has some small repairs")		/return "excellent"%;\
	/elseif ({1}=~"has some minor fixes")		/return "great"%;\
	/elseif ({1}=~"been fixed a few times")		/return "good"%;\
	/elseif ({1}=~"been fixed several times")	/return "fine"%;\
	/elseif ({1}=~"patched up a few times")		/return "battered"%;\
	/elseif ({1}=~"patched up several times")	/return "poor"%;\
	/elseif ({1}=~"repaired a few times")		/return "bad(?)"%;\
	/else /return {1}%;/endif

/def -i gidentify_sep =\
	/msw +$[strrep("-",idc_width+2)]+

/def -i gidentify_sep2 =\
	/msw +-| @{BCgreen}%{1}@{n} |$[strrep("-",idc_width-strlen({1})-3)]+

/def -i gidentify_idc_add =\
	/set idc_st=$[idc_st+1]%;/set idc_imp=%{idc_imp} $[replace(" ","_",{1})]


/def -i -F -p9999 -mregexp -t"^The following messages seem to vibrate from (.+):$" gidentify_start =\
	/msq Collecting information ...%;\
	/if (opt_havebelt=~"on") /set idc_getweight=1%;@@weigh %{P1}%;/endif%;\
	/set idc_item=%{P1}%;/set idc_st=1%;/set idc_kgw=UNKNOWN%;\
	/set idc_imp=%;/set idc_age=%;/set idc_cond=%;/set idc_handles=%;\
	/set idc_maxcond=%;/set idc_cond=%;/set idc_name=%;/set idc_quality=%;\
	/set idc_size=%;/set idc_slots=%;/set idc_weight=%;/set idc_worth=%;\
	/set idc_material=UNKNOWN%;/set idc_fwd=%;/set idc_worn=%;\
	/set idc_wielded=%;/set idc_names=%;\
	/repeat -2 1 /gidentify_output
	
/def -i -F -Eidc_getweight -ag -p9999 -mregexp -t"^: *([0-9]+\.[0-9]+) " gidentify_weight =\
	/set idc_getweight=0%;/set idc_kgw=%{P1}

/def -i -F -Eidc_st>=1 -p9999 -mregexp -t"^It is called (.+) and identified as (.+)\.$" gidentify_handles =\
	/set idc_st=$[idc_st+1]%;/set idc_name=%{P1}%;/set idc_handles=%{P2}

/def -i -F -Eidc_st>=2 -p9999 -mregexp -t"^It takes the following slots: (.*)\.$" gidentify_slots =\
	/set idc_st=$[idc_st+1]%;/set idc_slots=%{P1}

/def -i -F -Eidc_st>=2 -p9999 -mregexp -t"^It will (.+)\.$" gidentify_sksp =\
	/test gidentify_idc_add({P1})

/def -i -F -Eidc_st>=2 -p9999 -mregexp -t"^(A halo of purity surrounds it|An aura of blackness surrounds it)\." gidentify_specials =\
	/test gidentify_idc_add({P1})

/def -i -F -Eidc_st>=2 -p9999 -mregexp -t"^([A-Z][A-Za-z, ]+) did the heroic deed to bring" gidentify_i1 =\
	/set idc_names=%{P1}

/def -i -F -Eidc_st>=2 -p9999 -mregexp -t"has been in the game for ([0-9a-z, ]+)\." gidentify_i2 =\
	/set idc_age=%{P1}

/def -i -F -Eidc_st>=2 -p9999 -mregexp -t"It is ([A-Za-z -]+), ([A-Za-z -]+)," gidentify_i3 =\
	/set idc_weight=%{P1}%;/set idc_size=%{P2}

/def -i -F -Eidc_st>=2 -p9999 -mregexp -t"in ([A-Za-z '-]+) condition, ([A-Za-z '-]+)" gidentify_i4 =\
	/set idc_cond=%{P1}%;/set idc_maxcond=$[gidentify_maxcond({P2})]

/def -i -F -Eidc_st>=2 -p9999 -mregexp -t"of ([A-Za-z ]+) quality" gidentify_i5 =\
	/set idc_quality=%{P1}

/def -i -F -Eidc_st>=2 -p9999 -mregexp -t"worth ([0-9]+)" gidentify_i6 =\
	/set idc_worth=%{P1}

/def -i -F -Eidc_st>=2 -p9999 -mregexp -t"made of,? ?(.+?), (feather|worth)" gidentify_i7 =\
	/set idc_material=%{P1}

/def -i -F -Eidc_st>=2 -p9999 -mregexp -t"featherweighted for (.+), worth" gidentify_i8 =\
	/set idc_fwd=%{P1}

/def -i -F -Eidc_st>=2 -p9999 -mregexp -t", (sheds light|emits darkness)," gidentify_i9 =\
	/test gidentify_idc_add(strcat("It ",{P1}))

/def -i -F -Eidc_st>=2 -p9999 -mregexp -t"^It (has|hasn't) been (worn|wielded) by (.+)\.$" gidentify_worn1 =\
	/if ({P1}=~"has") /set idc_%{P2}=%{P3}%;/endif%;\

/def -i -F -Eidc_st>=2 -p9999 -mregexp -t"^It (has|hasn't) been mostly (worn|wielded) by (.+)\.$" gidentify_worn2 =\
	/if ({P1}=~"has") /set idc_%{P2}=%{P3}%;/endif%;\

/def -i gidentify_list =\
	/while ({#})\
		/let _tmp=$[replace("_"," ",{1})]%;\
		/msw | $[prsubipad(_tmp,idc_width)] |%;\
		/shift%;\
	/done

/def -i gidentify_output =\
	/set idc_width=74%;\
	/gidentify_sep2 General %;\
	/msw | Item....: $[prsubipad(idc_item,idc_width-10)] |%;\
	/msw | Name....: $[prsubipad(idc_name,idc_width-10)] |%;\
	/gidentify_print Handles %{idc_handles}%;\
	/gidentify_print Names %{idc_names}%;\
	/gidentify_print Slots %{idc_slots}%;\
	/gidentify_print Material %{idc_material}%;\
	/gidentify_sep%;\
	/msw | In game.: @{BCwhite}$[prsubipad(idc_age,   30)]@{n} | Condition: @{BCwhite}$[prsubipad(idc_cond,20)]@{n} |%;\
	/msw | Size....: @{BCwhite}$[prsubipad(idc_size,  30)]@{n} | Maxcond..: @{BCwhite}$[prsubipad(idc_maxcond,20)]@{n} |%;\
	/msw | Worth...: @{BCwhite}$[prsubipad(idc_worth, 30)]@{n} | Quality..: @{BCwhite}$[prsubipad(idc_quality,20)]@{n} |%;\
	/msw | Weight..: @{BCwhite}$[prsubipad(idc_weight,30)]@{n} | Weight/kg: @{BCwhite}$[prsubipad(idc_kgw,20)]@{n} |%;\
	/if (idc_imp!~"")\
		/gidentify_sep2 Stats%;\
		/gidentify_list %{idc_imp}%;\
	/endif%;\
	/gidentify_sep2 Misc%;\
	/gidentify_print Worn %{idc_worn}%;\
	/gidentify_print Wielded %{idc_wielded}%;\
	/if (idc_fwd!~"") /gidentify_print FW'd %{idc_fwd}%;/endif%;\
	/gidentify_sep
