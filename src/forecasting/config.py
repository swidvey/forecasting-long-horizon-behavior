"""Config loading and validation.

Rule (CLAUDE.md): config is data. Everything tunable lives in ``configs/*.yaml``
and is validated here with pydantic before any code consumes it. No magic
constants in code.
"""

from pathlib import Path
from typing import Self

import yaml
from pydantic import BaseModel, Field, model_validator

# Repo root when running from a source checkout; components running in
# containers pass explicit paths instead of relying on this.
DEFAULT_CONFIG_DIR = Path(__file__).resolve().parents[2] / "configs"


class HorizonBucket(BaseModel):
    """A contiguous, inclusive range of forecast horizon days, e.g. H2 = days 8-30."""

    name: str
    start_day: int = Field(ge=1)
    end_day: int = Field(ge=1)

    @model_validator(mode="after")
    def _start_not_after_end(self) -> Self:
        if self.start_day > self.end_day:
            raise ValueError(
                f"bucket {self.name!r}: start_day {self.start_day} > end_day {self.end_day}"
            )
        return self


class HorizonsConfig(BaseModel):
    """The evaluation horizon structure: max horizon plus its bucket partition.

    Buckets must exactly partition days ``1..max_horizon_days`` in order --
    no gaps, no overlaps. Champion selection is per (series, bucket), so a
    malformed partition would silently corrupt everything downstream; we
    fail loudly here instead.
    """

    max_horizon_days: int = Field(ge=1)
    buckets: list[HorizonBucket] = Field(min_length=1)

    @model_validator(mode="after")
    def _buckets_partition_horizon(self) -> Self:
        expected_start = 1
        for bucket in self.buckets:
            if bucket.start_day != expected_start:
                raise ValueError(
                    f"bucket {bucket.name!r} starts at day {bucket.start_day}, "
                    f"expected {expected_start} (buckets must be contiguous from day 1)"
                )
            expected_start = bucket.end_day + 1
        last_end = self.buckets[-1].end_day
        if last_end != self.max_horizon_days:
            raise ValueError(
                f"last bucket ends at day {last_end}, expected max_horizon_days "
                f"({self.max_horizon_days})"
            )
        return self

    def bucket_for(self, horizon_days: int) -> HorizonBucket:
        """Return the bucket containing ``horizon_days`` (1-based days ahead)."""
        for bucket in self.buckets:
            if bucket.start_day <= horizon_days <= bucket.end_day:
                return bucket
        raise ValueError(f"horizon_days {horizon_days} outside 1..{self.max_horizon_days}")


def load_horizons(path: Path | None = None) -> HorizonsConfig:
    """Load and validate the horizons config from YAML."""
    resolved = path if path is not None else DEFAULT_CONFIG_DIR / "horizons.yaml"
    with resolved.open(encoding="utf-8") as fh:
        raw = yaml.safe_load(fh)
    return HorizonsConfig.model_validate(raw)
