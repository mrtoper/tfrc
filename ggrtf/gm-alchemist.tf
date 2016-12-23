;;
;; GgrTF::Alchemist - Alchemist guild support and utility macros
;; (C) Copyright 2010-2015 Matti Hämäläinen (Ggr)
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
/loaded GgrTF:Alchemist
/test prdefmodule("Alchemist")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General settings and data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/eval /set galch_file=%{HOME}/alch_results.txt


/set galch_cans=\
	arm_ear			\
	antenna_beak		\
	bladder_brain		\
	eye_foot		\
	heart_horn		\
	leg_liver		\
	lung_kidney		\
	nose_paw		\
	spleen_stomach		\
	tail_snout		\
	tendril_wing		\
	c_gill


/set galch_jars=\
	apple_arnica_barberry		\
	bloodmoss_bloodroot_blueberry	\
	boneset_borage_burdock		\
	cabbage_carrot_cauliflower	\
	chickweed_chicory_comfrey	\
	costmary_cotton_crystalline	\
	elder_foxglove_garlic		\
	ginseng_hemlock_henbane		\
	holly_honeysuckle_jaslah	\
	lettuce_lobelia_lungwort	\
	mandrake_mangrel_mistletoe	\
	mugwort_mushroom_nightshade	\
	onion_pear_plum			\
	potato_raspberry_rhubarb	\
	soapwort_spinach_strawberry	\
	sweetflag_thistle_tomato	\
	turnip_vineseed_waterlily	\
	wolfbane_wormwood_yarrow	\
	j_jimsonweed
	

