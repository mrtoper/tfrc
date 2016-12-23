;;
;; GgrTF:SpellNames - Module for spell name translation @ BatMUD
;; (C) Copyright 2005-2015 Cutter, Dazzt & Ggr
;;
;; Based on original spellnames.tf by Cutter and Dazzt, used and
;; placed under GNU GPL v2 with permission.
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
/loaded GgrTF:SpellNames
/test prdefmodule("SpellNames")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialization and options
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/prdeftoggle -n"spwords" -d"Show spell words (off = only spellname)"
/prdeftoggle -n"spcolorize" -d"Enable coloring of spell names"
/set opt_spwords=off
/set opt_spcolorize=on

;@command /spwords
;@desc Toggles showing of actual spell words on/off.

;@command /spcolorize
;@desc Toggles colorization of spell name on/off.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/def -i gspell_colorize =\
	/if ({2}!~"none" & opt_spcolorize=~"on")\
		/eval /set _sp_colt=%%{col_spdam_%{2}}%;\
	/else \
		/eval /set _sp_colt=%%{col_spattr_%{1}}%;\
	/endif%;\
	/return "@{%_sp_colt}"

/def -i gspell_words =\
	/let _spell_name=$[replace("_"," ",{1})]%;\
	/def -i -F -p1 -mregexp -t"%{-3}" gspell_lite_%{1} =\
		/let _scol=$$[gspell_colorize("%{2}","%{3}")]%%;\
		/if (opt_spwords=~"on")\
			/test substitute(strcat({PL},_scol,{P0},"@{n} (%{_spell_name})",{PR}),"",1)%%;\
		/else \
			/test substitute(strcat({PL},_scol,"(%{_spell_name})@{n}",{PR}),"",1)%%;\
		/endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spell types
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/set col_spattr_heal=Cgreen
/set col_spattr_partyheal=BCgreen
/set col_spattr_damage=BCyellow
/set col_spattr_areadamage=BrCyellow
/set col_spattr_utility=B
/set col_spattr_teleport=Ccyan
/set col_spattr_boost=BrCgreen
/set col_spattr_prot=BrCblue
/set col_spattr_harm=Cred
/set col_spattr_field=BrCcyan
/set col_spattr_stun=BCred
/set col_spattr_dest=BrCred

/set col_spdam_phys=Cyellow
/set col_spdam_fire=Cred
/set col_spdam_cold=BCcyan
/set col_spdam_elec=BCblue
/set col_spdam_acid=Cgreen
/set col_spdam_poison=Cgreen
/set col_spdam_asphyx=BCmagenta
/set col_spdam_magic=BCyellow
/set col_spdam_psi=BCblue
/set col_spdam_harm=BCyellow
/set col_spdam_special=BCwhite


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Heal spells
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words heal_self             heal none   'judicandus littleee'
/gspell_words cure_light_wounds     heal none   'judicandus mercuree'
/gspell_words cure_light_wounds_    heal none   'Hard\! Rock\! Halleluuuujah\!'
/gspell_words cure_serious_wounds   heal none   'judicandus ignius'
/gspell_words cure_critical_wounds  heal none   'judicandus mangenic'
/gspell_words minor_heal            heal none   'judicandus pzarcumus'
/gspell_words major_heal            heal none   'judicandus pafzarmus'
/gspell_words true_heal             heal none   'judicandus zapracus'
/gspell_words half_heal             heal none   'pzzzar paf'
/gspell_words half_heal             heal none   'pzzzar paf'

; TODO FIXME is heal also pzzzar? or is pzzzarr something else?
;/gspell_words heal                  heal none   'pzzzarr'
/gspell_words heal                  heal none   'pzzarr'

/gspell_words deaths_door           heal none   'mumbo jumbo'
/gspell_words runic_heal            heal none   '\!\* \*'
/gspell_words remove_poison         heal none   'judicandus saugaiii'
/gspell_words cure_player           heal none   'freudemas egoid'
/gspell_words restore               heal none   'Siwa on selvaa saastoa.'
/gspell_words natural_renewal       heal none   'Naturallis Judicandus Imellys'
/gspell_words heal_body             heal none   'ZAP ZAP ZAP!'

/gspell_words minor_party_heal partyheal none   'judicandus puorgo ignius'
/gspell_words major_party_heal partyheal none   'judicandus puorgo mangenic'
/gspell_words true_party_heal  partyheal none   'judicandus eurto mangenic'
/gspell_words heal_all         partyheal none   'koko mudi kuntoon, hep'
/gspell_words blessed_warmth   partyheal none   '\! \(\*\) \!'

/gspell_words raise_dead            heal none   'vokinsalak elfirtluassa'
/gspell_words resurrection          heal none   'tuo fo wen stanhc'
/gspell_words new_body              heal none   'corpus novus foobar'

/gspell_words venturers_way         heal none   '\.\.a few steps to earthen might, a few steps.*
/gspell_words campfire_tune    partyheal none   'What child is this, who laid to rest on Mary's.*
/gspell_words shattered_feast       heal none   'That I have set free, return to me'
/gspell_words laying_on_hands       heal none   'Renew our strength'

