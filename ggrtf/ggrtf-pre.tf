;;
;; GgrTF::PreInit - Module for loading saved settings and pre-initialization
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
;; This file should be loaded BEFORE loading of ggrtf.tf or modules.
;;
/loaded GgrTF:PreInit

/def -i gloadpreinit =\
	/let _spreinit=%{set_datapath}%{set_saveprefix}pre.tf%;\
	/echo -p @{BCgreen}Loading pre-init settings from@{n} '@{Cyellow}%{_spreinit}@{n}'%;\
	/load -q %{_spreinit}%;\
	/echo -p @{BCgreen}Done.@{n}%;\


/gloadpreinit

;; Filter out liting/attribute options
/def -i gfilterlites =\
	/let _new=%;\
	/while ({#})\
		/if (!regmatch("^(-aBC|-aC|-P|-ab)",{1}))\
			/let _new=%{_new} %{1}%;\
		/endif%;\
		/shift%;\
	/done%;\
	/result _new

;; Magic happens here
/def -i gdef =\
	/if (opt_lites!~"on")\
		/split %{*}%;\
		/let _opts=%{P1}%;\
		/let _body=%{P2}%;\
		/let _nopts=$(/gfilterlites %{_opts})%;\
		/def %{_nopts} = %{_body}%;\
	/else \
		/def %{*}%;\
	/endif

;; Macro for defining plain lites (with no functionality)
/def -i glite =\
	/if (opt_lites!~"on")\
	/else \
		/def -i -F -p1 %{*}%;\
	/endif
