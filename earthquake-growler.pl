#!perl
use strict;
use warnings;
use utf8;
use XML::Feed;
use XML::Feed::Deduper;
use Growl::Any;
use File::Temp qw/ tempfile /;

our $VERSION = "0.01";

my $uri = 'http://tenki.jp/component/static_api/rss/earthquake/recent_entries_by_day.xml';

my $growl = Growl::Any->new( appname => '地震速報', events => ['地震'] );
my ( $fh, $temp ) = tempfile();
close $fh;
my $deduper = XML::Feed::Deduper->new( path => $temp );

while (1) {
    my $feed = XML::Feed->parse( URI->new($uri) )
      or die $growl->notify( 'Error', 'fetch feed', XML::Feed->errstr );
    if ($feed) {
        for my $entry ( $deduper->dedup( $feed->entries ) ) {
            my $title       = $entry->title;
            my $description = $entry->content->body;
            $description =~ s/<[^>]*>//sg;
            $growl->notify( '地震', $title, $description );
        }
    }
    sleep 30;
}
