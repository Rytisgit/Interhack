my %hunger_annotation = (
	'starving'   => 'Your pet is starving',
	'distressed' => 'pet is hungry/trapped/confused/fleeing/becoming untame',
	'hungry'     => 'pet is hungry',
	'almost hungry' => 'pet will be hungry in <1000 turns',
	'untame'     => 'pet is about to become untame',
	'OK'         => 'pet is not hungry',
);

#all pets
make_annotation 'You feel worried about' => $hunger_annotation{'starving'};

#dogs
make_annotation 'whines.' => $hunger_annotation{'distressed'};
make_annotation 'barks.' => $hunger_annotation{'almost hungry'};
make_annotation 'yips.' => $hunger_annotation{'OK'};

#cats
make_annotation 'yowls.' => $hunger_annotation{'distressed'};
make_annotation 'mews.' => $hunger_annotation{'almost hungry'};
make_annotation 'meows.' => $hunger_annotation{'hungry'};
make_annotation 'purrs.' => $hunger_annotation{'OK'};

#horses
make_annotation 'neighs.' => $hunger_annotation{'untame'};
make_annotation 'whinnies.' => $hunger_annotation{'hungry'};
make_annotation 'whickers.' => $hunger_annotation{'OK'};

