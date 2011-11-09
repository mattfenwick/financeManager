
use strict;
use warnings;
use Tkx;

package WidgetBase;

sub new {
    my ( $class, $parent, @options ) = @_;
    print "base: @_\n";
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

#package Example;
#use parent qw/WidgetBase/;

#sub new {
#    my ( $class, $parent ) = @_;
#    print "derived: @_\n";
#    my $self = $class->SUPER::new($parent);
#}


1;
