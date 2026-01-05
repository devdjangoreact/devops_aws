# Staging Environment Configuration

# Networking Module
module "networking" {
  source = "../../modules/networking"

  security_group_name_prefix = "staging-ec2-sg-"
  security_group_name        = "staging-ec2-security-group"
  environment               = "staging"
}

# EC2 Instance Module
module "ec2_instance" {
  source = "../../modules/ec2-instance"

  instance_type     = var.instance_type
  instance_name     = "staging-migration-instance"
  environment      = "staging"
  security_group_id = module.networking.security_group_id
  user_data        = local.user_data_script
}

# User data script with Docker and applications
locals {
  user_data_script = <<-EOF
              #!/bin/bash
              set -e

              # Update system
              yum update -y

              # Install Docker
              amazon-linux-extras install docker -y
              systemctl enable docker
              systemctl start docker

              # Install Docker Compose
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose

              # Create application directories
              mkdir -p /home/ec2-user/web-app
              mkdir -p /home/ec2-user/symfony-app
              mkdir -p /home/ec2-user/angular-app

              # Create Docker Compose configuration
              cat > /home/ec2-user/web-app/docker-compose.yml << 'DOCKERCOMPOSE'
              version: '3.8'
              services:
                # Main web server (nginx)
                web:
                  image: nginx:alpine
                  container_name: hello-web
                  ports:
                    - "80:80"
                  restart: unless-stopped
                  volumes:
                    - ./nginx.conf:/etc/nginx/nginx.conf:ro
                  depends_on:
                    - symfony-api
                    - angular-app
                  environment:
                    - NGINX_PORT=80

                # Symfony API application (simple PHP web server)
                symfony-api:
                  image: php:8.1-cli-alpine
                  container_name: symfony-api
                  ports:
                    - "4444:8000"
                  restart: unless-stopped
                  working_dir: /var/www/html
                  volumes:
                    - ../symfony-app:/var/www/html:ro
                  command: php -S 0.0.0.0:8000 -t /var/www/html
                  environment:
                    - APP_ENV=dev

                # Angular4 application
                angular-app:
                  image: nginx:alpine
                  container_name: angular-app
                  ports:
                    - "5555:80"
                  restart: unless-stopped
                  volumes:
                    - ../angular-app:/usr/share/nginx/html:ro
                  environment:
                    - NGINX_PORT=80
              DOCKERCOMPOSE

              # Create Symfony API application
              cat > /home/ec2-user/symfony-app/index.php << 'PHPAPP'
              <?php
              // Simple Symfony-like API endpoint
              header('Content-Type: application/json');
              header('Access-Control-Allow-Origin: *');
              header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
              header('Access-Control-Allow-Headers: Content-Type');

              // Simple routing
              $request_uri = $_SERVER['REQUEST_URI'];
              $request_method = $_SERVER['REQUEST_METHOD'];

              switch ($request_uri) {
                  case '/api/health':
                      echo json_encode([
                          'status' => 'OK',
                          'message' => 'Symfony API is running',
                          'timestamp' => date('Y-m-d H:i:s'),
                          'version' => '1.0.0',
                          'environment' => 'staging'
                      ]);
                      break;

                  case '/api/users':
                      if ($request_method === 'GET') {
                          echo json_encode([
                              'users' => [
                                  ['id' => 1, 'name' => 'John Doe', 'email' => 'john@example.com'],
                                  ['id' => 2, 'name' => 'Jane Smith', 'email' => 'jane@example.com']
                              ]
                          ]);
                      } else {
                          http_response_code(405);
                          echo json_encode(['error' => 'Method not allowed']);
                      }
                      break;

                  default:
                      http_response_code(404);
                      echo json_encode([
                          'error' => 'Endpoint not found',
                          'available_endpoints' => [
                              '/api/health',
                              '/api/users'
                          ]
                      ]);
                      break;
              }
              PHPAPP

              # Create Angular4 application
              cat > /home/ec2-user/angular-app/index.html << 'HTMLAPP'
              <!DOCTYPE html>
              <html lang="en">
              <head>
                  <meta charset="UTF-8" />
                  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                  <title>Angular4 Migration App - Staging</title>
                  <style>
                    body {
                      font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
                      margin: 0;
                      padding: 20px;
                      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                      color: white;
                      min-height: 100vh;
                    }
                    .container {
                      max-width: 800px;
                      margin: 0 auto;
                      background: rgba(255, 255, 255, 0.1);
                      padding: 30px;
                      border-radius: 10px;
                      backdrop-filter: blur(10px);
                    }
                    h1 {
                      text-align: center;
                      margin-bottom: 30px;
                      font-size: 2.5em;
                    }
                    .status-card {
                      background: rgba(255, 255, 255, 0.2);
                      padding: 20px;
                      border-radius: 8px;
                      margin: 20px 0;
                      border-left: 4px solid #4CAF50;
                    }
                    .footer {
                      text-align: center;
                      margin-top: 30px;
                      opacity: 0.8;
                    }
                  </style>
              </head>
              <body>
                  <div class="container">
                      <h1>🚀 Angular4 Migration App - Staging</h1>

                      <div class="status-card">
                          <h3>✅ Application Status</h3>
                          <p><strong>Angular4 Frontend:</strong> Running on port 5555</p>
                          <p><strong>Symfony API Backend:</strong> Running on port 4444</p>
                          <p><strong>Main Web Server:</strong> Running on port 80</p>
                          <p><strong>Environment:</strong> Staging</p>
                          <p><strong>Timestamp:</strong> <span id="timestamp"></span></p>
                      </div>

                      <div class="status-card">
                          <h3>🔗 API Endpoints to Test:</h3>
                          <p>
                            •
                            <a
                              href="http://localhost:4444/api/health"
                              target="_blank"
                              style="color: #4caf50"
                              >API Health Check</a
                            >
                          </p>
                          <p>
                            •
                            <a
                              href="http://localhost:4444/api/users"
                              target="_blank"
                              style="color: #4caf50"
                              >Get Users</a
                            >
                          </p>
                          <p>
                            •
                            <a href="http://localhost:80" target="_blank" style="color: #4caf50"
                              >Main Web Server</a
                            >
                          </p>
                      </div>

                      <div class="footer">
                          <p>Angular4 Migration Environment - Staging Environment</p>
                          <p>Ready for version upgrades and compatibility testing</p>
                      </div>
                  </div>

                  <script>
                    // Update timestamp
                    document.getElementById("timestamp").textContent =
                      new Date().toLocaleString();

                    // Update timestamp every second
                    setInterval(() => {
                      document.getElementById("timestamp").textContent =
                        new Date().toLocaleString();
                    }, 1000);
                  </script>
              </body>
              </html>
              HTMLAPP

              # Create test script
              cat > /home/ec2-user/test-apps.sh << 'TESTSCRIPT'
              #!/bin/bash
              echo "=== Testing Application Startup ==="
              cd /home/ec2-user/web-app

              echo "Stopping any existing containers..."
              docker-compose down

              echo "Starting containers..."
              docker-compose up -d

              echo -e "\nWaiting 15 seconds for containers to start..."
              sleep 15

              echo -e "\n=== Container Status ==="
              docker-compose ps

              echo -e "\n=== Testing Applications ==="
              echo "Testing Symfony API (port 4444):"
              curl -s http://localhost:4444/api/health | head -3

              echo -e "\nTesting Angular4 App (port 5555):"
              curl -I http://localhost:5555 | head -3

              echo -e "\nTesting Main Web Server (port 80):"
              curl -I http://localhost:80 | head -3

              echo -e "\n=== Container Logs ==="
              echo "Symfony API logs:"
              docker-compose logs symfony-api

              echo -e "\nAngular4 app logs:"
              docker-compose logs angular-app

              echo -e "\nWeb server logs:"
              docker-compose logs web

              echo -e "\n=== Network Check ==="
              echo "Checking if ports are listening:"
              netstat -tlnp | grep -E "(4444|5555|80)"

              echo -e "\n=== Application Files Check ==="
              echo "Symfony app exists:"
              ls -la /home/ec2-user/symfony-app/

              echo -e "\nAngular4 app exists:"
              ls -la /home/ec2-user/angular-app/
              TESTSCRIPT

              chmod +x /home/ec2-user/test-apps.sh

              # Create startup script to ensure containers start
              cat > /home/ec2-user/start-containers.sh << 'STARTSCRIPT'
              #!/bin/bash
              echo "Starting application containers..."
              cd /home/ec2-user/web-app

              # Stop any existing containers
              docker-compose down

              # Start containers
              docker-compose up -d

              echo "Containers started. Waiting 10 seconds..."
              sleep 10

              # Check status
              docker-compose ps

              echo "Applications should be available at:"
              echo "Symfony API: http://localhost:4444"
              echo "Angular4 App: http://localhost:5555"
              echo "Main Web: http://localhost:80"
              STARTSCRIPT

              chmod +x /home/ec2-user/start-containers.sh

              # Run startup script
              /home/ec2-user/start-containers.sh

              # Set proper permissions
              chown -R ec2-user:ec2-user /home/ec2-user/
              EOF
}
