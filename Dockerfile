FROM python:3.14.0rc1-slim

# Install security updates and system dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create a non-root user and switch to it
RUN useradd -m appuser
USER appuser

# Expose port 5000 to leave ports 80 / 443 free for the Nginx reverse-proxy that will live on the host.
EXPOSE 5000

# Use Gunicorn as the production WSGI server.
# This assumes your Flask app is defined in "app.py"
# with the app instance named "app" (i.e. app = Flask(__name__))
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
