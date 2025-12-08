ARG PYTHON_VERSION=3.12
ARG UV_VERSION=latest

FROM chainguard/wolfi-base:latest AS base
ARG PYTHON_VERSION
RUN apk add --no-cache python-${PYTHON_VERSION}
ARG WORKDIR=/app
ENV PATH="${WORKDIR}/.venv/bin:${PATH}"
WORKDIR ${WORKDIR}

FROM astral/uv:${UV_VERSION} AS uv_binary

FROM base AS builder
ARG UV_LINK_MODE=copy
ARG UV_PYTHON_DOWNLOADS=0
RUN --mount=from=uv_binary,source=/uv,target=/bin/uv \
    --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=./app/uv.lock,target=uv.lock \
    --mount=type=bind,source=./app/pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-editable --no-dev --compile-bytecode
COPY ./app .

FROM base AS final
COPY --from=builder ${WORKDIR} .
USER 999:999
CMD [ "gunicorn" ]
