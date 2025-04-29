# MJPG Streamer Project

## Overview
MJPG Streamer is a project that allows you to stream video from a camera using the MJPEG format. This project is containerized using Docker, making it easy to set up and run on any system that supports Docker.

## Project Structure
The project consists of the following files:

- **Dockerfile**: Defines a multi-stage build for the MJPG Streamer project, installing necessary dependencies and setting up the environment.
- **docker-compose.yml**: Configures the services, networks, and volumes for the Docker application.
- **requirements.txt**: Lists the Python dependencies required for the project, specifically including `opencv-python`.
- **install_commands.txt**: Contains shell commands to install system dependencies required for building and running MJPG Streamer.
- **start.sh**: A script to start the MJPG Streamer application using Docker Compose.
- **.env**: Contains environment variables used in the Docker Compose configuration.

## Setup Instructions

1. **Clone the Repository**
   Clone the repository to your local machine:
   ```
   git clone https://github.com/yourusername/mjpg-streamer.git
   cd mjpg-streamer
   ```

2. **Build the Docker Image**
   Use the following command to build the Docker image:
   ```
   docker-compose build
   ```

3. **Run the Application**
   Start the MJPG Streamer application using Docker Compose:
   ```
   ./start.sh
   ```

4. **Access the Stream**
   Once the application is running, you can access the video stream at `http://localhost:8080` (or the port specified in your `.env` file).

## Usage
You can customize the camera settings and other parameters by modifying the `.env` file. Ensure that your camera is connected and recognized by the system before starting the application.

## Troubleshooting
If you encounter any issues, check the logs of the Docker containers using:
```
docker-compose logs
```

## License
This project is licensed under the MIT License. See the LICENSE file for more details.