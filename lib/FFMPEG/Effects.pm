package FFMPEG::Effects;

# use warnings;
# use strict;
use MIME::Base64 ();
use Data::Dumper;



=head1 NAME

FFMPEG::Effects - PERL Routines To Generate Titles And Fades With libavfilter

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';



=head1 SYNOPSIS

use FFMPEG::Effects;

	my $effect=FFMPEG::Effects->new();

	$effect->Help('all');

	$effect->FadeIn('vidfile=short.mpg', 'size=cif', 'framerate=30', 'color=cyan', 'opacity=70', 'fadeinframes=90', 'fadeoutframes=56', 'holdframes=31', 'titleframes=91' );

	$effect->TitleFade('size=cif',  'framerate=30', 'color=black', 'opacity=100', 'fadeinframes=50', 'fadeoutframes=50', 'holdframes=30', 'titleframes=299', 'fontcolor=white', 'font=Courier', 'justify=center' );

	$effect->FadeOut('vidfile=short.mpg', 'size=cif', 'framerate=30', 'color=cyan', 'opacity=70', 'fadeinframes=90', 'fadeoutframes=56', 'holdframes=31', 'titleframes=91' );


=head1 USAGE

Make a Call to Help() To Find Out More.

The Methods Shown Above Are Shown With Their Relevant Arguments
And Can Be Called With No Arguments And Will Produce Useful Output.

Use This Module As In The Examples Above, Sending An Array Of Quoted Strings
To Each Function. Enclose String Values For Parameters In Double Quotes, 
Inside Single-Quoted Expressions.

=head1 DEPENDENCIES

This Module Uses FFMPEG With The libavformat Source Modified
To Include The "movie" Filter From The SOC Development.
See The Readme For More Info.


=head1 EXPORT

-- TBD

=head1 SUBROUTINES/METHODS


=head2 new()  Instantiate

=cut


my $DurationData="";

my $fadefactor=1;
my $i=0;

my @ProcDataArray="";
my $ProcData="";

my $VideoData="";
my @VideoDataArray="";

my @StreamInfo="";
my @Params="";

sub new
{
	my( $class, $debug ) = @_;

	# Set To Useful Values If Not Passed In.
	my $self = { 
				'vidfile' => 'new-video.mpg',
				'size' => '352x288',
				'framerate' => '30',
				'fadeinframes' => '75',
				'fadeoutframes' => '75',
				'holdframes' => '0',
				'titleframes' => '90',
				'color' => 'blue',
				'opacity' => '100',
				'width' => '352',
				'height' => '288',
				'DurationSecs' => '30',
				'aspect' => 'NA',
				'pngfile' => 'none',
				'justify' => 'center',
				'font' => 'Courier',
				'fontsize' => 'not-set',
				'fontcolor' => 'white',
				};

	if ( $debug )
	{
		$self->{'debug'} = eval("\$".$debug);
	}

	return bless( $self, $class);

}

=head2 Help() Print Help 

=cut

sub Help
{
	my ( $self, @inputargs) = @_;

	my $helphash = { 
					'vidfile' => 'The File Name of The Video File To Be Used As Input Or For Output',
					'size' => 'Video Image Size -- Can Use \'cif\', etc, or \'<width>x<height>\' ',
					'framerate' => 'Output File Frame Rate',
					'fadeinframes' => 'Number of Frames A \'Fade In\' Is Spread Over',
					'fadeoutframes' => 'Number of Frames A \'Fade Out\' Is Spread Over',
					'holdframes' => 'Number Of Frames Added to Beginning or End of Effect To Increase Its Duration',
					'titleframes' => 'Number of Frames That \'Title\' Frame Will Persist',
					'color' => 'The \'Fade To\' And \'Fade From\' Color',
					'opacity' => 'Final Opacity of Fade Sequence',
					'width' => 'Image Size In Width -- Internal Variable, Derived From \'size\'',
					'height' => 'Image Size In Height -- Internal Variable Derived From \'size\'',
					'aspect' => 'Aspect Ratio -- Internal Variable Derived From \'size\'',
					'DurationSecs' => 'Total Duration Of Video In Seconds',
					'fontcolor' => 'Text Color Used In Generated Titles',
					'justify' => 'Left, Center, or Right Justify Text In Generated Titles',
					'pngfile' => 'PNG Image File Used To Underlay Generated Titles'
					};


	if ( ( ! @inputargs ) || ( $inputargs[0] eq 'all' ) )
	{
		print("\nHelp for all...\n");

		while( my ($key, $value ) = each(%$helphash) ) 
		{
 			print("\t$key : $value\n");
		}	

		print("\n");
		print("Defaults: \n");
		while( my ($key, $value ) = each(%$self) ) 
		{
 			print("\t$key : $value\n");
		}	
		print("\n");
	}
	else 
	{
		foreach( @inputargs )
		{
			if ( $helphash->{$_}   ) 
			{
	 			print("$_: $helphash->{$_}, \n");
			}
			else
			{
				print("Help -- No Help For: $_ ... Try 'all'\n");

			}
		}
	}

	while( my ($key, $value ) = each(%$inputargs) ) 
	{
 		print($value, "\n");
 		print($helphash->{$key}, "\n");
	}	

}

