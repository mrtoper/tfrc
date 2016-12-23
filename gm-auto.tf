;; some automation

;; open gmap link
/def -p1 -mregexp -t'^URL: (http:\/\/jeskko.pupunen.net\/gmap2\/\?x=[0-9]+\&y=[0-9]+\&zoom=9)$' open_gmap=\
  /sys open '%{P1}'

/set rw_current_entity=
/def -F -q -mregexp -t'(Fire|Air) entity starts concentrating on a new offensive skill\.' _rw_current_entity=\
  /eval /set rw_current_entity=%{P1}

/def rw_use_entity_skill=\
  /if (battle_target!~'')\
    /if (rw_current_entity=~'Fire') /send gem cmd use 'blazing sunder' %{battle_target}%;\
    /elseif (rw_current_entity=~'Air') /send gem cmd use 'suffocating embrace' %{battle_target}%;\
    /endif%;\
  /endif

;; use entity's skill
/def -p1 -mglob -t'Your entity is prepared to do the skill.' _rw_use_entity_skill =\
  /if ({rw_current_entity}=~'Fire') /rw_use_entity_skill%;\
  /endif
/set rw_entity_skill_fail_list=\
  Your air entity falters and its wispy tendrils fall to its sides\.|\
  Your entity loses its concentration and cannot do the skill\.
/eval /def -F -p500 -mregexp -t'^%{rw_entity_skill_fail_list}$$' _rw_use_entity_skill_on_fail=\
  /rw_use_entity_skill
;; stop entity's skill
/def -p1 -mglob -t'Your entity failed to find a target.' stop_bs = /send gem cmd use stop


/set event_battle_end=x_event_battle_end
/def x_event_battle_end=\
  /echo -p @{Wu}BATTLE END!@{n}%;\
  /send cast stop%;\
  /send gem cmd use stop
/def goto=\
  /if ({1}=='bfarm')\
    /send tv e;tv s;tv e;tv ne;tv n;tv nw;tv w 49; 20 n%;\
  /endif
/def backfrom=\
  /if ({1}=='bfarm')\
    /send 20 s;tv e;tv se;tv s;tv sw;tv w;tv nw;tv w%;\
  /endif
