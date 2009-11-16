package AnyEvent::Plurk;

our $VERSION = 0.01;

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

    $self->{_tick_timer} = AnyEvent->timer(
        after => 60,
        cb    => sub {
            delete $self->{_tick_timer};
            $self->_tick
        }
    );
}

sub start {
    my $self = shift;
    $self->_tick;
}

1;
