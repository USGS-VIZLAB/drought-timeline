source('2_process/src/prep_stripswarm.R')

p2_targets <- list(
  ##### General metadata #####
  tar_target(p2_metadata,
             readr::read_csv(p1_metadata_csv, col_types=cols())),
  
  # Define states that are in the western U.S.
  tar_target(p2_western_states, 
             c('AZ','CA','CO','ID','MT','NV','NM','OR','UT','WA','WY')),
  
  ##### Data for 1951-2020 #####

  ###### Get 1951-2020 metadata ######
  tar_target(p2_1951_2020_metadata,
             filter(p2_metadata, national_1951) %>%
               mutate(western_us = STATE %in% p2_western_states)),
  
  ###### Load drought properties ######
  ## Using only variable 7d drought properties
  tar_target(p2_1951_2020_drought_prop_jd_7d,
             readr::read_csv(p1_1951_2020_drought_prop_jd_7d_csv, col_types = cols()) %>%
               mutate(across(c(start, end), ~as.Date(.x, '%Y-%m-%d')))),
  
  ### Prep drought properties for "strip swarm" duration chart
  # Filter to droughts defined using the 2% threshold
  # and to only drought that occurred in the western U.S.
  tar_target(p2_prop_western_2,
             p2_1951_2020_drought_prop_jd_7d %>%
               filter(threshold == 2) %>%
               left_join(p2_1951_2020_metadata %>%
                           select(StaID:STATE, HCDN_2009, western_us)) %>%
               filter(western_us)),

  # Identify drought chunks
  tar_target(p2_prop_western_2_drought_chunks,
             identify_drought_chunks(p2_prop_western_2, min_chunk_days=365)),
  
  # Process data to generate swarm
  ## Original approach (# cells filled per event = duration)
  ## nrow = # of drought days (unique site days with droughts)
  tar_target(p2_prop_western_2_swarm,
             create_event_swarm(event_data = p2_prop_western_2,
                                             start_period = p2_prop_western_2_drought_chunks$start_date,
                                             end_period = p2_prop_western_2_drought_chunks$break_date,
                                             max_droughts = p2_prop_western_2_drought_chunks$max_single_day_droughts),
             pattern = map(p2_prop_western_2_drought_chunks)),
  
  ## 'Compressed' approach (# cells filled per event = 1)
  ## nrow = # of drought events = nrow(p2_prop_western_2)
  tar_target(p2_prop_western_2_swarm_compressed,
             create_event_swarm_compressed(event_data = p2_prop_western_2,
                                start_period = p2_prop_western_2_drought_chunks$start_date,
                                end_period = p2_prop_western_2_drought_chunks$break_date,
                                max_droughts = p2_prop_western_2_drought_chunks$max_single_day_droughts),
             pattern = map(p2_prop_western_2_drought_chunks))
)