/set galch_organs=antenna|arm|beak|bladder|brain|ear|eye|foot|gill|heart|horn|kidney|leg|liver|lung|nose|paw|snout|spleen|stomach|tail|tendril|wing
/set galch_minerals=adamantium|aluminium|anipium|batium|brass|bronze|cesium|chromium|cobalt|copper|darksteel|diggalite|dukonium|duraluminium|durandium|electrum|gold|graphite|hematite|highsteel|illumium|indium|iridium|iron|kryptonite|lead|magnesium|mithril|molybdenum|mowgles|mowglite|nickel|nullium|osmium|palladium|pewter|platinum|potassium|pyrite|quicksilver|rhodium|silicon|silver|starmetal|steel|tadmium|tin|titanium|tormium|tungsten|uranium|vanadium|zhentorium|zinc
/set galch_herbs=apple|arnica|barberry|blood_moss|bloodroot|blueberry|boneset|borage|burdock|cabbage|carrot|cauliflower|chickweed|chicory|comfrey|costmary|cotton|crystalline|elder|foxglove|garlic|ginseng|hcliz|hemlock|henbane|holly|honeysuckle|jaslah|jimsonweed|lettuce|lobelia|lungwort|mandrake|mangrel|mistletoe|mugwort|mushroom|mystic_carrot|mystic_spinach|nightshade|onion|pear|plum|potato|raspberry|rhubarb|soapwort|spinach|strawberry|sweet_flag|thistle|tomato|turnip|vine_seed|water_lily|wolfbane|wormwood|yarrow


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Automatically label jars and cans
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i galch_label =\
	/let _item=%{1}%;\
	/let _num=1%;\
	/shift%;\
	/while ({#})\
		@@label %{_item} %{_num} as %{1}%;\
		/let _num=$[_num + 1]%;\
		/shift%;\
	/done


;@command /dolabels
;@desc Automatically re-label any jars and cans you have, to match the
;@desc naming scheme of GgrTF Alchemist module for those containers.
/def -i dolabels =\
	/galch_label jar %{galch_jars}%;\
	/galch_label can %{galch_cans}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i galch_get_item =\
	/let _item=$[replace("_", "", {1})]%;\
	/let _match=$[strcat("^", _item, "_|_", _item, "_|_", _item, "$")]%;\
	/shift%;\
	/while ({#})\
		/if (regmatch(_match, {1})) /result {1}%;/endif%;\
		/shift%;\
	/done%;\
	/result ""


/def -i galch_herb_fixes =\
	/if (regmatch("^vine|^seed", {1})) /return "vine_seed"%;\
	/elseif (regmatch("lily", {1})) /return "water_lily"%;\
	/elseif (regmatch("mushroom", {1})) /return "mushroom"%;\
	/else /return {1}%;/endif


;@command /mix <mineral> <organ> <herb>
;@desc Mix a potion from given materials. This command will automatically
;@desc retrieve organ and herb components from their specific containers.
;@desc The other logic in the module will also return them into those containers
;@desc if the skill is interrupted for some reason.
;@desc Also, organ and herb names are checked for sanity.
/def -i mix =\
	/if ({#} < 3)\
		/msq Usage: /mix <mineral> <organ> <herb>%;\
		/set alch_testing=0%;\
		/break%;\
	/endif%;\
	/set alch_mineral=%{1}%;\
	/set alch_organ=%{2}%;\
	/set alch_herb=$[galch_herb_fixes({3})]%;\
	/if (!regmatch(strcat("^(",galch_minerals,")$"), alch_mineral))\
		/msq Invalid mineral '%{alch_mineral}'.%;\
		/let _error=1%;\
	/endif%;\
	/if (!regmatch(strcat("^(",galch_organs,")$"), alch_organ))\
		/msq Invalid organ '%{alch_organ}'.%;\
		/let _error=1%;\
	/endif%;\
	/if (!regmatch(strcat("^(",galch_herbs,")$"), alch_herb))\
		/msq Invalid herb/plant '%{alch_herb}'.%;\
		/let _error=1%;\
	/endif%;\
	/if (_error)\
		/set alch_testing=0%;\
		/break%;\
	/endif%;\
	/set alch_can=$(/galch_get_item %{alch_organ} %{galch_cans})%;\
	/if (alch_can=~"")\
		/msq No matching can for organ '%{alch_organ}'.%;\
		/let _error=1%;\
	/endif%;\
	/set alch_jar=$(/galch_get_item %{alch_herb} %{galch_jars})%;\
	/if (alch_jar=~"")\
		/msq No matching jar for herb '%{alch_herb}'.%;\
		/let _error=1%;\
	/endif%;\
	/if (_error)\
		/set alch_testing=0%;\
		/break%;\
	/endif%;\
	/set alch_st=1%;\
	/let _herb=$[replace("_"," ", alch_herb)]%;\
	@@get %{_herb} from %{alch_jar}%;\
	/set alch_process=$(/grepeat -14 1 /galch_get_organ)%;\
	/msq @{BCwhite}Mixing potion from@{n} '@{BCyellow}%{alch_mineral}@{n}', '@{BCcyan}%{alch_organ}@{n}' and '@{BCgreen}%{_herb}@{n}'...%;\
	@@use mix potion at prepared flask use %{alch_mineral} %{alch_organ} %{_herb}


;@command /tmix <mineral> <organ> <herb>
;@desc Same as /mix, will mix a potion from given materials, but also
;@desc performs functions for potion research. Finished potion will be
;@desc submitted to authenticator, so only use this command when you
;@desc are doing potion research and reside in the authenticator room of the alchemist guild.
/def -i tmix =\
	/if (alch_testing)\
		/msq Previous test still running.%;\
	/else \
		/set alch_testing=1%;\
		/set alch_submit=1%;\
		/mix %{*}%;\
	/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i galch_get_organ =\
	/if (alch_st)\
		/set alch_hasorgan=1%;\
		@@get %{alch_organ} from %{alch_can}%;\
	/endif

/def -i galch_return =\
	/set alch_st=0%;\
	/kill %{alch_process}%;\
	/if (alch_hasorgan)\
		/set alch_hasorgan=0%;\
		/msq Returning '%{alch_organ}' in can '%{alch_can}'%;\
		@@put %{alch_organ} in %{alch_can}%;\
	/endif%;\
	/if (alch_jar!~"" & alch_herb!~"")\
		/let _herb=$[replace("_"," ", alch_herb)]%;\
		/msq Returning '%{_herb}' in can '%{alch_jar}'%;\
		@@put %{_herb} in %{alch_jar}%;\
	/endif%;\
	/set alch_testing=0


/gdef -i -msimple -Ealch_st -aBCred -t"You need a prepared alchemist's flask first." galch_need_flask =\
	/galch_return


/gdef -i -mregexp -Ealch_st -aBCred -t"^You do not seem to have any '([a-z_ -]+)' on you\.$" galch_has_no1 =\
	/galch_return

/gdef -i -mregexp -Ealch_st -aBCred -t"^ \.\. but you do not (seem to have any '[a-z_ -]+' on you|have enough '[a-z_ -]+' left)\." galch_has_no2 =\
	/galch_return


/def -i galch_interrupted =\
	/if (alch_st) /galch_return%;/endif

/test prlist_insert("event_skill_intr", "galch_interrupted")
/test prlist_insert("event_skill_stop", "galch_interrupted")


/gdef -i -F -aBCwhite -mregexp -t"^You mix the ingredients together and wait for the contents settle. A flask containing" galch_flask_ready =\
	/set alch_st=0%;\
	/set alch_close=0%;\
	/set alch_hasorgan=0%;\
	/if (alch_submit)\
		/set alch_submit=0%;\
		@@submit flask%;\
	/endif

/def -i galch_update =\
	/let _file=$[tfopen(galch_file, "a")]%;\
	/if (_file < 0)\
		/msq Could not open '%{galch_file}'! Match data not saved!%;\
		/return 0%;\
	/else \
		/let _line=%{alch_mineral}	%{alch_organ}	%{alch_herb}	%{1}%;\
		/test tfwrite(_file, _line)%;\
		/test tfclose(_file)%;\
		/return 1%;\
	/endif


/def -i galch_add_nomatch =\
	/if (alch_close)\
		/msq Ready for next mix.%;\
	/else \
		/if (galch_update("-"))\
			/msq Added no match for %{alch_mineral}, %{alch_organ}, %{alch_herb} to database.%;\
		/endif%;\
	/endif%;\
	/set alch_testing=0

/gdef -i -F -aCgreen -mregexp -t"^You submit the contents of a flask containing " galch_submit_done =\
	@@drop empty flask%;\
	/repeat -2 1 /galch_add_nomatch

/gdef -i -F -aCgreen -msimple -t"You feel close..." galch_submit_close1 =\
	/set alch_close=1

/gdef -i -F -aCgreen -mregexp -Ealch_close -t"^\.\.\.could be ([a-z_ -]+)\." galch_submit_close2 =\
	/let _match=$[replace(" ","_",{P1})]%;\
	/if (galch_update(strcat("?", _match)))\
		/msq Added near-match '%{_match}' (%{alch_mineral}, %{alch_organ}, %{alch_herb}) to database.%;\
	/endif

/gdef -i -F -aCgreen -mregexp -t"^Flask '([a-z_ -]+)' accepted\." galch_submit_match =\
	/set alch_close=1%;\
	/let _match=$[replace(" ","_",{P1})]%;\
	/if (galch_update(strcat("!", _match)))\
		/msq Added MATCH '%{_match}' (%{alch_mineral}, %{alch_organ}, %{alch_herb}) to database.%;\
	/endif

/gdef -i -F -aBCred -msimple -t"You've already researched that flask." galch_submit_already =\
	/set alch_close=1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Herb and organ management helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Store organ into proper can
/def -i galch_store_organ =\
	/let _organ=%{1}%;\
	/let _can=$(/galch_get_item %{_organ} %{galch_cans})%;\
	/if (opt_canmisc=~"on" | _can=~"") /let _can=can_misc%;/endif%;\
	/msq Store '%{_organ}' in '%{_can}'.%;\
	@@get %{_organ}%;\
	@@put %{_organ} in %{_can}


;; Store herb into proper jar
/def -i galch_store_herb =\
	/let _herb=$[galch_herb_fixes({1})]%;\
	/if (regmatch("^(purplish|light green|a green|white|orange|red|blue|green|yellow|head of|orange|brown) ([a-z]+)", _herb))\
		/let _herb=%{P2}%;\
	/endif%;\
	/let _jar=$(/galch_get_item %{_herb} %{galch_jars})%;\
	/let _herb=$[replace("_"," ",_herb)]%;\
	/if (opt_canmisc=~"on" | _jar=~"") /let _jar=jar_misc%;/endif%;\
	/msq Store '%{_herb}' in '%{_jar}'.%;\
	@@put %{_herb} in %{_jar}


;; Dissection and herb picking triggers
/def -i -F -mregexp -t"^You carefully remove a bloody bodypart '([a-z]+)'\.$" galch_dissect1 =\
	/test galch_store_organ({P1})

/def -i -F -mregexp -t"^ \.\.and slicing expertly, you cut out a second organ '([a-z]+)'\.$" galch_dissect2 =\
	/test galch_store_organ({P1})

/def -i -F -mregexp -t"^You pick ([a-z -]+)\.$" galch_pick =\
	/if ({P1}!~"your nose")\
		/test galch_store_herb({P1})%;\
	/endif


;@command /wconlook <herb or organ name>
;@desc Automatically look into a container containing specified type of herb or organ.
;@desc This is basically the same as 'look at jar x' or 'look at can y', except
;@desc "/wconlook blueberry" would automatically look into the correct container.
/def -i wconlook =\
	/let _item=$[galch_herb_fixes({*})]%;\
	/let _cont=$(/galch_get_item %{_item} %{galch_jars})%;\
	/if (_cont!~"")\
		@@look at %{_cont}%;\
	/else \
		/let _cont=$(/galch_get_item %{_item} %{galch_cans})%;\
		/if (_cont!~"")\
			@@look at %{_cont}%;\
		/else \
			/msq No match for '%{_item}'.%;\
		/endif%;\
	/endif

/prdefgbind -s"wla" -c"/wconlook"


;; Automatically put item into a container containing specified type of herb or organ
/def -i galch_container_cmd =\
	/let _cmd=%{1}%;/shift%;\
	/let _arg=%{1}%;/shift%;\
	/if (regmatch("^([0-9]+|all)$", {1}))\
		/let _count=%{1}%;\
		/shift%;\
	/else \
		/let _count=%;\
	/endif%;\
	/let _itemcnt=$[galch_herb_fixes({*})]%;\
	/let _item=$[replace("_"," ",_itemcnt)]%;\
	/if (_count!~"")\
		/let _tgt=%{_count} %{_item}%;\
	/else \
		/let _tgt=%{_item}%;\
	/endif%;\
	/let _cont=$(/galch_get_item %{_itemcnt} %{galch_jars})%;\
	/if (_cont!~"")\
		@@%{_cmd} %{_tgt} %{_arg} %{_cont}%;\
	/else \
		/let _cont=$(/galch_get_item %{_item} %{galch_cans})%;\
		/if (_cont!~"")\
			@@%{_cmd} %{_tgt} %{_arg} %{_cont}%;\
		/else \
			/msq No match for '%{_item}'.%;\
		/endif%;\
	/endif

;@command /wconput <herb or organ>
;@desc Place specified herb or organ into correct container.
/def -i wconput = /galch_container_cmd put in %{*}
/prdefgbind -s"wput" -c"/wconput"


;@command /wconget <herb or organ>
;@desc Get specified herb or organ from correct container.
/def -i wconget = /galch_container_cmd get from %{*}
/prdefgbind -s"wget" -c"/wconget"
