# Stage 1: Build Environment
FROM ubuntu:22.04 AS build-env

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa \
    fonts-droid-fallback lib32stdc++6 python3 \
    nodejs npm

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Verify Flutter installation
RUN flutter doctor -v
RUN flutter config --enable-web

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Install Flutter and Node dependencies
RUN flutter pub get
RUN npm install

# Build the Flutter Web app
RUN flutter build web

# Stage 2: Serve with Nginx (Optional for Web)
FROM nginx:1.21.1-alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html   