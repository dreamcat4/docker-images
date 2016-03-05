Irssi::signal_add_first("event 311", sub { level("-") } );
Irssi::signal_add_last("event 318", sub { level("+") } );
Irssi::signal_add_last("event 369", sub { level("+") } );

sub level {
   Irssi::window_find_name("(status)")->command("^window level $_[0]crap");
}

