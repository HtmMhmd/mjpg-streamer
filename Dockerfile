FROM ubuntu:latest AS builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libgl1 \
    libjpeg-dev \
    libgl1-mesa-dev \
    libatlas-base-dev \
    libewf-dev \
    libltdl-dev \
    libglib2.0-dev \
    pkg-config \
    python3-pip

# Clone mjpg-streamer
RUN git clone https://github.com/jacksonliam/mjpg-streamer.git /app/src/mjpg-streamer

# Build and install mjpg-streamer
WORKDIR /app/src/mjpg-streamer/mjpg-streamer-experimental
RUN make && make install

# Final stage
FROM ubuntu:latest

# Install required runtime packages
RUN apt-get update && apt-get install -y \
    libjpeg-dev \
    python3-pip

# Find mjpg_streamer location in builder
RUN find /usr -name "mjpg_streamer*" | sort

# Copy the built mjpg-streamer from the builder stage
COPY --from=builder /usr/local/bin/mjpg_streamer /usr/local/bin/
COPY --from=builder /app/src/mjpg-streamer/mjpg-streamer-experimental/lib /usr/local/lib/mjpg_streamer

# Set the working directory
WORKDIR /app/src

# Copy the application code
COPY . .

# arguments (default values in `.env` file)
ARG PORT
ARG RESOLUTION
ARG FPS
ARG ANGLE
ARG FLIPPED
ARG MIRRORED
ARG USERNAME
ARG PASSWORD

# environment variables
ENV PORT=${PORT} \
    RESOLUTION=${RESOLUTION} \
    FPS=${FPS} \
    ANGLE=${ANGLE} \
    FLIPPED=${FLIPPED} \
    MIRRORED=${MIRRORED} \
    USERNAME=${USERNAME} \
    PASSWORD=${PASSWORD}

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# configure
RUN mkdir -p /www && echo "{'angle': ${ANGLE}, 'flipped': ${FLIPPED}, 'mirrored': ${MIRRORED}}" \
    > /www/config.json

# Command to run the mjpg-streamer
CMD ["mjpg_streamer", "-i", "input_uvc.so", "-o", "output_http.so"]