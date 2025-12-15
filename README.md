# Docker Homework - Simple App

Dockerfile та конфігурація для збірки simple-app застосунку.

## Docker Build

```bash
# Збірка образу з кореня проекту
docker build -t simple-app:latest .

# Запуск контейнера (в фоні)
docker run -d -p 8080:8080 --name simple-app simple-app:latest

# Або запуск в інтерактивному режимі
docker run -p 8080:8080 simple-app:latest

# Якщо порт 8080 зайнятий, використайте інший порт
docker run -d -p 8081:8080 --name simple-app simple-app:latest
```

**Примітка:** Якщо порт 8080 вже зайнятий іншим контейнером, використайте інший порт (наприклад, 8081) або зупиніть контейнер, який використовує порт 8080.

**Корисні команди:**
```bash
# Перевірити, чи працює контейнер
docker ps | grep simple-app

# Переглянути логи
docker logs simple-app

# Зупинити контейнер
docker stop simple-app

# Видалити контейнер
docker rm simple-app
```

## Структура Dockerfile

Dockerfile використовує **multi-stage build** для оптимізації розміру образу.

### Stage 1: Builder
- Базовий образ: `golang:1.23-alpine`
- Призначення: компіляція Go додатку
- Копіює файли з `app/simple-app/` та компілює бінарник

### Stage 2: Runtime
- Базовий образ: `alpine:latest`
- Призначення: мінімальний runtime для запуску додатку
- Містить тільки скомпільований бінарник

## Multi-Stage Build Explanation

**Як multi-stage зменшив розмір образу:**

1. **Builder stage (golang:1.23-alpine)**: Використовується тільки для компіляції. Містить повний Go toolchain (~300-400MB), компілятор, залежності для збірки.

2. **Runtime stage (alpine:latest)**: Містить тільки мінімальний Alpine Linux (~5MB) + скомпільований бінарник (~10-15MB).

**Результат:**
- Без multi-stage: образ міг би бути ~300-400MB (golang:1.23-alpine з усіма інструментами)
- З multi-stage: фінальний образ ~48.9MB (тільки Alpine + бінарник + ca-certificates)

**Переваги:**
- Менший розмір образу = швидше завантаження та деплой
- Менша поверхня атаки (немає компілятора та інструментів розробки)
- Швидший старт контейнера
- Економія ресурсів при зберіганні та передачі образів

## Особливості реалізації

- ✅ Базовий актуальний образ (golang:1.23-alpine, alpine:latest)
- ✅ Multi-stage build (окремі етапи для залежностей/рантайму)
- ✅ Встановлення залежностей через `go mod download`
- ✅ Запуск під нерут-користувачем (appuser, UID 1000)
- ✅ Порт 8080 відкритий назовні (EXPOSE 8080)
- ✅ Статична збірка (CGO_ENABLED=0) для мінімального образу

## Публікація в реєстр (опціонально)

```bash
# Тегування образу
docker tag simple-app:latest your-username/simple-app:latest

# Логін в Docker Hub
docker login

# Публікація
docker push your-username/simple-app:latest

# Запуск з реєстру
docker run -d -p 8080:8080 --name simple-app your-username/simple-app:latest
```

