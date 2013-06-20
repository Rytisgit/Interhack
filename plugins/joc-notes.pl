# This is a simple fork of the original notes plugin, with configurable
# autonotes and a search function.
#
# The original plugin must be excluded if this version is to be used
#
# add extended-commands #annotate, #notes and #grepnotes
#
# by joc

our $note_file ||= 'notes.txt';

sub open_notes # {{{
{
    my $rw = shift || '>>';
    open my $h, $rw, $note_file
        or warn "Unable to open $note_file for ${rw}ing: $!";
    return $h;
} # }}}

my $note_handle = open_notes('>>');

sub make_note # {{{
{
    print {$note_handle} map {"$dlvl $_\n"} @_;
} # }}}

sub note_all # (stuff noted every time, like wishes) # {{{
{
    my ($matching, $note) = @_;
    each_match $matching => sub { make_note(value_of($note)) };
} # }}}

# sub note_once_per_dl (stuff noted only once for a dlvl, like shops) {{{
{
	my %seen_dl;
	my $noted = "";
	my $file_parsed = 0;
	if (!file_parsed) {
		close $note_handle;
		$note_handle = open_notes('<');
		while (my $line = <$note_handle>)
		{
			$noted = $noted . $line;
		}
		close $note_handle;
		$note_handle = open_notes('>>');
		$file_parsed = 1;
	}

	sub note_once_per_dl
	{
		my ($matching, $note) = @_;

		each_match $matching => sub
		{
			my $t = value_of($note);
			return if $t eq '' || $seen_dl{"$dlvl $t"}++ || $noted =~ qr/$dlvl:\s*$t/;
			make_note($t);
		}
	}
	my %seen;

	sub note_once
	{
		my ($matching, $note) = @_;

		each_match $matching => sub
		{
			my $t = value_of($note);
			return if $t eq '' || $seen{$t}++;
			make_note($t);
		}
	}
}

extended_command "#annotate" # {{{
              => sub
                 {
                     my (undef, $args) = @_;
                     if (!defined($args))
                     {
                        return "Syntax: #write [note]";
                     }
                     make_note $args;
                     return "Noted!";
                 }; # }}}
extended_command "#notes" # {{{
              => sub
                 {
                     close $note_handle;

                     $ENV{EDITOR} = 'vi' unless exists $ENV{EDITOR};
                     system("$ENV{EDITOR} $note_file");

                     $note_handle = open_notes('>>');
                     request_redraw();

                     return "Thank you sir, may I have another?";
                 }; # }}}
extended_command "#grepnotes" # {{{
				=> sub
					{
						my (undef, $regexp) = @_;
						if (!defined($regexp))
						{
							return "Syntax: #grepnotes [regexp]";
						}
						close $note_handle;
						$note_handle = open_notes('<');
						my @matches;
						while (my $line = <$note_handle>)
						{
							if ($line =~ $regexp)
							{
								push @matches, $line;
							}
						}
						chomp(@matches);
						close $note_handle;
						$note_handle = open_notes('>>');
						return join(' | ', @matches) || "$colormap{red}no matches!\e[0m"
					}; # }}}
					

