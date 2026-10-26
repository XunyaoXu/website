# Blog Post 1: What Is a P-Value?

This post explains what a p-value means, why it is often misunderstood, and how to interpret it correctly.

The main question is:

> What does a p-value actually tell us about the data and the null hypothesis?

The post focuses on the distinction between

\[
P(\text{data at least as extreme as observed} \mid H_0)
\]

and

\[
P(H_0 \mid \text{data}),
\]

which are often incorrectly treated as the same probability.

## Main Example

The post uses a simple coin-flip example:

- Null hypothesis: the coin is fair, so \(p = 0.5\)
- Number of flips: 20
- Observed heads: 16
- Two-sided p-value: approximately 0.012, or 1.2%

The example shows how a p-value measures how unusual the observed result would be if the null hypothesis were true.

A medical-testing analogy is also used to explain why reversing conditional probabilities can lead to incorrect interpretations.

## Repository Structure

```text
post1/
├── index.qmd
├── README.md
└── blog_images/
    └── pvalue_coin_flip.png
```

## Files

- `index.qmd` contains the complete blog post.
- `blog_images/pvalue_coin_flip.png` is the figure used to illustrate the coin-flip example.

## Reproducing the Post

No external dataset is required for this post.

To render the post:

1. Open `index.qmd` in RStudio or another Quarto-compatible editor.
2. Make sure `blog_images/pvalue_coin_flip.png` is stored in the `blog_images/` folder.
3. Render `index.qmd` with Quarto.

## Reference

Wasserstein, R. L., & Lazar, N. A. (2016). *The ASA Statement on p-Values: Context, Process, and Purpose*. The American Statistician, 70(2), 129–133.

DOI: https://doi.org/10.1080/00031305.2016.1154108
