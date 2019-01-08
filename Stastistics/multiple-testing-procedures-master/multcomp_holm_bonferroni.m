function [Results] = multcomp_holm_bonferroni(p_values, varargin)
%
% This function receives a vector of p-values and outputs
% Holm-Bonferroni corrected results. The number of tests is
% determined by the length of the vector of p-values.
%
% Holm, S. (1979). A simple sequentially rejective multiple test procedure. 
% Scandinavian Journal of Statistics 6 (2): 65-70.
%
% Inputs:
%
%   p_values        vector of p-values from the hypothesis tests of interest
%
%  'Key1'          Keyword string for argument 1
%
%   Value1         Value of argument 1
%
% Optional Keyword Inputs:
%
%   alpha           uncorrected alpha level for statistical significance, 
%                   default 0.05
%
% Outputs:
%
%   Results structure containing:
%
%   corrected_h    vector of Holm-Bonferroni corrected hypothesis tests 
%                  derived from comparing p-values to Holm-Bonferroni 
%                  adjusted critical alpha level. 
%                  1 = statistically significant, 0 = not statistically significant
%
%   critical_alpha      the Holm-Bonferroni adjusted alpha level. 
%                       p-values smaller than this are declared as
%                       statistically significant.
%
% Example:  [Results] = multcomp_holm_bonferroni(p_values, 'alpha', 0.05)  
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


%% Holm-Bonferroni Correction
n_total_comparisons = length(p_values); % Get the number of comparisons
holm_corrected_h = zeros(1, length(p_values)); % preallocate

sorted_p = sort(p_values); % Sort p-values from smallest to largest
found_crit_alpha = 0; % Reset to signify that we have not found the Holm-Bonferroni corrected critical alpha level

for holm_step = 1:n_total_comparisons
   % Iteratively look for the critical alpha level
   if sorted_p(holm_step) > alpha_level / (n_total_comparisons + 1 - holm_step) && found_crit_alpha == 0
       holm_corrected_alpha = sorted_p(holm_step);
       found_crit_alpha = 1;
   end  
end

if ~exist('holm_corrected_alpha', 'var') % If all null hypotheses are rejected
    holm_corrected_alpha = alpha_level;
end

holm_corrected_h(p_values < holm_corrected_alpha) = 1; % Compare each p-value to the corrected threshold.

%% Copy output to Results structure
Results.corrected_h = holm_corrected_h;
Results.critical_alpha = holm_corrected_alpha;
