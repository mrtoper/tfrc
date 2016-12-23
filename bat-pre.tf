;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GgrTF v0.7.4.0 PRE-INIT savefile (Thu Dec 22 22:23:30 2016)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start row used by GgrTF in TF visual mode (GgrTF::TF5 uses 0 by default)
/set status_start=1

; The number of rows in the status area in TF visual mode (GgrTF::TF5 uses 2)
/set status_height=16

; Command/macro used for reporting blast resists
/set cmd_rresist=/msr

; Command/macro used for general magic reporting spam
/set cmd_rmagic=@@emote

; Format string for shape reporting. %{1}=shape colour, %{2}=shape short name, %{3}=percentage, %{4}=target name, %{5}=shape long name
/set fmt_shape=@{Cgreen}%{4} %{5}@{n} [@{%{1}}%{2}@{n}] (@{%{1}}%{3}%%@{n})

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; If keyboard numpad cast bindings should be used, requires GgrTF::TargettedCast module (on/off)
/set opt_keybinds=on

