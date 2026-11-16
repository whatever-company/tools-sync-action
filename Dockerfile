FROM ghcr.io/astral-sh/uv:0.13.8-alpine@sha256:d436fa324e71ef7c8accd7902e893d18a19a0e3afb3ecf57626d696d982137e5 AS uv
SHELL ["/bin/sh", "-o", "pipefail", "-c"]

WORKDIR /app

ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy
ENV UV_FROZEN=1

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --no-install-project --no-dev

COPY --link . /app

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --no-dev

ENV PATH="/app/.venv/bin:$PATH"
ENTRYPOINT ["/app/dev-sync.py", "from_github", "to_zendesk", "to_slack"]
