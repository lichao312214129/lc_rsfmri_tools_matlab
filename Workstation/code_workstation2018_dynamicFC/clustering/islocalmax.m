function [tf, P] = islocalmax(A, isMaxSearch, varargin)
%ISLOCALEXTREMA Mark local minimum or maximum values in an array.
%
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.
%

%   Copyright 2017 The MathWorks, Inc.

    [dim, maxNumExt, minSep, minProm, flatType, x, dataVars] = ...
        parseInputs(A, varargin{:});

    returnProminence = nargout > 1;
    
    if isa(A, 'tabular')
        [tf,P] = isLocalExtremaTabular(A, dataVars, maxNumExt, minSep, ...
            minProm, flatType, x, isMaxSearch, returnProminence);
    else
        if (dim > ndims(A))
            % There are no local extrema in scalar dimensions.
            tf = false(size(A));
            if returnProminence
                P = zeros(size(A), getProminenceType(A));
            end
        else
            % Operate along rows.
            if (dim ~= 1)
                permvec = [dim, 1:(dim-1), (dim+1):ndims(A)];
                A = permute(A, permvec);
            end
            
            [tf, P] = isLocalExtremaArray(A, maxNumExt, minSep, minProm,...
                flatType, x, isMaxSearch, returnProminence);
            
            % Reverse permutation.
            if (dim ~= 1)
                tf = ipermute(tf, permvec);
                if returnProminence
                    P = ipermute(P, permvec);
                end
            end
        end
        % Reconvert to sparse if the input was sparse.
        if issparse(A)
            tf = sparse(tf);
            if returnProminence
                P = sparse(P);
            end
        end
    end

end

%--------------------------------------------------------------------------
function [tf, P] = isLocalExtremaTabular(A, dataVars, maxNumExt, minSep,...
    minProm, flatType, x, isMaxSearch, returnProminence)
% Search for local extrema in the variables of a table.

    % Check for valid data variables.
    dvValid = varfun(@validDataVariableType, A, 'InputVariables',...
        dataVars, 'OutputFormat', 'uniform');
    if ~all(dvValid)
        if any(varfun(@(x) isnumeric(x) && ~isreal(x), A, ...
            'InputVariables', dataVars, 'OutputFormat', 'uniform'))
            error(message("MATLAB:isLocalExtrema:ComplexInputArray"));
        end
        error(message("MATLAB:isLocalExtrema:NonNumericTableVar"));
    end
    
    % All variables must be column vectors or empties.
    varsAreColumns = varfun(@(x) iscolumn(x) || isempty(x), A, ...
        'InputVariables', dataVars, 'OutputFormat', 'uniform');
    if ~all(varsAreColumns)
        error(message("MATLAB:isLocalExtrema:NonVectorTableVariable"));
    end
    
    % The data can be processed as one large array if all of the variables
    % are the same type and if they are all columnar data.
    vtypes = varfun(@class, A, 'InputVariables', dataVars, ...
        'OutputFormat', 'cell');
    vtypes = unique(string(vtypes));
    tf = false(height(A), width(A));
    P = A(:, dataVars);
    if (numel(vtypes) == 1)
        % Process all table variables at once.
        [tf(:,dataVars), P{:,1:end}] = isLocalExtremaArray(...
            A{:,dataVars}, maxNumExt, minSep, minProm, flatType, x, ...
            isMaxSearch, returnProminence);
    else
        % Process table variables one at a time.
        for i = 1:length(dataVars)
            [tf(:,dataVars(i)), P.(i)] = isLocalExtremaArray(...
                A.(dataVars(i)), maxNumExt, minSep, minProm, flatType, ...
                x, isMaxSearch, returnProminence);
        end
    end
end

%--------------------------------------------------------------------------
function [tf, P] = isLocalExtremaArray(A, maxNumExt, minSep, minProm, ...
    flatType, x, isMaxSearch, returnProminence)