/gspell_words crimson_mist          heal none   'aire sanguim'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Utility spells
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words identify_relic   utility none   'srR' Upon\^nep'
/gspell_words good_berry       utility none   'sezdaron montir'
/gspell_words mirror_image     utility none   'peilikuvia ja lasinsirpaleita'
/gspell_words floating_disc    utility none   'rex car bus xzar'
/gspell_words light            utility none   'ful'
/gspell_words greater_light    utility none   'vas ful'
/gspell_words darkness         utility none   'na ful'
/gspell_words nightfall        utility none   'Rez vas na ful'
/gspell_words greater_darkness utility none   'vas na ful'
/gspell_words moon_sense       utility none   'daaa timaaa of daaa maaanth'
/gspell_words see_invisible    utility none   '\$\%\&\@ \#\*\%\@\*\@\# \$\&\*\@\#'
/gspell_words see_magic        utility none   'ahne paskianen olen ma kun taikuutta nahda tahdon'
/gspell_words floating         utility none   'rise Rise RISE'
/gspell_words water_walking    utility none   'Jeeeeeeeeeeeesuuuuuuuus'
/gspell_words replenish_ally   utility none   'enfuego delyo'
/gspell_words drain_ally       utility none   'enfuego delmigo'
/gspell_words enhance_vision   utility none   'isar avatap patyan'
/gspell_words invisibility     utility none   '\.\.\.\.\. \.\.\.\. \.\.\. \.\.  \.    \.!'
/gspell_words aura_detection   utility none   'fooohh haaahhh booooloooooh'
/gspell_words feather_weight   utility none   'transformaticus minimus'
/gspell_words floating_letters utility none   'lentavia lauseita'
/gspell_words wizard_eye       utility none   'mad rad dar'
/gspell_words all-seeing_eye   utility none   'tamakan natelo assim'
/gspell_words levitation       utility none   'etati elem ekam'
/gspell_words there_not_there  utility none   'jakki makupala'
/gspell_words mental_watch     utility none   'kakakaaa  tsooon'
/gspell_words mental_glance    utility none   'vaxtextraktdryck'
/gspell_words spellteaching    utility none   'moon fiksu, soot tyhma  - opi tasta taika'
/gspell_words word_of_recall   utility none   'vole love velo levo'
/gspell_words call_pigeon      utility none   'habbi urblk'
/gspell_words summon_blade     utility none   'ahieppa weaapytama nyttemmin'
/gspell_words identify         utility none   'mega visa huijari'
/gspell_words spider_demon_conjuration utility none  'arachnid infernalicus arachnoidus demonicus'
/gspell_words spider_demon_channeling  utility none  'infernalicus nexus arachnid rex'
/gspell_words spider_demon_control     utility none  'infernalicus domus arachnid rex'
/gspell_words spider_gaze      utility none   'infernalicus claravonticus arachnidos'
/gspell_words spider_eye       utility none   'infernalicus intellegus arachnidos'
/gspell_words remove_scar      utility none   'lkzaz zueei enz orn'
/gspell_words infravision      utility none   'demoni on pomoni'
/gspell_words drain_room       utility none   'enfuegome delterra'
/gspell_words drain_item       utility none   'enfuego delcosa'
/gspell_words detect_misery    utility none   'misery ior noctar report'
/gspell_words see_the_light    utility none   'ogyawaelbirroh'
/gspell_words satiate_person   utility none   'Creo Herbamus Satisfus'
/gspell_words detect_alignment utility none   'annihilar hzzz golum'
/gspell_words create_money     utility none   'roope ankka rulettaa'
/gspell_words create_food      utility none   'juustoa ja pullaa, sita mun maha halajaa'
/gspell_words transmute_self   utility none   'nihenuak assaam no nek orrek'
/gspell_words life_link        utility none   'Corporem Connecticut Corporee'
/gspell_words drain_pool       utility none   fiery golden runes in mid-air '\$ \!\^'
/gspell_words detect_poison    utility none   fiery blue sigla '\$ \!\^'
/gspell_words youth            utility none   'Akronym Htouy, Hokrune Arafax' 
/gspell_words replenish_energy utility none   '\!\* %'
/gspell_words clairvoyance     utility none   'aalltyyuii regonza zirii'
/gspell_words create_air_armour utility none  'bloozdy etherum errazam zunk'
/gspell_words damn_armament    utility none   'Gawd DAMN IT!'
/gspell_words sex_change       utility none   'likz az zurgeeon'
/gspell_words charge_staff     utility none   '\# \!\('
/gspell_words shapechange      utility none   '\!\('
/gspell_words chaotic_warp     utility none   'weaapytama wezup boomie'
/gspell_words transform_golem  utility none   'insignificus et gargantum alternos'
/gspell_words remote_banking   utility none   'bat-o-mat'
/gspell_words wilderness_location utility none 'spirits of nature, show me the way!'
/gspell_words protect_weapon_or_armour_or_item utility none 'blueeeeeeeeeee\*\*\*\*saka\?\?am\!a'
/gspell_words dragonify        utility none   'mun enoni oli rakoni'
/gspell_words tiger_mask       utility none   'Tiger Power\!'
/gspell_words detect_race      utility none   'taxonimus zoologica whaddahellizzat'
/gspell_words kings_feast      utility none   'If you look behind a spider web, when it is covered with.*
/gspell_words clandestine_thoughts utility none 'To all the eyes around me, I wish to remain hidden, must I.*
/gspell_words jesters_trivia   utility none   'Green skins, white skins, black skins, purple skins.*
/gspell_words soothing_sounds  utility none   'Now that two decades gone by and I know that's a long.*
/gspell_words achromatic_eyes  utility none   'Stand confused with lack of comprehension, pagan of.*
/gspell_words vigilant_melody  utility none   'Lost I am not but knowledge I seek for there, my friend.*
/gspell_words catchy_singalong utility none   'Shooting Star'
/gspell_words sounds_of_silence utility none  'Hear this charm, there in the dark, lurking fiends.*
/gspell_words prayer_to_the_spider_queen   utility none 'Khizanth Arachnidus Satisfusmus'
/gspell_words spider_demon_mass_sacrifice  utility none 'infernalicus domus arachnid rex magnos'
/gspell_words spider_demon_banishment      utility none 'infernalicus thanatos arachnidos'
/gspell_words spider_demon_inquiry         utility none 'Khirsah Zokant Arachnidus'
/gspell_words spider_gate      utility none 'Khirsah Khazanth Arachinidus'
/gspell_words spider_servant   utility none 'infernalicus conjuratis arachnidos'
/gspell_words spider_walk      utility none 'Khizanth Arachnidus Walkitus'
/gspell_words blade_of_fire    utility none   'dsaflk aslfoir'
/gspell_words transfer_mana    utility none   '\"\) \!\#'
/gspell_words venom_blade      utility none   'May this become the blood of the Spider queen'
/gspell_words reincarnation    utility none   'henget uusix'
/gspell_words reanimation      utility none   'Blaarh ARGHAGHAHAHA URAAAH BELARGH!'
/gspell_words inquiry_to_ahm   utility none   '\!\?'
/gspell_words bless_armament   utility none   'Faerwon, grant your favor!'
/gspell_words sweet_lullaby    utility none   'There is nothing you can do, when you realize with.*
/gspell_words natural_transformation utility none '@\& \^'
/gspell_words preserve_corpse  utility none   'upo huurre helkama'
/gspell_words bless_vial       utility none   'Zanctum Zanctus Aqua'
/gspell_words patch_item       utility none   'jimmiii fixiiii'
/gspell_words cantrip          utility none   'Vita non est vivere sed valere vita est'
/gspell_words uncontrollable_hideous_laughter utility none 'nyuk nyuk nyuk'
/gspell_words musicians_alm    utility none   'Donations welcome'
/gspell_words singing_shepherd utility none   'Squirrel in the dirt, squirrel in the pool, squirrel don't get hurt, trying to stay cool!'
/gspell_words arms_lore	      utility none   'well, what have we here'
/gspell_words monster_lore     utility none   'haven't I seen you before\?'
/gspell_words rune_of_warding  utility none   'trpp dda prtolala offf pwerrrr'

