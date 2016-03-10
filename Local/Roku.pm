#!/usr/bin/perl

package Local::Roku;

my %codes = (

HOME                        => "keypress/Home",
REV                         => "keypress/Rev",
FWD                         => "keypress/Fwd",
PLAY                        => "keypress/Play",
SELECT                      => "keypress/Select",
LEFT                        => "keypress/Left",
RIGHT                       => "keypress/Right",
DOWN                        => "keypress/Down",
UP                          => "keypress/Up",
BACK                        => "keypress/Back",
INSTANTREPLAY               => "keypress/InstantReplay",
INFO                        => "keypress/Info",
BACKSPACE                   => "keypress/Backspace",
SEARCH                      => "keypress/Search",
ENTER                       => "keypress/Enter",
CHAR_SPACE                  => "keypress/Lit_%20",
MOVIE_STORE_AND_TV_STORE    => "launch/31012",
ROKU_HOME_NEWS              => "launch/31863",
NETFLIX                     => "launch/12",
AMAZON_VIDEO                => "launch/13",
VUDU                        => "launch/13842",
HULU                        => "launch/2285",
SHOWTIME                    => "launch/8838",
HBO_NOW                     => "launch/61322",
CRACKLE                     => "launch/2016",
POPCORNFLIX                 => "launch/6119",
DISNEY                      => "launch/2157",
FOX_NEWS_CHANNEL            => "launch/2946",
ANGRY_BIRDS_SPACE           => "launch/18101",
K_LOVE_RADIO                => "launch/20573",
PLEX                        => "launch/13535",
PANDORA                     => "launch/28",
TED_TALKS_HD                => "launch/1152_7EB1",
FLIXSTER                    => "launch/1968",
JOYCE_MEYER_MINISTRIES      => "launch/24124",
VEVO                        => "launch/20445",
BLOCKBUSTER_ON_DEMAND       => "launch/21952",
PBS_KIDS                    => "launch/23333",
PBS_VIDEO                   => "launch/23353",
TARGET_TICKET               => "launch/24356",
YOUTUBE                     => "launch/837",
DISNEY_CHANNEL              => "launch/32828",
LIFETIME                    => "launch/35058",
RARFLIX                     => "launch/28096",
CINEMA_NOW                  => "launch/43594",
PLAY_MOVIES                 => "launch/50025",
WATCHESPN                   => "launch/34376"

);

my %watchList = (

'netflix'               => "NETFLIX",
'amazon'                => "AMAZON_VIDEO",
'vudu'                  => "VUDU",
'voodoo'                => "VUDU",
'hulu'                  => "HULU",
'showtime'              => "SHOWTIME",
'hbo'                   => "HBO_NOW",
'crackle'               => "CRACKLE",
'popcorn'               => "POPCORNFLIX",
'disney'                => "DISNEY",
'fox news'              => "FOX_NEWS_CHANNEL",
'k love radio'          => "K_LOVE_RADIO",
'plex'                  => "PLEX",
'pandora'               => "PANDORA",
'ted talks'             => "TED_TALKS_HD",
'flixster'              => "FLIXSTER",
'joyce meyer'           => "JOYCE_MEYER_MINISTRIES",
'vevo'                  => "VEVO",
'blockbuster'           => "BLOCKBUSTER_ON_DEMAND",
'pbs kids'              => "PBS_KIDS",
'pbs'                   => "PBS_VIDEO",
'youtube'               => "YOUTUBE",
'lifetime'              => "LIFETIME",
'cinema now'            => "CINEMA NOW",
'espn'                  => "WATCHESPN"

);

sub codes
{
    # Add codes for alphabet and numbers
    foreach ('a'..'z', 'A'..'Z', '0'..'9')
    {
        my $hex = sprintf("%02x",ord($_));
        $codes{"CHAR_" . $_} = "keypress/Lit_%$hex"; 
    }
    return \%codes;
}

sub watchList
{
    return \%watchList;
}

return 1;

