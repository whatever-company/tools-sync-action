FROM ghcr.io/astral-sh/uv:0.13.7-alpine@sha256:a788290ce829958f18bcea1dfd9fb5dcf4bfb22f6380b52c9322f9d91e86b117 AS uv
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
