function extractedfc = lc_extract_fc(fcmatrix, mask)
% Used to extract fc values that in given mask
% INPUT:
% 	fcmatrix: functional connectivity matrix
%   mask: have the same dimension with fcmatrix
% OUTPUT:
%   extractedfc: extracted fc values
% within-network fc
nnode = size(fcmatrix,1);
mask_triu = triu(ones(nnode),1)==1;
mask_ext = mask .* mask_triu == 1;
extractedfc = fcmatrix(mask_ext);
end