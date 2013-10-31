package ExobrainPipeline;

use Moose 0.92;

use List::Util qw(first);
use Moose::Autobox 0.09; # ->flatten

use namespace::autoclean;

our $VERSION = '0.01';

has plugins => (
  is   => 'ro',
  isa  => 'ArrayRef[ExobrainPipeline::Role::Plugin]',
  init_arg => undef,
  default  => sub { [ ] },
);

sub plugin_named {
  my ($self, $name) = @_;
  my $plugin = first { $_->plugin_name eq $name } $self->plugins->flatten;

  return $plugin if $plugin;
  return;
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=encoding utf-8

=head1 NAME

ExobrainPipeline - Blah blah blah

=head1 SYNOPSIS

  use ExobrainPipeline;

=head1 DESCRIPTION

ExobrainPipeline is

=attr plugins

This is an arrayref of plugins that have been plugged into this ExobrainPipeline
object.

Non-core code B<must not> alter this arrayref.  Public access to this attribute
B<may go away> in the future.

=cut

=head1 AUTHORS

Mike Greb E<lt>michael@thegrebs.comE<gt>
Ricardo Signes E<lt>rjbs@cpan.orgE<gt>

rjbs wrote L<Dist::Zilla> which I stole^wborrowed lots of code/design from
=head1 COPYRIGHT

Copyright 2013- Mike Greb

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
