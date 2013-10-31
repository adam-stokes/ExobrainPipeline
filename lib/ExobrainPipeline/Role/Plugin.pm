package ExobrainPipeline::Role::Plugin;
# ABSTRACT: something that gets plugged in to ExobrainPipeline
use Moose::Role;

use Params::Util qw(_HASHLIKE);
use Moose::Autobox;
use MooseX::Types;

use namespace::autoclean;

=head1 DESCRIPTION

The Plugin role should be applied to all plugin classes.  It provides a few key
methods and attributes that all plugins will need.

=attr plugin_name

The plugin name is generally determined when configuration is read.

=cut

has plugin_name => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
);

=attr exobrain

This attribute contains the ExobrainPipeline object into which the plugin was
plugged.

=cut

has exobrain=> (
  is  => 'ro',
  isa => class_type('ExobrainPipeline'),
  required => 1,
  weak_ref => 1,
);

# We define these effectively-pointless subs here to allow other roles to
# modify them with around. -- rjbs, 2010-03-21
sub mvp_multivalue_args {};
sub mvp_aliases         { return {} };

sub plugin_from_config {
  my ($class, $name, $arg, $section) = @_;

  my $self = $class->new(
    $arg->merge({
      plugin_name => $name,
      exobrain => $section->sequence->assembler->exobrain,
    }),
  );
}

sub register_component {
  my ($class, $name, $arg, $section) = @_;

  my $self = $class->plugin_from_config($name, $arg, $section);

  my $version = $self->VERSION || 0;

  $self->exobrain->plugins->push($self);

  return;
}

1;
