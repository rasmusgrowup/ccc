# Use the official Node.js image as a base image
FROM --platform=linux/amd64 node:16-slim

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the application files
COPY . .

# Expose the application port
EXPOSE 8080

# Start the application
CMD ["node", "app.js"]