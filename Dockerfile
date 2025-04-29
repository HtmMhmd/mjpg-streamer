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

# Create the destination directory for mjpg-streamer plugins
RUN mkdir -p /usr/local/lib/mjpg_streamer

# Copy the built mjpg-streamer from the builder stage
COPY --from=builder /usr/local/bin/mjpg_streamer /usr/local/bin/

# Copy the .so files directly from where they were built
COPY --from=builder /app/src/mjpg-streamer/mjpg-streamer-experimental/*.so /usr/local/bin/
COPY --from=builder /app/src/mjpg-streamer/mjpg-streamer-experimental/_build/*.so /usr/local/lib/mjpg_streamer/
COPY --from=builder /app/src/mjpg-streamer/mjpg-streamer-experimental/_build/plugins/*/*.so /usr/local/lib/mjpg_streamer/

# Set the working directory
WORKDIR /app/src

# Copy the application code
COPY . .

# Rest of your Dockerfile remains the same
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

# Command to run the mjpg-streamer with updated plugin paths
CMD ["mjpg_streamer", "-i", "/usr/local/lib/mjpg_streamer/input_uvc.so", "-o", "/usr/local/lib/mjpg_streamer/output_http.so"]