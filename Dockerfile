FROM node:20-alpine

WORKDIR /app

# Copy package.json files for both client and server first
COPY client/package*.json ./client/
COPY server/package*.json ./server/

# Install dependencies for both
RUN cd client && npm install
RUN cd server && npm install

# Copy all source code
COPY . .

# Expose port 5001
EXPOSE 5001

# Start the server by default (docker-compose will override for dev)
CMD ["npm", "start", "--prefix", "server"]
