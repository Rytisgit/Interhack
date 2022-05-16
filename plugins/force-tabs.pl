# this sets up some "press tab to continue" prompts for important messages,
# like "You are slowing down."
# by Eidolos and toft (idea by doy)

press_tab(qr/\bYou are slowing down\./, "Lizard, !acid, STF, pray? 2 turns to live.");
press_tab(qr/\bYour limbs are stiffening\./, "Lizard, !acid, STF, pray? 1 turn to live.");

press_tab(qr/\bYou don't feel very well\./, 'Fire, Cure Sickness, Aesc, "unchang, poly, pray? 9 turns to live.');
press_tab(qr/\bYou are turning a little green\./, 'Fire, Cure Sickness, Aesc, "unchang, poly, pray? 8 turns to live.');
press_tab(qr/\bYour limbs are getting oozy\./, 'Fire, Cure Sickness, Aesc, "unchang, poly, pray? 6 turns to live.');
press_tab(qr/\bYour skin begins to peel away\./, 'Fire, Cure Sickness, Aesc, "unchang, poly, pray? 4 turns to live.');
press_tab(qr/\bYou are turning into a green slime\./, 'Fire, Cure Sickness, Aesc, "unchang, poly, pray? 2 turns to live.');

press_tab qr/\bYou faint from lack of food\./;
press_tab(qr/\bYou feel deathly sick\./, "You have about 20 turns to live.");
press_tab(qr/\bYou feel (?:much|even) worse\./, "Your turns to live have just been cut to about a third.");
press_tab qr/\bStop eating\?/;

press_tab(qr/\bThe [^.!\e]*? swings itself around you!/, 'Kill, tele, poly, "MB, freeze, delev? 1 turn to live.');
press_tab(qr/\bThe python grabs you!/, 'Kill, tele, poly, "MB, freeze, delev? 1 turn to live.');

press_tab qr/^Really quit\? \[yn\] \(n\) +$/;
press_tab qr/"So thou thought thou couldst kill me, fool\."/;
press_tab qr/\bDouble Trouble\.\.\./;

press_tab qr/\bNothing happens\./, undef, 0.5;
press_tab qr/\bYou don't have enough energy to cast that spell\./, undef, 0.5;

press_tab(qr/\bYou feel feverish\./, 'lycanthropy. sprig of wolfsbane/holy water/pray "unchang/poly control');
press_tab qr/\bYou see here a c(?:hi|o)ckatrice corpse\./;
press_tab qr/.*Vorpal Blade.*/;

press_tab qr/Your wielded .* rots away\./;
press_tab qr/You feel more confident in your.*skills./;
press_tab qr/You feel a strange vibration.*/;
press_tab qr/You have a .* feeling for a moment, then it passes\./;
press_tab qr/You sense a faint wave of psychic energy.*/;
press_tab qr/The scroll turns to dust as you pick it up\./;

