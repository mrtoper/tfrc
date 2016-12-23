GgrTF - TinyFugue script for BatMUD
===================================
(C) Copyright 2004-2016 Matti Hamalainen (Ggr Pupunen) & others.
See CREDITS.txt for more complete author information.


This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
version 2 as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
file "COPYING.txt" for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
MA 02110-1301 USA.


Important URLs
--------------
GgrTF homepage       : http://tnsp.org/~ccr/ggrtf/

Bugtracker           : http://pupunen.net/mantis/

Mercurial repository : http://pupunen.net/hg/ggrtf/


Release Notes for v0.7.4.0
--------------------------
For full list of changes, refer to "ChangeLog".

 * Implemented direction translation in default move/peer
   modes. E.g. n/s/w/e/etc get translated to full word
   commands north/south/west/east. Same for nw/sw/etc.

 * Fixed /beemaint -command in Nun module.

 * Some minor fixes in manual, updated links.


Release Notes for v0.7.3.2
--------------------------
Changes from v0.7.3.0:

 * Fix gparty_members handling in gm-pssmangle.tf.
   This should fix /np macro in nun module and some
   other functionality that rely on it.

 * Material information in merchant module updated.

 * Reagent pouch output mangler improved.

 * Some minor fixes in manual.

Changes from v0.7.2.3:

 * Fixes for pss-mangler, should work better with
   the changes that have occured in BatMUD 'pss' output
   during last few years or so.

 * Mangled pss now shows number of rescuers for 'stun'
   and 'unc' statuses like plain 'pss' does.

 * Minor spell name translator updates.

 * Documentation updates in the user's manual.

Changes from v0.7.1.0:

 * Support for changes in 'pss' output.

 * Several documentation updates and improvements.

 * Documentation also now available in PDF format.

 * Added support for third and fourth "weapon" type in hitstats,
   for those minotaurs, crazy barsoomians, etc.

 * Fixed hitstats module to actually work again.

Changes from v0.7.0.1:

 * Improved identify spell beautifier module, and fixed it to
   support some semi-recent changes in the spell's output.

 * Added support for 'claw' and 'bite' hit messages in the
   hit statistics module.


Changes from v0.6.18.3:

 * Various additions in spellname translator.

 * Added mindseize to blast analyzes.

 * Improved spider guild module, based on suggestions from Mardraum.

 * Heart subticks (don't ask.)


Changes from v0.6.17.x:

 * Initial support for elemental entities in pss-mangler.

 * Support for animist souls in pss-mangler.

 * Bugfixes and clarifications in Alexandra sleeves handling.

 * And various minor bugfixes, additions, etc.


Changes from v0.6.16.x:

 * Support for Alexandra sleeves 'balance' functionality.

 * Fixed 'curses' functionality.

 * Show heartbeat number on 'sc' lines where tick is detected.

 * Few misc bugfixes.


Changes from v0.6.15.x:

 * Various improvements and fixes in alchemist module.

 * Support for changes in flower BatMUD's round flag, etc.

 * Some internal changes in the core, including separation of
   skill/spell "stopped" and "interrupted" events.

 * A number of bugfixes and documentation improvements.


Changes from v0.6.14.3:

 * Support for few recent changes in flower BatMUD.

 * Added preliminary alchemist guild module (gm-alchemist.tf)
   However, it is not yet meant for general consumption. Feel
   free to test, but bugreports etc are NOT welcome.

 * Ability to disable most of the default lites during load-time
   by setting opt_lites=off in .tfrc or via the save system.

 * Automatically tries to create the datapath directory if it does
   not already exist.

 * Different reminder/belling modes for Raise module. See
   the "/acptbell" setting. Added new command "/acpurge" for
   purging stale/old accepts. Use "/acptpurge" to set the threshold
   time in minutes.

 * Improved tool autowielding and removing in Merchant module. Better
   support for merchant toolbelt.

 * Various and numerous bugfixes.


Changes from v0.6.13.6:

 * Integration of heartbeat+tick code in core (see manual for the details.)

 * Improvements and bugfixes in hitstats.

 * Initial beastmaster guild module (gm-bmaster.tf)

 * Some folklorist prot fixes (possibly not finalized yet.)

 * Documentation improvements.

 * Various cleanups and bugfixes.