/gspell_words detect_vial      utility none  'Eeneil okayssiv'
/gspell_words item_dispersion_shield utility none 'h\'njya'
/gspell_words enhanced_awareness utility none 'Bewareeeee\!'
/gspell_words create_herb      utility none  'greeeenie fiiingerie'
/gspell_words greater_create_herb      utility none  'creo herbula'
/gspell_words lift_of_load     utility none  'Myh myh\!'
/gspell_words spell_empathy    utility none  'doowesh maiket fyoleue\?'
/gspell_words lock_biter       utility none  'fzz zur tumblzegar'
/gspell_words steed_of_tzarakk utility none  'sanatagras teceah'
/gspell_words banish_mount     utility none  'aatevehal inok arepyt'
/gspell_words glance_of_predator utility none 'tooassim nenovehanroh uukkuk'
/gspell_words gust_of_wind     utility none  '\@\% \(\)\@'

/gspell_words beacon_of_enlightenment utility none 'homines, dum docent, discunt'
/gspell_words magnetic_levitation utility none 'zot sur gaussimen'
/gspell_words searing_fervor   utility none 'fah mar nak prztrzz'
/gspell_words holding_pattern  utility none 'niotalucaje erutamerp\!'
/gspell_words create_dimensional_gem  utility none  'zug zug'
/gspell_words prepare_flask    utility none  'phylli phylli'

/gspell_words touch_of_madness utility none 'tossikid jullitta'
/gspell_words curse_of_lycanthropy  utility none  'sanguinum lnarae est'
/gspell_words mana_barrier utility none 'Ouch ouch ow oww\!'
/gspell_words summon_dire_boar utility none  'Rzzakkaa Khaar Gaggnath'


/gspell_words soul_chorus      utility none  'lano i tanr etni'

