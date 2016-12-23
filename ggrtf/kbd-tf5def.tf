;;
;; TF5 translative bindings
;; Keyboard bindings for GgrTF under TF5
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/loaded KBD::TF5
/test prdefmodule("KBD_TF5")

;; Line editing
/def -i key_up = /dokey recallb
/def -i key_down = /dokey recallf
/def -i key_nkpEnt = /dokey newline

;; key_end does not seem to be defined for rxvt/xterm?
/def -i -b'^[[7~' = /dokey home
/def -i -b'^[[8~' = /dokey end

;; and neither ctrl+left/right
/def -i -b'^[Od' = /dokey wleft
/def -i -b'^[Oc' = /dokey wright

;; Numpad
/def -i key_nkp8 = /prmove n
/def -i key_nkp2 = /prmove s
/def -i key_nkp4 = /prmove w
/def -i key_nkp6 = /prmove e
/def -i key_nkp7 = /prmove nw
/def -i key_nkp9 = /prmove ne
/def -i key_nkp1 = /prmove sw
/def -i key_nkp3 = /prmove se
/def -i key_nkp5 = /prmove X

