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

# Copy the built mjpg-streamer from the builder stage
COPY --from=builder /usr/local/bin/mjpg_streamer /usr/local/bin/
COPY --from=builder /usr/local/lib/mjpg_streamer /usr/local/lib/mjpg_streamer

# Set the working directory
WORKDIR /app/src

# Copy the application code
COPY . .

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Command to run the mjpg-streamer
CMD ["mjpg_streamer", "-i", "input_uvc.so", "-o", "output_http.so"]