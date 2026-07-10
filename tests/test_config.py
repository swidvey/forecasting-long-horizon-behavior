"""Tests for forecasting.config -- the horizons partition logic."""

from pathlib import Path

import pytest
from pydantic import ValidationError

from forecasting.config import HorizonsConfig, load_horizons

REPO_ROOT = Path(__file__).resolve().parents[1]


def _cfg(buckets: list[dict[str, object]], max_days: int = 180) -> dict[str, object]:
    return {"max_horizon_days": max_days, "buckets": buckets}


class TestLoadRealConfig:
    def test_repo_config_is_valid(self) -> None:
        cfg = load_horizons(REPO_ROOT / "configs" / "horizons.yaml")
        assert cfg.max_horizon_days == 180
        assert [b.name for b in cfg.buckets] == ["H1", "H2", "H3", "H4"]

    def test_default_path_resolves(self) -> None:
        cfg = load_horizons()
        assert cfg.max_horizon_days == 180


class TestPartitionValidation:
    def test_gap_between_buckets_rejected(self) -> None:
        buckets = [
            {"name": "H1", "start_day": 1, "end_day": 7},
            {"name": "H2", "start_day": 9, "end_day": 180},  # gap: day 8
        ]
        with pytest.raises(ValidationError, match="contiguous"):
            HorizonsConfig.model_validate(_cfg(buckets))

    def test_overlap_rejected(self) -> None:
        buckets = [
            {"name": "H1", "start_day": 1, "end_day": 7},
            {"name": "H2", "start_day": 7, "end_day": 180},  # overlap: day 7
        ]
        with pytest.raises(ValidationError, match="contiguous"):
            HorizonsConfig.model_validate(_cfg(buckets))

    def test_short_partition_rejected(self) -> None:
        buckets = [{"name": "H1", "start_day": 1, "end_day": 90}]
        with pytest.raises(ValidationError, match="max_horizon_days"):
            HorizonsConfig.model_validate(_cfg(buckets))

    def test_inverted_bucket_rejected(self) -> None:
        buckets = [{"name": "H1", "start_day": 7, "end_day": 1}]
        with pytest.raises(ValidationError):
            HorizonsConfig.model_validate(_cfg(buckets))


class TestBucketFor:
    @pytest.fixture
    def cfg(self) -> HorizonsConfig:
        return load_horizons(REPO_ROOT / "configs" / "horizons.yaml")

    @pytest.mark.parametrize(
        ("day", "expected"),
        [
            (1, "H1"),
            (7, "H1"),
            (8, "H2"),
            (30, "H2"),
            (31, "H3"),
            (90, "H3"),
            (91, "H4"),
            (180, "H4"),
        ],
    )
    def test_boundaries(self, cfg: HorizonsConfig, day: int, expected: str) -> None:
        assert cfg.bucket_for(day).name == expected

    @pytest.mark.parametrize("day", [0, 181, -5])
    def test_out_of_range_raises(self, cfg: HorizonsConfig, day: int) -> None:
        with pytest.raises(ValueError, match="outside"):
            cfg.bucket_for(day)
