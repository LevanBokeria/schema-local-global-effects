# Fit Learning Model
# This function fits a learning model to the given data using either a two-parameter
# or three-parameter exponential decay model. It calculates the predicted values
# (`y_hat`) and optionally returns either the fitted values or the sum of squared
# errors (SSE).

# In this code repository, this function is not used to fit the model to the data. This function 
# is only used by another R script called integrate_matlab_output.R to return the fitted values 
# and integrate them with the main data files containing participant-level summary stats. 
# This is done after model fits have already been calculated in MATLAB.

# Arguments:
# - p: A numeric vector of parameters for the model.
#      For the two-parameter model: p[1] is the intercept, p[2] is the decay rate or the learning rate.
#      For the three-parameter model: p[2] is the decay rate or the learning rate, p[3] is the intercept,
#      and p[1] - p[3] is the asymptote.
# - t: A numeric vector representing the time points.
# - y: A numeric vector of observed values.
# - ret: A character string specifying the return type.
#        Use 'fit' to return the fitted values (`y_hat`) or any other value to return the sum of squared 
#        errors (SSE).
# - print_output: A logical value indicating whether to print intermediate output.
# - which_model: A character string specifying the model type.
#                Use 'two_param' for the two-parameter model or 'three_param' for the three-parameter 
#                model.

# Returns:
# - If ret is 'fit', the function returns a numeric vector of fitted values (`y_hat`).
# - Otherwise, it returns a numeric value representing the sum of squared errors (SSE).

fit_learning <- function(p, t, y, ret, print_output, which_model) {
    # Define the function:
    if (which_model == 'two_param') {
        y_hat = p[1] * exp(-p[2] * (t - 1))
    } else if (which_model == 'three_param') {
        y_hat = p[3] * exp(-p[2] * (t - 1)) + p[1] - p[3]
    }
    
    sse <- sum((y - y_hat)^2)

    if (print_output) {
        print(paste0('params: ', p))
        print(paste0('N parameters: ', which_model))
        print(paste0(y, collapse = ' '))
        print(paste0(y_hat, collapse = ' '))
        # print(paste0('sse: ', sse))
    }

    if (ret == 'fit') {
        return(y_hat)
    } else {
        return(sse)
    }
}