FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim@sha256:dd20c7312c1b0f77a18cd9b0e88d238997d6faab99cc9abc43d006945716c505
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
