#!/bin/bash

# Название сервиса CrowdSec в вашем docker-compose.yml
CROWDSEC_CONTAINER="crowdsec"
# Имя баунсера, который мы создаем
BOUNCER_NAME="traefik-bouncer"
# Имя файла с переменными окружения
ENV_FILE=".env"

echo "Attempting to remove old bouncer key (if it exists)..."
# Подавляем вывод ошибки, если баунсер не найден
docker compose exec "$CROWDSEC_CONTAINER" cscli bouncers delete "$BOUNCER_NAME" > /dev/null 2>&1

echo "Generating new API key for bouncer '$BOUNCER_NAME'..."
# Выполняем команду и сохраняем ее вывод в переменную
output=$(docker compose exec "$CROWDSEC_CONTAINER" cscli bouncers add "$BOUNCER_NAME")

# Извлекаем API ключ из вывода с помощью grep и регулярного выражения
# \K сбрасывает начало совпадения, поэтому выводится только сам ключ
api_key=$(echo "$output" | grep -oP "Api key for .*:\s*\K[a-zA-Z0-9]+")

# Проверяем, удалось ли извлечь ключ
if [ -z "$api_key" ]; then
  echo "Error: Could not extract API key."
  echo "Full command output:"
  echo "$output"
  exit 1
fi

echo "API Key successfully extracted."

# Проверяем, существует ли .env файл
if [ ! -f "$ENV_FILE" ]; then
  echo "Creating $ENV_FILE file..."
  touch "$ENV_FILE"
fi

# Проверяем, есть ли уже CROWDSEC_BOUNCER_KEY в .env файле
if grep -q "^CROWDSEC_BOUNCER_KEY=" "$ENV_FILE"; then
  # Если есть, заменяем значение
  sed -i "s|^CROWDSEC_BOUNCER_KEY=.*|CROWDSEC_BOUNCER_KEY=$api_key|" "$ENV_FILE"
  echo "Updated CROWDSEC_BOUNCER_KEY in $ENV_FILE."
else
  # Если нет, добавляем в конец файла
  echo "" >> "$ENV_FILE" # Добавляем пустую строку для красоты
  echo "CROWDSEC_BOUNCER_KEY=$api_key" >> "$ENV_FILE"
  echo "Added CROWDSEC_BOUNCER_KEY to $ENV_FILE."
fi

echo "Script finished successfully."
