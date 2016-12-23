;;
;; GgrTF::Merchant - Merchant guild support and utility macros
;; (C) Copyright 2005-2015 Matti Hämäläinen (Ggr)
;;
;; This file (triggerset) is Free Software distributed under
;; GNU General Public License version 2.
;;
;; NOTICE! This file requires GgrTF (version 0.6.15 or later) to be loaded.
;;
/loaded GgrTF:Merchant
/test prdefmodule("Merchant")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General settings and data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;@command /havebelt
;@desc Toggle support for merchant belt functionality on/off.
/prdeftoggle -n"havebelt" -d"Use merchant belt functionality"

;@command /usepouch
;@desc Toggle whether to use a reagent pouch with /mr (make reagent)
;@desc command's functionality. See also /pouchname.
/prdeftoggle -n"usepouch" -d"Use reagent pouch as target in /mr"

;@command /pouchname
;@desc Set name of the reagent pouch to use with /mr skill. Used only
;@desc if /usepouch option has been enabled.
/prdefvalue -n"pouchname" -d"Name of reagent pouch if usepouch enabled"

;@command /boxname
;@desc Name of the mineral box to use with /mbox operation mode.
;@desc Default value is 'collect'.
/prdefvalue -n"boxname"   -d"Name of mineral box for /mbox"
/set set_boxname=collect

;; Defaults for tools and workbenches
/set set_mforge_bs=metal
/set set_mforge_cp=lumber
/set set_mforge_gc=gems
/set set_mforge_gb=glassware
/set set_mforge_ma=masonry
/set set_mforge_sw=loom
/set set_mforge_sc=sculpture

/set set_mtool_bs=hammer
/set set_mtool_cp=saw
/set set_mtool_gc=hammer
/set set_mtool_gb=tube,tongs
/set set_mtool_ma=hammer
/set set_mtool_sw=needle
/set set_mtool_sc=hammer
/set set_mtool_mine=pick
/set set_mtool_lj=saw

;; Material data
;; TODO FIXME! This probably would be better to have elsewhere...
/set gmat_names=adamantium air alabaster alexandrite aluminium amber amethyst anipium aquamarine bamboo bark basalt batium birch bloodstone bone brass brick bronze burlap carnelian cedar cesium chalk charcoal chromium chrysoberyl clay cloth coal cobalt concrete copper coral cork cotton crystal darksteel diamond diggalite dragonscale dukonium duraluminium durandium earth ebony electrum elm emerald emulsion enchanted_air feathers fire flesh food fur garnet glass gold granite graphite hematite hemp highsteel ice illumium indium iridium iron ivory jade kryptonite laen lead leather magnesium mahogany malachite mallorn maple marble marlor mithril molybdenum moonstone moss_agate mowgles mowglite neo_burlap nickel nullium oak obsidian olivine onyx opal osmium palladium paper pearl petrified_wood pewter phosphorus platinum porcelain potassium pyrite quartz quicksilver rhodium rhodonite rift_plasma rubber ruby sapphire silicon silk silver slate starmetal steel steuben stone sulphur sunstone tadmium tin titanium topaz tormium tungsten turquoise uranium vanadium vegetation water wax weenite wood wool zhentorium zinc zircon
/set gmat_ntypes=metal organic inorganic gem metal stone gem metal gem wood wood stone metal wood gem bone alloy stone alloy cloth gem wood metal stone organic metal gem stone cloth stone metal stone metal bone wood cloth glass alloy gem metal bone metal alloy metal stone wood metal wood gem organic organic organic inorganic organic organic cloth gem glass metal stone metal metal organic alloy organic metal metal metal metal bone gem metal glass metal cloth metal wood gem wood wood stone wood metal metal stone gem metal metal cloth metal metal wood glass gem gem gem metal metal paper gem stone alloy organic metal inorganic metal metal gem metal metal gem inorganic inorganic gem gem metal cloth metal stone metal alloy glass stone stone gem metal metal metal gem metal metal gem metal metal organic organic organic gem wood cloth metal metal gem
/set gmat_types=alloy bone cloth gem glass inorganic metal organic paper stone wood
/set gmat_type_alloy=brass|bronze|darksteel|duraluminium|highsteel|pewter|steel
/set gmat_type_bone=bone|coral|dragonscale|ivory
/set gmat_type_cloth=burlap|cloth|cotton|fur|leather|neo burlap|silk|wool
/set gmat_type_gem=alexandrite|amethyst|aquamarine|bloodstone|carnelian|chrysoberyl|diamond|emerald|garnet|jade|malachite|moss agate|olivine|onyx|opal|pearl|quartz|rhodonite|ruby|sapphire|sunstone|topaz|turquoise|weenite|zircon
/set gmat_type_glass=crystal|glass|laen|obsidian|steuben
/set gmat_type_inorganic=alabaster|fire|porcelain|rift plasma|rubber
/set gmat_type_metal=adamantium|aluminium|anipium|batium|cesium|chromium|cobalt|copper|diggalite|dukonium|durandium|electrum|gold|graphite|hematite|illumium|indium|iridium|iron|kryptonite|lead|magnesium|mithril|molybdenum|mowgles|mowglite|nickel|nullium|osmium|palladium|platinum|potassium|pyrite|quicksilver|rhodium|silicon|silver|starmetal|tadmium|tin|titanium|tormium|tungsten|uranium|vanadium|zhentorium|zinc
/set gmat_type_organic=air|charcoal|emulsion|enchanted air|feathers|flesh|food|hemp|ice|phosphorus|vegetation|water|wax
/set gmat_type_paper=paper
/set gmat_type_stone=amber|basalt|brick|chalk|clay|coal|concrete|earth|granite|marble|moonstone|petrified wood|slate|stone|sulphur
/set gmat_type_wood=bamboo|bark|birch|cedar|cork|ebony|elm|mahogany|mallorn|maple|marlor|oak|wood

