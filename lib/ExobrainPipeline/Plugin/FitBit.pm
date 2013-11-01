package ExobrainPipeline::Plugin::FitBit;
use Moose;
with 'ExobrainPipeline::Role::Plugin';

use 5.010;

use WebService::FitBit;

use namespace::autoclean;

has step_goal => ( is => 'ro', isa => 'Int', default  => 10000 );
has tdp_id    => ( is => 'ro', isa => 'Int', required => 1 );

has _api => (
    is      => 'ro',
    isa     => 'WebService::FitBit',
    lazy    => 1,
    default => sub { return WebService::FitBit->new() } );

sub execute {
    my ( $self, $data ) = @_;

    my $steps = $self->_api->steps_taken();

    if ( $steps >= $self->step_goal ) {
        push @$data, {
            tdp => [ $self->tdp_id, "$steps steps" ],
            agenda => "You met your step goal with $steps steps\n",
        };

    }
    else {
        my $deficit = $self->step_goal - $steps;
        push @$data,
            { agenda =>
                "You were $deficit under your step goal with $steps steps." };
    }

    return $data;
}

1;

__END__
Sample conf:

[FitBit]
step_goal = 7500
tdp_id    = 12345
