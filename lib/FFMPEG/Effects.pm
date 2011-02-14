# package FFMPEG::Effects;

use warnings;
use strict;
use MIME::Base64 ();



=head1 NAME

FFMPEG::Effects - PERL Routines To Generate Titles And Fades

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


# Set Initial Useful Values For Necessary Variables Not Passed In.
my $vidfile="new-video.mpg";
my $size="352x288";
my $framerate=30;
my $fadeinframes=75;
my $fadeoutframes=75;
my $holdframes=60;
my $titleframes=90;
my $color="green";
my $opacity=100;
my $width="352";
my $height="288";
my $DurationSecs=30;


my $DurationData="";

my $fadefactor=1;
my $i=0;

my $prec1=length($fadeinframes);
my $prec2=length($fadeoutframes);

my @ProcDataArray="";
my $ProcData="";

my $VideoData="";
my @VideoDataArray="";

my @StreamInfo="";
my @Params="";


print("Defaults: \n");
print("vidfile: $vidfile\n");
print("size: $size\n");
print("framerate: $framerate\n");
print("fadeinframes: $fadeinframes\n");
print("fadeoutframes: $fadeoutframes\n");
print("holdframes: $holdframes\n");
print("titleframes: $titleframes\n");
print("color: $color\n");
print("opacity: $opacity\n");
print("width: $width\n");
print("height: $height\n");
print("DurationSecs: $DurationSecs\n");
print("\n");
print("\n");


=head1 SYNOPSIS

   use FFMPEG::Effects;

      my @infade=FadeIn('vidfile="short.mpg"', 'size="cif"', 'framerate=30', 'color="cyan"', 'opacity=70', 'fadeinframes=90', 'fadeoutframes=56', 'holdframes=31', 'titleframes=91' );

      my @title=TitleFade('size="cif"', 'framerate=30', 'color="white"', 'opacity=100', 'fadeinframes=45', 'fadeoutframes=60', 'holdframes=45', 'titleframes=599' );

      my @outfade=FadeOut('vidfile="short.mpg"', 'size="cif"', 'framerate=30', 'color="cyan"', 'opacity=70', 'fadeinframes=90', 'fadeoutframes=56', 'holdframes=31', 'titleframes=91' );


=head1 EXPORT

-- TBD

=head1 SUBROUTINES/METHODS

=head2 SetParams Set Necessary Parameters To Operate

=cut

sub SetParams 
{
my $data="";

# Make Variables Available To eval(); below.
# Set To Useful Values If Not Passed In.
$vidfile="new-video.mpg";
$size="352x288";
$framerate=30;
$fadeinframes=75;
$fadeoutframes=75;
$holdframes=60;
$titleframes=90;
$color="blue";
$opacity=100;
$width="352";
$height="288";
$DurationSecs=30;


foreach (@_)
{
	$data=('$' . $_ . ';' );
	eval($data);
}

if ( $size eq "sqcif" ) { $size="128x96" };
if ( $size eq "qcif" ) { $size="176x144" };
if ( $size eq "cif" ) { $size="352x288" };
if ( $size eq "4cif" ) { $size="704x576" };
if ( $size eq "16cif" ) { $size="1408x1152" };
if ( $size eq "qqvga" ) { $size="160x120" };
if ( $size eq "qvga" ) { $size="320x240" };
if ( $size eq "vga" ) { $size="640x480" };
if ( $size eq "svga" ) { $size="800x600" };
if ( $size eq "xga" ) { $size="1024x768" };
if ( $size eq "uxga" ) { $size="1600x1200" };
if ( $size eq "qxga" ) { $size="2048x1536" };
if ( $size eq "sxga" ) { $size="1280x1024" };
if ( $size eq "qsxga" ) { $size="2560x2048" };
if ( $size eq "hsxga" ) { $size="5120x4096" };
if ( $size eq "wvga" ) { $size="852x480" };
if ( $size eq "wxga" ) { $size="1366x768" };
if ( $size eq "wsxga" ) { $size="1600x1024" };
if ( $size eq "wuxga" ) { $size="1920x1200" };
if ( $size eq "woxga" ) { $size="2560x1600" };
if ( $size eq "wqsxga" ) { $size="3200x2048" };
if ( $size eq "wquxga" ) { $size="3840x2400" };
if ( $size eq "whsxga" ) { $size="6400x4096" };
if ( $size eq "whuxga" ) { $size="7680x4800" };
if ( $size eq "cga" ) { $size="320x200" };
if ( $size eq "ega" ) { $size="640x350" };
if ( $size eq "hd480" ) { $size="852x480" };
if ( $size eq "hd720" ) { $size="1280x720" };


my @sizedata=split(/[xX]/, $size);
my $width=$sizedata[0];
my $height=$sizedata[1];


@Params=($vidfile, $size, $framerate, $fadeinframes, $fadeoutframes, $holdframes, $titleframes, $color, $opacity, $width, $height, $DurationSecs); 
return(@Params);
}