% Search for local extrema in an array.

    if isempty(A)
        tf = false(size(A));
        P = zeros(size(A), getProminenceType(A));
        return;
    end

    if isa(A, 'integer')
        cls = class(A);
        % Convert unsigned types to signed types to preserve diff sign. 
        % For integer types, prominence is always be an unsigned type.
        if cls(1) == 'u'
            scls = cls(2:end);
            imax = cast(intmax(scls), cls);
            B = zeros(size(A), scls);
            idx = A <= imax;
            B(idx) = cast(A(idx), scls) - intmax(scls) - 1;
            B(~idx) = cast(A(~idx) - imax - 1, scls);
            A = B;
        end
        % Reverse the sign of A, and then correct for the elements
        % that were saturated from intmin to intmax.
        if ~isMaxSearch
            satIdx = A == intmin(class(A));
            A = -A;
            A(~satIdx) = A(~satIdx)-1;
        end
    else
        if ~isMaxSearch
            A = -A;
        end
    end

    % Cast prominence threshold to the correct class.
    minProm = cast(minProm, getProminenceType(A));

    % Reshape A so that we only have 2 dimensions.
    sz = size(A);
    A = reshape(A, size(A,1), []);
    
    if isfloat(A) % single and double
        tf = false(size(A));
        P = zeros(size(A), getProminenceType(A));
        % Do all columns that have no NaN values.
        batchCols = ~any(isnan(A));
        if any(batchCols)
            [tf(:, batchCols), P(:, batchCols)] = doLocalMaxSearch(...
                A(:, batchCols), maxNumExt, minSep,  minProm, flatType, ...
                x, returnProminence);
        end
        % For each remaining column, remove the points that are NaN.
        nanColumns = find(~batchCols);
        if ~isempty(nanColumns)
            for j = 1:length(nanColumns)
                jdx = nanColumns(j);
                idx = ~isnan(A(:,jdx));
                [tf(idx,jdx), P(idx,jdx)] = doLocalMaxSearch(...
                    A(idx,jdx), maxNumExt, minSep, minProm, flatType, ...
                    x(idx), returnProminence);
            end
        end
    else % Integer types
        [tf, P] = doLocalMaxSearch(A, maxNumExt, minSep, minProm, ...
            flatType, x, returnProminence);
    end

    % Reshape the result to the original size of A.
    tf = reshape(tf, sz);
    if returnProminence
        P = reshape(P, sz);
    end

end

%--------------------------------------------------------------------------
function [maxVals, P] = doLocalMaxSearch(A, maxNumExt, minSep, minProm, ...
    flatType, x, returnProminence)
% Search for local maxima in an array without NaN.

    P = zeros(size(A), getProminenceType(A));
    if size(A,1) < 3
        maxVals = false(size(A));
        return;
    end

    % Replace all positive infinites with NaN temporarily.
    if isfloat(A)
        infMaxVals = isinf(A) & (A > 0);
        A(infMaxVals) = NaN;
    end

    % Get the local maxima and inflection points.
    flatTypeIsLast = strcmp(flatType, 'last');
    if flatTypeIsLast
        % Flip the array for the search, then revert the flip.
        [maxVals, inflectionPts] = getAllLocalMax(flip(A, 1));
        maxVals = flip(maxVals, 1);
        inflectionPts = flip(inflectionPts, 1);
    else
        [maxVals, inflectionPts] = getAllLocalMax(A);
    end

    % Recombine the finite and infinite local maxima.
    if isfloat(A)
        maxVals = maxVals | infMaxVals;
        A(infMaxVals) = Inf;
    end
    
    % Calculate the prominence and filter local maxima based on the minumum
    % prominence criteria.
    filterByMaxNum = any(maxNumExt < sum(maxVals));
    calculateProminence = returnProminence || filterByMaxNum || (minSep > 0);
    if (minProm > 0) || calculateProminence
        [maxVals, P] = filterByProminence(A, maxVals, inflectionPts, ...
            minProm, calculateProminence);
    end

    % Filter local maxima based on distance.
    if (minSep > 0)
        % This will also restrict to the top N most prominent maxima.
        maxVals = filterByDistance(A, P, maxVals, x, minSep, ...
            flatTypeIsLast);
    end
    
    % Restrict to the top N most prominent local maxima.
    if any(maxNumExt < sum(maxVals))
        maxVals = restrictNumberOfExtrema(A, maxVals, maxNumExt, P);
    end

    % Adjust results in flat regions.
    if ~((strcmp(flatType, 'first') || strcmp(flatType, 'last')) && ...
            ~returnProminence)
        [maxVals, P] = adjustFlatRegions(A, maxVals, flatType, P, ...
            returnProminence);
    end