=head2 TestReel()  Generate Test Reel

=cut

sub TestReel
{
	my ( $self, $inputargs) = @_;
	print Dumper($self);
}


=head2 SetParams()  Set Necessary Parameters To Operate.
		Called By Effects Functions To Store Input Arguments
=cut


sub SetParams 
{

	my ( $self, @inputargs) = @_;
	my $data="";
	# print Dumper($self);
	
	foreach (@inputargs)
	{
		$data=($_ );
		my @argdata = split( '=', $data);
		my $param = $argdata[0];
		my $val = $argdata[1];
	
		if ( ! $self->{ $param } )
		{
				# print("No Such Parameter -- $param \n");
			$self->{$param} = $val;
		}
		else
		{
				# print("Indata -- $param : $val \n");
			$self->{$param} = $val;
		}
	}
	
	
	my $size = $self->{ 'size' };
	
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
	
	$self->{ 'size' } = $size;
	
	my @sizedata=split(/[xX]/, $size);
	my $width=$sizedata[0];
	my $height=$sizedata[1];
	
	$self->{ 'width' } = $width;
	$self->{ 'height' } = $height;

	my $foo  =  ($width / $height);

	my  $aspectratio = sprintf("%.2f", $foo);

	if (  $aspectratio == 1.78 )
	{
		$self->{ 'aspect' } = 'HD';
	}

	if (  $aspectratio  == 1.33 )
	{
		$self->{ 'aspect' } = 'TV';
	}

	if (  $aspectratio  == 1.50 )
	{
		$self->{ 'aspect' } = 'NTSC';
	}

	if ( ! ( ($aspectratio  == 1.33) || ($aspectratio  == 1.78) || ($aspectratio  == 1.50) )  ) 
	{
		$self->{ 'aspect' } = 'OTHER';
	}


	$self->{ 'prec1' } = length( $self->{ 'fadeinframes' } );
	$self->{ 'prec2' } = length( $self->{ 'fadeoutframes' });
	
	# print Dumper($self);
	# die $aspectratio;
	
	return();
}

=head2 FadeIn()  Fade In From Solid Or Transparent Color To Scene.

=cut

sub FadeIn  
{

$self->SetParams(@_);

$vidfile=$self->{'vidfile'};
$size=$self->{'size'};
$framerate=$self->{'framerate'};
$fadeinframes=$self->{'fadeinframes'};
$fadeoutframes=$self->{'fadeoutframes'};
$holdframes=$self->{'holdframes'};
$titleframes=$self->{'titleframes'};
$color=$self->{'color'};
$opacity=$self->{'opacity'};
$width=$self->{'width'};
$height=$self->{'height'};
$DurationSecs=$self->{'DurationSecs'};
$prec1=$self->{'prec1'};
$prec2=$self->{'prec2'};
$aspect=$self->{'aspect'};


# print("remaining values of \@Params from SetParams() = @Params\n");


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
		$ProcData=`ffmpeg -y -qmin 1 -qmax 1 -g 0 -i $vidfile -r $framerate -vf "color=$color\@$fade:$size [layer1]; [in][layer1] overlay=0:0" -s $size -qmin 1 -qmax 1 -g 0 -vframes 1 hold-$frameno.mpg  2>&1`;
		print $ProcData;

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
		print("Next: $skip\n\n");


		$ProcData=`ffmpeg -y -qmin 1 -qmax 1 -g 0 -ss $skip -i $vidfile -r $framerate -vf "color=$color\@$fade:$size [layer1]; [in][layer1] overlay=0:0" -s $size -qmin 1 -qmax 1 -g 0 -vframes 1 $vidfile-$frameno.mpg  2>&1`;

		system("cat $vidfile-$frameno.mpg >> $vidfile-front.mpg"); 
	}