; alone?
/gspell_words bless_ship_1     utility none  'sinta judican aqua'
; in a party?
/gspell_words bless_ship_2     utility none  'blese partina aqua'
; ???
/gspell_words bless_ship_3     utility none  'drina nailinq aqua'
/gspell_words ship_armour      utility none  'aqualin shieferus'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Field spells
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words force_dome       field none   'xulu tango charlie'
/gspell_words imprisonment     field none   'imprickening zang gah'
/gspell_words field_of_fear    field none   'wheeeaaaaaa oooooo'
/gspell_words anti_magic_field field none   'taikoja ma inhoan'
/gspell_words electric_field   field elec   'Ziiiiiiiiit Ziiit Ziiiit'
/gspell_words shelter          field none   'withing thang walz'
/gspell_words neutralize_field field none   'null, nill, noll, nutin'
/gspell_words rain             field none   'huku mopo huku'
/gspell_words drying_wind      field none   'hooooooooooowwwwwwwwwwwlllllllllllllll'
/gspell_words create_mud       field none   '\# \!\#'
/gspell_words field_of_light   field none   'ja nyt kenka kepposasti nousee'
/gspell_words celestial_haven  field none   'zeriqum'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Damage spells
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words magic_missile         damage magic  'gtzt zur fehh'
/gspell_words summon_lesser_spores  damage magic  'gtzt zur sanc'
/gspell_words levin_bolt            damage magic  'gtzt zur semen'
/gspell_words summon_greater_spores damage magic  'gtzt mar nak semen'
/gspell_words golden_arrow          damage magic  'gtzt mar nak grttzt'

/gspell_words shocking_grasp        damage elec   'zot zur fehh'
/gspell_words lightning_bolt        damage elec   'zot zur sanc'
/gspell_words blast_lightning       damage elec   'zot zur semen'
/gspell_words forked_lightning      damage elec   'zot mar nak semen'
/gspell_words electrocution         damage elec   'zot mar nak grttzt'

/gspell_words disruption            damage acid   'fzz zur fehh'
/gspell_words acid_wind             damage acid   'fzz zur sanc'
/gspell_words acid_arrow            damage acid   'fzz zur semen'
/gspell_words acid_ray              damage acid   'fzz mar nak semen'
/gspell_words acid_blast            damage acid   'fzz mar nak grttzt'

/gspell_words flame_arrow           damage fire   'fah zur fehh'
/gspell_words firebolt              damage fire   'fah zur sanc'
/gspell_words fire_blast            damage fire   'fah zur semen'
/gspell_words meteor_blast          damage fire   'fah mar nak semen'
/gspell_words lava_blast            damage fire   'fah mar nak grttzt'

/gspell_words thorn_spray           damage poison 'krkx zur fehh'
/gspell_words poison_blast          damage poison 'krkx zur sanc'
/gspell_words venom_strike          damage poison 'krkx zur semen'
/gspell_words power_blast           damage poison 'krkx mar nak semen'
/gspell_words summon_carnal_spores  damage poison 'krkx mar nak grttzt'

/gspell_words vacuumbolt            damage asphyx 'ghht zur fehh'
/gspell_words suffocation           damage asphyx 'ghht zur sanc'
/gspell_words chaos_bolt            damage asphyx 'ghht zur semen'
/gspell_words strangulation         damage asphyx 'ghht mar nak semen'
/gspell_words blast_vacuum          damage asphyx 'ghht mar nak grttzt'

/gspell_words mind_blast            damage psi    'omm zur fehh'
/gspell_words psibolt               damage psi    'omm zur sanc'
/gspell_words psi_blast             damage psi    'omm zur semen'
/gspell_words mind_disruption       damage psi    'omm mar nak semen'
/gspell_words psychic_crush         damage psi    'tora tora tora'

/gspell_words chill_touch           damage cold   'cah zur fehh'
/gspell_words flaming_ice           damage cold   'cah zur sanc'
/gspell_words darkfire              damage cold   'cah zur semen'
/gspell_words icebolt               damage cold   'cah mar nak semen'
/gspell_words cold_ray              damage cold   'cah mar nak grttzt'

