library(targets)

tar_option_set(packages = c("retry",
                            "sbtools",
                            "secret",
                            "tidyverse",
                            "zip",
                            'ggplot2',
                            'lubridate',
                            'scales',
                            'ggforce',
                            'showtext',
                            'paletteer',
                            'BAMMtools',
                            'scico',
                            'scales',
                            'ggthemes',
                            'usmap',
                            'cowplot',
                            'ggbeeswarm'))

# Phase target makefiles
source("0_config.R")
source("1_fetch.R")
source("2_process.R")
source("3_visualize.R")

# Combined list of target outputs
c(p0_targets, p1_targets, p2_targets, p3_targets)