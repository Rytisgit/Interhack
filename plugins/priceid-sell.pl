# Does price-identification when selling

# Options:
# $sell_id_tab=1  -  makes TAB name the item (not very tested yet)
# $sell_id_uniq=1 -  makes TAB pickup and drop the item again
#                    iff the price quote is not unique.

include "priceid-buy";

our ($sell_id_tab,$sell_id_uniq);

sub getslot {
	if (alphakeys(-2) eq "d"){
		return alphakeys(-1);
	};
	if (alphakeys(-3) eq "d" && alphakeys(-1) eq " "){
		return alphakeys(-2);
	};
    return "-";
}


sub do_sell_id {
	my ($amount,$appearance,$type)=@_;
	my $slot=getslot();

	my %obj=%{$price_table{$type}};

	my (@prices,@possibilities);
	for my $price (keys %obj){
		my $sale=int ($price /2);
		$sale = int ($price/3) if ($role eq 'Tou' && $xlvl <= 15) || $shirt;
		if ($amount == $sale){
			push @prices,$price;
			push @possibilities, @{$short_names{$type}{$price}||$obj{$price}};
		};
		$sale=int($sale*3/4 +0.5); # round up
		if ($amount == $sale){
			push @prices,$price;
			push @possibilities, @{$short_names{$type}{$price}||$obj{$price}};
		};
	};
	my $cost=join"/",@prices;
	$cost=~ s/00//g if ($type eq "spellbook");
	my $name;
	if (@possibilities <= 3){
		$name =join '/', @possibilities;
	} else { 
		$name = $cost;
	};
	
	my $txt="SELL-ID: $type($appearance) $name";
	if ($sell_id_tab && $slot =~ /^[a-zA-Z]$/){
		if(@prices == 2 && $sell_id_uniq){
			$tab="\e,\ed${slot} ";
			$txt.=" [TAB to try again]";
		}else{
			$tab="\e,\e#name\nn${slot}${appearance} ${name}\n";
			$txt.=" [TAB to name it]";
		};
		if(!$sell_id_tab_nice){
			$txt="Press tab to send the string: $tab";
			$txt =~ s/\n/\\n/g;
			$txt =~ s/\e/\\e/g;
		};
	}
	annotate($txt);
};

each_match qr/offers (\d+) gold pieces for your (\w+) (spellbook|potion|ring|wand)\. +Sell it\?/ => sub { do_sell_id($1,$2,$3) };

each_match qr/offers (\d+) gold pieces for your (scroll) labeled (.*?)\. +Sell it\?/ => sub { do_sell_id($1,$3,$2) };