/gspell_words prismatic_burst       damage special 'azkura colere'
/gspell_words poison_cloud          damage special 'ddt ddt ddt it is good for you and me\!'
/gspell_words celestial_spark       damage magic  'Avee Avee Aveallis'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bards
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words con_fioco             damage none   'AeaH\*h\*\*\*Gdg'
/gspell_words noituloves_dischord   damage phys   'dIsCHoRD'
/gspell_words dancing_blades        damage phys   'Dance my little blades, whip my enemies for I am.*

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Channellers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words channelbolt           damage elec   'tsaibaa'
/gspell_words channelball           damage magic  'shar ryo den\.\.\.Haa!'
/gspell_words channelburn           damage fire   'grhagrhagrhagrah gra gra Hyaa!'
/gspell_words channelray            damage magic  'lecaps meeb nonnock'
/gspell_words channelspray          damage fire   'grinurb sdan imflagrum'
/gspell_words drain_enemy           damage none   'enfuego delvivendo'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Priests
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words cause_light_wounds    damage harm 'tosi pieni neula'
/gspell_words cause_serious_wounds  damage harm 'rhuuuumm angotz amprltz'
/gspell_words cause_critical_wounds damage harm 'rhuuuumm angotz klekltz'
/gspell_words hemorrhage            damage harm 'yugzhrr'
/gspell_words aneurysm              damage harm 'yugzhrr paf'
/gspell_words harm_body             damage harm 'PAF PAF PAF!'
/gspell_words half_harm             damage harm 'ruotsalainen ensiapu'
/gspell_words harm                  damage harm 'puujalka jumalauta'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reavers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words word_of_attrition     damage magic 'khozak'
/gspell_words word_of_destruction   damage magic 'Sherpha!'
/gspell_words word_of_blasting      damage magic 'hraugh'
/gspell_words word_of_genocide      damage magic 'dephtua'
/gspell_words word_of_slaughter     damage magic 'niinr'
/gspell_words word_of_spite         damage magic 'torrfra'
/gspell_words word_of_oblivion      damage magic 'FRONOX!!'
/gspell_words black_hole            damage asphyx 'Azzarakk, take this sacrifice I offer thee!'
/gspell_words blood_seeker          utility destruction 'The sharper, the sweeter'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Kharim
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words phantasmal_reflection          utility none 'maergal ania phalantia'
/gspell_words sleeping_parasite              utility none 'redoc mirahk rof airgnas erom'
/gspell_words soul_guardian                  utility none 'phalantia elitae mortee'
/gspell_words nocturnal_charm                utility none 'teniara lais alluvana'
/gspell_words aura_of_chaos                  utility none 'Forces of Chaos, heed my call\!'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spiders
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words spider_wrath          damage poison 'Khizanth Arachnidus Iracundus'
/gspell_words hunger_of_the_spider  damage poison 'Khizanth Arachnidus Vitalis'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Aelena
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words sting_of_aelena                utility none 'nox rae hout'
/gspell_words command_blade                  utility none 'huul shaash harak'
/gspell_words bite_of_the_black_widow        utility none 'nox yul taree'
/gspell_words the_shadow                     utility none 'black winter day'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Riftwalker
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words spark_birth                    utility cold 'cwician ysl'
/gspell_words rift_pulse                     utility cold 'idel claeppetung'
/gspell_words create_rift                    utility none 'cennan gin'
/gspell_words beckon_rift_entity             utility none 'biecnan ambihtere hercyme'
/gspell_words dismiss_rift_entity            utility none 'nidgenga ambihtere'
/gspell_words establish_entity_control       utility none 'astellan geweald'
/gspell_words summon_rift_entity             utility none 'cuman agotenes ond cweman'
/gspell_words consume_weapon                 utility none 'abitan campwaepen'
/gspell_words regenerate_rift_entity         utility none 'gebreadian ambihtere'
/gspell_words absorbing_meld                 utility none 'bredan forswelgan'
/gspell_words create_rift_vortex             utility none 'cennan swelgend'
/gspell_words dimensional_leech              utility cold 'idel laece'
/gspell_words bind_rift_entity               utility none 'asaelan ambihtere'
/gspell_words transform_rift_entity          utility none 'forscieppan ambihtmecg'
/gspell_words rift_scramble                  utility none 'swicung asucan'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Druids
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words gem_fire              damage fire   gem '& \^'
/gspell_words hoar_frost            damage cold   ice crystal '& \^'
/gspell_words star_light            damage magic  '\!\( \!\!'
/gspell_words wither_flesh          damage none   '\"# \^'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Nuns
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words dispel_evil           damage magic  'Ez' div'
/gspell_words dispel_good           damage magic  'whoosy banzziii pal eeeiizz dooneb'
/gspell_words dispel_undead         damage magic  'Sanctum disqum'
/gspell_words holy_bolt             damage magic  'Sanctum circum'
/gspell_words holy_hand             damage magic  'Sanctus inxze'
/gspell_words saintly_touch         damage magic  'Exzorde' Å'
/gspell_words banish_demons         damage magic  'Satan down'
/gspell_words wrath_of_las          damage fire   ' ¤Lassum¤ '


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ghost liberator paladins
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words holy_glow                      utility none 'the light within'
/gspell_words restful_sleep                  utility none 'aa tuuti lullaa'
/gspell_words appease_ghost                  utility none 'tauko paikalla'
/gspell_words ghost_sword                    utility none 'kakkosnelonen'
/gspell_words ghost_light                    utility magical 'jack-o-lantern'
/gspell_words ghost_chill                    utility psionic 'itsy bitsy chill'
/gspell_words ghost_vision                   utility none 'kerubi on pomoni'
/gspell_words ghost_armour                   utility none 'protect me'
/gspell_words ghost_link                     utility none 'gimme gimme gimme'
/gspell_words ghost_companion                utility none 'I choose you, umm, whoever\.\.\.'
;/gspell_words ghost_companion_2              utility none 'I choose you, [A-Z][a-z]+\!'
/gspell_words ghost_guidance                 utility none 'Battlestations\!'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Folklorists
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words zoological_protection          utility none 'zoologicus munimentum'
/gspell_words cryptozoological_protection    utility none 'cryptozoologicus munimentum'
/gspell_words racial_protection              utility none 'genus munimentum'
/gspell_words kinemortological_protection    utility none 'kinemortologicus munimentum'
/gspell_words attune_racial_protection       utility none 'diffingo genus munimentum'
/gspell_words greater_create_herb            utility none 'creo herbula'