;; Reagent data
/set gmr_names=olivine stone bloodstone highsteel leather bronze steel electrum glass fur copper onyx ebony granite cobalt iron tungsten platinum quartz amethyst mallorn brass

;; Material              Spell name                Reagent name                  Exchange name
;;-------------------------------------------------------------------------------------------------
/set gmr_mat_olivine=    Acid_Blast                handful_of_olivine_powder     olivine_powder
/set gmr_mat_stone=      Acid_Shield               stone_cube                    stone_cube
/set gmr_mat_bloodstone= Acid_Storm                pair_of_interlocked_rings     interlocked_rings
/set gmr_mat_highsteel=  Armour_of_Aether          small_highsteel_disc          highsteel_disc
/set gmr_mat_leather=    Aura_of_Wind              tiny_leather_bag              leather_bag
/set gmr_mat_bronze=     Blast_Vacuum              bronze_marble                 bronze_marble
/set gmr_mat_steel=      Cold_Ray                  steel_arrowhead               steel_arrowhead
/set gmr_mat_electrum=   Electrocution             small_piece_of_electrum_wire  electrum_wire
/set gmr_mat_glass=      Flame_Shield              small_glass_cone              glass_cone
/set gmr_mat_fur=        Frost_Shield              grey_fur_triangle             fur_triangle
/set gmr_mat_copper=     Golden_Arrow              copper_rod                    copper_rod
/set gmr_mat_onyx=       Hailstorm                 handful_of_onyx_gravel        onyx_gravel
/set gmr_mat_ebony=      Killing_Cloud             ebony_tube                    ebony_tube
/set gmr_mat_granite=    Lava_Blast                granite_sphere                granite_sphere
/set gmr_mat_cobalt=     Lava_Storm                blue_cobalt_cup               cobalt_cup
/set gmr_mat_iron=       Lightning_Shield          small_iron_rod                iron_rod
/set gmr_mat_tungsten=   Lightning_Storm           cluster_of_tungsten_wires     tungsten_wire
/set gmr_mat_platinum=   Magic_Eruption            tiny_platinum_hammer          platinum_hammer
/set gmr_mat_quartz=     Repulsor_Aura             quartz_prism                  quartz_prism
/set gmr_mat_amethyst=   Shield_of_Detoxification  tiny_amethyst_crystal         amethyst_crystal
/set gmr_mat_mallorn=    Summon_Carnal_Spores      silvery_bark_chip             bark_chip
/set gmr_mat_brass=      Vacuum_Globe              small_fan                     small_fan


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Item move handling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;@command /mdisc
;@desc Change item move target to your floating disc.
/def -i mdisc = /msq Move Items -> @{Cgreen}disc@{n}%;\
	/undef gmatmove_start%;/def -i gmatmove_start =%;\
	/undef gmatmove_item%;/def -i gmatmove_item = @@put %%* in my disc%;\
	/undef gmatmove_end%;/def -i gmatmove_end =

;@command /mbox
;@desc Change item move target to box (labeled as 'collect' by default,
;@desc use /boxname command to change this setting.)
/def -i mbox = /msq Move Items -> @{Cgreen}%{set_boxname}@{n}%;\
	/undef gmatmove_start%;/def -i gmatmove_start = @@drop %%{set_boxname}%;\
	/undef gmatmove_item%;/def -i gmatmove_item = @@put %%* in %%{set_boxname}%%;@@get %%*%;\
	/undef gmatmove_end%;/def -i gmatmove_end = @@get %%{set_boxname}

;@command /mdrop
;@desc Change item move target to dropping of the item.
/def -i mdrop = /msq Move Items -> @{Cgreen}drop@{n}%;\
	/undef gmatmove_start%;/def -i gmatmove_start =%;\
	/undef gmatmove_item%;/def -i gmatmove_item = @@drop %%*%;\
	/undef gmatmove_end%;/def -i gmatmove_end =

/mdisc


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fails & fumbles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; We catch lots of these, but probably not nearly all.
;; Merchants can fumble and fail in so many wonderful ways, some of these
;; might be up to debate whether they are fumbles or fails. My criteria
;; has been that if it damages material, it is fumble, otherwise it is fail.

/prdeffail -k -F -r -t"^Bang! Bang! You forge "
/prdeffail -k -F -r -t"^You bang and bang the .* but wood refuses to bend"
/prdeffail -k -F -r -t"^You (fail to get anything useful done and discard the material|hammer and hammer as the piece of .+ won't fit the construction|fumble and cut|slip up and fumble your attempt|slip up and damage your ore|slip and cut the ore in the wrong place|screw up big time and ruin your ore completely)"
/prdeffail -k -F -r -t"^(Oh drat, you fumbled the skill and lost the salve|OH NO! *You really were not paying attention|OUCH, you cut your hand while trying to skin|Oops! Your grip on the .* slips, and you damage)"

