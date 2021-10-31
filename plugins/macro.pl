# Adds an extended command to record a macro that can be replayed with Ctrl-R
# joc

{
	my $recording_macro = 0;
	my $macro_start;
	my $macro_end;

	sub store_macro
	{
		$recording_macro = !$recording_macro;
		if ($recording_macro) {
			$macro_start = $keystrokes;
			return "Recording macro. Enter #macro again to stop recording.";
		} else {
			$macro_end = $keystrokes - 7;
			$duration = $macro_end - $macro_start;
			@macro_keys = ();
			for (my $i = -1 * $duration - 7; $i < -7; ++$i)
			{
				push @macro_keys, $lastkeys[$i];
			}
			$macro = join('', @macro_keys);
			remap "\cr" => "$macro";
			return "Recorded $duration keys. Press Ctrl-R to replay.";
		}
		#$args = shift;
		#remap "\cr" => "$args"; #ctrl-m doesn't work for some reason
		#return "press Ctrl-R to send $args";
	}
}

extended_command "#macro"
	=> sub
	{
		return store_macro;
		#my (undef, $args) = @_;
		#if (!defined $args)
		#{
		#	return "Usage: #macro [keysequence]";
		#}
		#chomp($args);
		#return store_macro $args;
	}