/gspell_words herbal_healing                 utility none 'holitorius curatio'
/gspell_words herbal_remove_poison           utility none 'holitorius veneficium curatio'

/gspell_words herbal_poison_blast            utility poison 'holitorius veneficium sagitta'
/gspell_words herbal_poison_spray            utility poison 'holitorius veneficium aspergo'
/gspell_words bolt_of_knowledge              utility psionic 'scientia et experientia sagitta'
/gspell_words living_poison                  utility none 'inficio vivus'
/gspell_words field_of_poison                utility none 'amplifico veneficium'

/gspell_words bookworm                       utility none 'transformo vermiculus'
/gspell_words magic_mount                    utility none 'magicus equus'
/gspell_words greater_magic_mount            utility none 'grandis magicus draco'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Animists
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words conjure_animal_soul            utility none 'Kindred spirits'
/gspell_words recall_animal_soul             utility none 'How to measure a planet\?'
/gspell_words animal_soul_link               utility none 'mi casa es su casa'
/gspell_words separate_soul                  utility none 'slash, cut, severance'
/gspell_words join_soul                      utility none 'join, meld, communion'
/gspell_words soul_chorus                    utility none 'lano i tanr etni'
/gspell_words resurrect_soul                 utility none 'come, come, come'
/gspell_words elemental_soul_ward            utility none 'Beware the big bad troll\!'
/gspell_words animal_aspect                  utility none 'Animal Aspects'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Area damage spells
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words meteor_swarm          areadamage fire   'fah zur semen gnatlnamauch'
/gspell_words magic_wave            areadamage magic  'gtzt zur semen gnatlnamauch'
/gspell_words vacuum_ball           areadamage asphyx 'ghht zur semen gnatlnamauch'
/gspell_words cone_of_cold          areadamage cold   'cah zur semen gnatlnamauch'
/gspell_words chain_lightning       areadamage elec   'zot zur semen gnatlnamauch'
/gspell_words acid_rain             areadamage acid   'fzz zur semen gnatlnamauch'
/gspell_words poison_spray          areadamage poison 'krkx zur semen gnatlnamauch'
/gspell_words psychic_shout         areadamage psi    'omm zur semen gnatlnamauch'

/gspell_words fireball              areadamage fire   'zing yulygul bugh'

/gspell_words lava_storm            areadamage fire   'fah mar nak grttzt gnatlnamauch'
/gspell_words magic_eruption        areadamage magic  'gtzt mar nak grttzt gnatlnamauch'
/gspell_words vacuum_globe          areadamage asphyx 'ghht mar nak grttzt gnatlnamauch'
/gspell_words hailstorm             areadamage cold   'cah mar nak grttzt gnatlnamauch'
/gspell_words lightning_storm       areadamage elec   'zot mar nak grttzt gnatlnamauch'
/gspell_words acid_storm            areadamage acid   'fzz mar nak grttzt gnatlnamauch'
/gspell_words killing_cloud         areadamage poison 'krkx mar nak grttzt gnatlnamauch'
/gspell_words psychic_storm         areadamage psi    'omm mar nak grttzt gnatlnamauch'

/gspell_words summon_storm          areadamage elec   '\*\* /\|/'
/gspell_words earthquake            areadamage magic  '\%'
/gspell_words flames_of_righteousness areadamage magic 'ex'domus naz'
/gspell_words holy_wind             areadamage magic  'Rev 'liz'
/gspell_words noituloves_deathlore  areadamage magic  'Thar! Rauko! Mor! Ris-Rim! Fuin-Heru! GOR! Gurthgwath!n'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Teleport spells
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words summon                 teleport none   'gwwaaajj'
/gspell_words teleport_without_error teleport none   'xafe ayz xckgandhuzqarr'
/gspell_words teleport_with_error    teleport none   'xafe xyyqh xckgandhuzqarr'
/gspell_words relocate               teleport none   'hypin pompin luokses juoksen'
/gspell_words phaze_shift            teleport none   'xafe uurthq'
/gspell_words go                     teleport none   'flzeeeziiiiying nyyyaaa'
/gspell_words mobile_cannon          teleport none   'buuuummbzdiiiiiibummm'
/gspell_words dimension_door         teleport none   'prtolala offf pwerrrr'
/gspell_words banish                 teleport none   'havia kauhistus pois'
/gspell_words party_banish           teleport none   'etsi poika pippuria'
/gspell_words mind_store             teleport none   'memono locati'
/gspell_words pathfinder             teleport none   'Fo fu fe fum, Lord of the Winds, I know Thy.*
/gspell_words holy_way               teleport none   'Avee Alee adudaaa..'
/gspell_words goto_ship              teleport none   'etheria aquariq [a-z]+'

