options(repos = c(CRAN = "https://repo.r-wasm.org"))

# ------------------------------------------------------------------
# 0. DEFINE PACKAGES FIRST (must exist before any step)
# ------------------------------------------------------------------

cran_packages <- c(
  #  "jsonlite",
  #  "rlang",
  #  "dplyr",
  #  "vctrs",
  #  "cli",
  #  "glue",
  #  "tibble",
  #  "tidyselect",
  #  "digest",
  #  "stringr",
  #  "nlsr",
  #  "nlstools",
  #  "nls2",
  #  "reshape2",
  #  "optimx",
  #  "ggplot2",
  #  "ggsced"
)

cran_packages <- c("nlsr", "nlstools", "nls2", "ggplot2", "reshape2", "optimx")

local_pkg <- "/work/packages/beezdemand_0.1.2.tar.gz"

options(
  repos = c(CRAN = "https://repo.r-wasm.org"),
  BioC_mirror = "https://bioconductor.org"
)

Sys.setenv(
  R_BIOC_VERSION = "3.20",
  R_BIOC_MIRROR = "https://bioconductor.org"
)

if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak",
                   repos = sprintf("https://r-lib.github.io/p/pak/%s/%s/%s/%s",
                                   "devel",
                                   .Platform$pkgType,
                                   R.Version()$os,
                                   R.Version()$arch))
}

# Pin pkgdepends to the known-good resolver version before loading rwasm
pak::pak("r-lib/pkgdepends@v0.9.0", lib = .Library)

if (!requireNamespace("rwasm", quietly = TRUE)) {
  pak::pak("r-wasm/rwasm")
}

library(rwasm)

options(pkgdepends_cache = NULL)

# IMPORTANT: isolate build from /work to avoid permissions issues
#repo_dir <- tempfile("webr_repo_")
dir.create("/work/repo", recursive = TRUE, showWarnings = FALSE)

repo_dir <- "/work/repo"

dir.create(repo_dir, recursive = TRUE, showWarnings = FALSE)

lib_path <- "/work/library"

dir.create(lib_path, recursive = TRUE, showWarnings = FALSE)

.libPaths(c(lib_path, .libPaths()))

rwasm::add_pkg(cran_packages,
               repo = repo_dir,
               dependencies = TRUE)

install.packages(
  local_pkg,
  repos = NULL,
  type = "source",
  dependencies = TRUE
)

# Broken: Hates the new build
# rwasm::add_pkg("beezdemand", repo = repo_dir)

dir.create("/work/webr-repo", recursive = TRUE, showWarnings = FALSE)
dir.create("/work/public/webr/vfs", recursive = TRUE, showWarnings = FALSE)

rwasm::add_pkg(
  c(sprintf("beezdemand=local::%s", local_pkg), cran_packages),
  repo_dir = repo_dir
)

rwasm::make_vfs_library(
  out_dir = "/work/public/webr/vfs",
  out_name = "library.data",
  repo_dir = repo_dir
)

#rwasm::make_vfs_library(
#  out_dir = "/work/public/webr",
#  out_name = "library.data",
#  repo_dir = repo_dir
#)

#rwasm::add_pkg(cran_packages, repo = repo_dir)

#rwasm::make_vfs_library(
#  out_dir = "/work/public/webr",
#  out_name = "library.data",
#  repo_dir = repo_dir
#)