;; Show map in statusline

/loaded GgrTF:X_STATUS
/test prdefmodule("X_STATUS", "TF5")

;;;;;;;;;;;;;;;;
;; Map status ;;
;;;;;;;;;;;;;;;;

/def x_status_map_reset=\
  /set  x_status_map_r0=<---------^--------->%;\
  /set  x_status_map_r1=|                   |%;\
  /set  x_status_map_r2=|                   |%;\
  /set  x_status_map_r3=|                   |%;\
  /set  x_status_map_r4=|                   |%;\
  /set  x_status_map_r5=|                   |%;\
  /set  x_status_map_r6=<                   >%;\
  /set  x_status_map_r7=|                   |%;\
  /set  x_status_map_r8=|                   |%;\
  /set  x_status_map_r9=|                   |%;\
  /set x_status_map_r10=|                   |%;\
  /set x_status_map_r11=|                   |%;\
  /set x_status_map_r12=<---------v--------->

/def -i x_status_map_init =\
  /x_map_reset

;; Listen on map changes and update
/set x_status_map_update_next=0

/def -i -F -p9999 -mregexp -ag -t"^[<.]---------[\^-]---------[.>].*$" _start_x_status_map_update=\
  /eval /set x_status_map_r0 %{P0}%;\
  /set x_status_map_update_next=1

/def -i -F -p9999 -mregexp -ag -t"^[<`]---------[v-]---------['>]" _end_x_status_map_update=\
  /eval /set x_status_map_r12 %{P0}%;\
  /set x_status_map_update_next=0

/def -i -F -p9999 -mregexp -ag -t"^[<|].{19}[|>].*$" _do_x_status_map_update=\
  /eval /set x_status_map_r$[x_status_map_update_next] %{P0}%;\
  /set x_status_map_update_next=$[x_status_map_update_next + 1]


;;;;;;;;;;;;;;;;;;
;; Exits status ;;
;;;;;;;;;;;;;;;;;;
/def -i x_status_exits_reset =\
	/eval /set x_status_exits_nw=$[char(32)]%;\
  /eval /set x_status_exits_n=$[char(32)]%;\
  /eval /set x_status_exits_ne=$[char(32)]%;\
  /eval /set x_status_exits_w=$[char(32)]%;\
  /eval /set x_status_exits_e=$[char(32)]%;\
  /eval /set x_status_exits_sw=$[char(32)]%;\
  /eval /set x_status_exits_s=$[char(32)]%;\
  /eval /set x_status_exits_se=$[char(32)]%;\
  /eval /set x_status_exits_u=$[char(32)]%;\
  /eval /set x_status_exits_d=$[char(32)]%;\
  /set x_status_exits_nw_color=Cgreen%;\
  /set x_status_exits_n_color=Cgreen%;\
  /set x_status_exits_ne_color=Cgreen%;\
  /set x_status_exits_w_color=Cgreen%;\
  /set x_status_exits_e_color=Cgreen%;\
  /set x_status_exits_sw_color=Cgreen%;\
  /set x_status_exits_s_color=Cgreen%;\
  /set x_status_exits_se_color=Cgreen

 /def -i x_status_exits_update_row =\
   /if ({1}=~0)\
     /eval /set x_status_exits_r0=[ %{x_status_exits_nw} %{x_status_exits_n} %{x_status_exits_ne} %{x_status_exits_u}]%;\
   /endif%;\
   /if ({1}=~1)\
     /eval /set x_status_exits_r1=[ %{x_status_exits_w} @ %{x_status_exits_e}  ]%;\
   /endif%;\
   /if ({1}=~2)\
     /eval /set x_status_exits_r2=[ %{x_status_exits_sw} %{x_status_exits_s} %{x_status_exits_se} %{x_status_exits_d}]%;\
   /endif

