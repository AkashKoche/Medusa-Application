FROM node:20
WORKDIR /app
COPY package.json yarn.lock ./
RUN npm install
COPY . .
EXPOSE 8000
CMD ["npm", "run", "dev"]
