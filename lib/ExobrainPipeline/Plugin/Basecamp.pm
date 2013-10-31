package ExobrainPipeline::Plugin::Basecamp;
use Moose;
with 'ExobrainPipeline::Role::Plugin';

use 5.010;

use Template;
use Moose::Autobox;
use Time::Duration;
use WebService::BasecampX;
use DateTime::Format::ISO8601;

use namespace::autoclean;

has username   => ( is => 'ro', isa => 'Str', required => 1 );
has password   => ( is => 'ro', isa => 'Str', required => 1 );
has account_id => ( is => 'ro', isa => 'Int', required => 1 );
has person     => ( is => 'ro', isa => 'Int', required => 0 );

sub mvp_multivalue_args { 'ignore' }
has ignore     => ( is => 'ro', isa => 'ArrayRef[Int]', required => 0 );

has format_string =>
    ( is => 'ro', isa => 'Str', default => "%-40.40s %10.10s  %-10s  %-10s\n" );

has _api => (
    is      => 'ro',
    isa     => 'WebService::BasecampX',
    lazy    => 1,
    builder => '_get_api'
);

sub _get_api {
    my $self = shift;
    return WebService::BasecampX->new(
        username   => $self->username,
        password   => $self->password,
        account_id => $self->account_id
    );
}

sub execute {
    my ( $self, $data ) = @_;

    my $person = $self->person || $self->_api->person_me->{id};
    my $todo_lists = $self->_api->person_todolists( person => $person );

    my $text_output = "Basecamp ToDos\n";
    $text_output .= '=' x 14 . "\n";
    $text_output .= sprintf( $self->format_string, qw(Task Creator Updated Due) );

    my $tt            = Template->new;
    my $html_template = join( '', <DATA> );
    my $html_output   = "<h1>Basecamp Todos</h1>\n";

    for my $todo_list (@$todo_lists) {
        next if $self->ignore->any == $todo_list->{id};

        $text_output .= "$todo_list->{bucket}{name} - $todo_list->{name}:\n";

        my $todos_data = [];
        for my $todo ( @{ $todo_list->{assigned_todos} } ) {
            $todo->{updated_at} = ddiff( $todo->{updated_at} );
            $todo->{due_on}     = ddiff( $todo->{due_on} );
            $todos_data->push(
                {   item    => $todo->{content},
                    creator => $todo->{creator}{name}->split(' ')->[0],
                    updated => $todo->{updated_at},
                    due     => $todo->{due_on},
                    url     => $self->todo_url(
                        $todo_list->{bucket}{id}, $todo->{id}
                    ),
                } );
            $text_output .= sprintf $self->format_string,
                $todo->{content},    $todo->{creator}{name},
                $todo->{updated_at}, $todo->{due_on};
        }
       $text_output .= "\n";

        my $html_fragment;
        $tt->process(
            \$html_template,
            {   list => {
                    name    => $todo_list->{name},
                    project => $todo_list->{bucket}{name},
                    project_url =>
                        $self->project_url( $todo_list->{bucket}{id} )
                },
                todos => $todos_data
            },
            \$html_fragment
        );
        $html_output .= $html_fragment;
    }

    return $data->push(
        { agenda => { text => $text_output, html => $html_output } } );
}

sub project_url {
    my ( $self, $project ) = @_;
    return
          'https://basecamp.com/'
        . $self->account_id
        . '/projects/'
        . $project;
}

sub todo_url {
    my ($self, $project, $todo) = @_;
    return $self->project_url($project) . '/todos/' . $todo;
}

sub ddiff {
    state $now = time;
    my $date = shift || return '';
    my $dt = DateTime::Format::ISO8601->parse_datetime($date);
    return concise( duration( $now - $dt->epoch ) );
}

__PACKAGE__->meta->make_immutable;

1;

__DATA__
<h2> <a href="[% list.project_url %]">[% list.project %] - [% list.name %]</a></h2>
<table border="1">
<tr>
    <th align="left">Item</th>
    <th align="left">Creator</th>
    <th align="left">Updated</th>
    <th align="left">Due</th>
</tr>
[% FOREACH todo IN todos -%]
<tr height="35">
    <td style="height:35px;width:500px"><a href="[% todo.url %]">[% todo.item %]</a></td>
    <td style="height:35px;width:90px">[% todo.creator %]</td>
    <td style="height:35px;width:90px">[% todo.updated %]</td>
    <td style="height:35px;width:90px">[% todo.due %]</td>
</tr>
[% END -%]
</table>
