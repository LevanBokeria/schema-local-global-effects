# Local vs Global Effects of Schemas

A repository associated with the publication of the paper "Local vs Global Effects of Schemas on Learning of New Object-Location Paired-Associates".

## Description of folders:

- data: data files for each participant, extracted from JATOS output files after completing the experiment.
- results: contains quality check data, preprocessed data, analysed data, and plots for each experiment.
scripts: contains scripts to reproduce results for both experiments

## How to reproduce results:

For each experiment, go to the corresponding folder in the `/scripts/` and run each script sequentially. Scripts 1-6 will perform all the preprocessing and basic analysis. The `all_plots_and_group_analyses.Rmd` performs statistical analysis and plots reported in the paper.

Note: 
- before running the sequence of scripts, the following files must be present in `/results/experiment<n>/qc_check_sheets/qc_check_debrief_and_errors.xlsx`. This file is created manually after manual quality checks for certain conditions for each participant.
- All of the preprocessing and analysis scripts MUST be rerun all together. If you need to rerun the analysis, delete all the results files (except for files in qc_check_sheets) and rerun all of the scripts.
