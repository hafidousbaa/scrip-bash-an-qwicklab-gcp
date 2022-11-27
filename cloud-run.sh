#! /bin/bash 

# hafidousbaa8@gmail.com

# enable the Cloud Run API
gcloud services enable run.googleapis.com

# Set the compute region

gcloud config set compute/region us-central1

# Create a LOCATION environment variable 

LOCATION="us-central1"

# create a new directory named helloworld and change directpry to it

mkdir helloworld && cd helloworld

# create a file json package on the helloworld directory

echo '{
  "name": "helloworld",
  "description": "Simple hello world sample in Node",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "author": "Google LLC",
  "license": "Apache-2.0",
  "dependencies": {
    "express": "^4.17.1"
  }
}'    > package.json

# create a file index on the same directory helloworl

echo 'const express = require('express');
const app = express();
const port = process.env.PORT || 8080;
app.get('/', (req, res) => {
  const name = process.env.NAME || 'World';
  res.send(`Hello ${name}!`);
});
app.listen(port, () => {
  console.log(`helloworld: listening on port ${port}`);
});'  > index.js 



# containerize the app that we just created 

echo '# Use the official lightweight Node.js 12 image.
# https://hub.docker.com/_/node
FROM node:12-slim
# Create and change to the app directory.
WORKDIR /usr/src/app
# Copy application dependency manifests to the container image.
# A wildcard is used to ensure copying both package.json AND package-lock.json (when available).
# Copying this first prevents re-running npm install on every code change.
COPY package*.json ./
# Install production dependencies.
# If you add a package-lock.json, speed your build by switching to 'npm ci'.
# RUN npm ci --only=production
RUN npm install --only=production
# Copy local code to the container image.
COPY . ./
# Run the web service on container startup.
CMD [ "npm", "start" ]'  >    Dockerfile 


# build container image using cloud build 

gcloud builds submit --tag gcr.io/$GOOGLE_CLOUD_PROJECT/helloworld

# list the container images 

gcloud container images list

# run and test the application locally

docker run -d -p 8080:8080 gcr.io/$GOOGLE_CLOUD_PROJECT/helloworld  

# check is the contaier running as we expected  

curl localhost:8000

# Deploying your containerized application to Cloud Run

gcloud run deploy --image gcr.io/$GOOGLE_CLOUD_PROJECT/helloworld --allow-unauthenticated --region=$LOCATION

# clean up
# delete helloworld image

gcloud container images -o delete gcr.io/$GOOGLE_CLOUD_PROJECT/helloworld 

# delete run service 

gcloud run services delete helloworld --region=us-central1