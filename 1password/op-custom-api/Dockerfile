ARG PYTHON_VERSION=3.12
ARG UV_VERSION=latest

FROM chainguard/wolfi-base:latest AS base
ARG PYTHON_VERSION
RUN apk add --no-cache python-${PYTHON_VERSION}
ARG WORKDIR=/app
WORKDIR ${WORKDIR}

FROM astral/uv:${UV_VERSION} AS uv_binary

FROM base AS builder
ARG UV_LINK_MODE=copy
COPY ./app .
RUN --mount=from=uv_binary,source=/uv,target=/bin/uv \
    --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-editable --no-dev --compile-bytecode

FROM base AS final
COPY --from=builder ${WORKDIR} .
USER 999:999
CMD [ "gunicorn", "--bind", "0.0.0.0:5000", "--reload", "app.wsgi:app" ]
