# =========================
# 1. Сборка фронтенда
# =========================
FROM node:20-alpine AS build

# Рабочая директория внутри контейнера
WORKDIR /app

# Копируем только package* для кэша установок
COPY package.json package-lock.json* ./

# Устанавливаем зависимости
RUN npm ci

# Копируем остальной код
COPY . .

# Сборка Vite-приложения
RUN npm run build


# =========================
# 2. nginx для отдачи статики
# =========================
FROM nginx:1.27-alpine

# Удаляем дефолтный конфиг nginx
RUN rm /etc/nginx/conf.d/default.conf

# Кладём наш конфиг (SPA + fallback на index.html)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Кладём собранную статику из первого слоя
COPY --from=build /app/dist /usr/share/nginx/html

# nginx слушает 80 порт
EXPOSE 80

# Запуск nginx в foreground
CMD ["nginx", "-g", "daemon off;"]