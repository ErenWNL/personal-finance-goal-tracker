#!/usr/bin/env node

const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🚀 Personal Finance Frontend Test Script\n');

// Check if we're in the frontend directory
const currentDir = process.cwd();
const packageJsonPath = path.join(currentDir, 'package.json');

if (!fs.existsSync(packageJsonPath)) {
  console.error('❌ Error: package.json not found. Please run this script from the frontend directory.');
  process.exit(1);
}

// Check if node_modules exists
const nodeModulesPath = path.join(currentDir, 'node_modules');
if (!fs.existsSync(nodeModulesPath)) {
  console.log('📦 Installing dependencies...');
  exec('npm install', (error, stdout, stderr) => {
    if (error) {
      console.error('❌ Error installing dependencies:', error);
      return;
    }
    console.log('✅ Dependencies installed successfully!');
    startFrontend();
  });
} else {
  startFrontend();
}

function startFrontend() {
  console.log('🎯 Starting React development server...');
  console.log('📍 Frontend will be available at: http://localhost:3000');
  console.log('🔑 Guest Login Credentials:');
  console.log('   📧 Email: arya@gmail.com');
  console.log('   🔒 Password: arya@123');
  console.log('\n⏳ Starting server (this may take a moment)...\n');

  const child = exec('npm start', (error, stdout, stderr) => {
    if (error) {
      console.error('❌ Error starting frontend:', error);
      return;
    }
  });

  child.stdout.on('data', (data) => {
    console.log(data);
  });

  child.stderr.on('data', (data) => {
    console.error(data);
  });

  // Handle Ctrl+C
  process.on('SIGINT', () => {
    console.log('\n🛑 Stopping frontend server...');
    child.kill('SIGINT');
    process.exit(0);
  });
}

console.log('📋 Testing Instructions:');
console.log('1. Wait for "webpack compiled successfully" message');
console.log('2. Open http://localhost:3000 in your browser');
console.log('3. Click "Login as Guest" button for quick access');
console.log('4. Explore: Dashboard → Goals → Transactions → Insights → Profile');
console.log('5. Test responsive design by resizing browser window');
console.log('\n🔧 Troubleshooting:');
console.log('- If login fails: Backend services may not be running');
console.log('- If charts are empty: This is normal without backend data');
console.log('- If styles look broken: Try refreshing the page');
console.log('\n🎉 Happy Testing!\n');
