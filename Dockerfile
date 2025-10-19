FROM ghcr.io/astral-sh/uv:python3.14-alpine AS app

ENV PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

# Install the application dependencies.
RUN apk add --no-cache \
    build-base \
    gfortran \
    linux-headers \
    openblas-dev \
    gcc \
    python3-dev \
    musl-dev

WORKDIR /app

# Install dependencies
COPY pyproject.toml uv.lock* ./
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev --no-cache

COPY . .
EXPOSE 8888
CMD ["uv", "run", "jupyter-notebook", "--ip=0.0.0.0", "--no-browser", "--allow-root"]