/def -i x_status_exits_update =\
  /if (regmatch("^nw$|^nw,| nw,| nw$", %{1})) /set x_status_exits_nw=\\\\%; /x_status_exits_update_row 0%; /endif%;\
  /if (regmatch("^n$|^n,| n,| n$", %{1})) /set x_status_exits_n=|%; /x_status_exits_update_row 0%; /endif%;\
  /if (regmatch("^ne$|^ne,| ne,| ne$", %{1})) /set x_status_exits_ne=/%; /x_status_exits_update_row 0%; /endif%;\
  /if (regmatch("^w$|^w,| w,| w$", %{1})) /set x_status_exits_w=-%; /x_status_exits_update_row 1%; /endif%;\
  /if (regmatch("^e$|^e,| e,| e$", %{1})) /set x_status_exits_e=-%; /x_status_exits_update_row 1%; /endif%;\
  /if (regmatch("^sw$|^sw,| sw,| sw$", %{1})) /set x_status_exits_sw=/%; /x_status_exits_update_row 2%; /endif%;\
  /if (regmatch("^s$|^s,| s,| s$", %{1})) /set x_status_exits_s=|%; /x_status_exits_update_row 2%; /endif%;\
  /if (regmatch("^se$|^se,| se,| se$", %{1})) /set x_status_exits_se=\\\\%; /x_status_exits_update_row 2%; /endif%;\
  /if (regmatch("^u$|^u,| u,| u$", %{1})) /set x_status_exits_u=~%; /x_status_exits_update_row 0%; /endif%;\
  /if (regmatch("^d$|^d,| d,| d$", %{1})) /set x_status_exits_d=~%; /x_status_exits_update_row 2%; /endif%;

/def -i x_exits_patch =\
  /let pre=$$[substr(x_exits_r%{1}, 0, {2})]%;\
  /let suf=$$[substr(x_exits_r%{1}, $$[{2}+1])]%;\
  /eval /set x_exits_r%{1}=$$[strcat(%{pre}, {3}, %{suf})]

/def -i x_status_exits_normalize = \
  /let input=%{1}%; \
  /let input=$[replace("north", "n", {input})]%; \
  /let input=$[replace("south", "s", {input})]%; \
  /let input=$[replace("west", "w", {input})]%; \
  /let input=$[replace("east", "e", {input})]%; \
  /let input=$[replace("up", "u", {input})]%; \
  /let input=$[replace("down", "d", {input})]%; \
  /return {input}

/set x_status_exits_reset_list=\
  n|north|\
  s|south|\
  e|east|\
  w|west|\
  ne|northest|\
  se|southeast|\
  nw|northwest|\
  sw|southwest|\
  u|up|\
  d|down

/eval /def -i -F -q -mregexp -h'SEND ^(%{x_status_exits_reset_list})$$' \
  _do_x_status_exits_reset=/x_status_exits_reset

;; Exits:  nw, n, ne, w, e, sw, s, se
/def -i -F -p9999 -mregexp -t"Exits:[ ]*([a-z, ]*)$" _update_x_status_exits =\
  /test x_status_exits_update(x_status_exits_normalize({P1}))
;; |        ~w~        |          southwest, west, northwest
/def -i -F -p9999 -mregexp -t"^\|.{19}\|[ ]{10}([a-z, ]*)$" _update_x_status_exits_2 =\
  /test x_status_exits_update(x_status_exits_normalize({P1}))
;; Obvious exits are: u, d, w and n
;; Obvious exit is: south
/def -i -F -p9999 -mregexp -t"^Obvious exit(s are| is): ([a-z, ]*)\.$" _update_x_status_exits_3 =\
  /test x_status_exits_update(x_status_exits_normalize(replace(" and", ",", {P2})))

/set x_status_exits_noway_list=\
  You cannot go that way.|\
  Unknown command.

/eval /def -i -F -p500 -mregexp -t'%{x_status_exits_noway_list}' _do_x_status_exits_look=\
  /send look