end

%--------------------------------------------------------------------------
function [maxVals, inflectionPts] = getAllLocalMax(A)
% Find all local maxima along the rows of A.

    % Find local maxima.
    s = sign(diff(A));

    % Correct for repeated points.  To have the first local maxima of a
    % plateau marked as true, the sign of subsequent repeated values should
    % be set to the sign of the next non-zero difference.  This ensures
    % that the second order difference has the correct sign.
    if ~all(s(:))
        if isinteger(A)
            s = single(s);
        end
        s(s == 0) = NaN;
        s = fillmissing(s, 'next', 'EndValues', 'nearest');
    end

    % Find points where the second order difference is negative and pad the
    % result to be of the correct size.
    pad = true(1, size(A,2));
    maxVals = [~pad; diff(s) < 0; ~pad];

    % Ignore repeated values.
    uniquePts = [pad; (A(2:end,:) ~= A(1:(end-1),:))];
    if isfloat(A) && any(isnan(A(:)))
        uniquePts = uniquePts & ...
            [pad; ~(isnan(A(2:end,:)) & isnan(A(1:(end-1),:)))];
    end

    % Get the inflection points: every place where the first order
    % difference of A changes sign.  Remove duplicate points.  Consider end
    % points inflection points.
    inflectionPts = [pad; (s(1:(end-1),:) ~= s(2:end, :)) & ...
        uniquePts(2:(end-1),:); pad];
end

%--------------------------------------------------------------------------
function [maxVals, P] = filterByProminence(A, maxVals, inflectionPts, ...
    minProm, returnProminence)
% Remove local maxima not satisfying a prominence criteria.

    % Go through columns of the input.
    idx = 1:size(A,1);
    m = min(A);
    P = zeros(size(A), getProminenceType(A));

    for j = 1:size(A, 2)
        % Pull out local maxima and local minima.
        extremaList = idx(maxVals(:,j) | inflectionPts(:,j));
        isLocMax = maxVals(idx,j);

        % Iterate through all extrema.
        for i = 1:length(extremaList)
            % Skip localMins.
            if ~isLocMax(extremaList(i))
                continue;
            end
            localMaxValue = A(extremaList(i),j);
            
            % Non-finite points.
            if ~isfinite(localMaxValue)
                P(extremaList(i),j) = Inf;
                continue;
            end
            
            % If we filter by prominence but don't need to return the
            % computed prominence values, then do a quick skip if this
            % local maxima could not possibly fit the criteria.
            if ~returnProminence
                if isa(A, 'integer')
                    if unsignedDiff(localMaxValue, m(j)) < minProm
                        maxVals(extremaList(i),j) = false;
                        continue;
                    end
                elseif (localMaxValue - m(j)) < minProm
                    maxVals(extremaList(i),j) = false;
                    continue;
                end
            end
            
            % Initialize the lowest points on either side.
            localMins = localMaxValue([1 1]);
            left = i-1;
            right = i+1;
            % Search points to the left
            while left > 0
                if ~isLocMax(extremaList(left))
                    % Update left local minimum if this point is a minimum.
                    localMins(1) = min(localMins(1), ...
                        A(extremaList(left),j));
                elseif A(extremaList(left),j) > localMaxValue
                    % Exit if we found a larger local maximum.
                    break;
                end
                left = left - 1;
            end
            % Search points to the right
            while right <= length(extremaList)
                if ~isLocMax(extremaList(right))
                    % Update right local minimum if this point is a minimum.
                    localMins(2) = min(localMins(2), ...
                        A(extremaList(right), j));
                elseif A(extremaList(right),j) > localMaxValue
                    % Exit if we found a larger local maximum.
                    break;
                end
                right = right + 1;
            end
            % Figure out which localMin we will use to compute the
            % prominence.
            localMinToUse = max(localMins);
            % Compute the prominence.
            if isa(A, 'integer')
                P(extremaList(i),j) = unsignedDiff(localMaxValue, ...
                    localMinToUse);
            else
                P(extremaList(i),j) = localMaxValue - localMinToUse;
            end
            maxVals(extremaList(i),j) = P(extremaList(i),j) >= minProm;
        end
    end
