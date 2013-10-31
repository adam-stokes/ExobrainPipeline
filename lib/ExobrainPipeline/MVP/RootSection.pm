package ExobrainPipeline::MVP::RootSection;
use Moose;
extends 'Config::MVP::Section';
# ABSTRACT: a standard section in ExobrainPipeline's configuration sequence

use namespace::autoclean;

=head1 DESCRIPTION

This is a subclass of L<Config::MVP::Section>, used as the starting section by
L<ExobrainPipeline::MVP::Assembler::Exobrain>.  It has a number of useful defaults, as
well as an C<exobrain> attribute which will, after section finalization, contain an
ExobrainPipeline object with which subsequent plugin sections may register.

Those useful defaults are:

=for :list
* name defaults to _

=cut

use MooseX::LazyRequire;
use MooseX::SetOnce;
use Moose::Util::TypeConstraints;

has '+name'    => (default => '_');

has exobrain => (
  is     => 'ro',
  isa    => class_type('ExobrainPipeline'),
  traits => [ qw(SetOnce) ],
  writer => 'set_exobrain',
  lazy_required => 1,
);

after finalize => sub {
  my ($self) = @_;

  my $assembler = $self->sequence->assembler;

  my %payload = %{ $self->payload };

  my %exobrain;
  $exobrain{$_} = delete $payload{":$_"} for grep { s/\A:// } keys %payload;

  require ExobrainPipeline;
  my $exobrain = ExobrainPipeline->new( \%payload );

  $self->set_exobrain($exobrain);
};

__PACKAGE__->meta->make_immutable;
1;