/def -i x_status_exits_init =\
  /x_status_exits_reset%;\
  /x_status_exits_update_row 0%;\
  /x_status_exits_update_row 1%;\
  /x_status_exits_update_row 2


;;;;;;;;;;;;;;;;;;;;;;;;
;; Rift walker entity ;;
;;;;;;;;;;;;;;;;;;;;;;;;
/def x_status_entity_skill_off=\
  /set x_status_entity_skill="[S]"

/def x_status_entity_skill_on=\
  /set x_status_entity_skill="[" "S"::BCwhite "]"

/def -i -F -p9999 -mregexp -t"^[A-Za-z]* entity starts concentrating on a new (offensive) skill\.$" _x_status_entity_skill_on=\
  /x_status_entity_skill_on
/def -i -F -p9999 -t"Your entity is prepared to do the skill."=\
  /x_status_entity_skill_off
/def -i -F -p500 -t"Your entity breaks its skill attempt."=\
  /x_status_entity_skill_off

/def -i -F -p9999 -mregexp \
  -t"^--=  ([a-zA-Z]*) entity  HP:([0-9]*)\(([0-9]*)\) \[((\+|-)[0-9]*)?\] \[(controlled)?\] \[(.*)?\]  =--$" \
  _do_x_status_update_entity=\
  /test x_status_update_entity(strip_attr({P1}),{P2},{P3},{P6},{P4})

/def x_status_update_entity=\
  /if (strlen({4}) == 0) \
    /let code="?:"::BCred%;\
  /elseif ({1}=~'Fire') \
    /let code="F:"::BCred%;\
  /elseif ({1}=~'Air') \
    /let code="A:"::BCblue%;\
  /else \
    /let code="X:"::BCred%;\
  /endif%;\
  /set x_status_entity="[" %{code} "%{2}":-4:$[prgetnlite(%{2},%{3})] "/" "%{3}":-4:BCgreen "]"

/def x_status_entity_init=\
	/x_status_entity_skill_off%;\
	/set x_status_entity="[" "???"::Cblue "]"


;;;;;;;;;;;;;;
;; Kick off ;;
;;;;;;;;;;;;;;
/def -i x_status_init =\
;; 17 = 1 (empty/separator) + 3 (navigator+status) + 13 (map)
	/if (status_height < 17) /set status_height=17%;/endif%;\
  /set status_start=1%;\
  /set status_pad= %;\
  /x_status_map_init%;\
  /x_status_exits_init%;\
  /x_status_entity_init%;\
;; separator
	/status_add -r0 -c%;\
;; exits
	/status_add -s0 -r$[status_start] -B -s1 x_status_exits_r0:10%;\
	/status_add -s0 -r$[status_start+1] -c "["%;\
	/status_add -s0 -r$[status_start+1] status_protstr2::Cgreen%;\
	/status_add -s0 -r$[status_start+1] "]"%;\
	/status_add -s0 -r$[status_start+1] -B -s1 x_status_exits_r1:10%;\
	/status_add -s0 -r$[status_start+2] -c x_status_exits_r2:10%;\
;; map
  /let i=0%;\
  /while (i <= 12) \
    /eval /status_add -r$[i + 4] -c x_status_map_r%{i}%;\
    /let i=$[i + 1]%;\
  /done%;\
;; rift walker entity
	/status_add -s1 -r$[status_start+2] %{x_status_entity}%;\
  /status_add -s0 -r$[status_start+2] %{x_status_entity_skill}

/def -i gstatus_update =\
	/gstatus_update_do%;\
	/eval /status_add -c -s0 -r%{status_start} %{status_pstr}%;\
	/status_add -s0 -r$[status_start] -B -s1 x_status_exits_r0:10%;\
	/status_add -s0 -r$[status_start+2] -c x_status_exits_r2:10%;\
	/status_add -s1 -r$[status_start+2] %{x_status_entity}%;\
  /status_add -s0 -r$[status_start+2] %{x_status_entity_skill}

/x_status_init
/gstatus_update