/prdeffail -k -f -r -t"^OUCH! You swing your hammer and hit your own thumb."
/prdeffail -k -f -r -t"^You completely fail to amalgamate the (material|ore) properly\.$"
/prdeffail -k -f -r -t"^You (try to label .+ but cannot get it done properly|mine for a long time but don't find anything|are unable to find a good splitting point|try to improve .+'s appearance but you fail)\.$"
/prdeffail -k -f -r -t"^(ARGH! *DARN! *CRAP! *You drop|Oh shoot! You nick)"
/prdeffail -k -f -r -t"^You fail to (alloy the substances properly|refine the ore properly|get the parts to fit|.+ into its base material)\.$"

;You are unable to assemble anything.                                                                                          

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Workbench and tool helper code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tool wielding function
/set mwb_mode=
/set mwb_target=1
/set mwb_wielded=

/def -i gwb_wield_tool =\
	/if (opt_havebelt=~"on" & {1}=~"")\
		/set mwb_wield=toolbelt%;\
	/else \
		/set mwb_wield=%{1}%;\
	/endif%;\
	/if (mwb_wielded!~{1})\
		/if (mwb_wielded!~"")\
			/msq Switching '%{mwb_wielded}' -> '%{mwb_wield}'%;\
			@@remove %{mwb_wielded}%;\
			/if ({1}!~"")\
				@@wield %{1}%;\
			/endif%;\
		/elseif ({1}!~"")\
			/msq Wielding -> '%{1}'%;\
			@@wield %{1}%;\
		/endif%;\
		/set mwb_wielded=%{1}%;\
	/endif

;; Get workbench type for given material
/eval /def -i gwb_get_type =\
	/if (regmatch("^(%{gmat_type_alloy}|%{gmat_type_metal})$$",{1})) /return "bs"%%;\
	/elseif (regmatch("^(%{gmat_type_gem})$$",{1})) /return "gc"%%;\
	/elseif (regmatch("^(%{gmat_type_stone})$$",{1})) /return "ma"%%;\
	/elseif (regmatch("^(%{gmat_type_wood}|%{gmat_type_bone})$$",{1})) /return "cp"%%;\
	/elseif (regmatch("^(%{gmat_type_glass})$$",{1})) /return "gb"%%;\
	/elseif (regmatch("^(%{gmat_type_organic}|%{gmat_type_cloth})$$",{1})) /return "sw"%%;\
	/elseif (regmatch("^(%{gmat_type_inorganic})$$",{1})) /return "sc"%%;\
	/else /return ""%%;/endif

;; (Assume everything to be metal/bs by default)
/def -i gwb_set_bench =\
	/set mwb_type=$[gwb_get_type({1})]%;\
	/if (mwb_type=~"")\
		/msq @{Cred}No workbench type found for material@{n} '@{BCwhite}%{1}@{n}'%;\
		/return 0%;\
	/endif%;\
	/set mwb_forge=$[prgetval(strcat("set_mforge_",mwb_type))]%;\
	/set mwb_tool=$[prgetval(strcat("set_mtool_",mwb_type))]%;\
	/return 1


;; Check new mode against currently set working mode and change tools etc. if necessary.
/def -i gwb_check_mode =\
	/if (mwb_mode!~{1} | mwb_target!~{3} | !mwb_merchant)\
		/set mwb_target=%{3}%;\
		/set mwb_mode=%{1}%;\
		/test gwb_wield_tool({2})%;\
	/endif%;\
	/set mwb_merchant=1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Non-merchant skills
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hook into skill starts to remove merchant tools when using non-merchant skills
/def -i gunwield_tool =\
	/if (!mwb_merchant & mwb_wielded!~"")\
		/test gwb_wield_tool("")%;\
	/endif%;\
	/set mwb_merchant=0

/test prlist_insert("event_skill_start", "gunwield_tool")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LUMBERJACKING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set mwb_mode=
/set mwb_target=1
/set lj_target=

;A birch tree with smooth, papery bark is growing here.
;A tall mahogany tree is growing here.
;A dark grey elm tree stands here.
;A cedar tree with smooth bark stands here.
;A maple tree is growing here.
/def -i glumberjack_grep =\
	/if (regmatch("^pine|holly$",{1}))\
		/set lj_target=%{1} tree%;\
		/let _tmps=tree%;\
	/else \
		/set lj_target=%{1}%;\
		/let _tmps=%{1}%;\
	/endif%;\
	@@grep 'It can be cut down for ' look at %{_tmps} on ground


/def -i -F -p9999 -mregexp -t"^.+  .* ([a-z][a-z]+) tree" glumberjack_at1 =\
	/test glumberjack_grep({P1})

/def -i -F -p9999 -mregexp -t"([a-z][a-z]+) tree stands" glumberjack_at2 =\
	/test glumberjack_grep({P1})


/def -i -p9999 -ag -msimple -t"No matches for 'It can be cut down for '." glumberjack_gag

/def -i -p9999 -ag -mregexp -t"^It can be cut down for ([0-9]) logs? of ([a-z]+)\.$" glumberjack_amount =\
	/msq [@{BCgreen}%{P1} logs@{n}] of @{Cyellow}%{P2}@{n}


;@command /lj [target]
;@desc Use lumberjacking (at optional target, if no target given,
;@desc autotargetting or previous specified target is used.) (*) (!)
/def -i lj =\
	/if ({*}!~"") /set lj_target=%*%;/endif%;\
	/test gwb_check_mode("lj", set_mtool_lj, lj_target)%;\
	/msq Lumberjacking '%{lj_target}' ...%;\
	@@use lumberjacking at %{lj_target}


