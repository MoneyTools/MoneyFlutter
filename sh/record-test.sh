#!/bin/bash

# Define the output video file
OUTPUT_VIDEO="test_run_$(date +%Y-%m-%d_%H-%M-%S).mp4"

# Start recording with ffmpeg (adjust the screen dimensions as needed)
ffmpeg -video_size 1280x720 -framerate 30 -f avfoundation -i "1" -r 30 "$OUTPUT_VIDEO" &
FFMPEG_PID=$!

# Run the Flutter integration test
flutter drive --target=integration_test/app_test.dart -d macos

# Stop the ffmpeg recording
kill $FFMPEG_PID
