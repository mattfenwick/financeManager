
use strict;
use warnings;

package LabelEntry;
use parent qw/WidgetBase/;


# public functions:
#    new(class, parent widget, text of the label, text validator)
#                    --> a new LabelEntry instance
#    getText(self)            --> the text in the entry widget
#    setText(self)
#
# private functions:
#

sub new {
    my ($class, $parent, $text, $validator) = @_;
    my $self = $class->SUPER::new($parent);
    my $frame = $self->{frame};
    $self->{label} = $frame->new_label(-text => $text);
    $self->{text} = "";
    $self->{entry} = $frame->new_entry(-textvariable => \$self->{text});
    $self->{validator} = $validator;
    $self->{label}->g_grid(-row => 0);
    $self->{entry}->g_grid(-row => 1);
#    $frame->configure(-relief => 'raised', -bd => 2, -background => 'blue');
    return $self;
}


sub getText {
    my ($self) = @_;
    my $text = $self->{text};
    my $validator = $self->{validator};
    &{$validator}($text);# throw an exception if invalid
    return $text;
}

sub setText {
    my ($self, $newtext) = @_;
    $self->{text} = $newtext;
}

1;