=head2 FadeIn Fade In From Solid Or Transparent Color To Scene

=cut

sub FadeIn  
{
print("value of \@_ sent to FadeIn: @_\n");

# my @testit=SetParams(@_);
# print("Return of \@Params from SetParams() = @testit\n");
SetParams(@_);

$vidfile=shift(@Params);
$size=shift(@Params);
$framerate=shift(@Params);
$fadeinframes=shift(@Params);
$fadeoutframes=shift(@Params);
$holdframes=shift(@Params);
$titleframes=shift(@Params);
$color=shift(@Params);
$opacity=shift(@Params);
$width=shift(@Params);
$height=shift(@Params);
$DurationSecs=shift(@Params);

print("remaining values of \@Params from SetParams() = @Params\n");


my $frameno=0;
my $fade=($opacity / 100);
my $fadefactor=( ($fade / $fadeinframes) );

system("rm -f $vidfile-front.mpg"); 


my $skipsecs=0;
print("skipsecs: $skipsecs\n");
my $skip=sprintf("%.2f", $skipsecs);
my $next=( 1 / $framerate);
print("skip: $skip\n");
print("nextval: $next\n");


	for ( $frameno = 1; $frameno <= $holdframes; $frameno++)
	{
		$ProcData=`ffmpeg -y -qmin 1 -qmax 1 -g 0 -vframes 1 -i $vidfile -r $framerate -vf "color=$color\@$fade:$size [layer1]; [in][layer1] overlay=0:0" -s $size -qmin 1 -qmax 1 -g 0 hold-$frameno.mpg  2>&1`;
		# print $ProcData;

		system("cat hold-$frameno.mpg >> $vidfile-front.mpg"); 

	}

	for ( $frameno = 1; $frameno <= $fadeinframes; $frameno++)
	{
		$frameno=sprintf("%0"."$prec2"."d", "$frameno");
		print("Frame No $frameno\n");


		$fade=($fade - $fadefactor);

		if ( $frameno == $fadeinframes)
		{
			$fade=0;
		}

		print("Opacity: $fade\n");
		$skip=( $skip + $next );
		print("Next: $skip\n");


		$ProcData=`ffmpeg -y -qmin 1 -qmax 1 -g 0 -ss $skip -vframes 1 -i $vidfile -r $framerate -vf "color=$color\@$fade:$size [layer1]; [in][layer1] overlay=0:0" -s $size -qmin 1 -qmax 1 -g 0 $vidfile-$frameno.mpg  2>&1`;

		system("cat $vidfile-$frameno.mpg >> $vidfile-front.mpg"); 
	}


$ProcData=`ffmpeg -y -qmin 1 -qmax 1 -g 0 -ss $skip -i $vidfile -r $framerate -s $size -qmin 1 -qmax 1 -g 0 $vidfile-back.mpg  2>&1`;

system("cat $vidfile-back.mpg >> $vidfile-front.mpg"); 
system("mv $vidfile-front.mpg fadein.mpg"); 

system("rm -f $vidfile-*.mpg hold-*.mpg"); 

system("mv fadein.mpg $vidfile-fadein.mpg  "); 

return @ProcDataArray;
}


=head2 FadeOut  Fade Out From Video To Solid Or Transparent Color

=cut

