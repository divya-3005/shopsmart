# Stage 1: Build foundations
FROM node:20-alpine AS builder
WORKDIR /app

# Copy package files
COPY client/package*.json ./client/
COPY server/package*.json ./server/

# Install all dependencies (including devDeps for build)
RUN cd client && npm install
RUN cd server && npm install

# Copy source code and build client
COPY . .
RUN cd client && npm run build

# Stage 2: Final Production Image
FROM node:20-alpine
WORKDIR /app

# Create non-root user for security
RUN addgroup -S shopsmart && adduser -S shopsmart -G shopsmart

# Copy built server and client from builder
COPY --from=builder /app/server ./server
COPY --from=builder /app/client/dist ./client/dist

# Install production dependencies only for server
RUN cd server && npm prune --production

# Set ownership to non-root user
RUN chown -R shopsmart:shopsmart /app

# Switch to non-root user
USER shopsmart

# Expose port
EXPOSE 5001

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5001/api/health || exit 1

# Start command
CMD ["npm", "start", "--prefix", "server"]
