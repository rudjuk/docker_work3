# Stage 1: Build stage - для компіляції та встановлення залежностей
FROM golang:1.23-alpine AS builder

# Встановлюємо робочу директорію
WORKDIR /build

# Копіюємо файли залежностей з app/simple-app
COPY app/simple-app/go.mod app/simple-app/go.sum ./

# Завантажуємо залежності (кешується окремо від коду)
RUN go mod download

# Копіюємо вихідний код з app/simple-app
COPY app/simple-app/ .

# Компілюємо додаток (статична збірка для Alpine)
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# Stage 2: Runtime stage - мінімальний образ для запуску
FROM alpine:latest

# Встановлюємо ca-certificates для HTTPS запитів (якщо потрібно)
RUN apk --no-cache add ca-certificates

# Створюємо нерут-користувача
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser

# Встановлюємо робочу директорію
WORKDIR /app

# Копіюємо скомпільований бінарник з builder stage
COPY --from=builder /build/app .

# Змінюємо власника файлів на нерут-користувача
RUN chown -R appuser:appuser /app

# Перемикаємось на нерут-користувача
USER appuser

# Відкриваємо порт 8080
EXPOSE 8080

# Запускаємо додаток
CMD ["./app"]

