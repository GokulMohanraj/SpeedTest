# Use a lightweight Python base image based on Debian
FROM python:3.9-slim-buster

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install Python dependencies.
# --no-cache-dir reduces the image size by not storing pip's cache.
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files into the container
# This includes app.py and the templates/ directory
COPY . .

# Expose the port that Flask will run on
EXPOSE 5000

# Define the command to run the Flask application
# Using gunicorn for a more robust production-like server
# than Flask's built-in development server.
# Using 0.0.0.0 to make the app accessible from outside the container.
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
