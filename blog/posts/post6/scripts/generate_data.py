"""Create completely reproducible fictional family and longitudinal earnings files."""
from pathlib import Path
import numpy as np
import pandas as pd

BASE = Path(__file__).resolve().parents[1]
OUT = BASE / 'data'
OUT.mkdir(parents=True, exist_ok=True)
rng = np.random.default_rng(64006)
n = 1200
parent_ids = np.arange(10001, 10001 + n)
child_ids = np.arange(30001, 30001 + n)
family_ids = np.arange(50001, 50001 + n)
parent_log_long_run = rng.normal(np.log(62000), 0.48, n)
child_log_long_run = (np.log(54000) + 0.43 * (parent_log_long_run - np.log(62000))
                      + rng.normal(0, 0.37, n))
individuals = pd.DataFrame({
    'person_id': np.r_[parent_ids, child_ids],
    'family_id': np.r_[family_ids, family_ids],
    'parent_id': np.r_[np.full(n, np.nan), parent_ids],
    'role': ['parent'] * n + ['child'] * n
})
records = []
for year in range(2010, 2020):
    parent_age = 39 + (year - 2010)
    child_age = 22 + (year - 2010)
    # Age-specific dispersion can affect estimated IGE; common age shifts alone do not.
    child_age_slope = 0.55 + 0.065 * (child_age - 22)
    p_log = parent_log_long_run + rng.normal(0, 0.22, n)
    c_log = np.log(54000) + child_age_slope * (child_log_long_run - np.log(54000)) + \
        (-0.45 + 0.065 * (child_age - 22)) + rng.normal(0, 0.29, n)
    for ids, logs, age in ((parent_ids, p_log, parent_age), (child_ids, c_log, child_age)):
        records.extend((int(pid), year, age, round(float(np.exp(v)), 2))
                       for pid, v in zip(ids, logs))
earnings = pd.DataFrame(records, columns=['person_id', 'year', 'age', 'income'])
individuals.to_csv(OUT / 'individuals.csv', index=False)
earnings.to_csv(OUT / 'earnings.csv', index=False)
print(f'Generated {len(individuals)} individuals and {len(earnings)} person-year records.')
