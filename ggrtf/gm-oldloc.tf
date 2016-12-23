;;
;; GgrTF::OldLoC - Old Lords of Chaos guild support @ BatMUD
;; (C) Copyright 2005-2008 Jarkko V‰‰r‰niemi (Jeskko) & Matti H‰m‰l‰inen (Ggr)
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
;; NOTICE! This file requires GgrTF (version 0.6.12 or later) to be loaded.
;;
/loaded GgrTF::OldLoC
/test prdefmodule("OldLoC")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fails and fumbles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdeffail -k -f -r -t"^Your blade doesn\'t even come close to "
/prdeffail -k -F -r -t"^Something goes terribly wrong as you bring .+ across to connect with"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LoC blood
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdefripfunc blood @lord_chaos blood corpse
/ripaction blood

;@command /ripaction <action>
;@desc LoC module adds option "blood" to /ripaction, which automagically
;@desc runs "lord_chaos blood corpse" on monster RIP.

;@command /locaction <action>
;@desc This setting is related to LoCs, but defined in main GgrTF module
;@desc as also other than LoCs have use for this, if partying with a LoC.
