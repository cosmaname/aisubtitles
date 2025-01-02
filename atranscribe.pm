package atranscribe;

use v5.34.0;
use Moo;
use OpenAPI::Client::OpenAI;
use Data::Dumper;

has model           => ( is => 'ro', default => 'whisper-1' );
has language        => ( is => 'ro', default => 'en' );
has response_format => ( is => 'ro', default => 'vtt' );
has temperature     => ( is => 'ro', default => .1 );
has max_tokens      => ( is => 'ro', default => 8000 );
has prompt          => ( is => 'ro', default => 'This MP3 file is a movie fragment with dialogue in British English, transcribe it. ' );
# This MP3 is a movie fragment with dialogue in Romanian, transcribe it. Use ISO-8859-2 text encoding.' );
has _client         => ( is => 'ro', default => sub { OpenAPI::Client::OpenAI->new } );

sub transcribe_file {
  my ($self,$filename, $offset) = @_;
  $self->_client->ua->inactivity_timeout ( $self->max_tokens / 8 );
  my $response = $self->_client->createTranscription(
    {},
    file_upload => {
      file            => $filename,
      model           => $self->model,
      temperature     => $self->temperature,
      language        => $self->language,
      response_format => $self->response_format,
      prompt          => $self->prompt . "Offset the timestamp by ".$offset." seconds.",
    },
  );
  if ( $response->result->is_success ) {
    return $self->_extract_transcription($response);
  } else {
    say("Request was not successful:");
    local $Data::Dumper::Indent   = 1;
    local $Data::Dumper::Sortkeys = 1;
    die Dumper( $response->res );
  }
}

sub _extract_transcription {
  my ($self,$response) = @_;
  my $transcription;
  my $json = $response->res;
  if ($transcription = $json->content->asset->slurp) {
    return $transcription;
  } else {
    say("JSON not good:");
    local $Data::Dumper::Indent   = 1;
    local $Data::Dumper::Sortkeys = 1;
    die Dumper( $response->res );
  }
}

1;
