#!perl
use strict;
use warnings;
use 5.008001;

use utf8;
use XML::Feed;
use XML::Feed::Deduper;
use Growl::Any;
use File::Temp qw/ tempdir /;

our $VERSION = "0.02";

my $uri = 'http://tenki.jp/component/static_api/rss/earthquake/recent_entries_by_day.xml';

my @events;
push @events, "震度$_" for 1 .. 10;
my $growl = Growl::Any->new( appname => '地震速報', events => [@events] );
my $dir = tempdir( CLEANUP => 1 );
my $deduper = XML::Feed::Deduper->new( path => "$dir/earthquake-growler.db" );

while (1) {
    my $feed = XML::Feed->parse( URI->new($uri) )
      or $growl->notify( 'Error', 'fetch feed', XML::Feed->errstr );
    if ($feed) {
        for my $entry ( $deduper->dedup( $feed->entries ) ) {
            my $title       = $entry->title;
            my $level       = $1 if $entry->title =~ /最大震度 (\d+)/;
            my $description = $entry->content->body;
            $description =~ s/<[^>]*>//sg;
            $growl->notify( "震度$level", $title, $description );
        }
    }
    sleep 30;
}

__END__

=head1 NAME

earthquake-growler

=head1 AUTHOR

Yasuhiro Matsumoto

=head1 LICENSE

This program is licensed under the same terms as Perl itself.

=cut
