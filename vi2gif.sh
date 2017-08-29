#!/bin/bash

# FFMPEG WRAPPER FOR CONVERTING VIDEO TO GIF
#
# Original article
# http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html

NAME=$(basename "$0")
SCALE="320:-1"
IN=
OUT=
START_FRAME=
END_FRAME=
PALETTE_ONLY=false
PALETTE="/tmp/palette.png"

function usage {
  printf "$NAME\n\nUsage:\n"
  printf "Arguments:\n\n"
  printf "\t-i <path>\t - Input path (video file)\n"
  printf "\t-o <path>\t - Output path (gif file)\n"
  printf "\t-s <w:h>\t - Scale mode for ffmpeg. Use -1 for auto\n"
  printf "\t-t <path>\t - Temp folder for palette image\n"
  printf "\t-p \t\t - Export palette only (according to -t option, or /tmp folder by default)\n"
  printf "\t-f <seconds>\t - Get part of video from\n"
  printf "\t-d <seconds>\t - Duration of part\n"
  exit "$1"
}

# read args
while [[ $# -gt 1 ]]
do
  key="$1"

  case $key in
    -i)
      IN="$PWD/$2"
      shift
    ;;
    -o)
      OUT="$PWD/$2"
      shift
    ;;
    -s)
      SCALE="$2"
      shift
    ;;
    -t)
      PALETTE="$PWD/$2"
      shift
    ;;
    -f)
      START_FRAME="$2"
      shift
    ;;
    -d)
      END_FRAME="$2"
      shift
    ;;
    -p)
      PALETTE_ONLY=true
    ;;
    *)
      usage 0
    ;;
  esac
  shift
done

FILTERS="fps=15,scale=$SCALE:flags=lanczos"

if [[ $START_FRAME && $END_FRAME ]]; then
  FILTERS="trim=start_frame=$START_FRAME:end_frame=$END_FRAME,$FILTERS"
fi

if [[ ! $IN || ! $OUT ]]; then
  usage 1

else
  echo "Extract palette..."
  ffmpeg -v warning -i "$IN" -vf "$FILTERS,palettegen" -y $PALETTE

  if [[ "$PALETTE_ONLY" = false ]]; then
    echo "Convert video to gif"
    ffmpeg -v warning -i "$IN" -i $PALETTE -lavfi "$FILTERS [x]; [x][1:v] paletteuse" -y "$OUT"
  fi

  echo "Done!"
fi