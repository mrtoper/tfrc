;;
;; GgrTF::TF5 - TinyFugue 5.x compatibility and extras
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
/loaded GgrTF:TF5
/test prdefmodule("TF5")

/if (gtf_version < 50007)\
	/gerror This module is designed for TinyFugue v5.0 beta 7 or later, it does not work in older versions of TF%;\
	/exit%;\
/endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TF5 extended statusline handling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gstatus_init =\
	/prdefvar -n"status_height" -v"2" -c"The number of rows in the status area in TF visual mode (GgrTF::TF5 uses 2)"%;\
	/prdefvar -n"status_start" -v"0" -c"Start row used by GgrTF in TF visual mode (GgrTF::TF5 uses 0 by default)"%;\
	/if (status_height < 2) /set status_height=2%;/endif%;\
	/status_add -s0 -r$[status_start+1] -c "["%;\
	/status_add -s0 -r$[status_start+1] status_protstr2::Cgreen%;\
	/status_add -s0 -r$[status_start+1] "]"

/def -i gstatus_update =\
	/gstatus_update_do%;\
	/eval /status_add -c -s0 -r%{status_start} %{status_pstr}

/gstatus_init
/gstatus_update