# set up some autonotes (this will become its own plugin) {{{
# major events {{{
note_all qr/^For what do you wish\?/ => "Got a wish!" if $note_wishes;
note_all qr/Welcome to experience level (\d+)\./ => sub { "Hit experience
	level $1." } if $note_levels;
note_all 'You receive a faint telepathic message from ' => "Quest!" unless $nonote_quest;
note_all '"So thou thought thou couldst kill me, fool."' => "Rodney encounter!" if $note_rodney;
note_all 'Double Trouble...' => "Double Trouble!" if $note_rodney;
note_all 'A mysterious force momentarily surrounds you...' => "Hit by the mysterious force." if $note_hell;
note_all 'But now thou must face the final Test...' => "Entered the Endgame." if $note_planes;
# }}}
# altars {{{
note_once_per_dl qr/There is an altar to .*? \((\w+)\) here\./ => sub { "\u$1 altar" } unless $nonote_altars;
note_once_per_dl qr/^.\s+.*?\((\w+) altar\)/ => sub { "\u$1 altar" } unless $nonote_altars;
# }}}
# shops {{{
# when we get a generic shop message, we check $shop{dlvl} -- if it's already
# set to >0, then we have seen a more specific shop message
our %shop;

note_once_per_dl qr/You hear (?:the chime of a cash register|someone cursing shoplifters)\./ => sub { $shop{$dlvl} ? "" : "Level has some kind of shop"} if $note_unknownshop;

# get rid of "again" when persistence is in..
our %shoptype =
(
    'general store' => 'general',
    'used armor dealership' => 'armor',
    'second-hand bookstore' => 'scroll',
    'liquor emporium' => 'potion',
    'antique weapons outlet' => 'weapon',
    'delicatessen' => 'food',
    'jewelers' => 'ring',
    'quality apparel and accessories' => 'wand',
    'hardware store' => 'tool',
    'rare books' => 'spellbook',
    'lighting store' => 'lighting',
);
my $shops = join '|', keys %shoptype;

unless ($nonote_shops) 
{
   	note_once_per_dl qr/"[^\e]+Welcome(?: again)? to .*? ($shops)!"/
       => sub { $shop{$dlvl} = 1; "Level has a $shoptype{$1} store"};

	note_once_per_dl qr/You read: "Closed for inventory"./
	   => sub { "Level has a closed shop"};
}
# }}}
# nonshop special rooms {{{
note_once_per_dl "You hear the footsteps of a guard on patrol." => "Level has a vault" unless $nonote_vaults;
# }}}
# }}}

# The following is blatantly stolen from intrinsics-matcher
include "stats";

my %role_intrinsics =
(
    Arc => ['stealth', 'fast'],
    Bar => ['poison'],
    Cav => [],
    Hea => ['poison'],
    Kni => [],
    Mon => ['fast', 'sleep', 'see invisible'],
    Pri => [],
    Rog => ['searching'],
    Ran => ['stealth'],
    Sam => ['fast'],
    Tou => [],
    Val => ['cold'],
    Wiz => [],
);

my %race_intrinsics =
(
    'Dwa' => [],
    'Elf' => [],
    'Hum' => [],
    'Orc' => ['poison'],
    'Gno' => [],
);
my $seen_role = '';
my $seen_race = '';

unless ($nonote_intrinsics)
{
# Check for starting intrinsics and stuff
	each_iteration
	{
		if ($seen_role ne $role)
		{
			for my $intrinsic (@{$role_intrinsics{$role}})
			{
				make_note "Gained " . $intrinsic . " by role"
			}
			$seen_role = $role;
		}
		if ($seen_race ne $race)
		{
			for my $intrinsic (@{$race_intrinsics{$race}})
			{
				make_note "Gained " . $intrinsic . " by race"
			}
			$seen_race = $race;
		}
	}

# good messages {{{
# resists {{{
	note_once qr/You feel (?:(?:especially )?healthy|hardy)\./ => "gained poison resistance";
	note_once qr/You feel (?:full of hot air|warm)\./ => $add, "gained cold resistence";
	note_once qr/You (?:feel a momentary chill|feel cool(?!er)|be chillin')\./ => "gained fire resistance";
	note_once qr/You feel (?:wide )?awake./ => "gained sleep resistance";
	note_once qr/You feel (?:very firm|totally together, man)\./ => "gained disintegration resistance";
	note_once "Your health currently feels amplified!" => "gained shock resistance";
	note_once qr/You feel (?:insulated|grounded in reality)/ => "gained shock resistance";
# }}}
# other intrinsics {{{
	note_once qr/You feel (?:very jumpy|diffuse)\./ => "got teleportitis";
	note_once qr/You feel (?:in control of yourself|centered in your personal space)\./ => "gained teleport control";
	note_once "You feel controlled." => "gained teleport control";
	note_once qr/You feel (?:a strange mental acuity|in touch with the cosmos)\./ => "gained telepathy";
	note_once "You feel hidden." => "gained invisibility";
	note_once "You feel perceptive." => "gained searching";
	note_once "You feel stealthy." => "gained stealth";
	note_once "You feel sensitive." => "gained warning";
	note_once qr/You feel (?:very self-conscious|transparent)\./ => "gained see invisible";
	note_once "You see an image of someone stalking you." => "gained see invisible";
	note_once "Your vision becomes clear." => "gained see invisible";
	note_once qr/You (?:seem faster|feel quick|speed up)./ => "gained fast speed";
	note_once qr/"and thus I grant thee the gift of Speed!"/ => "gained fast speed";
# }}}
# }}}
# dangerous messages {{{
# losing resists {{{
	note_once "You feel warmer." => "lost fire resistance";
	note_once "You feel cooler." => "lost cold resistance";
	note_once "You feel a little sick." => "lost poison resistance";
	note_once "You feel tired." => "lost sleep resistance";
	note_once "You feel conductive." => "lost shock resistance";
# }}}
# losing intrinsics {{{
	note_once "You feel unaware." => "lost warning";
	note_once "You slow down." => "lost fast speed";
	note_once "You seem slower." => "lost fast speed";
	note_once qr/You feel (?:slow|slower)\./ => "lost fast speed";
	note_once "You feel paranoid." => "lost invisibility";
	note_once "You feel clumsy." => "lost stealth";
	note_once "You feel less jumpy." => "lost teleportitis";
	note_once "You feel uncontrolled." => "lost teleport control";
	note_once qr/You (?:thought you saw something|tawt you taw a puttie tat)\./ => $add, "lost see invisible";
	note_once "Your senses fail." => "lost telepathy";
# }}}
# }}}
}
