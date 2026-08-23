FROM node:20-alpine AS base

# Stage 1: Install build dependencies (includes devDependencies for TS & Strapi build)
FROM base AS deps
RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev > /dev/null 2>&1
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci && npm cache clean --force

# Stage 2: Build Strapi application
FROM base AS builder
WORKDIR /app
RUN apk add --no-cache vips-dev

COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NODE_ENV=production
RUN npm run build

# Stage 3: Production dependencies only
FROM base AS prod-deps
WORKDIR /app
RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev > /dev/null 2>&1

COPY package.json package-lock.json* ./
RUN npm ci --omit=dev --ignore-scripts && npm cache clean --force

# Stage 4: Production runner
FROM base AS runner
WORKDIR /app

RUN apk add --no-cache vips-dev bash

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=1337

RUN addgroup --system --gid 1001 strapi && \
    adduser --system --uid 1001 strapi

# Copy production node_modules and compiled output
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/public ./public
COPY --from=builder /app/config ./config
COPY --from=builder /app/database ./database
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./package.json

RUN chown -R strapi:strapi /app

USER strapi

EXPOSE 1337

CMD ["npm", "run", "start"]
