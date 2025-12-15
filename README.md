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
# 1. Спочатку зберіть образ (якщо ще не зібрано)
docker build -t simple-app:latest .

# 2. Перевірте наявні образи (опціонально)
docker images | grep simple-app

# 3. Перетегуйте образ для Docker Hub
# Формат: docker tag <локальний-образ> <username>/<repository>:<tag>
# Приклад: docker tag simple-app:latest rudjuk/docker_work3_rudiuk:latest
docker tag simple-app:latest your-username/simple-app:latest

# 4. Перевірте, що новий тег створився
docker images | grep your-username

# 5. Увійдіть в Docker Hub
docker login

# 6. Публікація образу
docker push your-username/simple-app:latest

# Запуск з реєстру
docker run -d -p 8080:8080 --name simple-app your-username/simple-app:latest
```

**Важливо:** 
- Перед `docker push` переконайтеся, що образ з потрібним тегом існує локально
- Якщо ви отримуєте помилку **"tag does not exist"**, це означає, що образ з таким тегом не існує локально
- **Рішення:** Спочатку виконайте `docker tag <існуючий-образ> <новий-тег>` або `docker build -t <новий-тег> .`
- Використовуйте конкретні теги замість загальних (наприклад, `v1.0`, `latest` замість `tagname`)

## Завантаження образу з Docker Hub

Після публікації образу в Docker Hub, ви або інші користувачі можете завантажити його на будь-який комп'ютер:

```bash
# Завантаження опублікованого образу
# Формат: docker pull <username>/<repository>:<tag>
# Приклад: docker pull rudjuk/docker_work3_rudiuk:tagname
docker pull your-username/simple-app:latest

# Перевірка, що образ завантажився
docker images | grep your-username

# Запуск завантаженого образу
docker run -d -p 8080:8080 --name simple-app your-username/simple-app:latest

# Або якщо образ вже опублікований, можна запустити безпосередньо без pull
# Docker автоматично завантажить образ, якщо його немає локально
docker run -d -p 8080:8080 --name simple-app your-username/simple-app:latest
```

**Примітка:** Якщо репозиторій публічний, `docker pull` працює без логіну. Для приватних репозиторіїв спочатку виконайте `docker login`.

