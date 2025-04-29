# Stage 1: Builder for mjpg-streamer
FROM ubuntu:latest AS mjpg-builder

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

#=======================================================================#
# Stage 2: Python environment builder
FROM python:3.10-slim AS python-builder

WORKDIR /app

# Install minimal build dependencies for OpenCV headless
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    libglib2.0-0 \
    libgl1 \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Create and activate virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir numpy

#=======================================================================#   
# Stage 3: Final runtime image
FROM ubuntu:latest

# Install required runtime packages for both mjpg-streamer and OpenCV
RUN apt-get update && apt-get install --no-install-recommends -y \
    libjpeg-dev \
    python3 \
    python3-venv \
    libglib2.0-0 \
    libgl1 \
    libsm6 \
    libxext6 \
    libxrender1 \
    && rm -rf /var/lib/apt/lists/*

# Create the destination directory for mjpg-streamer plugins
RUN mkdir -p /usr/local/lib/mjpg_streamer

# Copy the built mjpg-streamer from the builder stage
COPY --from=mjpg-builder /usr/local/bin/mjpg_streamer /usr/local/bin/

# Copy the .so files directly from where they were built
COPY --from=mjpg-builder /app/src/mjpg-streamer/mjpg-streamer-experimental/*.so /usr/local/bin/
COPY --from=mjpg-builder /app/src/mjpg-streamer/mjpg-streamer-experimental/_build/*.so /usr/local/lib/mjpg_streamer/
COPY --from=mjpg-builder /app/src/mjpg-streamer/mjpg-streamer-experimental/_build/plugins/*/*.so /usr/local/lib/mjpg_streamer/

# Copy Python virtual environment
COPY --from=python-builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

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
    PASSWORD=${PASSWORD} \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# configure
RUN mkdir -p /www && echo "{'angle': ${ANGLE}, 'flipped': ${FLIPPED}, 'mirrored': ${MIRRORED}}" \
    > /www/config.json

# Command to run the mjpg-streamer
CMD ["mjpg_streamer", "-i", "/usr/local/lib/mjpg_streamer/input_uvc.so", "-o", "/usr/local/lib/mjpg_streamer/output_http.so"]