/gspell_words demonic_gate           teleport special '###### PORTTI HELVETTIIN AUKI, SAATANA JUMALAUTA ######'

/gspell_words travel                 teleport none   'okta atsavi osnile hup'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Boost spells
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words arches_favour         boost none   'In the Shadows cast down by the moon, a.*
/gspell_words melodical_embracement boost none   'Once there were two knights and maidens They'd walk together.*
/gspell_words war_ensemble          boost none   'War is TOTAL massacre, sport the war, war SUPPOORT!!!'
/gspell_words psionic_shield        boost none   'niihek atierapip aj niiramaan aaffaj'
/gspell_words unpain                boost none   'harnaxan temnahecne'
/gspell_words blessing_of_tarmalen  boost none   'nilaehz arzocupne'
/gspell_words mind_development      boost none   'Annatheer graaweizta'
/gspell_words unstable_mutation     boost none   'ragus on etsat mumixam!'
/gspell_words energy_aura_yellow    boost none   'hhhnnnnnrrrrraaahhh!!'
/gspell_words energy_aura_red       boost none   'hnnn\.\.\.\.Urrgggg\.\.\.\.\.RRAAHH!!!'
/gspell_words energy_aura_blue      boost none   'RRRRAAAAAHHRRRRGGGGGGHHH!!!!!'
/gspell_words earth_blood           boost none   '!\( \*\)'
/gspell_words earth_power           boost none   '% \!\^'
/gspell_words regeneration          boost none   'nilaehz temnahecne'
/gspell_words haste                 boost none   'sakenoivasta voimasta'
/gspell_words aura_of_hate          boost none   'Feel your anger and strike with.*

/gspell_words artificial_intelligence  boost none  'nitin mof'
/gspell_words aura_of_power            boost none  'noccon mof'
/gspell_words awareness                boost none  'siwwis mof'
/gspell_words giant_strength           boost none  'rtsstr mof'
/gspell_words flame_fists              boost none  'Polo Polomii'
/gspell_words glory_of_destruction     boost none  'Grant me the power, the fire from within'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Prot spells
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words resist_temptation         prot none   'qxx'rzzzz'
/gspell_words resist_disintegrate       prot none   'bii thee dzname uv tii blaaaz drazon'
/gspell_words vine_mantle               prot none   '\"\" \!\#'
/gspell_words strength_in_unity         prot none   'You say you don't believe this unity will last,.*
/gspell_words protection_from_aging     prot none   'Tempora Rolex Timex'
/gspell_words unstun                    prot none   'Paxus'
/gspell_words lessen_poison             prot none   'Impuqueto es Bien'
/gspell_words protection_from_evil      prot none   'sanctus Exzordus'
/gspell_words protection_from_good      prot none   'Good is dumb'
/gspell_words flex_shield               prot none   '\^ !\)'
/gspell_words force_shield              prot none   'thoiiiiiisss huuuiahashn'
/gspell_words personal_force_field      prot none   'riljya'
/gspell_words earth_skin                prot none   '% \!\('
/gspell_words soul_hold                 prot none   'naxanhar hecnatemne'
/gspell_words guardian_angel            prot none   'Judicandee iocus merciaa Tarmalen'
/gspell_words shield_of_faith           prot none   'Grant your worshipper your protection'
/gspell_words soul_shield               prot none   'sanctus angeliq'
/gspell_words enhanced_vitality         prot none   'zoot zoot zoot'
/gspell_words resist_dispel             prot none   'zicks laai qluu'
/gspell_words iron_will                 prot none   'nostaaaanndiz noszum'
/gspell_words shield_of_protection      prot none   'nsiiznau'
/gspell_words blurred_image             prot none   'ziiiuuuuns wiz'
/gspell_words displacement              prot none   'diiiiuuunz aaanziz'
/gspell_words force_absorption          prot phys   'ztonez des deckers'
/gspell_words toxic_dilution            prot poison 'morri nam pantoloosa'
/gspell_words heat_reduction            prot fire   'hot hot not zeis daimons'
/gspell_words magic_dispersion          prot magic  'meke tul magic'
/gspell_words energy_channeling         prot elec   'kablaaaammmmm bliitz zundfer'
/gspell_words corrosion_shield          prot acid   'sulphiraidzik hydrochloodriz gidz zuf'
/gspell_words ether_boundary            prot asphyx 'qor monoliftus'
/gspell_words frost_insulation          prot cold   'skaki barictos yetz fiil'
/gspell_words psychic_sanctuary         prot psi    'toughen da mind reeez un biis'
/gspell_words armour_of_aether          prot phys   'fooharribah inaminos cantor'
/gspell_words shield_of_detoxification  prot poison 'nyiaha llaimay exchekes ployp'
/gspell_words flame_shield              prot fire   'huppa huppa tiki tiki'
/gspell_words repulsor_aura             prot magic  'shamarubu incixtes delfo'
/gspell_words lightning_shield          prot elec   'ohm'
/gspell_words acid_shield               prot acid   'hfizz hfizz nglurglptz'
/gspell_words aura_of_wind              prot asphyx 'englobo globo mc'pop'
/gspell_words frost_shield              prot cold   'nbarrimon zfettix roi'
/gspell_words psionic_phalanx           prot psi    'all for one, gather around me'
/gspell_words heavy_weight              prot none   'tonnikalaa'
/gspell_words resist_entropy            prot none   'Ourglazz Schmourglazz'
/gspell_words last_rites                prot none   'Ab sinestris, mortum demitteri'
/gspell_words heavenly_protection       prot none   'sanctus . o O'
/gspell_words quicksilver               prot none   'jumpiiz laika wabbitzz'
/gspell_words blessing_of_faerwon       prot none   'Benedic, Faerwon, nos et haec tua dona.*
/gspell_words reflector_shield          prot none   'sakat ikkiak satsjaieh'
/gspell_words mana_shield               prot none   'nullum driiiks umbah mana'
/gspell_words guardian                  prot none   ' -¤- Zanctus -¤- '
/gspell_words shadow_armour             prot none   'klainmox'
/gspell_words stoneskin                 prot none   'aflitruz'
/gspell_words resist_gaseous_form       prot none   'Break like the wind'
/gspell_words mesmeric_threshold        prot none   'lkrp ajuvah'
/gspell_words air_shield                prot none   'ghht mar zrrprghh'

