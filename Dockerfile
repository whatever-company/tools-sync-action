FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim@sha256:5c8edeb8b5644b618882e06ddaa8ddf509dcd1aa7d08fedac7155106116a9a9e
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /app

ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

COPY . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

ENV PATH="/app/.venv/bin:$PATH"
ENTRYPOINT ["/app/dev-sync.py", "from_github", "to_zendesk", "to_slack"]
