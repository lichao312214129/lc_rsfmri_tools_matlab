function [Results] = multcomp_fdr_bh(p_values, varargin)
%
% This function receives a vector of p-values and outputs
% false discovery rate-corrected null hypothesis test results (Benjamin-Hochberg procedure).
% The number of tests is determined by the length of the vector of p-values.
%
% Benjamini, Y., & Hochberg, Y. (1995). Controlling the false discovery rate: 
% A practical and powerful approach to multiple testing. Journal of the 
% Royal Statistical Society. Series B (Methodological), 57, 289-300. 
% Stable link:http://www.jstor.org/stable/2346101 
%
%
% Inputs:
%
%   p_values       vector of p-values from the hypothesis tests of interest
%
%  'Key1'          Keyword string for argument 1
%
%   Value1         Value of argument 1
%
% Optional Keyword Inputs:
%
%   alpha               uncorrected alpha level for statistical significance, default 0.05
%
% Outputs:
%
%   Results structure containing:
%
%   corrected_h     vector of false discovery rate corrected hypothesis tests 
%                   derived from comparing p-values to false discovery rate 
%                   adjusted critical alpha level. 
%                   1 = statistically significant, 0 = not statistically significant
%
%   critical_alpha      the adjusted critical alpha for the false
%                       discovery rate procedure. p-values smaller
%                       or equal to this value are declared
%                       statistically significant. This value is 0 
%                       if no tests were statistically significant.
%
%
% Example:      [Results] = multcomp_fdr_bh(p_values, 'alpha', 0.05)
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


%% Benjamini-Hochberg False Discovery Rate Correction
n_total_comparisons = length(p_values); % Get the number of comparisons
fdr_corrected_h = zeros(1, length(p_values)); % preallocate

sorted_p = sort(p_values); % Sort p-values from smallest to largest

% Find critical k value
for benhoch_step = 1:n_total_comparisons
    if sorted_p(benhoch_step) <= (benhoch_step / n_total_comparisons) * alpha_level
        benhoch_critical_alpha = sorted_p(benhoch_step);
    end
end

% If no steps are significant set critical alpha to zero
if ~exist('benhoch_critical_alpha', 'var')
    benhoch_critical_alpha = 0;
end

% Declare tests significant if they are smaller than or equal to the adjusted critical alpha
fdr_corrected_h(p_values <= benhoch_critical_alpha) = 1;

%% Copy output into Results structure
Results.corrected_h = fdr_corrected_h;
Results.critical_alpha = benhoch_critical_alpha;