sub FadeOut
{

print("value of \@_ sent to FadeOut: @_\n");

# my @testit=SetParams(@_);
# print("Return of \@Params from SetParams() = @testit\n");
SetParams(@_);
$vidfile=shift(@Params);
$size=shift(@Params);
$framerate=shift(@Params);
$fadeinframes=shift(@Params);
$fadeoutframes=shift(@Params);
$holdframes=shift(@Params);
$titleframes=shift(@Params);
$color=shift(@Params);
$opacity=shift(@Params);
$width=shift(@Params);
$height=shift(@Params);
$DurationSecs=shift(@Params);

print("remaining values of \@Params from SetParams() = @Params\n");

GetDuration($vidfile);
print("duration $DurationSecs\n");
# GetStreamInfo($vidfile);
# print("rate $framerate\n");

my $frameno=0;
my $fade=0;
my $fadefactor=( ( ( $opacity / 100 ) / $fadeoutframes) );



my $skipsecs=(  (($framerate * $DurationSecs ) - $fadeoutframes) / $framerate  );
print("skipsecs: $skipsecs\n");
my $skip=sprintf("%.2f", $skipsecs);
my $next=( 1 / $framerate);
print("skip: $skip\n");
print("nextval: $next\n");
my $lastframetime=($skip - $next);
my $holdframe="";


my $frontframes=($framerate * $skipsecs);
my $front=sprintf("%d", $frontframes);

$ProcData=`ffmpeg -y -qmin 1 -qmax 1 -g 0 -i $vidfile -r $framerate -s $size -g 0 $vidfile-tmp.mpg  2>&1`;
$ProcData=`ffmpeg -y -qmin 1 -qmax 1 -g 0 -vframes $front -i $vidfile -r $framerate -s $size $vidfile-front.mpg  2>&1`;
print $ProcData;

	for ( $frameno = 1; $frameno <= $fadeoutframes; $frameno++)
	{
		$frameno=sprintf("%0"."$prec2"."d", "$frameno");
		print("Frame No $frameno\n");

		$fade=($fade + $fadefactor);


		if ( $frameno == $fadeoutframes)
		{
			$fade=($opacity / 100 );

			for ( $holdframe = 1; $holdframe <= $holdframes; $holdframe++)
			{
				$ProcData=`ffmpeg -y -qmin 1 -qmax 1 -g 0 -ss $skip -vframes 1 -i $vidfile-tmp.mpg -r $framerate -vf "color=$color\@$fade:$size [layer1]; [in][layer1] overlay=0:0" -s $size -qmin 1 -qmax 1 -g 0 hold-$frameno.mpg  2>&1`;
				print $ProcData;
				system("cat hold-$frameno.mpg >> $vidfile-front.mpg"); 
			}

		}

		print("Opacity: $fade\n");
		$skip=( $skip + $next );
		print("Next: $skip\n");


		$ProcData=`ffmpeg -y -qmin 1 -qmax 1 -g 0 -ss $skip -vframes 1 -i $vidfile-tmp.mpg -r $framerate -vf "color=$color\@$fade:$size [layer1]; [in][layer1] overlay=0:0" -s $size -qmin 1 -qmax 1 -g 0 $vidfile-$frameno.mpg  2>&1`;
		# print $ProcData;

		system("cat $vidfile-$frameno.mpg >> $vidfile-front.mpg"); 

	}




system("mv $vidfile-front.mpg fadeout.mpg"); 
system("rm -f $vidfile-*.mpg hold-*.mpg"); 
system("mv fadeout.mpg   $vidfile-fadeout.mpg"); 
return @ProcDataArray;
}


=head2 Transition Between Scenes. TBD

=cut

sub Transition
{
}


=head2 GetDuration Get Duration Seconds Of Video

=cut

