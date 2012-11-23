#!/usr/bin/perl -w

# use strict;
# package FFMPEG::Effects;
use FFMPEG::Effects;
use Data::Dumper;


my $effect = new FFMPEG::Effects;


print Dumper($effect);


#### black.png or other color is necessary!

# $effect->TitleFade('size=1280x1024',  'framerate=30', 'color=black', 'opacity=100', 'fadeinframes=50', 'fadeoutframes=50', 'holdframes=30', 'titleframes=299', 'justify=center', 'fontcolor=magenta', 'font=Helvetica' );
# $effect->TitleFade('size=cif',  'framerate=30', 'color=black', 'opacity=100', 'fadeinframes=50', 'fadeoutframes=50', 'holdframes=30', 'titleframes=299', 'fontcolor=magenta', 'font=Courier' );

$effect->TitleFade(
		'size=1920x1080',
	  	'framerate=24',
	   	'opacity=100',
	   	'fadeinframes=50',
	   	'fadeoutframes=50',
	   	'holdframes=30',
	   	'titleframes=299',
	   	'justify=center',
	   	'fontcolor=white',
	   	'color=black',
		'pngfile=1920x1080-Black.png',
	   	'font=Helvetica'
		);

