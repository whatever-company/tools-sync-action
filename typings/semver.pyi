from typing import NamedTuple

class Version(NamedTuple):
    major: int
    minor: int
    patch: int
    prerelease: str | None
    build: str | None

def parse_version_info(version: str) -> Version: ...
