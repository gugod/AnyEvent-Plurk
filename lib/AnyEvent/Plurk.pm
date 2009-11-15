package AnyEvent::Plurk;

our $VERSON = 0.01;

use common::sense 2.02;
use parent        0.223 "Object::Event";
use AnyEvent   5.202;
use Net::Plurk 0.000;

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

    my $plurks = $self->{_plurk}->get_owner_latest_plurks();

    my @new_plurks = ();
    for my $i (0..$#$plurks) {
        my $id = $plurks->[$i]->{id};

        unless ($self->{_seen_plurk}{$id}) {
            push @new_plurks, $plurks->[$i]
        }

        $self->{_seen_plurk}{$id} = 1;
    }

    $self->event("latest_owner_plurks" => \@new_plurks);

    AnyEvent->timer(
        after => 60,
        cb    => sub { $self->_tick }
    );
}

sub start {
    my $self = shift;
    $self->_tick;
}

1;
