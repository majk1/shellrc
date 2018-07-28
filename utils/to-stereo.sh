#!/usr/bin/env bash
#
# TODO: utils/to-stereo.sh (draft)
#

# ${TITLE}_stereo.ac3: ${TITLE}_51.ac3
#         ffmpeg -i ${TITLE}_51.ac3 -ac 2 \
#         -af "pan=stereo|FL=FC+0.30*FL+0.30*BL|FR=FC+0.30*FR+0.30*BR"    \
#         ${TITLE}_stereo.ac3


#
# 
# ffmpeg -i input_51.mkv -c:v copy -c:a ac3 -ac 2 -af "pan=stereo|FL=FC+0.30*FL+0.30*BL|FR=FC+0.30*FR+0.30*BR" output_stereo.mkv
# 
# ffmpeg -i input_51.mkv -map 0:a:0 -map 0:v:0 -map 0:s -c:v copy -c:a ac3 -ac 2 -af "aresample=matrix_encoding=dplii" output_stereo.mkv
# 
# 

