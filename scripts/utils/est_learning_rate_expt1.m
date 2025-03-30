function [out_params,fval,exitFlag] = est_learning_rate_expt1(ptp_data,params,plotEstimation,which_model)
    
    % fminsearch will find the best gamma
    if plotEstimation
        options = optimset('PlotFcns',@optimplotfval);    
        [out_params,fval,exitFlag] = fminsearch(@fit_learning,params,options);
    else
        options = optimset('MaxFunEvals',2e10);
        [out_params,fval,exitFlag] = fminsearch(@fit_learning,params,options);
    end

    function sse = fit_learning(x)
       
        trials = 1:length(ptp_data);
        
        % For optimize both rate and offset
        if strcmp(which_model,'three_parameters')
            
            y_hat = x(3) * exp(-x(2) * (trials - 1)) + x(1) - x(3);
            
        elseif strcmp(which_model,'two_parameters')
            
            y_hat = x(1) * exp(-x(2) * (trials - 1));
            
        else
            error('Incorrect model type given!')
        end
        
        % If the intercept is below 0 or above the maximum possible error 
        % on the boards, have a terrible sse
        if x(1) < 0 || x(1) > sqrt(2*500^2)
            sse = Inf;
        else
            sse = nansum(abs(ptp_data - y_hat).^2);
        end
        
        % If the asymptote is less than 0, infinite error
        if strcmp(which_model,'three_parameters')
            if (x(1) - x(3)) < 0 || (x(1) - x(3)) > sqrt(2*500^2)
                
                sse = Inf;
                
            end
        end
        
    end

end