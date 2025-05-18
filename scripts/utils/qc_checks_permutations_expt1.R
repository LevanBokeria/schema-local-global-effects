
permute_mouse_error_expt1 <- function(long_data,load_existing_data,saveData){
        
        # Description #####################################################
        
        # 1. For each participant, get all the trials of session 2 across all conditions.
        # 2. Then, shuffle the "label" aka which prompt was presented. Thats 1 permutation.
        # 3. Do 10,000 permutations, calculating mean accuracy for each of them. 
        #    Both, correct_exact and correct_one_square_away accuracy measures will be calculated.
        #    This gives the participant-specific null distribution.
        # 4. Compare the real participant accuracy to this data.
        
        # The script allows to do such permutations on a subset of PAs, for example
        # those only 3+ squares away from the border.
        
        
        # Initial setup ############################
        
        source('./scripts/utils/load_all_libraries.R')
        
        ## Load the data -----------------------------
        
        if (missing('long_data')){
                source('./scripts/utils/load_transform_data_expt1.R')
        }
        
        
        ## General parameters and flags --------------------
        if (missing('saveData')){
                saveData <- F                
        }

        if (missing('load_existing_data')){
                load_existing_data <- F        
        }
        
        
        # Start analysis ###########################################################
        
        if (load_existing_data){
                
                results_bound <- import(
                        paste0(
                                './results/experiment1/qc_check_sheets/qc_permutations_raw.csv'
                        ))
                
                df_percentile <- import(
                        paste0(
                                './results/experiment1/qc_check_sheets/qc_permutations_summary.csv'
                        )
                )
                
                niter <- df_percentile$n_perm[1]
                
                # List of participants who already have permutations done
                ptp_done <- unique(df_percentile$ptp) %>% as.character()
                
        } else {
                
                ptp_done <- c()
                
                results_bound <- c()
                df_percentile <- c()
                
        }
                
        ## Permutation-based chance level --------------------------
        results <- list()
        
        # A giant matrix approach
        df_all_ptp <- long_data %>%
                filter(block == 2,
                       !ptp %in% ptp_done) %>%
                droplevels() %>%
                select(ptp,
                       condition,
                       row,col,
                       corr_row,corr_col,
                       pa_center_x,
                       pa_center_y,
                       mouse_clientX,
                       mouse_clientY,
                       mouse_error,
                       border_dist_closest,
                       hidden_pa_img_type)
        
        # df_all_ptp <- df_all_ptp %>%
        #         filter(near_pa == FALSE)
        
        ctr <- 1
        
        niter <- 10000
        
        for (iPtp in levels(df_all_ptp$ptp)){
                
                print(iPtp)
                
                df <- df_all_ptp %>%
                        filter(ptp == iPtp) %>%
                        droplevels() %>%
                        as.data.frame(row.names = 1:nrow(.))
                
                # Replicate
                df <- rbindlist(replicate(niter,df,simplify = F), idcol = 'id')
                
                # Create a column containing shuffling indices
                df <- df %>%
                        group_by(ptp,id) %>%
                        mutate(rand_idx = sample(n())) %>%
                        ungroup()
                
                # Shuffle the correct row col and calculate the accuracy
                df <- df %>%
                        group_by(ptp,id) %>%
                        mutate(pa_center_x_shuff = pa_center_x[rand_idx],
                               pa_center_y_shuff = pa_center_y[rand_idx],
                               mouse_error_shuff = sqrt(
                                       (mouse_clientX - pa_center_x_shuff)^2 +
                                       (mouse_clientY - pa_center_y_shuff)^2
                                       )
                               ) %>%
                        ungroup()
                
                # Now, just distill down to a summary statistic across trials
                df <- df %>%
                        group_by(ptp,id) %>%
                        summarise(mean_mouse_error_shuff = mean(mouse_error_shuff, na.rm = T),
                                  mean_mouse_error       = mean(mouse_error,       na.rm = T)) %>%
                        ungroup()
                
                # Get the percentile, and distill even further
                # df_sum <- df %>%
                #         group_by(ptp,condition) %>%
                #         summarise(n_perm_less = sum(
                #                 mean_correct_one_square_away_shuff < mean(mean_correct_one_square_away, na.rm = T)
                #                 ),
                #                 n_perm = n(),
                #                 percentile = n_perm_less * 100 / n_perm) %>%
                #         ungroup()
                
                results[[ctr]] <- df
                
                ctr <- ctr + 1
        }
        
        results_bound_new_ptp <- rbindlist(results, idcol = 'id_ptp')
        
        if (length(results) == 0){
                
                # So all participants have been previously processed, no new participants
                df_percentile_new_ptp <- c()
                
        } else {
                
                
                # Get the percentile, and distill even further
                df_percentile_new_ptp <- results_bound_new_ptp %>%
                        group_by(ptp) %>%
                        summarise(n_perm = n(),
                                  mean_mouse_error = mean(mean_mouse_error, na.rm = T),
                                  n_perm_less_mouse_error = sum(
                                          mean_mouse_error_shuff < mean_mouse_error
                                  ),                                      
                                  percentile_sim_mouse_error = 
                                          n_perm_less_mouse_error * 100 / n_perm) %>%
                        ungroup()
                
                
                # Did any fail? ---------------------------------------------------------------
                
                threshold <- 5
                
                df_percentile_new_ptp <- df_percentile_new_ptp %>%
                        mutate(qc_fail_mouse_error = percentile_sim_mouse_error >= threshold)
                
                
        }
        # Now, combine them with existing data ----------------------------------------
        results_bound <- rbind(results_bound,results_bound_new_ptp)
        df_percentile <- rbind(df_percentile,df_percentile_new_ptp)
        
        # Save the df --------------------------------------------
        if (saveData){
                results_bound %>% write_csv(
                        paste0(
                                './results/experiment1/qc_check_sheets/qc_permutations_raw.csv'
                        )
                )
                df_percentile %>% write_csv(
                        paste0(
                                './results/experiment1/qc_check_sheets/qc_permutations_summary.csv'
                        )
                )
        }
                
        return(df_percentile)

}