sub GetDuration
{
my $vidfile=shift;

# Stream Whole File
# my $VideoData=`ffmpeg  -i $vidfile -f null /dev/null 2>&1`;
# Summary Only 
my $VideoData=`ffmpeg  -i $vidfile  2>&1`;
 
$VideoData =~ s/\r/\n/g;
$VideoData =~ s/\n */\n/g;
my @VideoDataArray=split("\n", $VideoData);

	foreach $i (0..$#VideoDataArray)
	{
		if ( $VideoDataArray[$i] =~ /Duration/ )
		{
			$DurationData=$VideoDataArray[$i];
		}

	}

$DurationData =~ s/ //g;
my @DurationArray=split(",", $DurationData);

my @timearray=split(":", $DurationArray[0]);
my $DurationHMS=$timearray[1] . ":" . $timearray[2] . ":" . $timearray[3];

$DurationSecs=($timearray[1] * 3600) + ($timearray[2] * 60 ) + $timearray[3];

return($DurationSecs);
}
### End GetDuration


=head2 GetStreamInfo Get Various Stream Parameters

=cut

sub GetStreamInfo
{
my $vidfile=shift;

my $ProcData=`ffmpeg  -i $vidfile  2>&1`;
$ProcData =~ s/\r/\n/g;
$ProcData =~ s/\n */\n/g;
my @ProcDataArray=split("\n", $ProcData);



	foreach $i (0..$#ProcDataArray)
	{
		if ( $ProcDataArray[$i] =~ /Stream #0.0.*fps/ )
		{
			$ProcData=$ProcDataArray[$i];
		}
	}

$ProcData =~ s/ //g;
my @ProcArray=split(",", $ProcData);

# print("@ProcArray\n");

my @sizedata=split(/\[/, $ProcArray[2]);

$size=$sizedata[0];
print("size $size\n");

$framerate=$ProcArray[4];

$framerate =~ s/fps//;
$framerate =~ s/ //;

# print("$ProcArray[4]\n");
# print("$framerate\n");
# return($framerate);
@StreamInfo=($framerate, $size);
return(@StreamInfo);


}


=head2 TitleFade Generate A Title From PostScript With Fade In And Out

=cut

sub TitleFade  
{
print("value of \@_ sent to OpeningTitle: @_\n");

# my @testit=SetParams(@_);
# print("Return of \@Params from SetParams() = @testit\n");
SetParams(@_);

Clear1024x7681Frame();

$vidfile=shift(@Params);
$size=shift(@Params);
$framerate=shift(@Params);
$fadeinframes=shift(@Params);
$fadeoutframes=shift(@Params);
$holdframes=shift(@Params);
$titleframes=shift(@Params);
$color=shift(@Params);
$opacity=shift(@Params);
$width=shift(@Params);
$height=shift(@Params);
$DurationSecs=shift(@Params);

print("remaining values of \@Params from SetParams() = @Params\n");

my $frameno=0;
my $fadefactor=( ($opacity / $fadeinframes) );

my $fade=($opacity / 100);

system("rm -f $vidfile-front.mpg"); 
system("rm -f $vidfile-titlebackground.mpg"); 

PSTitleFrame();

$ProcData=`gs -dBATCH -dNOPAUSE -sDEVICE=pngalpha -g288x352 -sOutputFile=title.tmp.png Title.ps`;
$ProcData=`convert -rotate 90 title.tmp.png title.png`;
# $ProcData=`convert RCA_Indian_Head_test_pattern.JPG -scale 352 title.png`;


my $skipsecs=0;
print("skipsecs: $skipsecs\n");
my $skip=sprintf("%.2f", $skipsecs);
my $next=( 1 / $framerate);
print("skip: $skip\n");
print("nextval: $next\n");


Clear1024x7681Frame();

# $ProcData=`ffmpeg -y -qmin 1 -qmax 1 -g 0 -vframes 1 -i clear-1fr-1024x768.mpg -r $framerate -vf "color=$color\@$fade:$size [layer1]; [in][layer1] overlay=0:0" -s $size -qmin 1 -qmax 1 -g 0 color-0.mpg `;


	for ( $frameno = 1; $frameno <= $titleframes; $frameno++)
	{
		system("cat color-0.mpg >> $vidfile-titlebackground.mpg"); 
	}

$ProcData=`ffmpeg -y -i $vidfile-titlebackground.mpg -vf "movie=0:png:title.png [title]; [in][title] overlay=0:0" -qmin 1 -qmax 1 -g 0 -s $size  title-out.mpg  `;
print("$ProcData\n");


FadeIn('vidfile="title-out.mpg"', 'size="' . $size . '"', 'framerate=' . $framerate, 'color="' . $color . '"', 'opacity=' . $opacity, 'fadeinframes=' . $fadeinframes, 'fadeoutframes=' . $fadeoutframes, 'holdframes=' . $holdframes, 'titleframes=' . $titleframes );
FadeOut('vidfile="title-out.mpg-fadein.mpg"', 'size="' . $size . '"', 'framerate=' . $framerate, 'color="' . $color . '"', 'opacity=' . $opacity, 'fadeinframes=' . $fadeinframes, 'fadeoutframes=' . $fadeoutframes, 'holdframes=' . $holdframes, 'titleframes=' . $titleframes );



system("mv $vidfile-fadeout.mpg titlefade.mpg"); 

system("rm -f title-out*"); 
return @ProcDataArray;
}



=head2 Clear1024x7681Frame Base64 Encoded 1024x768 MPG 1 Frame

=cut

sub Clear1024x7681Frame {

my $clearframe=<<DATA;
AAABuiEAA0ghwzNnAAABuwAJwzNnACH/4ODmAAAB4AffMQAFvyERAAWnsQAAAbNAAwAV///gGAAA
AbgACAAAAAABAAAP//gAAAEBC/z/SlIlcpSkTuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSJXKUpE7lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUkSZXKUpOdylKRFylKR
FylKRFylKRFylKRFylKRFylKRFylKRFylKQzyuUpSIuUpSJ3KUpCUS5tylKRO5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5GFIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIlcpSkTuUpSIuUpSIuUpSIswpSJDRdylKRO5SlIi5SlIi5SlJRcpSkSu
UpScXKUpE7lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKRiVilKRO5SlI
i5SlIi5SlJgB+JlcpSkouUpSJ3KUpKLlKUiLlKUnFylKRFylKRFylKRFylKRK5SlIncpSkRcpSkR
cpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRc
pSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcp
SkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkSuUpSJ3KUpEXKUpEXKUpErlKUidylKRFyl
KRFylKRFylKRFylKRK5SlIncpSkRcpSkRcpSkRcpSkRcpSkSuUpSJ3KUpEXKUpEXKUpEXKUpEXKU
pEXKUpEXKUpEXKUpOVylKSncpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpS
kRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSk
RcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkSuUpSJ3KUpE
XKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpOLlKUlK5SlIncpSkRcpSkRcpSkRcpSkR
cpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRc
pSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcp
SkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkSuUpSJ3KUpEXKUpEXKUpEXKU
pErlKUidylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKSlcpSk53KU
pEWYUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUp
EXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpE
XKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEX
KUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXK
UpEXKUpKLlKRiVilKTi5SlIncpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcp
SkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpS
kRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSk
RcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkpXKUpO
dylKRFylKRFylKSlcpSkRcpSk53KUpEXKUpEXKUpEXKUpNgIxcpSkouUpSIuUpSIuUpSIuUAAAHg
B/oPKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiVylKRO5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIlcpSkTuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpScXKUpK
LlKUiLlKUiLlKUiLlKUiLlKUnFylKSQiLlIwlK5SlJzuUpSIuUpSJXKUpE7lKUiVylKRO5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlJjAuLlKUlFylKRFylKRFylKRFylKRF
ylKRFylKRFylKRK5SlIncpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRc
pSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcp
SkRcpSkRcpSkRcpSkRcpSkSuUpSJ3KUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKU
pEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUp
EXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpE
XKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEX
KUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpErlKUidylKRFylKSlcpSk53KUpEXKUpEX
KUpEXKUpEXKUpEXIwpEXKUpEXIkaFIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlI6gORcpSk8uVylKSncpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSk
RcpSkSuUpSJ3KUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpE
XKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEX
KUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXK
UpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpErlKUidylKRFylKRFylKRFylKSk+AjcpSkTuUpScXKUp
EXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpE
XKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEX
KUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXK
UpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKU
pEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUp
EXKUpEXKUpEXKUpEXKUpEXKUpEXKUpErlKUidylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKR
FylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRF
ylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylI4t4ixSlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIlcpSkRcpSkTuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIgAAAeAH+g/l
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUlFylKTi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIlcpSkouUpScXKUpE7lKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUh8BGLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUlK5SlJkidy
lKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFyl
KRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylK
RFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKR
FylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRF
ykyEFoliVylKRO5SlIlcpSkTuUpSJXKUpE7lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiVylKRO5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIlcpSkTuUpSJXKUpE7lKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlIkaESuUpSIuUpSJ3
KUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXK
UpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKU
pEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUp
EXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpE
XKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEX
KUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXK
UpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKU
pEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUp
EXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpE
XKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEX
KUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXK
UpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKU
pEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpKLlKUnK5SlIncpSkRcpAAAB4Af6D0pEXKUp
EXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpErlKUidylKRFylKRFylKR
FylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRF
ylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFy
lKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFyl
KRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylK
RFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKR
FylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRF
ylKSlcpSk53KUpEXKUpEXKRhKVylKTncpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkR
cpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRc
pSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcp
SkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpS
kRcpSkRcpSkRcpSkRcpSkSuUpSJ3KUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUp
EXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpE
XKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEX
KUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXK
UpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpNi4uUpSUXKUpEXKUpEXKUpEXKUpEXKUpEX
KUpErlKUidylKRFylKRFylKRFylKRK5SlIncpSkRcpSkEeVylKRO5SlIi5SlIizClIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIlcpSkTuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSJXKUpE7lKUiLlKUiVylKRO5SlIi5SlIi5SlIi5SlIi5SI1cIlcpSkT
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIs4poUpErlKUidylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFyl
KRFylKRFylKRFylKRFylKRFylKRFylKRFylKRK5SlIncpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpS
kRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSk
RcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkR
cpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRc
pSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcp
SkSuUpSJ3KUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKU
pEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUp
EXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpE
XKUpErlKUidylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRF
ylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKREAAAHgB/oPcpSkRcpSkRcp
SkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpS
kRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSk
ScXcpSkTuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSJXKUpE7lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiVylKRO5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIlcpSk
TuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSJXKUpE7lKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiVylKRO5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlJSuUpScXKUpE7lKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUnyWBOVylKSncpSkRcpSkRcpSkRcpSkRcp
SkRcpSkRcpSkSuUpSJ3KUpEXKUpEXKUpEXKUpEXKUpEXKUpOVylKSncpSkRcpSkRcpSkRcpSkRcp
SkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpS
kRcpSkRcpSkSuUpSJ3KUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUp
EXKUpEXKUpKLlKUnFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKSlcpSk
53KUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpE
XKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEX
KUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXK
UpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKU
pEXKUpEXKUpEXKUpEXKUpEXKUpCURcpSkYIlcpSkTuR2hSJXKUpEXKUpE7lKUlK5SlJzuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSaS2lcpSkp3KUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXK
UpEXKUpEXKUpEXKUpKVylKTncpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcp
SkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkpXKUpOdylKRFylKTJcrlKUlO
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SgAAAeAFxg9SIuUpSIuUpSIuUpSI
uUpSJXKUpEXKUpE7lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiVylKRO5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIlcpSkTuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSJXKUpE7lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLMKUiLlKUiLlKUiLlKUiLlKUiVylKRO5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIlcpSkRcpSkTuUpSUrlKUnFylKRO5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIlcpSkTuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
JXKUpE7lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKRlKxSlJvoswpSBouLlKUiLlKUiLlKUjeLlKUi
dylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRF
ylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFy
lKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFyl
KRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFylKRFykYSlcpSk4uUpSUXKU
pOdylKRFylKRFylKRFylKRFylKRK5SlIncpSkRcpSkRcpSkSuUpSJ3KUpEXKUpEXKUpEXKUpEXKU
pEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUpEXKUp
EXKUpEXKUpEXKUpEXKUpEXKUiRoixSlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SkYixSlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIlcpSkRcpSkTskaFKRIaLuUpScXKUpKdylKRFylKRFylKRFylKRFylKRK5SlIncpSkRcpSkR
cpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRc
pSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcp
SkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSkRcpSLtEWKUpErlKUiLlKUidy
lKRFylKRFylKRFylKRFylKRFylKRFylKRFylKSlcpSk4uRhGRKnAAAABvgIuD///////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////
DATA


# my $returndata=uudecode($sampledata);
my $returndata=MIME::Base64::decode($clearframe);

open (OUTFILE,  '>', "color-0.mpg") or  die $!;
print(OUTFILE $returndata);
close (OUTFILE);

return($returndata);
}


=head2 PSTitleFrame -- Title Frame Template In PostScript

=cut

sub PSTitleFrame {

my $titleframe=<<DATA;
%!PS-Adobe-3.0
%%Creator: Applixware
%%Pages: 1
%%DocumentNeededResources: font Helvetica Times-Roman
%%EndComments
%%BeginProlog
/bd { bind def } bind def
/n  { newpath } bd
/L  { lineto } bd
/M  { moveto } bd
/C  { curveto } bd
/RL { rlineto } bd
/MR { rmoveto } bd
/ST { show } bd
/S  { stroke } bd
/SP { strokepath } bd
/GS { gsave } bd
/GR { grestore } bd
/GRAY { setgray } bd
/AXscale { 72 1000 div } bd
/DOSETUP {
      AXscale dup scale
      1 setlinecap
      4 setlinewidth
      1 setlinejoin
      4 setmiterlimit
      [] 0 setdash
} bd
/DOCLIPBOX {
    n 4 2 roll 2 copy M 4 1 roll exch 2 copy L exch pop 2 copy L pop
    exch L closepath clip
} bd
/DOLANDSCAPE {
      90 rotate
      0 exch -1 mul translate
} bd
/UNDOLANDSCAPE {
      0 exch translate
      -90 rotate
} bd
/AXredict 14 dict def
/X {
      AXredict begin
      exch /str exch def
      str stringwidth pop sub
      str length div 0 str ashow
      end
} bd
/FINDFONT {
    { findfont } stopped
    { /Times-Roman findfont } if
} bd
/POINTSCALEFONT { AXscale div scalefont } bd
/DOTSCALEFONT { scalefont } bd
/SETFONT { setfont } bd
/p01 <000e0e0600e0e060> def
/p02 <0f0f0f0ff0f0f0f0> def
/p03 <ff1f1f9ffff1f1f9> def
/p10 <040f0f0e40f0f0e0> def
/p12 <0006060000606000> def
/p13 <ff9f9ffffff9f9ff> def
/p21 <ff0f0f1ffff0f0f1> def
/DEFINEFONTS {
      /AXFont0p180000 /Helvetica-Bold FINDFONT 38.000 POINTSCALEFONT def
      /AXFont1p480000 /Courier-Bold FINDFONT 48.000 POINTSCALEFONT def
      /AXFont1p280000 /Courier-Bold FINDFONT 28.000 POINTSCALEFONT def
      /AXFont1p180000 /Courier-Bold FINDFONT 18.000 POINTSCALEFONT def



} def
%%EndProlog
%%BeginSetup
%%IncludeResource: font Helvetica
%%IncludeResource: font Times-Roman

DEFINEFONTS
systemdict /setcmykcolor known
{
       /SET_CMYK { setcmykcolor } bd
}
{
       /SET_CMYK {
       exch .2 mul add
       exch .4 mul add
       exch .3 mul add
       dup 1 gt
       {pop 1} {} ifelse
       1 exch sub setgray
       } bd
}
ifelse
systemdict /colorimage known
{
       /GET_CMYK { currentcmykcolor } bd
}
{
       /GET_CMYK {
       0 0 0 
       1 currentgray sub
       } bd
}
ifelse
systemdict /colorimage known
{
   /COLORIMAGE { false 4 colorimage } bd
       /SELECTBUF { pop } bd
}
{
       /COLORIMAGE { image } bd
       /SELECTBUF { exch pop } bd
}
ifelse
%%EndSetup
%%Page: 1 1
%%BeginPageSetup
save /AXPageSave exch def
DOSETUP
3000 DOLANDSCAPE
%%EndPageSetup


0.1000 0.1000 0.1000 0.0000 SET_CMYK
AXFont1p480000 SETFONT
GS
n
700 2400 M
(A Film By:) 3000 X
GR

0.1000 0.1000 0.1000 0.0000 SET_CMYK
AXFont1p480000 SETFONT
GS
n
600 1250 M
(Your Name Here) 4000 X
GR


0.1000 0.2000 0.1000 0.0000 SET_CMYK
AXFont1p280000 SETFONT
GS
n
600 0 M
(YYYY-MM-DD) 3000 X
GR




%%PageTrailer
AXPageSave restore
showpage
%%Trailer
%%EOF
DATA

open (TITLEFILE,  '>', "Title.ps") or  die $!;
print(TITLEFILE $titleframe);
close (TITLEFILE);

return($titleframe); 

}


=head1 AUTHOR

Piero Bugoni, C<< <PBugoni at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-ffmpeg-effects at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=FFMPEG-Effects>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc FFMPEG::Effects


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=FFMPEG-Effects>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/FFMPEG-Effects>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/FFMPEG-Effects>

=item * Search CPAN

L<http://search.cpan.org/dist/FFMPEG-Effects/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Piero Bugoni.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of FFMPEG::Effects
