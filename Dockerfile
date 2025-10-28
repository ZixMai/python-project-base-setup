FROM ghcr.io/astral-sh/uv:python3.14-alpine AS build

ENV PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

RUN apk add --no-cache \
    build-base \
    gfortran \
    linux-headers \
    openblas-dev \
    gcc \
    python3-dev \
    musl-dev

WORKDIR /app

COPY pyproject.toml uv.lock* ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev --no-group browser
RUN rm -rf /root/.cache /tmp/*


FROM python:3.14-alpine AS runtime

WORKDIR /app
COPY --from=build /app /app

RUN apk add --no-cache \
    libstdc++ \
    openblas

ENV VIRTUAL_ENV=/app/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

EXPOSE 8888

CMD ["python", "-m", "notebook", "--ip=0.0.0.0", "--no-browser", "--allow-root"]