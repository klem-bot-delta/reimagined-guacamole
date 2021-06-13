FROM node:latest

RUN apt-get update && apt-get install yarn -y

ADD . app/

WORKDIR /app

RUN yarn install --prod