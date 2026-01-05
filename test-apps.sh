#!/bin/bash
# Test script to verify all applications are running
# Run this after SSH into the EC2 instance

echo "=== Testing Application Startup ==="

echo "Checking Docker containers..."
cd /home/ec2-user/web-app

echo "Starting containers..."
docker-compose up -d

echo -e "\nWaiting 10 seconds for containers to start..."
sleep 10

echo -e "\n=== Container Status ==="
docker-compose ps

echo -e "\n=== Testing Applications ==="

echo "Testing Symfony API (port 4444):"
curl -s http://localhost:4444/api/health | head -3

echo -e "\nTesting Angular4 App (port 5555):"
curl -I http://localhost:5555 | head -3

echo -e "\nTesting Main Web Server (port 80):"
curl -I http://localhost:80 | head -3

echo -e "\n=== Container Logs (last 5 lines each) ==="
echo "Symfony API logs:"
docker-compose logs symfony-api | tail -5

echo -e "\nAngular4 app logs:"
docker-compose logs angular-app | tail -5

echo -e "\nWeb server logs:"
docker-compose logs web | tail -5

echo -e "\n=== Application Files Check ==="
echo "Symfony app files:"
ls -la /home/ec2-user/symfony-app/

echo -e "\nAngular4 app files:"
ls -la /home/ec2-user/angular-app/

echo -e "\nDocker Compose file:"
ls -la /home/ec2-user/web-app/docker-compose.yml