$ProcData=`ffmpeg -y -qmin 1 -qmax 1 -g 0 -ss $skip -i $vidfile -r $framerate -s $size -qmin 1 -qmax 1 -g 0 $vidfile-back.mpg  2>&1`;

system("cat $vidfile-back.mpg >> $vidfile-front.mpg"); 
system("mv $vidfile-front.mpg fadein.mpg"); 

system("rm -f $vidfile-*.mpg hold-*.mpg"); 

system("mv fadein.mpg $vidfile-fadein.mpg  "); 

return @ProcDataArray;
}


=head2 FadeOut()  Fade Out From Scene To Solid Or Transparent Color.

=cut

sub FadeOut
{

$self->SetParams(@_);

$vidfile=$self->{'vidfile'};
$size=$self->{'size'};
$framerate=$self->{'framerate'};
$fadeinframes=$self->{'fadeinframes'};
$fadeoutframes=$self->{'fadeoutframes'};
$holdframes=$self->{'holdframes'};
$titleframes=$self->{'titleframes'};
$color=$self->{'color'};
$opacity=$self->{'opacity'};
$width=$self->{'width'};
$height=$self->{'height'};
$DurationSecs=$self->{'DurationSecs'};
$prec1=$self->{'prec1'};
$prec2=$self->{'prec2'};
$aspect=$self->{'aspect'};


# print("remaining values of \@Params from SetParams() = @Params\n");

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
$ProcData=`ffmpeg -y -qmin 1 -qmax 1 -g 0 -i $vidfile -r $framerate -s $size -vframes $front $vidfile-front.mpg  2>&1`;
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
				$ProcData=`ffmpeg -y -qmin 1 -qmax 1 -g 0 -ss $skip -i $vidfile-tmp.mpg -r $framerate -vf "color=$color\@$fade:$size [layer1]; [in][layer1] overlay=0:0" -s $size -qmin 1 -qmax 1 -g 0 -vframes 1 hold-$frameno.mpg  2>&1`;
				print $ProcData;
				system("cat hold-$frameno.mpg >> $vidfile-front.mpg"); 
			}

		}

		print("Opacity: $fade\n");
		$skip=( $skip + $next );
		print("Next: $skip\n\n");


		$ProcData=`ffmpeg -y -qmin 1 -qmax 1 -g 0 -ss $skip -i $vidfile-tmp.mpg -r $framerate -vf "color=$color\@$fade:$size [layer1]; [in][layer1] overlay=0:0" -s $size -qmin 1 -qmax 1 -g 0 -vframes 1 $vidfile-$frameno.mpg  2>&1`;
		# print $ProcData;

		system("cat $vidfile-$frameno.mpg >> $vidfile-front.mpg"); 

	}


system("mv $vidfile-front.mpg fadeout.mpg"); 
system("rm -f $vidfile-*.mpg hold-*.mpg"); 
system("mv fadeout.mpg   $vidfile-fadeout.mpg"); 
return @ProcDataArray;
}


=head2 Transition()  Transition Between Scenes. TBD

=cut

sub Transition
{
}


=head2 GetDuration()  Get Duration Seconds Of Video.

=cut

sub GetDuration
{

$vidfile=$self->{'vidfile'};

## Stream Whole File
# my $VideoData=`ffmpeg  -i $vidfile -f null /dev/null 2>&1`;
## Summary Only 
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

print("DurationData--->  $DurationData \n");

$DurationData =~ s/ //g;
my @DurationArray=split(",", $DurationData);

my @timearray=split(":", $DurationArray[0]);
my $DurationHMS=$timearray[1] . ":" . $timearray[2] . ":" . $timearray[3];

$DurationSecs=($timearray[1] * 3600) + ($timearray[2] * 60 ) + $timearray[3];

return($DurationSecs);
}
### End GetDuration


=head2 GetStreamInfo()  Get Various Stream Parameters.

=cut

