# SoleSociety Backend API

Node.js/Express backend server that uses the `sneaks-api` npm package to provide sneaker data to the SoleSociety iOS app.

Must be ran out of the root directory for it to work properly

## Quick Start

### Prerequisites
- Node.js 14.0 or higher
- npm or yarn

### Installation

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Start the server:
```bash
npm start
```

The server will run on `http://localhost:3000`

### Development Mode

For auto-restart on file changes:
```bash
npm run dev
```

## API Endpoints

### 1. Health Check
```
GET /
```

**Response:**
```json
{
  "message": "SoleSociety API Server",
  "status": "running",
  "version": "1.0.0"
}
```

### 2. Get Most Popular Sneakers
```
GET /api/popular?limit=10
```

**Parameters:**
- `limit` (optional): Number of sneakers to return (default: 10)

**Response:** Array of sneaker objects

### 3. Search Sneakers
```
GET /api/products?keyword=yeezy&limit=10
```

**Parameters:**
- `keyword` (required): Search keyword
- `limit` (optional): Number of results (default: 10)

**Response:** Array of sneaker objects

### 4. Get Product Details
```
GET /api/product/:styleId
```

**Parameters:**
- `styleId` (required): Sneaker style ID (e.g., "FY2903")

**Response:** Detailed sneaker object with prices and images

## Testing the API

### Using curl

```bash
# Test health check
curl http://localhost:3000/

# Get popular sneakers
curl http://localhost:3000/api/popular?limit=5

# Search for sneakers
curl "http://localhost:3000/api/products?keyword=yeezy&limit=5"

# Get product details
curl http://localhost:3000/api/product/FY2903
```

### Using a browser

Simply navigate to:
- http://localhost:3000/api/popular
- http://localhost:3000/api/products?keyword=yeezy
- http://localhost:3000/api/product/FY2903

## Connecting to iOS App

### For Local Testing

1. Make sure your backend server is running
2. Find your computer's IP address:
   - Mac: System Preferences → Network
   - Windows: `ipconfig` in Command Prompt
   - Look for something like `192.168.1.x`

3. In Xcode, update `Services/SneakAPIService.swift`:
```swift
private let baseURL = "http://YOUR_IP_ADDRESS:3000/api"
// Example: "http://192.168.1.100:3000/api"
```

4. Make sure your iPhone/simulator is on the same network

### For iOS Simulator

The simulator can access localhost:
```swift
private let baseURL = "http://localhost:3000/api"
```

### For Production

Deploy your backend to a hosting service:

#### Option 1: Heroku
```bash
# Install Heroku CLI, then:
heroku create your-app-name
git push heroku main
```

Then update the iOS app:
```swift
private let baseURL = "https://your-app-name.herokuapp.com/api"
```

#### Option 2: Railway
```bash
# Connect to Railway and deploy
# Update iOS app with the provided URL
```

#### Option 3: Render
- Push your code to GitHub
- Connect to Render
- Deploy and get your URL

## Environment Variables

For production, create a `.env` file:

```env
PORT=3000
NODE_ENV=production
```

Update `server.js` to use environment variables:
```javascript
require('dotenv').config();
const PORT = process.env.PORT || 3000;
```

Install dotenv:
```bash
npm install dotenv
```

## Troubleshooting

### Port already in use
```bash
# Find process using port 3000
lsof -i :3000

# Kill the process
kill -9 <PID>
```

### CORS errors from iOS app
Make sure the `cors` middleware is enabled in `server.js`.

### API returns empty data
The sneaks-api scrapes websites, so responses may be slow or occasionally fail. Add retry logic if needed.

## Project Structure

```
backend/
├── server.js          # Main server file
├── package.json       # Dependencies and scripts
├── .gitignore        # Git ignore rules
└── README.md         # This file
```

## Dependencies

- **express**: Web framework
- **cors**: Enable CORS for iOS app requests
- **sneaks-api**: Sneaker data from StockX, GOAT, etc.

## License

MIT

