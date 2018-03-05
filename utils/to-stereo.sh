#!/usr/bin/env bash
#
# TODO: utils/to-stereo.sh (draft)
#

# ${TITLE}_stereo.ac3: ${TITLE}_51.ac3
#         ffmpeg -i ${TITLE}_51.ac3 -ac 2 \
#         -af "pan=stereo|FL=FC+0.30*FL+0.30*BL|FR=FC+0.30*FR+0.30*BR"    \
#         ${TITLE}_stereo.ac3

