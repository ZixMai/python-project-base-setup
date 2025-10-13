FROM ghcr.io/astral-sh/uv:python3.14-alpine AS app

ENV PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

COPY . /app

# Install the application dependencies.
WORKDIR /app
RUN apk add --no-cache \
    build-base \
    gfortran \
    linux-headers \
    openblas-dev \
    gcc \
    python3-dev \
    musl-dev

# Install dependencies
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev --no-cache

# Запуск: просто python main.py
ENTRYPOINT ["uv", "run", "python", "main.py"]