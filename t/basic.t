use strict;
use warnings;
use Test::More;
use Test::Exception;
use ElasticSearch::TestServer;

BEGIN {
  $ENV{ES_TRANSPORT} = 'http';
  use_ok 'ElasticSearch::TestServer'
    || die "ElasticSearch::TestServer required";
}

{

  package TestES;
  use Moose;
  use namespace::autoclean;
  extends 'Catalyst::Model::Search::ElasticSearch';

  use ElasticSearch::TestServer;
  sub _build_es {
    return ElasticSearch::TestServer->new( home => '/opt/elasticsearch/', instances => 1 );
  }

  __PACKAGE__->meta->make_immutable;
}

use Data::Dumper;
use_ok 'Catalyst::Model::Search::ElasticSearch';
my $es_model;
lives_ok { $es_model = TestES->new() };
lives_ok {
  $es_model->index(
    index  => 'test',
    type   => 'test',
    data   => { schpongle => 'bongle' },
    create => 1,
    refresh => 1,
  );
};
my $search = $es_model->search(
  index => 'test',
  type  => 'test',
  query => { term => { schpongle => 'bongle' } }
);
my $expected = { _source => { schpongle => 'bongle', }, };
is_deeply( $search->{hits}{hits}->[0]->{_source}, $expected->{_source} );

done_testing;
