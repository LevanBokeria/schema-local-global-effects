%% Description

%% Global setup
clear; clc; close all;
dbstop if error;

warning('off','MATLAB:table:RowsAddedExistingVars')
% warning('off','MATLAB:rankDeficientMatrix')
% warning('off','stats:nlinfit:IllConditionedJacobian')
% warning('off','stats:nlinfit:IllConditionedJacobian')

saveData = 0;
qc_filter = 0;

%% Load and prepare the dataset
opts = detectImportOptions('./results/mean_by_rep_long_all_types.csv');
opts = setvartype(opts,{'border_dist_closest'},'char');

df = readtable('./results/mean_by_rep_long_all_types.csv',opts);

% Load the qc pass data
opts = detectImportOptions('./results/qc_check_sheets/qc_table.csv');
opts = setvartype(opts,{'qc_fail_overall'},'logical');

qc_pass = readtable('./results/qc_check_sheets/qc_table.csv',opts);
qc_pass_ptp = qc_pass.ptp(~qc_pass.qc_fail_overall);

% Get only the needed accuracy types
indices = strcmp(df.border_dist_closest,'all');
df = df(indices,:);

if qc_filter
    % Get only qc pass
    indices = ismember(df.ptp,qc_pass_ptp);
    df = df(indices,:);
end

all_ptp = unique(df.ptp);
n_ptp   = length(all_ptp);

all_conditions        = unique(df.condition);
all_hidden_pa_types   = unique(df.hidden_pa_img_type);
all_border_dist_types = unique(df.border_dist_closest);

%% Start the for loop
params_two   = [250,0.1];

params_three = [250,0.1,230];

plotFMSEstimation = 0;

tbl = table;

ctr = 1;

% Some options for fitting nlm 3 parameter
opt_three_param = statset('MaxIter', 0);

for iPtp = 1:n_ptp
    iPtp

    for iCond = 1:length(all_conditions)
