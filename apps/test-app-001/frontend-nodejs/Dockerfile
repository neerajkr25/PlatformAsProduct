# pic the base image 
FROM node:18-alpine

# create app directory
WORKDIR /usr/src/app

# copy package files
COPY package*.json ./

# install dependencies
RUN npm install

# copy source code
COPY . .

# Expose port
EXPOSE 3000

# start the app
CMD ["npm", "start" ]