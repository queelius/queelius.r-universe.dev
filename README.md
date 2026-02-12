# queelius R-universe

[![:registry status](https://queelius.r-universe.dev/badges/:registry)](https://queelius.r-universe.dev/)

This is the package registry for [queelius.r-universe.dev](https://queelius.r-universe.dev/). It defines which R packages are built and distributed as binaries through R-universe.

## Packages

| Package | Description |
|---------|-------------|
| [femtograd](https://github.com/queelius/femtograd) | Automatic differentiation |
| [algebraic.mle](https://github.com/queelius/algebraic.mle) | Algebraic maximum likelihood estimation |
| [algebraic.dist](https://github.com/queelius/algebraic.dist) | Algebraic distributions |
| [hypothesize](https://github.com/queelius/hypothesize) | Hypothesis testing |
| [likelihood.model](https://github.com/queelius/likelihood.model) | Likelihood models |
| [compositional.mle](https://github.com/queelius/compositional.mle) | Compositional MLE |
| [nabla](https://github.com/queelius/nabla) | Nabla operator |
| [likelihood.model.series.md](https://github.com/queelius/likelihood.model.series.md) | Likelihood models for masked series data |

## Installation

To install packages from this universe, add the repository to your R options:

```r
options(repos = c(
  queelius = "https://queelius.r-universe.dev",
  CRAN = "https://cloud.r-project.org"
))
```

Then install any package normally:

```r
install.packages("algebraic.mle")
```

## Adding a package

Edit `packages.json` and add an entry:

```json
{
  "package": "my-package",
  "url": "https://github.com/queelius/my-package"
}
```
