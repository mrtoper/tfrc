;; Salve testing helper triggers
;; (C) Copyright 2005-2006 Matti Hämäläinen (Ggr)
;;
;; This file (triggerset) is Free Software distributed under
;; GNU General Public License version 2.
;;
;; NOTICE! This file requires GgrTF (version 0.6.0 or later) to be loaded.
;;
;; This file is not direct part of GgrTF, it's a optional module which
;; provides simple triggers for measuring stat-effects of salves made
;; by channellers and alchemists. The measuring mechanism only takes
;; into account stats (str,dex,con,int,wis,cha,siz) at the moment.
;;
/set salve_st=off
/set salve_st2=off
/set salve_m=off

/def -i -mregexp -ag -t"^You stop what you were doing and begin to apply clay dish of ([a-z]+) salve to yourself\.$" salve_getn =\
	/set salve_name=%{P1}%;\
	/msq Applying '%{salve_name}' salve ...

/def -i -mregexp -ag -t"^You stop what you were doing and begin to apply clay dish of ([a-z]+) salve labeled as .+ to yourself\.$" salve_getn2 =\
	/set salve_name=%{P1}%;\
	/msq Applying '%{salve_name}' salve ...

/def -i salve_add =\
	/let qval=$[{2}-{3}]%;\
	/if (qval > 0)\
		/let qval=+%{qval} %{1}%;\
	/elseif (qval < 0)\
		/let qval=%{qval} %{1}%;\
	/else \
		/let qval=%;\
	/endif%;\
	/if (qval!~"")\
		/if (salve_res!~"")\
			/set salve_res=%{qval}:%{salve_res}%;\
		/else \
			/set salve_res=%{qval}%;\
		/endif%;\
	/endif

/def -i -mregexp -ag -t"^You say 'Str: [A-Z][a-z]+ \(([0-9]+)[\+\-]*\), Dex: [A-Z][a-z]+ \(([0-9]+)[\+\-]*\), Con: [A-Z][a-z]+ \(([0-9]+)[\+\-]*\), Int: [A-Z][a-z]+ \(([0-9]+)[\+\-]*\), Wis: [A-Z][a-z]+ \(([0-9]+)[\+\-]*\), Cha: [A-Z][a-z]+ \(([0-9]+)[\+\-]*\), Siz: [A-Z][a-z]+ \(([0-9]+)[\+\-]*\)\.'$" salve_stats =\
	/msq STR:%{P1}|DEX:%{P2}|CON:%{P3}|INT:%{P4}|WIS:%{P5}|CHA:%{P6}|SIZ:%{P7}%;\
	/if (salve_st=~"on" & salve_m=~"off")\
		/msq Saving salve effects ...%;\
		/set salve_m=on%;\
		/set salve_str=%{P1}%;\
		/set salve_dex=%{P2}%;\
		/set salve_con=%{P3}%;\
		/set salve_int=%{P4}%;\
		/set salve_wis=%{P5}%;\
		/set salve_cha=%{P6}%;\
		/set salve_siz=%{P7}%;\
	/else \
		/if (salve_st2=~"on")\
			/set salve_st2=off%;\
			/set salve_res=%;\
			/test salve_add("str",salve_str,{P1})%;\
			/test salve_add("dex",salve_dex,{P2})%;\
			/test salve_add("con",salve_con,{P3})%;\
			/test salve_add("int",salve_int,{P4})%;\
			/test salve_add("wis",salve_wis,{P5})%;\
			/test salve_add("cha",salve_cha,{P6})%;\
			/test salve_add("siz",salve_siz,{P7})%;\
			/echo $[pad(salve_name,-15)] | $[pad(salve_res,-30)] | $[prgetstime(salve_t)]  | -%;\
		/endif%;\
	/endif

/gdef -i -aBCmagenta -msimple -t"You finish applying the salve." salve_begin =\
	/set salve_st=on%;\
	/set salve_m=off%;\
	/set salve_t=$[time()]%;\
	/msq Salve timer started, waiting effects ...%;\
	/repeat -10 1 @report stats

/gdef -i -aBCmagenta -msimple -t"You feel your body returning to normal." salve_end =\
	/set salve_st=off%;/set salve_st2=on%;\
	/msq Salve duration: $[prgetstime(salve_t)]%;\
	@report stats

/def -i sstat =\
	/if (salve_st=~"on")\
		/msq Salve measurement in progress. Duration: $[prgetstime(salve_t)]%;\
	/else \
		/msq No salve measurement in progress.%;\
	/endif