/def -i -p9999 -mregexp -t"^You chop up the [a-z ]+ into ([0-9]+) useable logs\.$" glumberjack_get =\
	/if (mwb_mode=~"lj" & skill_st2=~"on")\
		/let _i=%{P1}%;\
		/gmatmove_start%;\
		/while (_i > 0)\
			/gmatmove_item log%;\
			/let _i=$[_i - 1]%;\
		/done%;\
		/gmatmove_end%;\
	/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; AMALGAMATING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;@command /amal <material>
;@desc Amalgamate given material. Workbench and tools are automatically
;@desc selected.
/def -i amal =\
	/test gwb_set_bench({*})%;\
	/test gwb_check_mode("amal", mwb_tool, {*})%;\
	/msq Amalgamating '%{*}' in '%{mwb_forge}' with '%{mwb_wield}' ...%;\
	@@use amalgamate at %{*} in %{mwb_forge}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; REFINING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;@command /refine <material> [number]
;@desc Refine specified material, or numbered chunk of material.
/def -i refine =\
	/if (regmatch("^([A-Za-z ]+) +([0-9]+) *$",{*}))\
		/let _tmat=%{P1}%;\
		/let _tnum=%{P1} %{P2}%;\
	/else \
		/let _tmat=%{*}%;\
		/let _tnum=%{*}%;\
	/endif%;\
	/if (_tmat=~"") /msq @{BCred}No material given!@{n}%;/break%;/endif%;\
	/test gwb_set_bench(_tmat)%;\
	/test gwb_check_mode("refine", mwb_tool, _tmat)%;\
	/msq Refining '%{*}' in '%{mwb_forge}' with '%{mwb_wield}' ...%;\
	@@use refining at %{*} in %{mwb_forge}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MINERAL CUTTING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;@command /mcut <material> [number] [/amount in grams]
;@desc Mineral cut material. Optional number/index and amount/size can be
;@desc given in grams. If no amount/size is specified, material chunk is
;@desc cut in half. Use "/mcut" without arguments to get some examples.
/def -i mcut =\
	/if (regmatch("^([A-Za-z ]+) +([0-9]+) +\/ *([0-9]+)",{*}))\
		/let _tmat=%{P1}%;\
		/let _tnum=%{P1} %{P2}%;\
		/let _tcut=%{P3}%;\
	/elseif (regmatch("^([A-Za-z ]+) +\/ *([0-9]+)",{*}))\
		/let _tmat=%{P1}%;\
		/let _tnum=%{P1}%;\
		/let _tcut=%{P2}%;\
	/elseif (regmatch("^([A-Za-z ]+) +([0-9]+)",{*}))\
		/let _tmat=%{P1}%;\
		/if ({P2} > 50)\
			/let _tnum=%{P1}%;\
			/let _tcut=%{P2}%;\
		/else \
			/let _tnum=%{P1} %{P2}%;\
			/let _tcut=%;\
		/endif%;\
	/elseif (regmatch("^([A-Za-z ]+)$",{*}))\
		/let _tmat=%{P1}%;\
		/let _tnum=%{P1}%;\
		/let _tcut=%;\
	/else \
		/msq @{BCwhite}Usage:@{n} @{Cyellow}/mcut@{n} @{Cred}<material>@{} @{Cgreen}[number]@{n} @{Ccyan}[/amount in grams]@{n}%;\
		/msq /mcut wood 1 /50000 @{BCwhite}|@{n} /mcut steel /5000 @{BCwhite}|@{n} /mcut ebony 2%;\
		/break%;\
	/endif%;\
	/if (_tcut!~"")\
		/let _tcuts=%{_tcut}g piece%;\
		/let _tcut=cut %{_tcut}%;\
	/else \
		/let _tcuts=half%;\
	/endif%;\
	/test gwb_set_bench(_tmat)%;\
	/test gwb_check_mode("mcut", mwb_tool, _tmat)%;\
	/msq Mineral Cutting '%{_tnum}' in '%{mwb_forge}' with '%{mwb_wield}' to %{_tcuts} ...%;\
	@@use mineral cutting at %{_tnum} in %{mwb_forge} %{_tcut}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ALLOYING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;@command /alloy <material1,material2[,material3...]>
;@desc Alloy specified materials. Example: /alloy illumium,nullium
/def -i alloy =\
	/let _smat=$[replace(",", " ", replace(" ","_",{*}))]%;\
	/let _sfirst=$[prgetitem(1, _smat)]%;\
	/test gwb_set_bench(_sfirst)%;\
	/test gwb_check_mode("alloy", mwb_tool, _smat)%;\
	/set alloy_fumble=0%;\
	/msq Alloying '%{*}' in '%{mwb_forge}' with '%{mwb_wield}' ...%;\
	@@use alloying at %{*} in %{mwb_forge}

/def -i -F -msimple -t"You slip up and fumble your attempt." galloy_fumble =\
	/set alloy_fumble=1

/def -i prurify =\
	/return replace(" ", "+", strip_attr({*}))

/gdef -i -F -p9999 -aBCwhite -mregexp -t"^You mix [a-z ,]+ and create a quantity of ([a-z ]+)\.?$" galloy_check =\
	/let _match=%{P0}%;/set _result=%{P1}%;\
	@@look at %{_result} in %{mwb_forge}
	