end

%--------------------------------------------------------------------------
function maxVals = filterByDistance(A, P, maxVals, x, minSep, ...
    flatTypeIsLast)
% Remove local maxima that are too close to a larger local maxima.

    % Create a linear index array for each column.
    m = size(A,1);
    idx = 1:m;
    for j = 1:size(A,2)
        
        % Get the linear indices of all local maxima in this column.
        locMaxima = idx(maxVals(:,j));
        n = length(locMaxima);
        
        % Get the left and right indices for each local maxima in this
        % column.  These indices dictate the extent of each local maxima.
        leftIndices = x(locMaxima);
        rightIndices = leftIndices;
        if flatTypeIsLast
            % When 'FlatSelection' is 'last', each flat region is marked by
            % its rightmost point, so we need to extend the left side.
            for i = 1:n
                % Index of the current local maximum
                k = locMaxima(i);
                % Find how many elements it repeats to the left.
                if isfinite(A(k,j))
                    while (k > 0) && (A(k-1,j) == A(k,j))
                        k = k - 1;
                    end
                    leftIndices(i) = x(k);
                end
            end
        else
            % For all other 'FlatSelection' types, each flat region is
            % marked by the rightmost point, so we need to extend the
            % right side.
            for i = 1:n
                % Index of the current local maximum
                k = locMaxima(i);
                % Find how many elements it repeats to the right.
                if isfinite(A(k,j))
                    while (k < (m-1)) && (A(k+1,j) == A(k,j))
                        k = k + 1;
                    end
                    rightIndices(i) = x(k);
                end
            end
        end
        
        % Iterate through each local maxima.
        left = 1;
        right = 1;
        for i = 1:n
            % Find those maxima to the left that are still within range.
            while ((leftIndices(i) - rightIndices(left)) >= minSep)
                left = left + 1;
            end
            % Find those maxima to the right that are still within range.
            right = max(i, right);
            while ((right <= (n-1)) && ...
                    ((leftIndices(right+1) - rightIndices(i)) < minSep))
                right = right + 1;
            end
            % If this local maxima is Inf, move on.
            if ~isfinite(A(locMaxima(i),j))
                continue;
            end
            % Otherwise, find all values we have to compare against.
            leftIdx = locMaxima(left:(i-1));
            % Remove local maxima we already filtered out.
            leftIdx(~maxVals(locMaxima(left:(i-1)),j)) = [];
            leftMax = max(P(leftIdx,j));
            rightMax = max(P(locMaxima((i+1):right), j));
            % Remove this local maxima if there is another to the left
            % or right within range that is larger.
            if ~isempty(leftMax) && (leftMax >= P(locMaxima(i),j))
                maxVals(locMaxima(i),j) = false;
            elseif ~isempty(rightMax) && (rightMax > P(locMaxima(i),j))
                maxVals(locMaxima(i),j) = false;
            end
        end
    end

end

