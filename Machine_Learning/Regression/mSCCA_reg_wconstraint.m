function [c_arr,w_arr,Corr_mat] = mSCCA_reg_wconstraint(X_arr, Spar_arr,w_sgn_arr,niter)

%% this function calculates sparse CCA weights between sets of variables
% Ref. "Identification of neurobehavioural symptom groups based on shared
% brain mechanisms"
%% Inputs:
% X_arr: this is a 1 x mv cell array of matrices, where mv is the number of
% matrices to be compared in the analysis conducted. Each cell of the
% matrix should contain a matrix represeting a view of the data.
% Spar_arr: this is a 1 x mv array. This array should contain sparsity
% values for each of the views to be compared in the analysis.
% w_sgn_arr: this is a 1 x mv array. Value in an array specify whether weight
% vectors should be constrained to be positive (1), negative(-1) or
% unconstrained (0).
% niter: number of iterrations script must run through
%% Outputs:
% c_arr: this is a 1 x mv cell array of canonical correlates, one for each
% view of the data.
% w_arr: this is a 1 x mv cell array of canonical vectors, one for each
% view of the data.
% Corr_mat: this is a mv x mv correlation matrix. Each element of the matrix
% specifies the correlation between associated canonical correlates.
% Example:
% X_arr{1}=rand(100,50);
% X_arr{2}=rand(100,10);
% X_arr{3}=rand(100,100);
% Spar_arr= [0.9 0.9 0.9];
% w_sgn_arr = [1 0 0];
% niter = 100;
% [c_arr,w_arr,Corr_mat] = mSCCA_reg_wconstraint(X_arr, Spar_arr,w_sgn_arr,niter);
%% Initialise canonical correlate values, set sparsity parameters

w_arr = cell(1,size(X_arr,2));
r_arr = w_arr;
for i = 1:size(X_arr,2)
    if size(X_arr{1,i},2)~=1
        w_temp = randn(size(X_arr{1,i},2),1);   % here, we initialise weight vectors for use in msCCA by generating vectors of random numbers
        w_temp = w_temp/norm(w_temp,2);
    else
        w_temp = w_sgn_arr(i);
    end
    w_arr{i} = w_temp;
    % w_arr is a 1 x mv cell array of weight vectors
    
    
    r_temp = round((sqrt(size(X_arr{1,i},2))*Spar_arr(1,i)),2);  % here, we set sparsity values for use in the different data views
    if (r_temp <=1)
        r_temp = 1;
    else
    end
    r_arr{i} = r_temp;                         % r_arr is a 1 x mv array of sparsity values, for use in the msCCA analysis
end

%% run the msCCA model between the different data views
c_arr = zeros(size(X_arr{1,1},1),size(X_arr,2));
for n = 1:niter  % the algorithm used here is iterative. The number of iterations used is niter.
    n
    for j = 1:size(X_arr,2) % in this loop, we apply the msCCA algorithm in each view of the data
        if size(X_arr{1,j},2)~=1
            
            a = scca_vec(X_arr,w_arr,j); %% here, we calculate scca_vectors on the basis of the scca_vec subroutine
            
            if (w_sgn_arr(j) == 0)
                a = a;
            elseif (w_sgn_arr(j) == 1)
                a = subplus(a);
            else
                a = -subplus(-a);
            end
            
            sygna = (((a > 0)*2) - 1);     %% here, we renormalise the canonical vectors to have a 2-norm of one
            S_p = abs(a);
            S = sygna.*(S_p.*(S_p > 0));
            a = S;
            w = a/norm(a,2);
            norm_wr = round(norm(w,1),2);
            
            w = scca_sparse(w,a,norm_wr,r_arr{j},sygna); %% here, we apply a subroutine to apply sparsity to canonical vectors
            
        else
            w = w_sgn_arr(j);
        end
        
        w_arr{j} = w;
        c_arr(:,j) = (X_arr{j})*w_arr{j}; %% calculate canonical correlates
        
    end
    
    
    Corr_mat = corr(c_arr,c_arr);
    
end

[b,bint,r,rint,stats] = regress(zscore(c_arr(:,1)),zscore(c_arr(:,2:size(c_arr,2))));

end

function a = scca_vec(X_arr,w_arr,j) % this sub-routine is used to calculate the correlation between sets

if round(size(w_arr{j},1))~=1
    if j == 1
        w_adder = 2:size(X_arr,2);
    else
        w_adder = 1;
    end
    a = zeros(size(w_arr{j}));
    for x = 1:size(w_adder,2)
        if (w_adder(x))>=1
            a_add = (((X_arr{j})')*(X_arr{w_adder(x)}))*(w_arr{w_adder(x)});
            a = a+a_add;
        else
        end
    end
else
end

end


function w = scca_sparse(w,a,norm_wr,r,sygna) % this sub-routine is used to apply sparsity to the canonical vectors

if (round(size(w,1))~=1)
    
    if  (norm_wr >= r);
        
        deltamax = max(abs(a))/2;
        delta_temp = 0;
        
        while (norm_wr ~= r)
            
            delta_sign = (((norm(w,1) > r)*2) -1);
            delta = delta_temp + ((delta_sign)*(deltamax));
            S_p = ((abs(a))-delta);
            S = sygna.*(S_p.*(S_p > 0));
            w = S/norm(S,2);
            norm_wr = round(norm(w,1),2);
            delta_temp = delta;
            deltamax = deltamax/2;
        end
    else
    end
else
end

end
