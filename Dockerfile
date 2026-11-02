FROM ghcr.io/astral-sh/uv:0.13.6-alpine@sha256:95f501aef734a5aaf167ff0640e02f215dcc7043ff48685de70328e5c55a57b0 AS uv
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