%--------------------------------------------------------------------------
function maxVals = restrictNumberOfExtrema(A, maxVals, maxNumExt, P)
% Keep only the N largest local maxima in each column

    idx = 1:size(A,1);
    for j = 1:size(A,2)
        % Get the linear indices of all local maxima in this column.
        locMaxima = idx(maxVals(:,j));
        % Get the values of all local maxima.
        [~, sortedIdx] = sort(P(locMaxima,j), 'descend');
        maxVals(locMaxima(sortedIdx((maxNumExt+1):end)), j) = false;
    end
end

%---------------------------------------------------------------------------
function [maxVals, P] = adjustFlatRegions(A, maxVals, flatType, P, ...
    returnProminence)
% Compensate for flat regions.

    if strcmp(flatType, 'center')
		% Go through the columns.
        [m,n] = size(A);
        for j = 1:n
            % Iterate through local maxima.
            ind = find(maxVals(:,j));
            for i = 1:length(ind)
                % Find the bounds of this flat region.
                leftBnd = ind(i);
                if ~isfinite(A(leftBnd,j))
                    continue;
                end
                rightBnd = leftBnd;
                while (A(rightBnd+1,j) == A(leftBnd,j)) && ((rightBnd+1) < m)
                    rightBnd = rightBnd + 1;
                end
                % Compute the center point and assign the prominence value.
                maxVals(leftBnd,j) = false;
                maxVals(floor((leftBnd+rightBnd)/2),j) = true;
                if returnProminence
                    P(leftBnd:rightBnd,j) = P(leftBnd,j);
                end
            end
        end
    elseif strcmp(flatType, 'all') || returnProminence
        % Mark all valid repeated points as local maxima.
        repetitions = [false(1, size(A,2)); A(2:end,:) == A(1:(end-1),:)];
        if isfloat(A)
            % +Inf local maxima are considered to be distinct.
            repetitions = repetitions & [true(1, size(A,2)); ...
                isfinite(A(2:end,:))];
        end
        flatTypeIsAll = strcmp(flatType, 'all');
		c = cumsum(~repetitions);
        % Go through the columns.
        for j = 1:size(A,2)
            % Create a mapping to all unique values in the input.
            if flatTypeIsAll
                % Use the mapping to mark all repeated local maxima.
                maxVals(:,j) = ismember(c(:,j), c(maxVals(:,j), j));
            end
            if returnProminence
                % Use the mapping to compute the prominence.
                promVals = splitapply(@max, P(:, j), c(:,j));
                P(:,j) = promVals(c(:,j));
            end
        end
    end

end

%--------------------------------------------------------------------------
function tf = isRealFiniteNonNegativeScalar(A, strictlyPositive)
% Determine if an input is a real, finite, non-negative scalar.

    tf = true;
    if ~isduration(A)
        tf = isreal(A);
    end
    if strictlyPositive
        tf = tf && isscalar(A) && (A > 0) && isfinite(A);
    else
        tf = tf && isscalar(A) && (A >= 0) && isfinite(A);
    end

end

%--------------------------------------------------------------------------
function [dim, maxNumExtrema, minSep, minProm, flatType, x, dataVars] = ...
    parseInputs(A, varargin)