sub GetStreamInfo
{

$self->SetParams(@_);

$vidfile=$self->{'vidfile'};

my $StreamInfo = {};
my $ffmpeg = {};
my $StreamCount = 0;

my $ProcData=`ffmpeg  -i $vidfile  2>&1`;
$ProcData =~ s/\r/\n/g;
$ProcData =~ s/\n */\n/g;
my @ProcDataArray=split("\n", $ProcData);

	foreach $i (0..$#ProcDataArray)
	{
			# print("--->> $ProcDataArray[$i]\n");

		if ( $ProcDataArray[$i] =~ /FFmpeg version/ )
		{
			$ProcData=$ProcDataArray[$i];
			my @ProcArray=split(", ", $ProcData);
			# print("$ProcArray[0]\n");
			# print("$ProcArray[1]\n");
			$ffmpeg->{'version'} = $ProcArray[0];
			$ffmpeg->{'Copyright'} = $ProcArray[1];
		}

		if ( $ProcDataArray[$i] =~ /built on/ )
		{
			$ProcData=$ProcDataArray[$i];
			my @ProcArray=$ProcData;
			# print("$ProcArray[0]\n");
			$ffmpeg->{'builton'} = $ProcArray[0];
			# print($StreamInfo->{'builton'}, "\n");
		}

		if ( $ProcDataArray[$i] =~ /configuration:/ )
		{
			$ProcData=$ProcDataArray[$i];
			my @ProcArray=$ProcData;
			# print("$ProcArray[0]\n");
			my @dataline = split(": ", $ProcArray[0]);
			$ffmpeg->{'configuration'} = $dataline[1];
		}

		if ( $ProcDataArray[$i] =~ /libav/ )
		{
			$ProcData=$ProcDataArray[$i];
			my @ProcArray=$ProcData;
			my ( $foo ) = ( $ProcArray[0] =~ m/(^.*?) /);
			$ProcArray[0] =~ s/(^.*?) /$foo-/;
			$ProcArray[0] =~ s/ //g;
			# print("$ProcArray[0]\n");
			my @libav=split('-', $ProcArray[0]);
			$ffmpeg->{$libav[0]} = $libav[1];
		}

		if ( $ProcDataArray[$i] =~ /libsw/ )
		{
			$ProcData=$ProcDataArray[$i];
			my @ProcArray=$ProcData;
			my ( $foo ) = ( $ProcArray[0] =~ m/(^.*?) /);
			$ProcArray[0] =~ s/(^.*?) /$foo-/;
			$ProcArray[0] =~ s/ //g;
			# print("$ProcArray[0]\n");
			my @libsw=split('-', $ProcArray[0]);
			$ffmpeg->{$libsw[0]} = $libsw[1];
		}

		if ( $ProcDataArray[$i] =~ /Input/ )
		{
			$ProcData=$ProcDataArray[$i];
			my @ProcArray=split(", ", $ProcData);
			# print("$ProcArray[0]\n");
			# print("$ProcArray[1]\n");
			# print("$ProcArray[2]\n");
			$ProcArray[0] =~ s/ //g;
			$ProcArray[2] =~ s/from //g;
			$ProcArray[2] =~ s/://g;
			$ProcArray[2] =~ s/'//g;
			$StreamInfo->{$ProcArray[0]}->{'container'} = $ProcArray[1];
			$StreamInfo->{$ProcArray[0]}->{'source'} = $ProcArray[2];
		}

		if ( $ProcDataArray[$i] =~ /Duration:/ )
		{
			my @dataline = ();
			$ProcData=$ProcDataArray[$i];
			my @ProcArray=split(", ", $ProcData);
			# print("^$ProcArray[0]\n");
			# print("^^$ProcArray[1]\n");
			# print("^^^$ProcArray[2]\n");

			@dataline = split(": ", $ProcArray[0]);
			$StreamInfo->{$dataline[0]} = $dataline[1];

			@dataline = split(": ", $ProcArray[1]);
			$StreamInfo->{$dataline[0]} = $dataline[1];

			@dataline = split(": ", $ProcArray[2]);
			$StreamInfo->{$dataline[0]} = $dataline[1];

			my @timearray=split(":", $StreamInfo->{'Duration'});

			$DurationSecs=($timearray[0] * 3600) + ($timearray[1] * 60 ) + $timearray[2];

			$StreamInfo->{'DurationSecs'} = $DurationSecs;
		}

		if ( $ProcDataArray[$i] =~ /Stream/ )
		{
			my @dataline = ();
			$ProcData=$ProcDataArray[$i];
			my @ProcArray=split(": ", $ProcData);

			$ProcArray[0] =~ s/ //g;

			@dataline = split("\\[", $ProcArray[0]);
			my $stream = $dataline[0];

			$StreamInfo->{$stream}->{'type'} = $ProcArray[1];

			if ( $StreamInfo->{$stream}->{'type'} =~ /Video/)
			{
				@dataline = split(", ", $ProcArray[2]);
				$StreamInfo->{$stream}->{'codec'} = $dataline[0];
				$StreamInfo->{$stream}->{'colorspace'} = $dataline[1];
				$StreamInfo->{$stream}->{'aspect'} = $dataline[2];
				$StreamInfo->{$stream}->{'bitrate'} = $dataline[3];
				$StreamInfo->{$stream}->{'framerate'} = $dataline[4];
				$StreamInfo->{$stream}->{'tbr'} = $dataline[5];
				$StreamInfo->{$stream}->{'tbn'} = $dataline[6];
				$StreamInfo->{$stream}->{'tbc'} = $dataline[7];

				$StreamCount++;
			}

			if ( $StreamInfo->{$stream}->{'type'} =~ /Audio/)
			{
				@dataline = split(", ", $ProcArray[2]);
				$StreamInfo->{$stream}->{'codec'} = $dataline[0];
				$StreamInfo->{$stream}->{'samplerate'} = $dataline[1];
				$StreamInfo->{$stream}->{'channels'} = $dataline[2];
				$StreamInfo->{$stream}->{'sampletype'} = $dataline[3];
				$StreamInfo->{$stream}->{'bitrate'} = $dataline[4];

				$StreamCount++;
			}

			# 	print("^$ProcArray[0]\n");
			#	print("^^$ProcArray[1]\n");
			#	print("^^^$ProcArray[2]\n");

		}

	}

	if ($self->{'debug'})
	{
		print Dumper($ffmpeg);
		print Dumper($StreamInfo);
	}

@StreamInfo=($framerate, $size);
return(@StreamInfo);


}


=head2 TitleFade()  Generate A Title From PostScript With Fade In And Out.

=cut

sub TitleFade 
{

	$self->SetParams(@_);
	
	$vidfile=$self->{'vidfile'};
	$size=$self->{'size'};
	$framerate=$self->{'framerate'};
	$fadeinframes=$self->{'fadeinframes'};
	$fadeoutframes=$self->{'fadeoutframes'};
	$holdframes=$self->{'holdframes'};
	$titleframes=$self->{'titleframes'};
	$color=$self->{'color'};
	$opacity=$self->{'opacity'};
	$width=$self->{'width'};
	$height=$self->{'height'};
	$DurationSecs=$self->{'DurationSecs'};
	$prec1=$self->{'prec1'};
	$prec2=$self->{'prec2'};
	$aspect=$self->{'aspect'};
	
	my $gsize = $height . 'x' . $width;
	
	# print("remaining values of \@Params from SetParams() = @Params\n");
	
	my $frameno=0;
	my $fadefactor=( ($opacity / $fadeinframes) );
	
	my $fade=($opacity / 100);
	
	system("rm -f $vidfile-front.mpg"); 
	system("rm -f $vidfile-titlebackground.mpg"); 



### Here is where the main difficulty is:
### GhostScript seems to be a bit buggy when generating PNG Images.
### When a PNG Image is successfully generated, the FFMPEG
### Functions usually will work just fine. 

if (  ( ! $self->{'pngfile'} ) || ( $self->{'pngfile'} eq 'none' ) )
	{
		$self->PSTitleFrame();
		$ProcData=`gs -dBATCH -dNOPAUSE -sDEVICE=pngalpha -g"$gsize" -sOutputFile=title.tmp.png Title.ps`;
		$ProcData=`convert -rotate 90 title.tmp.png title.png`;
	}
else 
 	{
 		$self->PSTitleFrame();
 		$ProcData=`gs -dBATCH -dNOPAUSE -sDEVICE=pngalpha -g"$gsize" -sOutputFile=title.tmp.png Title.ps`;
 		$ProcData=`convert -rotate 90 title.tmp.png title.png`;
 		$ProcData=`convert $self->{'pngfile'} -resize $self->{'size'}!  pngfile.png`;
 		$ProcData=`convert pngfile.png title.png -composite -size $gsize composite.png`;
 		$ProcData=`mv composite.png title.png`;
 	}

	# $ProcData=`gs -dBATCH -dNOPAUSE -sDEVICE=pngalpha -g288x352 -sOutputFile=title.tmp.png Title.ps`;
	# $ProcData=`convert RCA_Indian_Head_test_pattern.JPG -scale 352 title.png`;
	
	my $skipsecs=0;
	print("skipsecs: $skipsecs\n");
	my $skip=sprintf("%.2f", $skipsecs);
	my $next=( 1 / $framerate);
	print("skip: $skip\n");
	print("nextval: $next\n");
	

	if ( $aspect  eq 'HD')
	{
		Clear1600x9001Frame();
	}

	if ( $aspect  eq 'NTSC')
	{
		Clear720x4801Frame();
	}
	else
	{
		Clear1024x7681Frame();
	}
	
	for ( $frameno = 1; $frameno <= $titleframes; $frameno++)
	{
		system("cat color-0.mpg >> $vidfile-titlebackground.mpg"); 
	}

	$ProcData=`ffmpeg -y -i $vidfile-titlebackground.mpg -vf "movie=0:png:title.png [title]; [in][title] overlay=0:0" -qmin 1 -qmax 1 -g 0 -s $size  title-out.mpg  `;
	print("$ProcData\n");


	$self->FadeIn("vidfile=title-out.mpg", "size=$size", "framerate=$framerate", "color=$color", "opacity=$opacity", "fadeinframes=$fadeinframes", "fadeoutframes=$fadeoutframes", "holdframes=$holdframes", "titleframes=$titleframes" );


	$self->FadeOut("vidfile=title-out.mpg-fadein.mpg", "size=$size", "framerate=$framerate", "color=$color", "opacity=$opacity", "fadeinframes=$fadeinframes", "fadeoutframes=$fadeoutframes", "holdframes=$holdframes", "titleframes=$titleframes" );


	system("mv $vidfile-fadeout.mpg titlefade.mpg"); 

	system("rm -f title-out*"); 
	return @ProcDataArray;
}


=head2 Clear1024x7681Frame()  Returns Base64 Encoded 1024x768 MPG 1 Frame.

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


# my $returndata=uudecode($clearframe);
my $returndata=MIME::Base64::decode($clearframe);

open (OUTFILE,  '>', "color-0.mpg") or  die $!;
print(OUTFILE $returndata);
close (OUTFILE);

return($returndata);
}

