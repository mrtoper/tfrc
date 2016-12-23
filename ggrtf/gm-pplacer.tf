;;
;; GgrTF::PartyPlacer - Automagic party formation saving and restoring
;; (C) Copyright 2006-2015 Aloysha & Matti Hämäläinen (Ggr)
;;
;; This file (triggerset) is Free Software distributed under
;; GNU General Public License version 2.
;;
;; NOTICE! This file requires GgrTF (version 0.6.15 or later) to be loaded.
;;
/loaded GgrTF::PartyPlacer
/test prdefmodule("PartyPlacer", "PSSMangle")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Save positions to save variables
/def -i gparty_save =\
	/for _ccol 1 3 \
	/for _crow 1 3 \
		/let _gps=%%%{_crow}_%%%{_ccol}%%%;\
		/eval /set gparty_%%%{_gps}_fs=$$$$[gparty_%%%{_gps}_s]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Find position of a player in party formation
/def -i gparty_getpos =\
	/let _crow=3%;\
	/while (_crow>0) \
		/let _ccol=3%;\
		/while (_ccol>0) \
			/let _gps=%{_crow}_%{_ccol}%;\
			/let _tps=$[prgetval(strcat("gparty_",_gps,"_s"))]%;\
			/if (_tps=~{1}) /return _gps%;/endif%;\
			/let _ccol=$[_ccol-1]%;\
		/done%;\
		/let _crow=$[_crow-1]%;\
	/done%;\
	/return ""


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Save currently known party formation
/def -i ppsave =\
	/msq Saving current party formation ...%;\
	/set gparty_grab=1%;\
	/set event_pss_once=gparty_save%;\
	@@party status short


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Restore party formation (correct execution requires that you have
;; recently invoked party status so GgrTF knows current party formation)
/def -i ppreset =\
	/msq Restoring saved party formation ...%;\
	/set event_pss_once=gparty_reset_do%;\
	/set gparty_grab=1%;\
	@@party forcefollow all%;\
	@@party status short

/def -i gparty_reset_do =\
	/let _crow=3%;\
	/while (_crow>0) \
		/let _ccol=3%;\
		/while (_ccol>0) \
			/let _gps=%{_crow}_%{_ccol}%;\
			/let _gcur=$[prgetval(strcat("gparty_",_gps,"_s"))]%;\
			/let _gwant=$[prgetval(strcat("gparty_",_gps,"_fs"))]%;\
			/if (_gcur!~_gwant) \
				/if (_gcur!~"" & _gwant!~"") \
					@@party swap %{_gcur} %{_gwant}%;\
					/let _gfpos=$[gparty_getpos(_gwant)]%;\
					/set gparty_%{_gfpos}_s=%{_gcur}%;\
					/set gparty_%{_gps}_s=%{_gwant}%;\
				/elseif (_gwant!~"") \
					@@party place %{_gwant} %{_crow},%{_ccol}%;\
					/let _gfpos=$[gparty_getpos(_gwant)]%;\
					/set gparty_%{_gfpos}_s=%;\
					/set gparty_%{_gps}_s=%{_gwant}%;\
				/endif%;\
			/endif%;\
			/let _ccol=$[_ccol-1]%;\
		/done%;\
		/let _crow=$[_crow-1]%;\
	/done%;\
	/set gparty_grab=1%;\
	@@party forcefollow all%;\
	@@party status short

