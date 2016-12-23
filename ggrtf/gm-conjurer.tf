;;
;; GgrTF::Conjurer - Conjurer guild support @ BatMUD
;; (C) Copyright 2006-2015 Matti Hämäläinen (Ggr)
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
/loaded GgrTF::Conjurer
/test prdefmodule("Conjurer", "Magical")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdefcbind -s"rdisp"	-c"Resist Dispel"
/prdefcbind -s"sop"	-c"Shield of Protection"
/prdefcbind -s"bi"	-c"Blurred Image"
/prdefcbind -s"disp"	-c"Displacement"
/prdefcbind -s"shelter"	-c"Shelter"		-n	-d"Sheltering ..."
/prdefcbind -s"dmp"	-c"Dispel Magical Protection"
/prdefcbind -s"nf"	-c"Neutralize Field"	-n
/prdefcbind -s"mi"	-c"Mirror Image"
/prdefcbind -s"iw"	-c"Iron Will"
/prdefcbind -s"rentr"	-c"Resist Entropy"
/prdefcbind -s"fabs"	-c"Force Absorption"
/prdefcbind -s"cmana"	-c"Magic Dispersion"
/prdefcbind -s"cpoison"	-c"Toxic Dilution"
/prdefcbind -s"ccold"	-c"Frost Insulation"
/prdefcbind -s"cfire"	-c"Heat Reduction"
/prdefcbind -s"cacid"	-c"Corrosion Shield"
/prdefcbind -s"celec"	-c"Energy Channeling"
/prdefcbind -s"casphyx"	-c"Ether Boundary"
/prdefcbind -s"cpsi"	-c"Psychic Sanctuary"
/prdefcbind -s"aoa"	-c"Armour of Aether"
/prdefcbind -s"mmana"	-c"Repulsor Aura"
/prdefcbind -s"mpoison"	-c"Shield of Detoxification"
/prdefcbind -s"mcold"	-c"Frost Shield"
/prdefcbind -s"mfire"	-c"Flame Shield"
/prdefcbind -s"macid"	-c"Acid Shield"
/prdefcbind -s"melec"	-c"Lightning Shield"
/prdefcbind -s"masphyx"	-c"Aura of Wind"
/prdefcbind -s"mpsi"	-c"Psionic Phalanx"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Numpad cast bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;/eval /gcheck_keybinds

;; Meta/Alt + [qwer] = Single, targetted heals
;/def -i -b'^[q' = /prcast cure light wounds
;/def -i -b'^[w' = /prcast cure serious wounds
;/def -i -b'^[e' = /prcast cure critical wounds
;/def -i -b'^[r' = /prcast major heal
;/def -i -b'^[t' = /prcast true heal
