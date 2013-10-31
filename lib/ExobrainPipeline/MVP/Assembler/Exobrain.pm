package ExobrainPipeline::MVP::Assembler::Exobrain;
use Moose;
extends 'ExobrainPipeline::MVP::Assembler';
# ABSTRACT: ExobrainPipeline::MVP::Assembler for the ExobrainPipeline object

use namespace::autoclean;

=head1 OVERVIEW

This is a subclass of L<ExobrainPipeline::MVP::Assembler> used when assembling the
ExobrainPipeline object.

Upon construction, the assembler will create an L<ExobrainPipeline::MVP::RootSection>
as the initial section.

=cut

use MooseX::Types::Perl qw(PackageName);
use ExobrainPipeline::MVP::RootSection;

sub BUILD {
  my ($self) = @_;

  my $root = ExobrainPipeline::MVP::RootSection->new;
  $self->sequence->add_section($root);
}

=method exobrain

This method is a shortcut for retrieving the C<exobrain> from the root section.
If called before that section has been finalized, it will result in an
exception.

=cut

sub exobrain {
  my ($self) = @_;
  $self->sequence->section_named('_')->exobrain;
}

__PACKAGE__->meta->make_immutable;
1;