% Parse input arguments.

    % Validate input array type.
    if isnumeric(A) || islogical(A)
        if ~isreal(A)
            error(message('MATLAB:isLocalExtrema:ComplexInputArray'));
        end
        AisTabular = false;
    elseif isa(A, 'table')  || isa(A, 'timetable')
        AisTabular = true;
    else
        error(message('MATLAB:isLocalExtrema:FirstInputInvalid'));
    end

    % Set default parameters.
    if AisTabular
        dim = 1;
        dataVars = 1:width(A);
    else
        dim = find(size(A) ~= 1,1); % default to first non-singleton dim
        if isempty(dim)
            dim = 2; % dim = 2 for scalar and empty A
        end
        dataVars = []; % not supported for arrays
    end
    minSep = 0;
    minProm = 0;
    flatType = 'center';
    x = [];
    userGaveMinSep = false;

    % Parse dim input.
    argIdx = 1;
    if (nargin > 1) && (isnumeric(varargin{argIdx}) || ...
            islogical(varargin{argIdx}))
        if AisTabular
            error(message('MATLAB:isLocalExtrema:DimensionTable'));
        end
        dim = varargin{argIdx};
        argIdx = 2;
        if ~isRealFiniteNonNegativeScalar(dim, true) || (fix(dim) ~= dim)
            error(message('MATLAB:isLocalExtrema:DimensionInvalid'));
        end
    end
    maxNumExtrema = size(A, dim);

    % Parse Name-Value Pairs.
    numRemainingArguments = nargin-1-(argIdx-1);
    if rem(numRemainingArguments, 2) ~= 0
        error(message('MATLAB:isLocalExtrema:NameValuePairs'));
    end

    nameOptions = [ "MaxNumExtrema", "MinSeparation", "MinProminence", ...
        "FlatSelection", "SamplePoints", "DataVariables"];
    for i = 1:2:numRemainingArguments
        if ~((ischar(varargin{argIdx}) && isrow(varargin{argIdx})) || ...
             (isstring(varargin{argIdx}) && isscalar(varargin{argIdx})))
            if AisTabular
                error(message('MATLAB:isLocalExtrema:InvalidNameTable'));
            else
                error(message('MATLAB:isLocalExtrema:InvalidNameArray'));
            end
        end
        optionMatches = startsWith(nameOptions, varargin{argIdx}, ...
            'IgnoreCase', true);
        % Multiple or no matches.
        if sum(optionMatches) ~= 1
            if AisTabular
                error(message('MATLAB:isLocalExtrema:InvalidNameTable'));
            else
                error(message('MATLAB:isLocalExtrema:InvalidNameArray'));
            end
        end
        if optionMatches(1) % MaxNumExtrema
            maxNumExtrema = varargin{argIdx+1};
            if ~(isnumeric(maxNumExtrema) || islogical(maxNumExtrema)) || ...
               ~isscalar(maxNumExtrema) || ~isreal(maxNumExtrema) || ...
               (maxNumExtrema <= 0) || (fix(maxNumExtrema) ~= maxNumExtrema)
                error(message('MATLAB:isLocalExtrema:MaxNumInvalid'));
            end
        elseif optionMatches(2) % MinSeparation
            minSep = varargin{argIdx+1};
            if ~isRealFiniteNonNegativeScalar(minSep, false)
                error(message('MATLAB:isLocalExtrema:MinSeparationInvalid'));
            end
            userGaveMinSep = true;
        elseif optionMatches(3) % MinProminence
            minProm = varargin{argIdx+1};
            if ~(isnumeric(minProm) || islogical(minProm)) || ...
               ~isRealFiniteNonNegativeScalar(minProm, false)
                error(message('MATLAB:isLocalExtrema:MinProminenceInvalid'));
            end
        elseif optionMatches(4) % FlatSelection
            flatOptions = [ "all", "first", "center", "last"];
            opt = varargin{argIdx+1};
            if ~((ischar(opt) && isrow(opt)) || ...
                 (isstring(opt) && isscalar(opt)))
                error(message('MATLAB:isLocalExtrema:FlatSelectionInvalid'));
            else
                tf = startsWith(flatOptions, varargin{argIdx+1}, ...
                    'IgnoreCase', true);
                if sum(tf) ~= 1 % No or multiple matches.
                    error(message('MATLAB:isLocalExtrema:FlatSelectionInvalid'));
                end
                flatType = flatOptions(tf);
            end
        elseif optionMatches(5) % SamplePoints
            if isa(A,'timetable')
                error(message('MATLAB:isLocalExtrema:SamplePointsTimeTable'));
            end
            x = varargin{argIdx+1};
            x = checkSamplePoints(x, A, false, dim);
        else % DataVariables
            if AisTabular
                dataVars = matlab.internal.math.checkDataVariables(A,...
                    varargin{argIdx+1},'isLocalExtrema');
            else
                error(message('MATLAB:isLocalExtrema:DataVariablesArray'));
            end
        end
        argIdx = argIdx + 2;
    end

    % Set default sample points.
    if isempty(x)
        if isa(A, 'timetable')
            x = checkSamplePoints(A.Properties.RowTimes,A,true,dim);
        else
            x = 1:size(A,dim);
        end
    end

    % Check that minimum separation is in the correct units.
    if isa(x, 'duration') || isa(x, 'datetime')
        if ~isa(minSep, 'duration')
            % Error if user gave a non-duration minimum separation.
            if userGaveMinSep
                if isa(A, 'timetable')
                    error(message('MATLAB:isLocalExtrema:SeparationMustBeDurationTimetable'));
                else
                    error(message('MATLAB:isLocalExtrema:SeparationMustBeDuration'));
                end
            end
            minSep = milliseconds(0);
        end
    elseif isa(minSep, 'duration')
        % Error if user gave a duration minimum separation.
        error(message('MATLAB:isLocalExtrema:SeparationCannotBeDuration'));
    end

    % For efficiency, we can check if we can just totally ignore sample
    % points and minimum separation.
    if minSep < min(diff(x))
        minSep = 0;
        x = 1:size(A,dim);
    end

