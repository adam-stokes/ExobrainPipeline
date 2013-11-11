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

sub run {
    my $self = shift;

    my $data = [];
    $data = $_->execute($data) for $self->plugins->flatten;

    return $data;
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=encoding utf-8

=head1 NAME

ExobrainPipeline - plugin based application for letting Perl think for you

=head1 DESCRIPTION

ExobrainPipeline is an application implementing a data pipeline and plugins
to let Perl automate your life.  Plugins can aggregate iCal feeds,
quantified-self data, etc that get passed on to other plugins generating daily
emails, complete goals on https://tdp.me , etc.

Design of L<ExobrainPipeline> is largely based on L<Dist::Zilla> and ideas from
Ricardo Signes & Paul Fenwick.

=head1 AUTHOR

Mike Greb E<lt>michael@thegrebs.comE<gt>

=head1 COPYRIGHT

Copyright 2013- Mike Greb

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

https://www.facebook.com/paul.fenwick/posts/10151680344699611

https://github.com/rjbs/Ywar


=cut