;	%;\
;	/if (alloy_fumble == 0)\
;		/let _req=$[strcat("http://tnsp.org/mat/submit.php?guid=gAS51sPqeRQw3hX&match=",prurify(_match))]%;\
;		/quote -S /msq !wget -qO- "%{_req}"%;\
;	/endif
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GEM CUTTING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;@command /gcut [material]
;@desc Use gem cutting at material. (!) Workbench and tools are automatically
;@desc selected. If material is not specified, material from previous /gcut
;@desc command is used.
/def -i gcut =\
	/if ({*}!~"") /set gcut_gem=%*%;/endif%;\
	/test gwb_set_bench(gcut_gem)%;\
	/set mwb_tool=magnifying glass,chisel%;\
	/test gwb_check_mode("gcut", mwb_tool, gcut_gem)%;\
	/msq Gem Cutting '%{gcut_gem}' in '%{mwb_forge}' with '%{mwb_wield}' ...%;\
	@@use gem cutting at %{gcut_gem} in %{mwb_forge}


/gdef -i -F -p9999 -aBCwhite -t"You skillfully cut the gem ore into a beautiful gem." ggcut_get1 =\
	/if (mwb_mode=~"gcut" & skill_st2=~"on")\
		@@get gem from %{mwb_forge}%;\
		/gmatmove_item gem%;\
		@@look at %{gcut_gem} in %{mwb_forge}%;\
	/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MINING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Autotargetting
/set mine_target=
/set mine_amount=
/set mine_grep=0

/gdef -i -F -p9 -P0BCgreen -mregexp -t"(exits|Exits:)" gmine_init =\
	/set mine_match=1

/def -i -F -p9999 -P2BCred -mregexp -t"(abyss|chunky|coil|crag|deposit|gloss|graveyard|hill|hit|lode|lump|mass|mound|mountain|nest|network|pile|pocket|pool|protrusion|puddle|shard|slab|stack|tangle|torrent) of ([a-z]+|moss agate|petrified wood) *(ore|is|$)" gmine_at1 =\
	/if (mine_match)\
		/set mine_match=0%;\
		/set mine_grep=0%;\
		/set mine_target=%{P2}%;\
		@@grep 'contains roughly' look at %{P1} on ground%;\
	/endif

/def -i -F -p999 -mregexp -t"An? (abyss|chunky|coil|crag|deposit|gloss|graveyard|hill|hit|lode|lump|mass|mound|mountain|nest|network|pile|pocket|pool|protrusion|puddle|shard|slab|stack|tangle|torrent)" gmine_at2 =\
	/if (mine_match)\
		/set mine_match=0%;\
		/set mine_grep=1%;\
		/set mine_type=%{P1}%;\
	/endif

/def -i -F -p99 -P1BCred -mregexp -t"([a-z]+|moss agate|petrified wood) (ore is|is) embedded" gmine_at3 =\
	/if (mine_grep)\
		/set mine_grep=0%;\
		/set mine_target=%{P1}%;\
		@@grep 'contains roughly' look at %{mine_type} on ground%;\
	/endif


/def -i -F -p9999 -ag -msimple -t"No matches for 'contains roughly'." gmine_gag1

/def -i -F -p9999 -mregexp -t"^The ([a-z]+) contains roughly ([0-9]+) kg of ([a-z ]+)\.$" gmine_amount =\
	/set mine_amount=%{P2}%;/set mine_target=%{P3}%;\
	/substitute -p [@{BCgreen}%{P2} kg@{n}] of @{Cyellow}%{P3}@{n}.

/def -i -F -p9999 -mregexp -t"^No matches for \'\(" gmine_gag2 =\
	/substitute ====================


;@command /mine [target]
;@desc Use mining (at optional target, if no target given, autotargetting
;@desc or previous specified target is used.) (*) (!)
/def -i mine =\
	/if ({*}!~"") /set mine_target=%*%;/endif%;\
	/test gwb_check_mode("mine", set_mtool_mine, mine_target)%;\
	/msq Mining '%{mine_target}' ...%;\
	@@use mining at %{mine_target}


/def -i gmine_move =\
	/if (mwb_mode=~"mine" & skill_st2=~"on")\
		/gmatmove_item %{1}%;\
	/endif

/gdef -i -p9999 -aBCwhite -mregexp -t"^You begin mining the [a-z ]+ ([a-z]+) and you manage to retrieve an? ([a-z ]+)\." gmine_get1 =\
	/test gmine_move({P2},{P1})%;\
	@@grep 'contains roughly' look at %{P1} on ground

/gdef -i -p9999 -aBCwhite -mregexp -t"^You mine the [a-z]+ ([a-z]+) and retrieve an? ([a-z ]+)\." gmine_get2 =\
	/test gmine_move({P2},{P1})


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MINECRAFTING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gdef -i -F -p9999 -aBCwhite -msimple -t"You start preparing for the tunneling." gminecraft_start =\
	/test gwb_check_mode("minecraft", set_mtool_mine, "lode")
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAKE REAGENT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i prgetitem=\
	/let _ptmp=$(/nth %{1} %{2})%;\
	/return replace("_"," ",_ptmp)