end % parseInputs

%--------------------------------------------------------------------------
function x = checkSamplePoints(x,A,AisTimeTable,dim)
% Validate SamplePoints value.

    if AisTimeTable
        errBase = 'RowTimes';
    else
        errBase = 'SamplePoints';
    end
    
    % Empty timetables should not error
    if AisTimeTable && isempty(A)
        return;
    end
    
    if ~AisTimeTable
        if (~isvector(x) && ~isempty(x)) || ...
            (~isfloat(x) && ~isduration(x) && ~isdatetime(x))
            error(message('MATLAB:isLocalExtrema:SamplePointsInvalidDatatype'));
        end
        if numel(x) ~= (size(A,dim) * ~isempty(A))
            error(message(['MATLAB:isLocalExtrema:', errBase, 'Length']));
        end
        if isfloat(x)
            if ~isreal(x)
                error(message(['MATLAB:isLocalExtrema:', errBase, 'Complex']));
            end
            if issparse(x)
                error(message(['MATLAB:isLocalExtrema:', errBase, 'Sparse']));
            end
        end
    end
    if any(~isfinite(x))
        error(message(['MATLAB:isLocalExtrema:', errBase, 'Finite']));
    end
    
    x = x(:);
    if any(diff(x) <= 0) % && intConstOffset == 0
        if any(diff(x) == 0)
            error(message(['MATLAB:isLocalExtrema:', errBase, 'Duplicate']));
        else
            error(message(['MATLAB:isLocalExtrema:', errBase, 'Sorted']));
        end
    end
end % checkSamplePoints

%--------------------------------------------------------------------------
function tf = validDataVariableType(x)
% Indicates valid data types for table variables
    tf = (isnumeric(x) || islogical(x)) && isreal(x) && ...
        ~(isinteger(x) && ~isreal(x));
end

%--------------------------------------------------------------------------
function D = unsignedDiff(a, b)
% Compute the difference of two signed integer values and return as an
% unsigned integer value.

    if sign(a) == sign(b)
        D = cast(a - b, ['u', class(a)]);
    else % a is always greater than b, so a > 0, b < 0
        D = cast(a, ['u', class(a)]) + cast(-b, ['u', class(a)]);
        if b == intmin(class(b))
            D = D + 1;
        end
    end

end

%--------------------------------------------------------------------------
function pt = getProminenceType(A)
    if isinteger(A) && startsWith(class(A), 'i')
        pt = ['u', class(A)];
    else
        pt = class(A);
    end
end