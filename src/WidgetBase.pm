
use strict;
use warnings;
use Tkx;

package WidgetBase;
use Log::Log4perl qw(:easy);


sub new {
    my ( $class, $parent, @options ) = @_;
    
    DEBUG("initializing widget base with parameters: @_");
    
    my $self = { 
        frame => $parent->new_frame(@options), 
    };
    bless( $self, $class );
    return $self;
}


sub g_grid {
    my ( $self, @options ) = @_;
    my %options = @options;
    $options{-padx} = 5;
    $options{-pady} = 5;
    @options = %options;
    $self->{frame}->g_grid(@options);
}


sub setColor {
    my ($self, $color) = @_;
    DEBUG("changing color to <$color>");
    $self->{frame}->configure(-background => $color);
}


sub setDefaultColor {
    my ($self) = @_;
    $self->{frame}->configure(-background => "SystemButtonFace");
}


1;
