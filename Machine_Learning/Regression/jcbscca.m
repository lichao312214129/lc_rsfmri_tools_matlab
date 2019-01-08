function [u,v, objFun] = jcbscca(data, para,u0,v0)
% --------------------------------------------------------------------
% Joint connectivity based sparse CCA algorithm
% handle fused lasso and brain connectivity 
% --------------------------------------------------------------------
% Input:
%       - data.X, Multimodal Imaging feature matrix
%       - data.Y, Genetic data matrix
%       - data.PX, brain connectivity penalty matrix
%       - data.PY, genetic connectivity panalty matrix
%       - paras: lambda1, lambda2, tau 
%
% Output:
%       - u, weight of X
%       - v, weight of Y
%
%---------------------------------------------------------------------
% Author: Mansu Kim, mansooru@skku.edu or mansooru.kim@gamil.com
% Date created: July-30-2018
% @Sungkyunkwan univertity.
% --------------------------------------------------------------------

% Setting
n_img = size(data.Y{1},2); 
n_snp = size(data.X{1},2); 
n_class = data.class; 

% Set data
X = data.X;
Y = data.Y;

% connectivity penalty
H1{1,1} = data.PX{1};
H2{1,1} = data.PY{1};
H2{2,1} = data.PY{2};

% Initialization
u_new = u0;
v = repmat(v0,1,1,n_class); 

d1{1,1} = 1 ./ sqrt(u_new.^2+eps);
d2{1,1} = 1 ./ sqrt(v(:,1,1).^2+eps);
d2{1,2} = 1 ./ sqrt(v(:,1,2).^2+eps);

max_iter = 400;
err = 0.005; % 0.01 ~ 0.001
diff_obj = err*10;

% set parameters
lambda1 = para(3);
lambda2{1} = para(4); lambda2{2} = para(5);
tau = para(6);

%figure; hold on;
for i = 1: max_iter
    beta_1 = para(1);%max(n_snp*0.5/1.1^i,para(1));
    beta_2 = para(2);%max(n_img*0.5/1.1^i,para(2));
    
    % Solved u, fixed V
    u = u0;%zeros(n_snp,1);  
    for ic = 1 : n_class
        u = u + X{ic}'*(Y{ic}*v(:,ic)./n_img);
    end
    u = u + lambda1*diag(H1{1}*u_new)*(diag(d1{1})*u_new);
    
    % update u
    u_new = soft(u,fix(beta_1));
    u = u_new;
    d1{1,1} = 1 ./ sqrt(u.^2+eps);
    
    % Solved V, fixed u
    for ic = 1 : n_class
        v(:,1,ic) = Y{ic}'*(X{ic}*u./n_snp) + lambda2{ic}*diag(H2{ic}*v(:,1,ic))*(diag(d2{ic})*v(:,1,ic));
    end
    [v_new, ~] = flsa_2c(v, tau);
    v_new = vsoft(v_new,fix(beta_2));
    
    % update v
    v = v_new;
    d2{1,1} = 1 ./ sqrt(v(:,1,1).^2+eps);
    d2{2,1} = 1 ./ sqrt(v(:,1,2).^2+eps);
    
    % Cost function and check convergence
    for ic = 1 : n_class
        objFun(i) = -u'*X{ic}'*Y{ic}*v(:,ic) + lambda2{ic}*v(:,ic)'*H2{ic}*v(:,ic) + beta_2*sum(abs(v(:,ic)));
    end
    objFun(i) = objFun(i) + beta_1*sum(abs(u)) + tau*sum(abs(v(:,1)-v(:,2))) + lambda1*u'*H1{1}*u;
    
    if i ~= 1
        diff_obj = abs((objFun(i)-objFun(i-1))/objFun(i-1)); % relative prediction error
        %plot(i,diff_obj,'o');
    end
    
    if diff_obj < err
        %hold off; 
        break;
    end
end

% scale u and v
scale1 = sqrt(u'*X{1}'*X{1}*u);
u = u./scale1;
scale2 = sqrt(v(:,1)'*Y{1}'*Y{1}*v(:,1));
v(:,1) = v(:,1)./scale2;
scale3 = sqrt(v(:,2)'*Y{2}'*Y{2}*v(:,2));
v(:,2) = v(:,2)./scale3;
end


% function to solve fused lasso in two-class cases.
function [vf,vhat] = flsa_2c(v,lam)
dx = (v(:,:,1)-v(:,:,2))/2;
dx = sign(dx).*min(abs(dx),lam);
vf(:,:,1) = v(:,:,1)-dx;
vf(:,:,2) = v(:,:,2)+dx;
vhat = vf;
end

% Soft-thresholding with normalization
function y = soft(x,lambda)
n = size(x,1);
temp = sort(abs(x),'descend');
th = temp(lambda,:);
y = sign(x).*max(abs(x)-repmat(th,n,1),0);
ny = sqrt(sum(y.^2));
y = y./repmat(ny,n,1);
end

% vSoft-thresholding with normalization
function v = vsoft(x,lam)
[n,k,nc] = size(x);
th_pos = fix(lam);
th_pos = repmat(th_pos,1,k*nc);
x = reshape(x,n,k*nc,1);
temp = sort(abs(x),'descend');
th = temp(th_pos);
y = sign(x).*max(abs(x)-repmat(th,n,1),0);
v = reshape(y,n,k,nc);
fnorm = sqrt(sum(sum(v.^2,3),1));
v = v./repmat(fnorm,n,1,nc);
end