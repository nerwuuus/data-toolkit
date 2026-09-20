# Use the official Python image as the base environment.
# It already includes Python and pip.
FROM python:3.14.6

# Set the working directory inside the container.
# All following commands will be executed from /app.
WORKDIR /app

# Copy the requirements file first.
# This allows Docker to cache installed dependencies if only project files change later.
COPY requirements.txt .

# Install Python dependencies inside the image.
RUN pip install -r requirements.txt

# Copy the rest of the project files into the container.
COPY . .
