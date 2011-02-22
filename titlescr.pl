#!/usr/bin/perl -w

# use strict;
use FFMPEG::Effects;
package FFMPEG::Effects;


my @title=TitleFade('size="cif"', 'framerate=30', 'color="black"', 'opacity=100', 'fadeinframes=50', 'fadeoutframes=50', 'holdframes=30', 'titleframes=299' );

my @infade=FadeIn('vidfile="short.mpg"', 'size="cif"', 'framerate=30', 'color="black"', 'opacity=100', 'fadeinframes=90', 'fadeoutframes=56', 'holdframes=15', 'titleframes=91' );


my @outfade=FadeOut('vidfile="short.mpg-fadein.mpg"', 'size="cif"', 'framerate=30', 'color="black"', 'opacity=100', 'fadeinframes=90', 'fadeoutframes=56', 'holdframes=61', 'titleframes=91' );

