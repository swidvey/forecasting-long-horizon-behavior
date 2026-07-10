# forecasting-long-horizon-behavior
End-to-end forecasting system on GCP: multi-model champion selection, digital-twin cold starts, and long-horizon forecasts scored live against reality.

## Development

Python 3.11+. Dependencies are declared once in `pyproject.toml` and locked with
hashes under `requirements/` (compiled by pip-tools; recompile commands are in
`requirements/requirements.in`).

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1        # PowerShell (source .venv/bin/activate on bash)
pip install --require-hashes -r requirements/dev-requirements.txt
pip install --no-deps -e .
```

Run the same checks CI runs:

```powershell
ruff check .
ruff format --check .
mypy
pytest
```
