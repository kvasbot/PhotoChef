#!/bin/bash
set -e

export PATH="$PATH:$HOME/flutter/bin"
flutter config --no-analytics
flutter build web --release --web-renderer canvaskit