=head2 Clear1600x9001Frame()  Returns Base64 Encoded 1600x900 MPG 1 Frame.

=cut

sub Clear1600x9001Frame {

my $clearframe=<<DATA;
AAABuiEAA0ghwzNnAAABuwAJwzNnACH/4ODmAAAB4AffMQAFvyERAAWnsQAAAbNkA4QV///gGAAA
AbgACAAAAAABAAAP//gAAAEBC/h9KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUAAAHg
B/oPIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIgAAAeAH+g8u
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuAAAB4Af6D1KUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlIAAAHgB/oPlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlAAAAeAH+g+IuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIAAAB4Af6D7lKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLkAAAHgB/oPSlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SgAAAeAH+g9SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSAAAB4Af6DyLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiIAAAHgBAwP5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIiAAABvgPoD///////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////w==
DATA


# my $returndata=uudecode($clearframe);
my $returndata=MIME::Base64::decode($clearframe);

open (OUTFILE,  '>', "color-0.mpg") or  die $!;
print(OUTFILE $returndata);
close (OUTFILE);

return($returndata);
}

=head2 Clear720x4801Frame()  Returns Base64 Encoded 1600x900 MPG 1 Frame.

=cut

sub Clear720x4801Frame {

my $clearframe=<<DATA;
AAABuiEAA0ghwzNnAAABuwAJwzNnACH/4ODmAAAB4AffMQAFvyERAAWnsQAAAbMtAeAV///gGAAA
AbgACAAAAAABAAAP//gAAAEBC/h9KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKU
iLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUi
LlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiL
lKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLl
KUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlK
UiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUiLlKUAAAHg
B/oPIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi
5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5
SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5S
lIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5Sl
Ii5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlI
i5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIi5SlIgAAAeAEHA8u
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSI
uUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIu
UpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuU
pSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUp
SIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIuUpS
IuUpSIuUpSIuUpSIuUpSIuUpSIuUpSIgAAABvgPYD///////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
DATA

# my $returndata=uudecode($clearframe);
my $returndata=MIME::Base64::decode($clearframe);

open (OUTFILE,  '>', "color-0.mpg") or  die $!;
print(OUTFILE $returndata);
close (OUTFILE);

return($returndata);
}

