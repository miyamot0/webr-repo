options(repos = c(CRAN = "https://repo.r-wasm.org"))

cran_packages <- c("nlsr", "nlstools", "nls2", "ggplot2", "reshape2", "optimx", "ggsced")

# Local custom compiles
local_pkg <- "/work/packages/beezdemand_0.1.2.tar.gz"

options(repos = c(CRAN = "https://repo.r-wasm.org"), 
        BioC_mirror = "https://bioconductor.org")

Sys.setenv(R_BIOC_VERSION = "3.20",
           R_BIOC_MIRROR = "https://bioconductor.org")

if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak",
                   repos = sprintf("https://r-lib.github.io/p/pak/%s/%s/%s/%s",
                                   "devel",
                                   .Platform$pkgType,
                                   R.Version()$os,
                                   R.Version()$arch))
}

pak::pak("r-lib/pkgdepends@v0.9.0", lib = .Library)

if (!requireNamespace("rwasm", quietly = TRUE)) {
  pak::pak("r-wasm/rwasm")
}

library(rwasm)

options(pkgdepends_cache = NULL)

repo_dir <- "/work/repo"
dir.create(repo_dir, recursive = TRUE, showWarnings = FALSE)

lib_path <- "/work/library"
dir.create(lib_path, recursive = TRUE, showWarnings = FALSE)

.libPaths(c(lib_path, .libPaths()))

rwasm::add_pkg(cran_packages,
               repo = repo_dir,
               dependencies = TRUE)

install.packages(local_pkg,
                 repos = NULL,
                 type = "source",
                 dependencies = TRUE)

# rwasm::add_pkg("beezdemand", repo = repo_dir) # Borked due to nloptr

#dir.create("/work/webr-repo", recursive = TRUE, showWarnings = FALSE)

rwasm::add_pkg(c(sprintf("beezdemand=local::%s", local_pkg), cran_packages),
                 repo_dir = repo_dir)

#dir.create("/work", recursive = TRUE, showWarnings = FALSE)

rwasm::make_vfs_library(out_dir = "/work",
                        out_name = "library.data",
                        repo_dir = repo_dir)
