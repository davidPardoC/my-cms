# Etapa de build: compila Strapi
FROM node:22-alpine AS build
RUN apk add --no-cache python3 make g++ vips-dev git
WORKDIR /opt/app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .
RUN yarn build

# Etapa final: runtime optimizado
FROM node:22-alpine

# Instala vips (para sharp) y su-exec (para bajar privilegios)
RUN apk add --no-cache vips su-exec

ENV NODE_ENV=production
ENV HOST=0.0.0.0

WORKDIR /opt/app
COPY --from=build /opt/app ./

# Copiamos el entrypoint
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# No definimos USER aquí; el entrypoint se encargará
EXPOSE 1337

ENTRYPOINT ["/entrypoint.sh"]
CMD ["yarn", "start"]