/def -i gmrshowlist =\
	/let _mrline=$[strrep("-",12)]+$[strrep("-",27)]+$[strrep("-",32)]%;\
	/msw ,%{_mrline}.%;\
	/msw | Material   | Spell                     | Reagent                        |%;\
	/msw +%{_mrline}+%;\
	/let _nline=0%;\
	/while ({#})\
		/if (mod(_nline,2) == 1)\
			/let _mrcol=@{Cred}%;\
		/else \
			/let _mrcol=@{Cyellow}%;\
		/endif%;\
		/let _nline=$[_nline+1]%;\
		/let _mrvar=gmr_mat_%{1}%;\
		/let _mrdata=$[prgetval(_mrvar)]%;\
		/msw | %{_mrcol}$[pad({1},-10)]@{n} | %{_mrcol}$[pad(prgetitem(1,_mrdata),-25)]@{n} | %{_mrcol}$[pad(prgetitem(2,_mrdata),-30)]@{n} |%;\
		/shift%;\
	/done%;\
	/msw `%{_mrline}'

;@command /mr [material]
;@desc Make reagent from material. Tools and spell are automatically selected
;@desc based on the material. If no material is specified, material of previous
;@desc /mr command is used. Invalid material will print a list of reagents,
;@desc spells and require materials for them.
/def -i mr =\
	/if ({*}!~"") /set mmr_target=%*%;/endif%;\
	/test gwb_set_bench(mmr_target)%;\
	/test gwb_check_mode("mr", mwb_tool, mmr_target)%;\
	/let _mrdata=$[prgetval(strcat("gmr_mat_", mmr_target))]%;\
	/if (_mrdata!~"")\
		/set mmr_spell=$[prgetitem(1,_mrdata)]%;\
		/set mmr_rn1=$[prgetitem(2,_mrdata)]%;\
		/set mmr_rn2=$[prgetitem(3,_mrdata)]%;\
		/if (opt_usepouch=~"on" & set_pouchname=~"" & mmr_warn != 1)\
			/set mmr_warn=1%;\
			/gwarning Pouch name (/pouchname) not set, but usepouch enabled.%;\
		/endif%;\
		/if (opt_usepouch=~"on" & set_pouchname!~"")\
			/msq Make Reagent from '%{mmr_target}' for spell '%{mmr_spell}' into '%{set_pouchname} ...%;\
			@@use make reagent at %{mmr_target} for $[tolower(mmr_spell)] into %{set_pouchname}%;\
		/else \
			/msq Make Reagent from '%{mmr_target}' for spell '%{mmr_spell}' ...%;\
			@@use make reagent at %{mmr_target} for $[tolower(mmr_spell)]%;\
		/endif%;\
	/else \
		/msq @{BCwhite}Unknown/unset material, possible reagent materials are:@{n}%;\
		/gmrshowlist %{gmr_names}%;\
		/break%;\
	/endif


;; Automagically weigh the remaining material after crafting, if belt is enabled
/gdef -i -F -p9999 -aCgreen -msimple -t"You craft some spell reagents." gmmr_done =\
	/if (opt_havebelt=~"on") @@weigh %{mmr_target}%;/endif


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Chest creation status translation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gchest_report =\
	/substitute -p @{BCyellow}%{1}@{n} @{BCwhite}(@{n}@{BCgreen}%{2}@{n}/@{Cgreen}%{3}@{n}@{BCwhite})@{n}

;; Chest build status
/def -i -msimple -t"It looks totally incomplete." gchest_build0 = /test gchest_report({*},0,16)
/def -i -msimple -t"The basic structure is forming up." gchest_build1 = /test gchest_report({*},1,16)
/def -i -msimple -t"It slightly resembles a chest." gchest_build2 = /test gchest_report({*},2,16)
/def -i -msimple -t"It is missing a lid." gchest_build3 = /test gchest_report({*},3,16)
/def -i -msimple -t"It is still quite shaky." gchest_build4 = /test gchest_report({*},4,16)
/def -i -msimple -t"It looks like a small chest but it could be so much more." gchest_build5 = /test gchest_report({*},5,16)
/def -i -msimple -t"It does not look quite safe yet." gchest_build6 = /test gchest_report({*},6,16)
/def -i -msimple -t"The base looks strong now, but the lid is still quite weak." gchest_build7 = /test gchest_report({*},7,16)
/def -i -mregexp -t"^The (chest is looking|coffer looks) much larger\.$" gchest_build8 = /test gchest_report({*},8,16)
/def -i -msimple -t"The construction looks bigger and bigger." gchest_build9 = /test gchest_report({*},9,16)
/def -i -msimple -t"The structure is now stronger than ever before." gchest_build10 = /test gchest_report({*},10,16)
/def -i -mregexp -t"^The (chest|coffer) looks big enough to hold (out several equipments|a lot of money)\.$" gchest_build11 = /test gchest_report({*},11,16)
/def -i -mregexp -t"^The extra material has made the (chest|coffer) almost impossible to breach.$" gchest_build12 = /test gchest_report({*},12,16)
/def -i -mregexp -t"^The (chest |)construction looks quite large and safe\.$" gchest_build13 = /test gchest_report({*},13,16)
/def -i -msimple -t"The extra material in support-structure guarantees quality." gchest_build14 = /test gchest_report({*},14,16)
/def -i -msimple -t"The chest looks just perfect and there is very little unfinished." gchest_build15 = /test gchest_report({*},15,16)
/def -i -msimple -t"The construction looks very big and sturdy." gchest_build16 = /test gchest_report({*},16,16)

;; Chest reinforcement status
/def -i -msimple -t"The reinforcement looks totally incomplete." gchest_reinf1 = /test gchest_report({*},1,8)
/def -i -msimple -t"The reinforcement is still quite weak." gchest_reinf2 = /test gchest_report({*},2,8)
/def -i -msimple -t"The structure looks much stronger because of the reinforcement." gchest_reinf3 = /test gchest_report({*},3,8)
/def -i -msimple -t"The reinforcement still lacks quality." gchest_reinf4 = /test gchest_report({*},4,8)
/def -i -msimple -t"The reinforcement looks fine but it could be improved." gchest_reinf5 = /test gchest_report({*},5,8)
/def -i -mregexp -t"^The reinforced (chest|coffer) looks quite sturdy now.$" gchest_reinf6 = /test gchest_report({*},6,8)
/def -i -msimple -t"It would be a pain to force through the reinforcements." gchest_reinf7 = /test gchest_report({*},7,8)
/def -i -msimple -t"Just a final touch and the reinforcement is fully complete." gchest_reinf8 = /test gchest_report({*},8,8)


;; Chest creation helper
/def -i cbuild =\
	/if ({#}>0) /set mcc_mat=%{1}%;/endif%;\
	/if ({#}>1) /set mcc_chest=%{-1}%;/endif%;\
	/if (mcc_chest=~"") /set mcc_chest=chest%;/endif%;\
	/if (mcc_mat!~"")\
		/msq Building '%{mcc_chest}' hull from '%{mcc_mat}' ...%;\
		@@get %{mcc_mat}%;\
		@@use chest creation at build %{mcc_chest} hull from %{mcc_mat}%;\
	/else \
		/msq No chest building material set or specified!%;\
	/endif

/def -i creinf =\
	/if ({#}>0) /set mcc_rmat=%{1}%;/endif%;\
	/if ({#}>1) /set mcc_chest=%{-1}%;/endif%;\
	/if (mcc_chest=~"") /set mcc_chest=chest%;/endif%;\
	/if (mcc_mat!~"")\
		/msq Reinforcing '%{mcc_chest}' hull from '%{mcc_rmat}' ...%;\
		@@get %{mcc_rmat}%;\
		@@use chest creation at reinforce %{mcc_chest} hull with %{mcc_rmat}%;\
	/else \
		/msq No chest building material set or specified!%;\
	/endif

/def -i ccomplete =\
	/if ({#}>0) /set mcc_chest=%{*}%;/endif%;\
	/if (mcc_chest=~"") /set mcc_chest=chest%;/endif%;\
	/msq Completing '%{mcc_chest}' ...%;\
	@@use chest creation at complete %{mcc_chest}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Workbench helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;@command /wbmang
;@desc Toggles pro-workbench beautifying / output list mangling. This
;@desc mangling mode tries to make the pro-workbench output more
;@desc readable, and adds mineral number indexes for easier accesss.
;@desc Especially helpful when you need to work on specific # of mineral.

/prdeftoggle -n"wbmang" -d"Mangle pro merchant workbench output"

/set gwbt_st=0

/def -i gwbt_clear =\
	/while ({#})\
		/eval /unset gwbt_%{1}_cnt%;\
		/shift%;\
	/done

/def -i gwbt_add =\
	/let _name=$[replace(" ","_",{1})]%;\
	/test prlist_insert("gwbt_minerals",_name)%;\
	/let _cnt=$[prgetval(strcat("gwbt_",_name,"_cnt")) + 1]%;\
	/set gwbt_%{_name}_cnt=%{_cnt}%;\
	/return _cnt

/def -i -F -E(opt_wbmang=~"on") -mregexp -t"^This is a (loom|forge|workbench) in which you can .store. and .sort. up to " gwbt_start =\
	/set gwbt_st=1%;\
	/gwbt_clear %{gwbt_minerals}%;\
	/set gwbt_minerals=

/def -i gwbt_output2 =\
	/eval /echo -p %%{gwbt_%{1}_str} | %%{gwbt_%{2}_str}%;\
	/eval /unset gwbt_%{1}_str%;\
	/eval /unset gwbt_%{2}_str

/def -i gwbt_output1 =\
	/eval /echo -p %%{gwbt_%{1}_str}%;\
	/eval /unset gwbt_%{1}_str

/def -i -F -Egwbt_st -mregexp -t"^It looks " gwbt_end =\
	/if (gwbt_st==2)\
		/echo -p @{BCwhite}-------------------------------------------------------------------------------@{n}%;\
		/if (gwbt_line >= 2)\
			/let _line=1%;\
			/while (_line <= gwbt_line)\
				/gwbt_output2 $[_line] $[_line+1]%;\
				/let _line=$[_line+2]%;\
			/done%;\
		/else \
			/let _line=1%;\
			/while (_line <= gwbt_line)\
				/gwbt_output1 %{_line}%;\
				/let _line=$[_line+1]%;\
			/done%;\
		/endif%;\
		/echo -p @{BCwhite}-------------------------------------------------------------------------------@{n}%;\
	/endif%;\
	/set gwbt_st=0

/def -i gwbt_queue =\
	/if (regmatch(gwbt_match, {1}))\
		/set gwbt_line=$[gwbt_line+1]%;\
		/set gwbt_%{gwbt_line}_str=%{2}%;\
	/endif

/def -i gwbt_str =\
	/if ({4}!~"divine")\
		/let _col1=Cred%;\
		/let _col2=Cgreen%;\
		/let _col3=Cyellow%;\
	/else \
		/let _col1=BCwhite%;\
		/let _col2=n%;\
		/let _col3=n%;\
	/endif%;\
	/return "@{%{_col1}}$[pad({1},3)]@{n} @{%{_col3}}$[prsubipad({2},13)]@{n}:@{BCwhite}$[pad({3},1)]@{n}@{%{_col2}}$[prsubpad({4},8)]@{n}/$[pad({5},10)]"

/def -i -F -Egwbt_st -mregexp -t"^ ([a-z ]+) \[(\*|)([a-z]+)/([0-9]+\.[0-9]+k?g|[0-9]+k?g)\] +([a-z ]+) \[(\*|)([a-z]+)/([0-9]+\.[0-9]+k?g|[0-9]+k?g)\] +$" gwbt_line1 =\
	/let _n1=%{P1}%;/let _n2=%{P5}%;\
	/let _r1=%{P2}%;/let _r2=%{P6}%;\
	/let _q1=%{P3}%;/let _q2=%{P7}%;\
	/let _k1=%{P4}%;/let _k2=%{P8}%;\
	/let _v1=$[gwbt_add(_n1)]%;/let _v2=$[gwbt_add(_n2)]%;\
	/if (gwbt_st==1)\
		/substitute -p $[gwbt_str(_v1,_n1,_r1,_q1,_k1)] | $[gwbt_str(_v2,_n2,_r2,_q2,_k2)]%;\
	/else \
		/test gwbt_queue(_n1, gwbt_str(_v1,_n1,_r1,_q1,_k1))%;\
		/test gwbt_queue(_n2, gwbt_str(_v2,_n2,_r2,_q2,_k2))%;\
		/substitute -ag%;\
	/endif

/def -i -F -Egwbt_st -mregexp -t"^ ([a-z ]+) \[(\*|)?([a-z]+)/([0-9]+\.[0-9]+k?g|[0-9]+k?g)\] +$" gwbt_line2 =\
	/let _n1=%{P1}%;/let _r1=%{P2}%;\
	/let _q1=%{P3}%;/let _k1=%{P4}%;\
	/let _v1=$[gwbt_add(_n1)]%;\
	/if (gwbt_st==1)\
		/substitute -p $[gwbt_str(_v1,_n1,_r1,_q1,_k1)] |%;\
	/else \
		/test gwbt_queue(_n1, gwbt_str(_v1,_n1,_r1,_q1,_k1))%;\
		/substitute -ag%;\
	/endif


;@command /wbgrep <workbench> <mineral regexp>
;@desc Performs a "grep '&lt;mineral regexp&gt;' look at &lt;workbench&gt;" with workbench
;@desc mangling enabled and filters results. This is useful for quick searches
;@desc to see if given material exists in the bench and how many pieces there are.
/def -i wbgrep =\
	/set gwbt_st=2%;\
	/set gwbt_line=0%;\
	/set gwbt_match=%{-1}%;\
	/gwbt_clear %{gwbt_minerals}%;\
	/set gwbt_minerals=%;\
	/test send(strcat("@@grep '",gwbt_match,"|^It looks ' look at ",{1}))

/prdefgbind -s"wbl"	-c"/wbgrep"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Leadership hall helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i -F -p999 -Emrlead_st -msimple -t"You see nothing special." mrchk_off1 =\
	/set mrlead_st=0

/def -i mrchk_check_types =\
	/while ({#})\
		/test send("@@grep 'leader\.\$' kneel %{1}")%;\
		/shift%;\
	/done

/def -i mrchk_print_types =\
	/set mrlead_st=0%;\
	/msw .---------------------------.%;\
	/msw | Merchant type leaderships |%;\
	/msw +---------------------------+---------.%;\
	/msw | Type       | Leader          | You  |%;\
	/msw |------------+-----------------+------|%;\
	/while ({#})\
		/let _name=$[prgetval(strcat("mrlead_",{1}))]%;\
		/let _perc=$[prgetval(strcat("mrlead_",{1},"_p"))]%;\
		/msw | $[pad({1},-10)] | $[pad(_name,-15)] | @{BCwhite}$[pad(_perc,3)]@{n}% |%;\
		/shift%;\
	/done%;\
	/msw `-------------------------------------'

/def -i -F -p999 -Emrlead_st -mregexp -t"^You feel like kneeling in front of the statue might yield more information" mrchk_off2 =\
	/substitute -ag%;\
	/mrchk_check_types %{gmat_types}

/def -i -Emrlead_st -mregexp -t"^There are several vitrines standing in the middle of the room. Each has been made in resemblance of a player." mrchk_line0 =\
	/substitute -ag

/def -i -Emrlead_st -mregexp -t"^An? ([a-z]+) statue resembling ([A-Z][a-z]+)\.$" mrchk_line1 =\
	/set mrlead_%{P1}=%{P2}%;\
	/substitute -ag

/def -i mrchk_end =\
	/set mrlead_%{1}_p=%{2}%;\
	/substitute -ag%;\
	/let _last=$(/last %{gmat_types})%;\
	/if ({1}=~_last) /mrchk_print_types %{gmat_types}%;/endif

/def -i -Emrlead_st -mregexp -t"^You feel like being ([0-9]+)\% as good as the current ([a-z]+) leader\.$" mrchk_line3 =\
	/test mrchk_end({P2},{P1})

/def -i -Emrlead_st -mregexp -t"^You have no experience with ([a-z]+), unlike ([A-Z][a-z]+), the current leader\.$" mrchk_line4 =\
	/test mrchk_end({P1},0)

/def -i chkmerc =\
	/set mrlead_st=1%;\
	/test send("@@look at statues")
