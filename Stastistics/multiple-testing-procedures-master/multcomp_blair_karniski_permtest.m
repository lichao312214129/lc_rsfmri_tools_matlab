function [Results] = multcomp_blair_karniski_permtest(cond1_data, cond2_data, varargin)
%
% This script receives paired-samples data and outputs corrected p-values and
% hypothesis test results based on a maximum statistic two-tailed permutation test
% (Blair & Karniski, 1993). The permutation test in this script is based
% on the t-statistic from a paired-samples t-test, but could be adapted 
% to use with other statistics such as the trimmed mean or yuen's t. 
% This method controls the strong familywise error rate.
%
% Blair, R. C., & Karniski, W. (1993). An alternative method for 
% significance testing of waveform difference potentials. 
% Psychophysiology, 30, 518-524. DOI: 10.1111/j.1469-8986.1993.tb02075.x
%
%
% Inputs:
%
%   cond1_data      data from condition 1, a subjects x time windows matrix
%
%   cond2_data      data from condition 2, a subjects x time windows matrix
%
%
%  'Key1'          Keyword string for argument 1
%
%   Value1         Value of argument 1
%
%   ...            ...
%
% Optional Keyword Inputs:
%
%   alpha           uncorrected alpha level for statistical significance, 
%                   default is 0.05
%
%   iterations      number of permutation samples to draw. Default is 5000
%                   At least 1000 is recommended for the p = 0.05 alpha 
%                   level, and at least 5000 is recommended for the 
%                   p = 0.01 alpha level. This is due to extreme events
%                   at the tails of the permutation distribution being very 
%                   rare, needing many random permutations to accurately estimate them.
%
% Outputs:
% 
%   Results structure containing:
%
%   corrected_h     vector of hypothesis tests in which statistical significance
%                   is defined by values above a threshold of the 
%                   ((1 - alpha / 2) * 100)th percentile of the maximum statistic distribution.
%                   1 = statistically significant, 0 = not statistically significant
%
%   corrected_p     vector of p-values derived from assessing the t-value of
%                   each test relative to the distribution of maximum t-values across
%                   iterations in the permutation test. For example, if above the 97.5th
%                   percentile then p < .05 (due to two-tailed testing).
%
%   critical_t      absolute critical t-value. t-values larger than this are
%                   counted as statistically significant.
%
%   t_values        t-values resulting from each paired-samples test.
%
%
% Example:          [Results] = multcomp_blair_karniski_permtest(cond1_data, cond2_data, 'alpha', '0.05', 'iterations', 10000) 
%
%
% Copyright (c) 2016 Daniel Feuerriegel and contributors
% 
% This file is part of DDTBOX.
%
% DDTBOX is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.


%% Handling variadic inputs
% Define defaults at the beginning
options = struct(...
    'alpha', 0.05,...
    'iterations', 5000);

% Read the acceptable names
option_names = fieldnames(options);

% Count arguments
n_args = length(varargin);
if round(n_args/2) ~= n_args/2
   error([mfilename ' needs property name/property value pairs'])
end

for pair = reshape(varargin,2,[]) % pair is {propName;propValue}
   inp_name = lower(pair{1}); % make case insensitive

   % Overwrite default options
   if any(strcmp(inp_name, option_names))
      options.(inp_name) = pair{2};
   else
      error('%s is not a recognized parameter name', inp_name)
   end
end
clear pair
clear inp_name

% Renaming variables for use below:
alpha_level = options.alpha;
n_iterations = options.iterations;
clear options;


%% Tests on observed data
% Checking whether the number of tests in the first and second datasets are equal
if size(cond1_data, 2) ~= size(cond2_data, 2)
   error('Condition 1 and 2 datasets do not contain the same number of comparisons/tests!');
end
if size(cond1_data, 1) ~= size(cond2_data, 1)
   error('Condition 1 and 2 datasets do not contain the same number of subjects!');
end

% Calculate difference scores between conditions
diff_scores = cond1_data - cond2_data;

n_subjects = size(diff_scores, 1); % Calculate number of subjects
n_total_comparisons = size(diff_scores, 2); % Calculating the number of comparisons

% Perform t-tests at each step    
[~, ~, ~, extra_stats] = ttest(diff_scores, 0, 'Alpha', alpha_level);
uncorrected_t = extra_stats.tstat; % Vector of t statistics from each test

% Seed the random number generator based on the clock time
rng('shuffle');

%% Maximum statistic permutation test
% Estimate t(max) distribution from the randomly-permuted data
t_max = zeros(1, n_iterations); % Preallocate
t_stat = zeros(n_total_comparisons, n_iterations); % Preallocate
        
% Generate the null hypothesis permutation distribution of maximum statistics    
for iteration = 1:n_iterations
    clear temp; % Clearing out temp variable
    temp_signs = zeros(n_subjects, 1); % Preallocate
    temp = zeros(n_subjects, n_total_comparisons); % Preallocate

    % Draw a permutation sample for each test    
    % Randomly switch the sign of difference scores (equivalent to
    % switching labels of conditions)
    % Note that the switch in the sign of difference scores is consistent
    % across tests within a participant.
    temp_signs(1:n_subjects) = (rand(n_subjects, 1) > .5) * 2 - 1; % Switches signs of difference scores

    % Calculate resulting difference scores
    for step = 1:n_total_comparisons
        temp(1:n_subjects, step) = temp_signs(1:n_subjects) .* diff_scores(1:n_subjects, step);
    end % of for step
    % Perform Student's paired-samples t tests
    [~, ~, ~, temp_stats] = ttest(temp, 0, 'Alpha', alpha_level);
    t_stat(:, iteration) = temp_stats.tstat;   

    % Get the maximum t-value (postive or negative) within the family of tests and store in a
    % vector. This is to create a null hypothesis distribution.
    t_max(iteration) = max(abs(t_stat(:, iteration)));  
end % of for iteration loop

% Calculating the 95th percentile of t_max values. This is the significance
% threshold for the test statistic (e.g. the t statistic)
% Calculates as 97.5th percentile for two-tailed testing
critical_t = prctile(t_max(1:n_iterations), ((1 - alpha_level / 2) * 100));

% Compare observed t statistics against critical_t and calculate resulting
% p-values corrected for multiple comparisons.
corrected_h = zeros(1,n_total_comparisons); % Preallocate
corrected_p = zeros(1,n_total_comparisons); % Preallocate

% Compare each result with the t-value threshold. Mark statistically
% significant when the t value > critical_t
corrected_h(abs(uncorrected_t) > critical_t) = 1;

% Calculating a p-value for each step
for step = 1:n_total_comparisons
    
    % Implementing a conservative p-value correction based on Phipson &
    % Smyth (2010)
    % Calculate the number of permutation samples with maximum statistics
    % larger than the observed test statistic for a given cluster
    b = sum(t_max(:) >= abs(uncorrected_t(step)));
    p_t = (b + 1) / (n_iterations + 1); % Calculate conservative version of p-value as in Phipson & Smyth, 2010
    p_t = p_t * 2; % Doubling p-value for two-tailed (essentially a Bonferroni correction for two tests)
    corrected_p(step) = p_t;
    
end % of for step loop

% Adjusting p-values that are larger than 1 (can occur due to doubling of
% p-values with two-tailed testing)
corrected_p(corrected_p > 1) = 1;

% Copy output into a results structure
Results.corrected_h = corrected_h;
Results.corrected_p = corrected_p;
Results.critical_t = critical_t;
Results.t_values = uncorrected_t;