%         all_conditions{iCond}

        for iType = 1:length(all_hidden_pa_types)
            %             iType

            % Reset the warning, so we can catch it later if it occurrs
            lastwarn('');

            curr_ptp  = all_ptp{iPtp};
            curr_cond = all_conditions{iCond};
            curr_type = all_hidden_pa_types{iType};

            % Save in a table
            tbl.ptp               {ctr} = curr_ptp;
            tbl.condition         {ctr} = curr_cond;
            tbl.hidden_pa_img_type{ctr} = curr_type;

            % Get the data
            y = df.mouse_error_mean(strcmp(df.ptp,curr_ptp) &...
                strcmp(df.condition,curr_cond) & ...
                strcmp(df.hidden_pa_img_type,curr_type));

            %% Estimate fminsearch two param
            lastwarn('');
            [out_two_params,fval_two_param,exitFlag] = est_learning_rate(y',params_two,plotFMSEstimation,'two_parameters');
            [warnMsg, warnId] = lastwarn;
            
            if ~isempty(warnMsg)
                warning('off',warnId);
            end

            tbl.fminsearch_two_param         {ctr} = out_two_params;
            tbl.fminsearch_two_param_fval    (ctr) = fval_two_param;
            tbl.fminsearch_two_param_exitflag(ctr) = exitFlag;
            tbl.fminsearch_two_param_message {ctr} = warnId;  

            %% Fminsearch two param on reps 2-8

            % Delete the first variable
            y_2_8 = y(2:end);

            lastwarn('');
            [out_two_params_2_8,fval_two_param_2_8,exitFlag_2_8] = est_learning_rate(y_2_8',params_two,plotFMSEstimation,'two_parameters');
            [warnMsg, warnId] = lastwarn;
            
            if ~isempty(warnMsg)
                warning('off',warnId);
            end

            tbl.fminsearch_two_param_2_8         {ctr} = out_two_params_2_8;
            tbl.fminsearch_two_param_fval_2_8    (ctr) = fval_two_param_2_8;
            tbl.fminsearch_two_param_exitflag_2_8(ctr) = exitFlag_2_8;
            tbl.fminsearch_two_param_message_2_8 {ctr} = warnId;              

            %% Try fminsearch 3 param
            lastwarn('');
            [out_three_params,fval_three_param,exitFlag] = ...
                est_learning_rate(y',params_three,plotFMSEstimation,'three_parameters');

            [warnMsg, warnId] = lastwarn;

            if ~isempty(warnMsg)
                warning('off',warnId);
            end

            % Record fminsearch output
            tbl.fminsearch_three_param         {ctr} = out_three_params;
            tbl.fminsearch_three_param_fval    (ctr) = fval_three_param;
            tbl.fminsearch_three_param_exitflag(ctr) = exitFlag;
            tbl.fminsearch_three_param_message {ctr} = warnId;            

            %% Try fminsearch 3 param on 2-8
            
            lastwarn('');
            [out_three_params_2_8,fval_three_param_2_8,exitFlag_2_8] = ...
                est_learning_rate(y_2_8',params_three,plotFMSEstimation,'three_parameters');

            [warnMsg, warnId] = lastwarn;

            if ~isempty(warnMsg)
                warning('off',warnId);
            end

            % Record fminsearch output
            tbl.fminsearch_three_param_2_8         {ctr} = out_three_params_2_8;
            tbl.fminsearch_three_param_fval_2_8    (ctr) = fval_three_param_2_8;
            tbl.fminsearch_three_param_exitflag_2_8(ctr) = exitFlag;
            tbl.fminsearch_three_param_message_2_8 {ctr} = warnId; 

            %% Now non linear fitting algorithm
            X = (1:8)';

            % Two parameters
            modelfun_two_par = @(b,x)b(1) * exp(-b(2) * (x(:,1)-1));
            mdl_two_par = fitnlm(X,y,modelfun_two_par,tbl.fminsearch_two_param{ctr});

            % Three parameter
            modelfun_three_par = @(b,x)b(3) * (exp(-b(2) * (x(:,1)-1)) - 1) + b(1);

            try
                lastwarn('');
                mdl_three_par = fitnlm(X,y,modelfun_three_par,tbl.fminsearch_three_param{ctr},'options', opt_three_param);           

            catch e

                tbl.errorMsg_three_param{ctr} = e.message;
                
                % Try with fminsearch estimated parameters
                try
                    lastwarn('')
                    mdl_three_par = fitnlm(X,y,modelfun_three_par,tbl.fminsearch_three_param{ctr},'options',opt_three_param);
                catch e2
                    
                    tbl.errorMsg_three_param_try2{ctr} = e2.message

                end
            end

            [warnMsg, warnId] = lastwarn;

            if ~isempty(warnMsg)

                % Plot
                %                 figure
                %                 plot(mdl_three_par.Variables.y)
                %                 hold on
                %                 plot(mdl_three_par.predict)
                warning('off',warnId);

                tbl.warnMsg{ctr} = warnMsg;
                tbl.warnId {ctr}  = warnId;

                lastwarn('');

            end

            %% Save in a table
            tbl.sse_two_param            (ctr) = mdl_two_par.SSE;
            tbl.intercept_two_param      (ctr) = mdl_two_par.Coefficients.Estimate(1);
            tbl.learning_rate_two_param  (ctr) = mdl_two_par.Coefficients.Estimate(2);
            tbl.logLik_two_param         (ctr) = mdl_two_par.LogLikelihood;
            tbl.AIC_two_param            (ctr) = mdl_two_par.ModelCriterion.AIC;
            tbl.BIC_two_param            (ctr) = mdl_two_par.ModelCriterion.BIC;
            tbl.sse_three_param          (ctr) = mdl_three_par.SSE;
            tbl.intercept_three_param    (ctr) = mdl_three_par.Coefficients.Estimate(1);
            tbl.learning_rate_three_param(ctr) = mdl_three_par.Coefficients.Estimate(2);
            tbl.asymptote_three_param    (ctr) = mdl_three_par.Coefficients.Estimate(1) - mdl_three_par.Coefficients.Estimate(3);          
            tbl.logLik_three_param       (ctr) = mdl_three_par.LogLikelihood;
            tbl.AIC_three_param          (ctr) = mdl_three_par.ModelCriterion.AIC;
            tbl.BIC_three_param          (ctr) = mdl_three_par.ModelCriterion.BIC;            

            ctr = ctr + 1;
        end %itype
    end % iCond
end %iPtp

%% Save the table
if saveData
    writetable(tbl,'./results/learning_rate_fits_matlab.csv');
end