/gspell_words conjure_element           prot none   'Aelores barrimus maximus'
/gspell_words conjure_lesser_element    prot none   'Aelores barrimus minimus'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Harming spells
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words degenerate_person   harm none   'kewa dan dol rae hout'
/gspell_words poison              harm none   'saugaiii'
/gspell_words forget              harm none   'sulta taiat pois, mulle hyva mieli taikadaikaduu'
/gspell_words make_scar           harm none   'viiltaja jaska'
/gspell_words entropy             harm none   'vaka vanha vainamoinen'
/gspell_words area_entropy        harm none   'vaka tosi vanha vainamoinen'
;/gspell_words nether_storm        harm none   'nihtiw ssenkrad'
/gspell_words psychic_purge       harm none   'aamad ato naav aanarub atyak ala'
/gspell_words terror              harm none   'BBBBOOOOOO!!!!'
/gspell_words dispel_magical_protection harm none   'removezzzzzarmour'
/gspell_words mana_drain          harm none   'I HATE MAGIC'
/gspell_words flip                harm none   'jammpa humppa ryydy mopsi'
/gspell_words hallucination       harm none   'huumeet miehen tiella pitaa'
/gspell_words curse_of_ogre       harm none   'rtsstr uurthg'
/gspell_words disease             harm none   'noccon uurthg'
/gspell_words feeblemind          harm none   'nitin uurthg'
/gspell_words amnesia             harm none   'siwwis uurthg'
/gspell_words wither              harm none   'xeddex uurthg'
/gspell_words life_leech          harm none   'gimme urhits'
/gspell_words energy_drain        harm none   'yugfzhrrr suuck suuuuuck suuuuuuuuuuck'
/gspell_words curse               harm none   'oli isa-sammakko, aiti-sammakko ja PIKKU-SAMMAKKO!!'
/gspell_words mellon_collie       harm none   'Zmasching Pupkins's infanitsadnnes'
/gspell_words pestilence          harm none   'Harken to me and hear my plea, disease is what I call to thee'
/gspell_words curse_of_tarmalen   harm none   'nilaehz temnahecne neg'
/gspell_words suppress_magic      harm none   'voi hellapoliisin kevatnuija'
/gspell_words energy_vortex       harm none   'incantar enfeugo aggriva'
/gspell_words spider_touch        harm none   'Khizanth Arachnidus Diametricus'
; xxx what is the correct name?
/gspell_words skill_drain         harm none   'nyyjoo happa hilleiksis'
/gspell_words spell_drain         harm none   'nyyjoo happa helleipsis'
/gspell_words cleanse_heathen     harm none   'Ala itkeä iletys, parkua paha kuvatus'

/gspell_words paranoia            harm none   'noxim delusa'
/gspell_words psychic_shackles    harm none   'poskid ujsi'
/gspell_words unholy_matrimony    harm none   'With this ring, i do deconsecrate thee'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Stun spells
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/gspell_words paralyze            stun none   'vorek ky taree'
/gspell_words mindseize           stun none   'diir mieelis sxil miarr mieelin'
/gspell_words tiger_claw          stun none   'Haii!'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dest spells
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 'by the power of grayskull' or so is also said to be disin? --Cutter
/gspell_words disintegrate    dest none 'sahanpurua'
/gspell_words acquisition     dest none 'mesmr pulrl metism'
/gspell_words destroy_weapon  dest none 'rikki ja poikki'
/gspell_words destroy_armour  dest none 'se on sarki nyt'
/gspell_words immolate        dest none 'fah relep krlnpth'


; TODO
; ----
; Electric spider utters the magic words 'gimmez a boltz'
; - bolt of lightning?

; Glaurung strokes a weapon and says 'The sharper, the sweeter'

