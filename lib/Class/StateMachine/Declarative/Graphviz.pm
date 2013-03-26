package Class::StateMachine::Declarative::Graphviz;

our $VERSION = '0.01';

use 5.010;
use strict;
use warnings;

use Moo;

sub draw_state_machine {
    my ($self, $graph, $sm_decl) = @_;
    $self->_start($graph);
    my @transitions;
    my @states = @$sm_decl;
    while (@states) {
        my $name = shift @states;
        my $decl = shift @states;
        my ($enter, $leave, @delay, @ignore);
        while (my ($k, $v) = each %$decl) {
            given ($k) {
                when ('enter') {
                    $enter = $v;
                }
                when ('leave') {
                    $leave = $v;
                }
                when (/^delay(?:_once)?$/) {
                    push @delay, @$v;
                }
                when ('ignore') {
                    push @ignore, $v;
                }
                when ('jump') {
                    push @transitions, { from => $name,
                                         event => 'jump',
                                         to => $v }
                }
                when ('transitions') {
                    while (my ($event, $to) = each %$v) {
                        push @transitions, { from => $name,
                                             event => $event,
                                             to => $to };
                    }
                }
                default {
                    warn "unsupported declaration $k\n";
                }
            }
        }
        my $node = $graph->gv::node($name);
        $node->gv::setv(shape => 'record');
        my $label = join("|", $name,
                         (defined $enter ? "enter: $enter" : ()),
                         (defined $leave ? "leave: $leave" : ()));
        $node->gv::setv(label => "{ $label }");
        # $node->setv

    }
    $self->_transitions($graph, @transitions);
    $self->_end($graph);
}

sub _transitions {
    my ($self, $graph, @transitions) = @_;
    for my $t (@transitions) {
        my $edge = $graph->gv::edge($t->{from}, $t->{to});
        $edge->gv::setv(label => $t->{event});
    }
}

sub _start {}
sub _end {}


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Class::StateMachine::Declarative::Graphviz - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Class::StateMachine::Declarative::Graphviz;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Class::StateMachine::Declarative::Graphviz, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Salvador Fandiño, E<lt>salva@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Salvador Fandiño

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
