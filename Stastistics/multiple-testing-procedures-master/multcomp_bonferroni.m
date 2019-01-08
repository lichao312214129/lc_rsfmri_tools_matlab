function [Results] = multcomp_bonferroni(p_values, varargin)
%
% This function receives a vector of p-values and outputs
% Bonferroni-corrected results. The number of tests is
% determined by the length of the vector of p-values. 
% This function outputs both the corrected alpha level and 
% Bonferroni-corrected p-values.
%
%
% Dunn, O. J. (1959). Estimation of the medians for dependent variables. 
% Annals of Mathematical Statistics, 30(1), 192-197. doi 10.1214/aoms/1177706374
%
% Dunn, O.J. (1961). Multiple comparisons among means. Journal of the 
% American Statistical Association, 56(293), 52-64. doi 10.1080/01621459.1961.10482090
%
%
% Inputs:
%
%   p_values    vector of p-values from the hypothesis tests of interest
% 
%  'Key1'          Keyword string for argument 1
%
%   Value1         Value of argument 1
% 
% Optional Keyword Inputs:
%
%   alpha       uncorrected alpha level for statistical significance, default 0.05
%
%
% Outputs:
%
%   Results structure containing:
%
%   corrected_h                 vector of Bonferroni-corrected hypothesis tests 
%                               derived from comparing p-values to Bonferroni 
%                               adjusted critical alpha level. 
%                               1 = statistically significant, 
%                               0 = not statistically significant
%
%   corrected_alpha                 adjusted alpha level. p-values below
%                                   threshold are declared statistically
%                                   significant.
%
%   uncorrected_p       Uncorrected p-values
%
%   corrected_p         Bonferroni-corrected p-values. These are the
%                       uncorrected p-values multiplied by the number of
%                       tests.
%
%
% Example:      [Results] = multcomp_bonferroni(p_values, 'alpha', 0.01)          
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
    'alpha', 0.05);

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
clear options;

%% Bonferroni correction
n_total_comparisons = length(p_values); % Get the number of comparisons
bonferroni_corrected_alpha = alpha_level / n_total_comparisons; % Calculate bonferroni-corrected alpha
bonferroni_corrected_h = zeros(1, length(p_values)); % preallocate
bonferroni_corrected_h(p_values < bonferroni_corrected_alpha) = 1; % Compare each p-value to the corrected threshold.

% Multiply p-values by the number of tests
bonferroni_corrected_p = p_values * n_total_comparisons;

%% Copy output into Results structure
Results.corrected_h = bonferroni_corrected_h;
Results.corrected_alpha = bonferroni_corrected_alpha;
Results.uncorrected_p = p_values;
Results.corrected_p = bonferroni_corrected_p;
