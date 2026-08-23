FROM node:20-alpine AS base

# Stage 1: Install dependencies
FROM base AS deps
RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev > /dev/null 2>&1
WORKDIR /app

# Enable pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

COPY package.json pnpm-lock.yaml* package-lock.json* ./
RUN if [ -f pnpm-lock.yaml ]; then pnpm i --frozen-lockfile; \
    elif [ -f package-lock.json ]; then npm ci; \
    else npm install; fi

# Stage 2: Build Strapi app
FROM base AS builder
WORKDIR /app
RUN apk add --no-cache vips-dev
RUN corepack enable && corepack prepare pnpm@latest --activate

COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NODE_ENV=production
RUN if [ -f pnpm-lock.yaml ]; then pnpm run build; \
    else npm run build; fi

# Stage 3: Production runner
FROM base AS runner
WORKDIR /app

RUN apk add --no-cache vips-dev bash

ENV NODE_ENV=production

RUN addgroup --system --gid 1001 strapi
RUN adduser --system --uid 1001 strapi

COPY --from=builder --chown=strapi:strapi /app ./

USER strapi

EXPOSE 1337

ENV HOST=0.0.0.0
ENV PORT=1337

CMD ["npm", "run", "start"]
