ARG TARGET_ENV=production
FROM node:12-alpine AS base
ARG NPM_TOKEN

USER node

ENV HOME=/home/node
ENV NPM_CONFIG_PREFIX=$HOME/.npm-global
ENV PATH=$PATH:$HOME/.npm-global/bin
ENV APP_HOME=$HOME/app

RUN mkdir $APP_HOME
RUN mkdir -p $APP_HOME/dist
RUN mkdir -p $APP_HOME/node_modules
WORKDIR $APP_HOME

# copy both 'package.json' and 'package-lock.json' (if available)
COPY --chown=node package*.json yarn.lock ./
RUN yarn

#Development Branch - Mount source as volume and set command to watch files
FROM base AS build-development
ENV NODE_ENV=development
CMD yarn watch-build

#Production Branch - Copy source to container, build it and set command to start the server.
FROM base AS build-production
ENV NODE_ENV=production
COPY --chown=node . $APP_HOME
RUN yarn build
RUN yarn test

FROM build-$TARGET_ENV