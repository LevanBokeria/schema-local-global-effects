# Description ##############################

# Helper function to load the long form data and transform columns as needed

# Global setup #############################

source('./scripts/utils/load_all_libraries.R')

## long form data ------------------------

### Load the long-form data ======================
long_data <- import('./results/experiment1/preprocessed_data/block_results_long_form.csv')

### Transform data ====================
long_data <- long_data %>%
        mutate(across(c(ptp,
                        counterbalancing,
                        condition,
                        arrangement,
                        block,
                        block_trial_idx,
                        hidden_pa_img,
                        hidden_pa_img_type,
                        hidden_pa_img_row_number_across_blocks,
                        border_dist_closest,
                        border_dist_summed),as.factor)) %>%
        filter(!condition %in% c('practice','practice2')) %>%
        droplevels() %>%
        reorder_levels(condition, order = c('schema_c',
                                            'schema_l',
                                            'schema_ic',
                                            'random_loc',
                                            'no_schema'))

## summary data --------------------------------------

if (file.exists('./results/experiment1/data_summary.csv')){
        
        data_summary <- import('./results/experiment1/data_summary.csv')
        
        data_summary <- data_summary %>%
                mutate(across(c(ptp,
                                 condition,
                                 hidden_pa_img_type),as.factor)) %>%
                reorder_levels(condition, order = c('schema_c',
                                                    'schema_l',
                                                    'schema_ic',
                                                    'random_loc',
                                                    'no_schema'))
        
}

## Mean by rep data -----------------------------------
if (file.exists('./results/experiment1/mean_by_rep_long_all_types.csv')){
        
        mean_by_rep_long_all_types <- import('./results/experiment1/mean_by_rep_long_all_types.csv')
        
        mean_by_rep_long_all_types <- mean_by_rep_long_all_types %>%
                mutate(across(c(ptp,
                                counterbalancing,
                                condition,
                                hidden_pa_img_type,
                                border_dist_closest),as.factor)) %>%
                reorder_levels(condition, order = c('schema_c',
                                                    'schema_l',
                                                    'schema_ic',
                                                    'random_loc',
                                                    'no_schema'))
        
}