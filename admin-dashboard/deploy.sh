#!/bin/bash

echo "🚀 Deploying Refab Admin Dashboard..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm first."
    exit 1
fi

echo "📦 Installing dependencies..."
npm install

echo "🔧 Building the application..."
npm run build

echo "✅ Build completed successfully!"
echo ""
echo "🌐 To deploy:"
echo "1. Push to GitHub: git add . && git commit -m 'Deploy admin dashboard' && git push"
echo "2. Deploy to Vercel: npx vercel --prod"
echo "3. Or deploy to Netlify: npx netlify deploy --prod"
echo ""
echo "🔗 Local development: npm run dev" 