package Class::StateMachine::Declarative::Graphviz;

our $VERSION = '0.01';

use 5.010;
use strict;
use warnings;

use Class::StateMachine::Declarative::Builder;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
}

sub draw_state_machine {
    my ($self, $graph, $class, $sm_decl) = @_;
    my $builder = Class::StateMachine::Declarative::Builder->new($class);
    $builder->parse_state_declarations(@$sm_decl);
    $self->_start($graph);
    $self->_add_state($graph, $builder->{top});
    $self->_add_transitions($graph, $builder);
    $self->_end($graph);
}

sub _add_state {
    my ($self, $graph, $state) = @_;
    my @ss = @{$state->{substates}};
    my $name = $state->{name};
    my $node;
    if (@ss) {
        my $name = "cluster_$name";
        $node = $graph->gv::graph($name);
        my $node0 = $node->gv::node($state->{name});
        $node0->gv::setv(label => 'o');
        $self->_add_state($node, $_) for @ss;
    }
    else {
        $node = $graph->gv::node($name);

    }
    $node->gv::setv(label => $state->{short_name});
    $state->{gv_name} = $name;
}

sub _add_transitions {
    my ($self, $graph, $builder) = @_;
    while (my ($n, $state) = each %{$builder->{states}}) {
        while (my ($event, $target) = each %{$state->{transitions_abs}}) {
            $self->_add_transition($graph, $event, $state, $builder->{states}{$target});
        }
        if (defined(my $jump = $state->{jump_abs})) {
            $self->_add_transition($graph, '<jump>', $state, $builder->{states}{$jump});
        }
    }
}

sub _add_transition {
    my ($self, $graph, $event, $from, $to) = @_;
    my $edge = $graph->gv::edge($from->{gv_name}, $to->{gv_name});
    $edge->gv::setv(label => $event);
}


    #     when ('transitions') {
    #                 while (my ($event, $to) = each %$v) {
    #                     push @transitions, { from => $name,
    #                                          event => $event,
    #                                          to => $to };
    #                 }
    #             }
    #             default {
    #                 warn "unsupported declaration $k\n";
    #             }
    #         }
    #     }
    #     my $node = $graph->gv::node($name);
    #     #$node->gv::setv(shape => 'record');
    #     #my $label = join("|", $name,
    #     #                 (defined $enter ? "enter: $enter" : ()),
    #     #                 (defined $leave ? "leave: $leave" : ()));
    #     #$node->gv::setv(label => "{ $label }");
    #     # $node->setv

    # }
    # $self->_transitions($graph, @transitions);


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
