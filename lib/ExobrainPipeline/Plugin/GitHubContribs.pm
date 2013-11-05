package ExobrainPipeline::Plugin::GitHubContribs;
use Moose;
with 'ExobrainPipeline::Role::Plugin';

use 5.010;
use Moose::Autobox;
use Net::GitHub 0.54;    # $user->contributions
use namespace::autoclean;

has title    => ( is => 'ro', isa => 'Str', default => 'GitHub Contributions' );
has username => ( is => 'ro', isa => 'Str', default => $ENV{USERNAME} );
has tdp_id    => ( is => 'ro', isa => 'Int',  required => 0 );
has time_zone => ( is => 'ro', isa => 'Str',  required => 0 );
has today     => ( is => 'ro', isa => 'Bool', default  => 0 );

sub execute {
    my ( $self, $data ) = @_;

    my %contrib_data;
    $contrib_data{ $_->[0] } = $_->[1]
        for Net::GitHub->new->user->contributions( $self->username )->flatten;

    my @dt_tz_args = $self->time_zone ? ( time_zone => $self->time_zone ) : ();

    my $day = DateTime->today(@dt_tz_args);
    $day = $day->subtract( days => 1 ) unless $self->today;
    $day = $day->strftime('%Y/%m/%d');
    my $contributions = $contrib_data{$day} || 'Unknown';

    my $message = "$contributions contributions to GitHub on $day.";

    my $output = {
        agenda => {
            text => $self->title . "\n"
                . '=' x length( $self->title ) . "\n"
                . $message . "\n",
            html => "<h1>" . $self->title . "</h1>\n<pre>$message</pre>\n"
        } };

    if ( $contributions && $contributions ne 'Unknown' && $self->tdp_id ) {
        $output->{tdp} = { id => $self->tdp_id, note => $message };
    }

    $data->push($output);

    return $data;
}

1;

__END__

[GitHubContribs]
username  = mikegrb
tdp_id    = 50543
time_zone = America/New_York