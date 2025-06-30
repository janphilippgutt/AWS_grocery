# Use the official lightweight Python base image
FROM python:3.9-slim

# Set environment variables (optional but good practice)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set the working directory inside the container
WORKDIR /app

# Copy only requirements first for better caching during builds
COPY requirements.txt .

# Install dependencies (avoid cache + install build tools if needed)
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Now copy the rest of the application files
COPY . .

# Optional: make the container explicitly expose your app port (e.g. 3000 or 5000)
EXPOSE 5000

# Use CMD to run your app
CMD ["python", "run.py"]
