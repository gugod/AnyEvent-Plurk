package AnyEvent::Plurk;
our $VERSION = "0.03";

use 5.008;
use common::sense 2.02;
use parent        0.223 "Object::Event";
use AnyEvent   5.202;
use Net::Plurk 1258308569;

use Carp "croak";

sub new {
   my $this  = shift;
   my $class = ref($this) || $this;
   my $self  = $class->SUPER::new(@_);

   unless (defined $self->{username}) {
      croak "no 'username' given to AnyEvent::Plurk\n";
   }

   unless (defined $self->{password}) {
      croak "no 'password' given to AnyEvent::Plurk\n";
   }

   $self->{_plurk} = Net::Plurk->new;

   $self->{_plurk}->login($self->{username}, $self->{password});
   $self->{_seen_plurk} = {};

   return $self
}

sub _tick {
    my $self = shift;

    my @unread_plurks =
        map  { $self->{_seen_plurk}{ $_->{id} } = 1; $_ }
        grep { !$self->{_seen_plurk}{ $_->{id} } }
        @{$self->{_plurk}->get_unread_plurks()};

    $self->event("unread_plurks" => \@unread_plurks);
}

sub start {
    my $self = shift;
    $self->{_tick_timer} = AE::timer(0, 60, sub { $self->_tick });
}

1;

__END__

=head1 NAME

AnyEvent::Plurk - plurk interface for AnyEvent-based programs

=head1 SYNOPSIS

    my $p = AnyEvent::Plurk->new(
        username => $username,
        password => $password
    );
    $p->reg_cb(
        unread_plurks => sub {
            my ($p, $plurks) = @_;
            is(ref($plurks), "ARRAY", "Received latest plurks");
        }
    );
    $p->start;


=head1 AUTHOR

Kang-min Liu  C<< <gugod@gugod.org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009, Kang-min Liu C<< <gugod@gugod.org> >>.

This is free software, licensed under:

    The MIT (X11) License

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
