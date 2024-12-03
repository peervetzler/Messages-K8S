# Use an official Python image as the base image
FROM python:3.12-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the application files into the container
COPY . /app

# Install Flask directly
RUN pip install --no-cache-dir flask

# Expose port 5000 for the Flask app
EXPOSE 5000

# Set the environment variable to run Flask in production
ENV FLASK_APP=main.py

# Command to run the Flask application
CMD ["flask", "run", "--host=0.0.0.0"]
