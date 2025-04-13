# Description ##############################

# Transform matlab learning rate estimates with 1.5IQR checks.
# Also, mark as to-be-excluded if missed the 1st trial
        
# Global setup #############################
rm(list=ls())
source('./scripts/utils/load_all_libraries.R')       
source('./scripts/utils/load_transform_data_expt1.R')

saveDataSummary <- T

## Import the data frames #####################
qc_table <- import('./results/experiment1/qc_check_sheets/qc_table.csv')
        
# Mark if missed first rep #######################
mean_by_rep_long_all_types <- mean_by_rep_long_all_types %>%
filter(border_dist_closest == 'all',
        hidden_pa_img_row_number_across_blocks == 1) %>% 
mutate(no_data_first_rep = is.na(mouse_error_mean))
        
if (!'no_data_first_rep' %in% colnames(data_summary)){
        
        
        # Add this column to matlab estimates
        data_summary <- merge(data_summary,
                                        select(mean_by_rep_long_all_types,
                                                ptp,
                                                condition,
                                                border_dist_closest,
                                                hidden_pa_img_type,
                                                no_data_first_rep))
        
        
        # Mark if outside 1.5IQR rule ###############################
        
        # Get the list of people passing QC till now
        good_ptp <- qc_table %>%
                filter(qc_fail_break_rt == F,
                        qc_fail_missing_or_fast == F,
                        qc_fail_manual == F,
                        qc_fail_mouse_error == F,
                        qc_fail_instructions_rt == F,
                        qc_fail_display_issues == F) %>%
                select(ptp) %>% .[[1]]
        
        # Get the list of people with no data for the 1st repetition
        no_data_first_rep_ptp <- data_summary %>%
                filter(no_data_first_rep) %>%
                mutate(ptp = as.character(ptp)) %>%
                select(ptp) %>% .[[1]]
        # Exclude those people
        good_ptp <- setdiff(good_ptp,no_data_first_rep_ptp)
        
        # Get data from only these participants 
        good_ptp_data <- data_summary %>%
                filter(ptp %in% good_ptp) %>%
                droplevels()
        
        # Calculate the Q1, Q2, IQR, and Q1-1.5xIQR and Q3+1.5xIQR
        learning_rate_check_iqr <- good_ptp_data %>%
                group_by(condition,
                                hidden_pa_img_type) %>%
                mutate(Q1_two_param = quantile(.$learning_rate_two_param, probs = 0.25),
                        Q3_two_param = quantile(.$learning_rate_two_param, probs = 0.75),
                        IQR_two_param = Q3_two_param - Q1_two_param,
                        lower_boundary_two_param = Q1_two_param - IQR_two_param * 1.5,
                        upper_boundary_two_param = Q3_two_param + IQR_two_param * 1.5,
                        outside_iqr_two_param = learning_rate_two_param < lower_boundary_two_param | 
                                learning_rate_two_param > upper_boundary_two_param,
                        Q1_three_param = quantile(.$learning_rate_three_param, probs = 0.25),
                        Q3_three_param = quantile(.$learning_rate_three_param, probs = 0.75),
                        IQR_three_param = Q3_three_param - Q1_three_param,
                        lower_boundary_three_param = Q1_three_param - IQR_three_param * 1.5,
                        upper_boundary_three_param = Q3_three_param + IQR_three_param * 1.5,
                        outside_iqr_three_param = learning_rate_three_param < lower_boundary_three_param | 
                                learning_rate_three_param > upper_boundary_three_param,
                        ) %>%
                ungroup()
        
        # Calculate group specific averages #########################################
        
        # What is the group-specific learning rate average, for those within 1.5IQR rule?
        learning_rate_check_iqr <- learning_rate_check_iqr %>%
                group_by(condition,
                                hidden_pa_img_type) %>%
                mutate(group_average_data_two_param   = mean(
                        learning_rate_two_param[outside_iqr_two_param == F]),
                        group_average_data_three_param = mean(
                                learning_rate_three_param[outside_iqr_three_param == F])) %>%
                ungroup()
        
        # Create new columns without outlier data ###################################
        # Finally, create new columns, with the learning rate being substituted by group average rate for
        learning_rate_check_iqr <- learning_rate_check_iqr %>%
                mutate(learning_rate_two_param_no_outlier = case_when(
                        outside_iqr_two_param == T ~ group_average_data_two_param,
                        TRUE ~ learning_rate_two_param
                ),
                learning_rate_three_param_no_outlier = case_when(
                        outside_iqr_three_param == T ~ group_average_data_three_param,
                        TRUE ~ learning_rate_three_param
                ))
                
        # Gaussianize the rates
        learning_rate_check_iqr <- learning_rate_check_iqr %>%
                mutate(learning_rate_two_param_no_outlier_G = as.numeric(
                        Gaussianize(
                        learning_rate_two_param_no_outlier,
                        type = 's')),
                        learning_rate_two_param_G = as.numeric(
                                Gaussianize(
                                        learning_rate_two_param,
                                        type = 's'
                                        )
                                ),
                        learning_rate_three_param_no_outlier_G = as.numeric(
                                Gaussianize(
                                        learning_rate_three_param_no_outlier,
                                        type = 's')),
                        learning_rate_three_param_G = as.numeric(
                                Gaussianize(
                                        learning_rate_three_param,
                                        type = 's'
                                        )
                                )
                        )
        
        # Merge with ml_learning_rate
        data_summary <- merge(data_summary,
                                        learning_rate_check_iqr,
                                        all.x = T)

        
        if (saveDataSummary){
                
                write_csv(data_summary,
                                './results/experiment1/data_summary.csv')
                
        }
        
} else {
        
        print('Data summary data frame already seems to have relevant columns.')
        print('Regenerate anew if must recalculate.')
}
        