=head2 PSTitleFrame() Returns PostScript Title Frame Template.

=cut

sub PSTitleFrame {
	my ( $self, @inputargs) = @_;

	my $height = $self->{'height'};
	my $width = $self->{'width'};
	my $justify = $self->{'justify'};


	my $hscale = ( $height * 10 );	
	my $wscale = ( $width * 10 );	
	
	my $verysmallfontsize = 12;
	my $smallfontsize = 18;
	my $mediumfontsize = 28;
	# my $largefontsize = 43; 
	# my $autofontsize = 310; 

	my $cyan = '0.7777';
	my $magenta = '0.7777';
	my $yellow = '0.7777';
	my $black = '0.0000';


    my $redline = "0.1111 0.7777 0.7777 0.0000 SET_CMYK \n";
    my $blueline = "0.7777 0.7777 0.1111 0.0000 SET_CMYK \n";
    my $greenline = "0.7777 0.1111 0.7777 0.0000 SET_CMYK \n";
    my $cyanline = "0.7777 0.1111 0.1111 0.0000 SET_CMYK \n";
    my $magentaline = "0.1111 0.7777 0.1111 0.0000 SET_CMYK \n";
    my $yellowline = "0.1111 0.1117 0.7777 0.0000 SET_CMYK \n";
    my $blackline = "0.9999 0.9999 0.9999 0.9999 SET_CMYK \n";
		my $whiteline = "0.1051 0.1049 0.1051 0.0000 SET_CMYK \n";
    my $greyline = "0.1111 0.1111 0.1111 0.5000 SET_CMYK \n";


	my $colorline = $redline;

	if ( lc($self->{'fontcolor'})  eq 'red' )
	{
		$colorline = $redline;
	}

	if ( lc($self->{'fontcolor'})  eq 'blue' )
	{
		$colorline = $blueline;
	}

	if ( lc($self->{'fontcolor'})  eq 'green' )
	{
		$colorline = $greenline;
	}

	if ( lc($self->{'fontcolor'})  eq 'cyan' )
	{
		$colorline = $cyanline;
	}

	if ( lc($self->{'fontcolor'})  eq 'magenta' )
	{
		$colorline = $magentaline;
	}

	if ( lc($self->{'fontcolor'})  eq 'yellow' )
	{
		$colorline = $yellowline;
	}

	if ( lc($self->{'fontcolor'})  eq 'white' )
	{
		$colorline = $whiteline;
	}

	if ( lc($self->{'fontcolor'})  eq 'grey' )
	{
		$colorline = $greyline;
	}

	if ( lc($self->{'fontcolor'})  eq 'black' )
	{
		$colorline = $blackline;
	}

	if ( lc($self->{'font'})  eq 'helvetica' )
	{
		$fontline = 'HelveticaLarge';
	}

	if ( lc($self->{'font'})  eq 'courier' )
	{
		$fontline = 'CourierLarge';
	}
	else
	{
		$fontline = 'CourierLarge';
	}


	my $titletextfile = 'title.txt';
	# my $filesize = (stat($titletextfile))[7];
	# print $filesize;

	if ( ! open(FILE, "title.txt") ) 
	{
		open(FILE, "+>", "title.txt");
		print(FILE "This Video\n\nProduced With:\n\nFFMPEG::Effects 0.4\n");
		close(FILE);
	}

	open(FILE, "title.txt");
	my $linecount = scalar(grep{/\n/}<FILE>);
	print("$linecount \n");

	my $longestline = 0;
	seek( FILE, 0, 0);
	while (<FILE>)
	{
		# chomp($_);
		my $linelength = length($_);
		if ( $linelength > $longestline )
		{
			$longestline = $linelength;
		}
	}
	
	if ( ( ! $self->{'fontsize'}  ) || ( $self->{'fontsize'}  eq 'not-set' )  )  
	{
		$fontsize = ( ( $wscale / 5 ) / $longestline );
	}
	else
	{
		$fontsize = $self->{'fontsize'}; 
	}

	my $pad = ( $fontsize * 2 );

	my $letterheight = ( ( 6.7 * $fontsize ) * 1 );
	# my $letterheight = ( ( 8 * $fontsize ) * 1 );
	my $pct = ( ( $letterheight / $hscale ) * 100 );
	my $factor =  ( ( ( 98 - $pct )  / 100 )  );


	my $lineypos = ( $hscale  * $factor );
	# my $yspace = ( $lineypos - ( 1 * $fontsize ) );
	my $yspace = $lineypos;

	my $largefontsize = $fontsize; 

	# my $linespace =  ( ( $hscale / $linecount ) * 20 );
	# my $linespace =  ( ( $hscale / $linecount ) * 20 );

	my $pngdata = "\n";

	my $linenumber = 0;
	my $line1text = 'foo';
	my $line1size;
	my $line1ypos = 0;
	my $line1xpos = 0;

	# open(FILE, "title.txt");
	seek( FILE, 0, 0);
	while (<FILE>)
	{
			# print ++$a." $_" if /./ <FILE>;
			# print "$_" if /./;
			if ( /./ )
			{
				$linenumber++;

				if ( $linenumber == 1 )
				{
					chomp($_);
					$line1text = $_;
					my $linecharcount = length($_);
					# $fontsize = ($fontsize / $linecharcount);

	 				use integer;
	 					$largefontsize = $fontsize / 1; 
	 					$fontsize = $fontsize / 1; 
						$line1size = ( 5 * $fontsize * $linecharcount );
	 				no integer;

					$line1ypos = $lineypos;
					$linespace = ( ( $yspace / $linecount ) *  1 );

					if ($justify eq 'left')
					{
						$line1xpos = ( 0 );
						$line1xpos =  ( $line1xpos  + $pad );
					}

					if ($justify eq 'center')
					{
						my $whitespace = ( ( $wscale  ) - ( $line1size ) );
						$line1xpos =  ($whitespace / 2 );
					}

					if ($justify eq 'right')
					{
						$line1xpos = ( 0 );
						my $whitespace = ( ( $wscale  ) - ( $line1size ) );
						$line1xpos =  ( $whitespace - $pad  );
					}

					if ($largefontsize < 1)
					{
						$largefontsize = 1;
					}

				}

				my $line = chomp($_);
				my $linecharcount = length($_);
				# print " $_" ;
				# print($linecharcount, "\n");

	 			use integer;
	 				$largefontsize = $fontsize / 1; 
	 				$fontsize = $fontsize / 1; 
					$linesize = ( 5 * $fontsize * $linecharcount );
	 			no integer;

				if ($justify eq 'left')
				{
					$linexpos = ( 0 );
					$linexpos =  ( $linexpos  + $pad );
				}

				if ($justify eq 'center')
				{
					my $whitespace = ( ( $wscale  ) - ( $linesize ) );
					$linexpos = ($whitespace / 2 );
				}

				if ($justify eq 'right')
				{
					$linexpos = ( 0 );
					my $whitespace = ( ( $wscale  ) - ( $linesize ) );
					$linexpos =  ( $whitespace - $pad );
				}


				# my $psdata = 	"$cyan $magenta $yellow $black SET_CMYK \n".
				my $psdata = 	$colorline.
								"$fontline SETFONT \n".
								"GS \n".
								"n \n".
								"$linexpos $lineypos M \n".
								"($_) $linesize X \n".
								"GR \n".
								"\n";

								# print $psdata;

				$pngdata =  $pngdata . $psdata;

				$lineypos = ( $lineypos - $linespace );
				# $lineypos = ( $lineypos  * $factor );
			}
			else
			{ 
				my $linesize = ( 5 * $fontsize * 1 );
				# my $whitespace = ( ( $wscale  ) - ( $linesize ) );
				# my $linexpos = ( $whitespace / 2 );

				# my $psdata = 	"$cyan $magenta $yellow $black SET_CMYK \n".
				my $psdata = 	$colorline.
								"$fontline SETFONT \n".
								"GS \n".
								"n \n".
								"0 $lineypos M \n".
								"( ) $linesize X \n".
								"GR \n".
								"\n";

								# print $psdata;

				$pngdata =  $pngdata . $psdata;

				$lineypos = ( $lineypos - $linespace );
			}

	}

	close(FILE);
	print $pngdata;
	# no integer;


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
/AXscale { 300 3000 div } bd
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
      /HelveticaLarge /Helvetica-Bold FINDFONT $largefontsize POINTSCALEFONT def
      /HelveticaMedium /Helvetica-Bold FINDFONT $mediumfontsize POINTSCALEFONT def
      /HelveticaSmall /Helvetica-Bold FINDFONT $smallfontsize POINTSCALEFONT def
      /HelveticaVerySmall /Helvetica-Bold FINDFONT $verysmallfontsize POINTSCALEFONT def

      /CourierLarge /Courier-Bold FINDFONT $largefontsize POINTSCALEFONT def
      /CourierMedium /Courier-Bold FINDFONT $mediumfontsize POINTSCALEFONT def
      /CourierSmall /Courier-Bold FINDFONT $smallfontsize POINTSCALEFONT def
      /CourierVerySmall /Courier-Bold FINDFONT $verysmallfontsize POINTSCALEFONT def
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
$hscale DOLANDSCAPE
%%EndPageSetup

0.9999 0.9960 0.9999 0.0000 SET_CMYK
CourierLarge SETFONT
GS
n
$line1xpos $line1ypos M
($line1text) $line1size X
GR

$pngdata

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
