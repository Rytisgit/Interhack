my %objanno = (
    "leather jacket"			=> "AC: 1, W: 30",
    "leather armor"				=> "AC: 2, W: 150",
    "orcish ring mail"			=> "AC: 2, MC: 1, W: 250",
    "crude ring mail"			=> "AC: 2, MC: 1, W: 250 (orcish)",
    "studded leather armor"		=> "AC: 3, MC: 1, W: 200",
    "ring mail"					=> "AC: 3, W: 250",
    "scale mail"				=> "AC: 4, W: 250",
    "orcish chain mail"			=> "AC: 4, MC: 1, W: 300",
    "crude chain mail"			=> "AC: 4, MC: 1, W: 300 (orcish)",
    "chain mail"				=> "AC: 5, W: 300",
    "elven mithril coat"		=> "AC: 5, MC: 3, W: 150",
    "splint mail"				=> "AC: 6, MC: 1, W: 400",
    "banded mail"				=> "AC: 6, W: 350",
    "dwarfish mithril coat"		=> "AC: 6, MC: 3, W: 150",
    "bronze plate mail"			=> "AC: 6, W: 400",
    "plate mail"				=> "AC: 7, MC: 2, W: 450",
    "tanko"						=> "AC: 7, MC: 2, W: 450 (plate mail)",
    "crystal plate mail"		=> "AC: 7, MC: 2, W: 450",
);


make_annotation qr/You see here a (.*?)\./ => sub {
	return if (!defined $objanno{$1});
	$objanno{$1};
};
