
use strict;
use warnings;

package CheckBox;
use parent qw/WidgetBase/;
use Log::Log4perl qw(:easy);



sub new {
    my ($class, $parent, $text) = @_;
    my $self = $class->SUPER::new($parent);
    my $frame = $self->{frame};
    
    $self->{var} = 0;
    $self->{checkBox} = $frame->new_ttk__checkbutton(-text => $text,
        -variable => \$self->{var},
        -command => sub {$self->{frame}->configure(-background => "red");} );
        
    $self->{checkBox}->g_grid(-row => 0, -column => 0);
    # colors ########
    $self->{frame}->configure(-borderwidth => 5);
    # end colors ########
    return $self;
}


sub setChecked {
    my ($self, $isChecked) = @_;
    $self->{var} = $isChecked;
}


sub isChecked {
	my ($self) = @_;
	return $self->{var};
}


1;