##
## load_package.R, install + load defined package
##
load_package = function(packages) {
  new.packages = packages[!(packages %in% installed.packages()[, 'Package'])]
  if (length(new.packages))
    install.packages(new.packages, dependencies = TRUE, repos='http://cran.rstudio.com/')
  sapply(packages, require, character.only = TRUE)
}
