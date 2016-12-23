;;
;; xterm, rxvt and compatibles
;; Keyboard bindings for GgrTF under TF4/5
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/loaded KBD::XTerm
/test prdefmodule("KBD_XTerm")

;; Line editing
/def -i -b'^[[A' = /dokey recallb
/def -i -b'^[[B' = /dokey recallf
/def -i -b'^[OM' = /dokey newline
/def -i -b'^[[7~' = /dokey home
/def -i -b'^[[8~' = /dokey end
/def -i -b'^[Od' = /dokey wleft
/def -i -b'^[Oc' = /dokey wright

;; Numpad
/def -i -b'^[Ox' = /prmove n
/def -i -b'^[Or' = /prmove s
/def -i -b'^[Ot' = /prmove w
/def -i -b'^[Ov' = /prmove e
/def -i -b'^[Ow' = /prmove nw
/def -i -b'^[Oy' = /prmove ne
/def -i -b'^[Oq' = /prmove sw
/def -i -b'^[Os' = /prmove se
/def -i -b'^[Ou' = /prmove X
