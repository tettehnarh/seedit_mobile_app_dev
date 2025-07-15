#!/bin/bash

# SeedIt Development Servers Startup Script
echo "🚀 Starting SeedIt Development Environment..."

# Function to check if a port is in use
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null ; then
        echo "⚠️  Port $1 is already in use"
        return 1
    else
        return 0
    fi
}

# Function to start a service in the background
start_service() {
    local service_name=$1
    local command=$2
    local port=$3
    
    echo "📦 Starting $service_name on port $port..."
    
    if check_port $port; then
        eval $command &
        local pid=$!
        echo "✅ $service_name started with PID $pid"
        echo $pid > ".${service_name,,}_pid"
    else
        echo "❌ Cannot start $service_name - port $port is in use"
    fi
}

# Create logs directory
mkdir -p logs

# Start Next.js Web Application
echo ""
echo "🌐 Starting Next.js Web Application..."
cd seedit_web_app
if [ -f "package.json" ]; then
    start_service "NextJS" "npm run dev > ../logs/nextjs.log 2>&1" 3000
else
    echo "❌ Next.js package.json not found"
fi
cd ..

# Start Flutter Mobile Application (if on macOS with iOS Simulator)
echo ""
echo "📱 Starting Flutter Mobile Application..."
cd seedit_mobile_app
if [ -f "pubspec.yaml" ]; then
    if command -v flutter &> /dev/null; then
        echo "📦 Starting Flutter app in debug mode..."
        flutter run --debug > ../logs/flutter.log 2>&1 &
        local flutter_pid=$!
        echo "✅ Flutter app started with PID $flutter_pid"
        echo $flutter_pid > "../.flutter_pid"
    else
        echo "❌ Flutter CLI not found"
    fi
else
    echo "❌ Flutter pubspec.yaml not found"
fi
cd ..

# Start Amplify Backend (if configured)
echo ""
echo "☁️  Starting AWS Amplify Backend..."
if command -v amplify &> /dev/null; then
    echo "📦 Starting Amplify sandbox..."
    amplify sandbox > logs/amplify.log 2>&1 &
    local amplify_pid=$!
    echo "✅ Amplify sandbox started with PID $amplify_pid"
    echo $amplify_pid > ".amplify_pid"
else
    echo "❌ Amplify CLI not found"
fi

echo ""
echo "🎉 Development environment startup complete!"
echo ""
echo "📋 Services Status:"
echo "   🌐 Next.js Web App: http://localhost:3000"
echo "   📱 Flutter Mobile App: Check simulator/device"
echo "   ☁️  Amplify Backend: Check logs/amplify.log"
echo ""
echo "📝 Logs are available in the 'logs' directory"
echo "🛑 To stop all services, run: ./stop-dev-servers.sh"
echo ""

# Create stop script
cat > stop-dev-servers.sh << 'EOF'
#!/bin/bash

echo "🛑 Stopping SeedIt Development Environment..."

# Function to stop a service
stop_service() {
    local service_name=$1
    local pid_file=".${service_name,,}_pid"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 $pid 2>/dev/null; then
            echo "🛑 Stopping $service_name (PID: $pid)..."
            kill $pid
            rm "$pid_file"
            echo "✅ $service_name stopped"
        else
            echo "⚠️  $service_name process not found"
            rm "$pid_file"
        fi
    else
        echo "⚠️  No PID file found for $service_name"
    fi
}

# Stop all services
stop_service "NextJS"
stop_service "Flutter"
stop_service "Amplify"

# Kill any remaining processes on development ports
echo "🧹 Cleaning up remaining processes..."
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:3001 | xargs kill -9 2>/dev/null || true

echo "✅ All development services stopped"
EOF

chmod +x stop-dev-servers.sh

echo "📄 Created stop-dev-servers.sh script"
