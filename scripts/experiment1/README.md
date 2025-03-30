# Description

Scripts in this folder are for experiment 1, performing pre-processing of the data, analysis of dependent variables, statistical analyses, and plotting. 

## 1_preprocess_files.R

This step consists of taking data files for each participant and pre-processing and concatenating trial-by-trial results, outputs of feedback forms, and other behavioural data such as times spent reading instructions. 

## 2_analyze_dependent_variables.R

This script takes the output CSV files from 1_preprocess_files.R script, and calculate summary statistics such as accuracies and reaction times for participants and conditions.

## 3_qc_checks.R

This file loads the pre-processed behavioural data and performs quality checks for various conditions, saving a file called qc_table.csv documenting which of the participants passed QC. 

## 4_fit_non_linear_reg.m

This MATLAB script will load pre-processed data and fit the 2-parameter and 3-parameter models to the learning curve data (see the Methods section in the paper). 

## 5_integrate_matlab_output.R

This script will combine the CSV file produced by 4_fit_non_linear_reg.m script with the main pre-processed and analysed CSV files that include other behavioural stats, such that all the relevant statistics are in one CSV file for later analyses.

## 6_transform_learning_rates_iqr.R

Loads the data_summary.csv that already contains merged learning rate estimates, applies the 1.5*IQR rule to find outliers and substitute those with group-average values. The script also marks participant learning rates as to-be-excluded if they missed the 1st trial. See paper for more details.

## all_plots_and_group_analyses.Rmd

This R Markdown file loads the pre-processed and analysed data at the participant-level and performs group level analyses and plots.