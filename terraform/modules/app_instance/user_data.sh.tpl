#!/bin/bash
# Update and install Docker + PostgreSQL client
apt-get update -y
apt-get install -y docker.io git postgresql-client

# Clone the app repo
#git clone "${app_repo_url}" /app
cd /home/ubuntu
git clone "https://github.com/janphilippgutt/AWS_grocery.git"

# Write .env file from Terraform template
cat <<EOF > /home/ubuntu/AWS_grocery/backend/.env
${env_file_content}
EOF

chmod 600 /home/ubuntu/AWS_grocery/backend/.env

# Allow ubuntu user to use Docker
usermod -aG docker ubuntu
systemctl start docker

# Build the Docker image
cd /home/ubuntu/AWS_grocery/backend
docker build -t grocery-app .

# Wait for RDS to become available (retry psql)
for i in {1..10}; do
  echo "Checking DB availability..."
  PGPASSWORD=${db_password} psql -h ${db_host} -U ${db_user} -d ${db_name} -c '\q' && break
  echo "DB not ready yet. Sleeping..."
  sleep 10
done

# Run the SQL initialization script
PGPASSWORD=${db_password} psql -h ${db_host} -U ${db_user} -d ${db_name} -f /home/ubuntu/AWS_grocery/backend/app/sqlite_dump_clean.sql

# Start the app container
sudo docker run -d \
  -p 5000:5000 \
  --env-file /home/ubuntu/AWS_grocery/backend/.env \
  -w /app \
  grocery-app



