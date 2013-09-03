#!/bin/bash

# Functions
howto() {
	this=$(basename $(type $0 | awk '{print $3}'))
	echo -e "Cartoonify version 1.0\nUsage: $this [-v] input.jpg output.jpg\n"
}
error() {
	echo $1
	exit 1
}

# check if params is set
if [ $# -eq 0 ]; then
	howto
	exit 1
fi

# check if convert exists
command -v convert &>/dev/null || error "ImageMagick is not installed"

#check if version is ok
version=`convert -list configure | grep 'LIB_VERSION_NUMBER' | awk '{print $2}' | sed -s 's/,//g'`
if [ "$version" -ge "6686" ]; then
	exit 1;
fi

# valitate input
if [ "$1" == "-v" ]; then
	debug=1
	input=$2
	output=$3
else
	debug=0
	input=$1
	output=$2
fi

# validate if input file exists 
if [ ! -f "$input" ]; then
	echo "Cannnot find file $input"
fi

convolution=0.70
dx="-$convolution,0,$convolution,-$convolution,0,$convolution,-$convolution,0,$convolution"
dy="$convolution,$convolution,$convolution,0,0,0,-$convolution,-$convolution,-$convolution"

tmpA1="/tmp/tempfile_cartoon_1_$$.img"
tmpB1="/tmp/tempfile_cartoon_1_$$.cache"
tmpA2="/tmp/tempfile_cartoon_2_$$.img"
tmpB2="/tmp/tempfile_cartoon_2_$$.cache"
tmpA3="/tmp/tempfile_cartoon_3_$$.img"
tmpB3="/tmp/tempfile_cartoon_3_$$.cache"

if [ $debug -eq 1 ]; then
	echo "Converting $input to $output"
	echo -n "."
fi
convert -quiet -regard-warnings "$input" -colorspace RGB +repage "$tmpA1"

if [ $debug -eq 1 ]; then
	echo -n "."
fi
convert \( $tmpA1 -median 2 \) \( -size 1x256 gradient: -rotate 90 -fx "floor(u*10+0.5)/10" \) -clut $tmpA2

if [ $debug -eq 1 ]; then
	echo -n "."
fi
convert \( $tmpA1 -colorspace gray -median 2 \) \
	\( -clone 0 -bias 50% -convolve "$dx" -solarize 50% \) \
	\( -clone 0 -bias 50% -convolve "$dy" -solarize 50% \) \
	\( -clone 1 -clone 1 -compose multiply -composite -gamma 2 \) \
	\( -clone 2 -clone 2 -compose multiply -composite -gamma 2 \) \
	-delete 0-2 -compose plus -composite -threshold 75% $tmpA3

if [ $debug -eq 1 ]; then
	echo "."
fi
convert $tmpA2 $tmpA3 -compose multiply -composite $output

if [ $debug -eq 1 ]; then
	echo "Conversion completed"
	echo "Removing temporary files"
fi
rm -rf /tmp/tempfile_cartoon*