from pathlib import Path
import sqlite3
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

BASE = Path(__file__).resolve().parents[1]
DATA, FIGURES = BASE / 'data', BASE / 'figures'
FIGURES.mkdir(exist_ok=True)
people = pd.read_csv(DATA / 'individuals.csv')
earnings = pd.read_csv(DATA / 'earnings.csv')
with sqlite3.connect(':memory:') as db:
    people.to_sql('individuals', db, index=False)
    earnings.to_sql('earnings', db, index=False)
    example = pd.read_sql_query('SELECT person_id, family_id, role FROM individuals LIMIT 6', db)
    print('SELECT example:\n', example.to_string(index=False))
    pairs = pd.read_sql_query('''
      SELECT c.person_id AS child_id, p.person_id AS parent_id, c.family_id
      FROM individuals AS c
      JOIN individuals AS p
        ON c.parent_id = p.person_id AND c.family_id = p.family_id
      WHERE c.role = 'child' AND p.role = 'parent'
    ''', db)
    pairs.to_sql('pairs', db, index=False)
    panel = pd.read_sql_query('''
      SELECT pairs.child_id, pairs.parent_id, pairs.family_id,
             ce.year, ce.age AS child_age,
             ce.income AS child_income, pe.income AS parent_income
      FROM pairs
      JOIN earnings AS ce ON pairs.child_id = ce.person_id
      JOIN earnings AS pe ON pairs.parent_id = pe.person_id AND ce.year = pe.year
      WHERE ce.income > 0 AND pe.income > 0
    ''', db)
    panel.to_sql('matched_panel', db, index=False)
    one = pd.read_sql_query('''
      SELECT child_id, parent_id, AVG(child_income) AS child_income,
             AVG(parent_income) AS parent_income
      FROM matched_panel WHERE year = 2010
      GROUP BY child_id, parent_id
    ''', db)
    avg = pd.read_sql_query('''
      SELECT child_id, parent_id, COUNT(*) AS years,
             AVG(child_income) AS child_income,
             AVG(parent_income) AS parent_income
      FROM matched_panel GROUP BY child_id, parent_id HAVING COUNT(*) = 10
    ''', db)

def ige(df):
    """OLS slope of log(child income) on log(parent income) with intercept."""
    return float(np.polyfit(np.log(df['parent_income']), np.log(df['child_income']), 1)[0])

results = pd.DataFrame([
    {'comparison': '2010 single year', 'n_pairs': len(one), 'ige': ige(one)},
    {'comparison': '2010–2019 ten-year mean', 'n_pairs': len(avg), 'ige': ige(avg)}
])
age_results = panel.groupby('year').apply(
    lambda frame: pd.Series({'child_age': int(frame.child_age.iloc[0]), 'ige': ige(frame)})).reset_index()
results.to_csv(DATA / 'ige_comparison.csv', index=False)
age_results.to_csv(DATA / 'ige_by_child_age.csv', index=False)
panel.to_csv(DATA / 'matched_panel.csv', index=False)
fig, ax = plt.subplots(figsize=(7, 4))
ax.plot(age_results['child_age'], age_results['ige'], marker='o')
ax.axhline(0.43, linestyle='--', label='Simulated long-run transmission parameter (0.43)')
ax.set(xlabel='Child age at income measurement', ylabel='Estimated IGE',
       title='Synthetic demonstration: IGE by child measurement age')
ax.legend(fontsize=8)
fig.tight_layout()
fig.savefig(FIGURES / 'ige_by_age.png', dpi=170)
plt.close(fig)
print('\nIGE comparison:\n', results.to_string(index=False))
print('\nResults are simulated, NOT U.S. population estimates.')
