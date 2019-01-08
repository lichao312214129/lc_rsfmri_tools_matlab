function [F,P,B]=lc_ancova_regression()
%% =================================================================
% 一般线性模型的方法(协方差分析),进行线性回归
% 代码部分引用自dpabi软件，请引用
%% =================================================================

% input
path_DependentVariable='D:\others\刘婷婷科研数据\母乳喂养\RD.xlsx';
path_IndependentVariable='D:\others\刘婷婷科研数据\母乳喂养\Preterm-BreastFeeding.xlsx';
path_Covariates='D:\others\刘婷婷科研数据\母乳喂养\Preterm-Covariates.xlsx';

% load data
DependentVariable=xlsread(path_DependentVariable);
IndependentVariable=xlsread(path_IndependentVariable);
Covariates=xlsread(path_Covariates);

% 下面一行代码用于测试代码的准确性，将自变量第一行复制给第一列因变量
% 这样第一列肯定有相关
% DependentVariable(:,1)=IndependentVariable(:,1);
% 整理数据

% ancova
for i=1:size(DependentVariable,2)
    [F(i),P(i),B(:,i)]=y_ancova1(DependentVariable(:,i),IndependentVariable,Covariates);
end
B=B(2:end,:);
end

function [F,P,B]=y_ancova1(DependentVariable,IndependentVariable,Covariates)

if nargin==2
    Covariates=[];
end

% Construct dummy variable
N=size(DependentVariable,1);

% 回归子的自由度=未添加常量的所有待估计的系数数目
Df_Group=size([IndependentVariable,Covariates],2);
% 残差的自由度=总自由度-Df_Group
Df_E=N-Df_Group-1-Df_Group;

%% 利用分层回归思想，看净整量是否有统计学意义
% Calculate SSE_H: sum of squared errors when H0 is true
[~,r,SSE_H,SSR] = y_regress_ss1(DependentVariable,[ones(N,1),Covariates]);
% Calulate SSE
[B,r,SSE,SSR] = y_regress_ss1(DependentVariable,[ones(N,1),IndependentVariable,Covariates]);
% Calculate F
F=((SSE_H-SSE)/Df_Group)/(SSE/Df_E);
P =1-fcdf(F,Df_Group,Df_E);
end

function [b,r,SSE,SSR, T, TF_ForContrast, Cohen_f2] = y_regress_ss1(y,X,Contrast,TF_Flag)
[n,ncolX] = size(X);
[Q,R,perm] = qr(X,0);
p = sum(abs(diag(R)) > max(n,ncolX)*eps(R(1)));
if p < ncolX,
    R = R(1:p,1:p);
    Q = Q(:,1:p);
    perm = perm(1:p);
end
b = zeros(ncolX,1);
b(perm) = R \ (Q'*y);

if nargout >= 2
    yhat = X*b;                     % Predicted responses at each data point.
    r = y-yhat;                     % Residuals.
    if nargout >= 3
        SSE=sum(r.^2);
        if nargout >= 4
            SSR=sum((yhat-mean(y)).^2);
            
            if nargout >= 5
                %Also output T value for each beta. Referenced from regstats.m
                [Q,R] = qr(X,0);
                ri = R\eye(ncolX);
                T = b./sqrt(diag(ri*ri' * (SSE/(n-ncolX))));
                
                if nargout >= 6
                    %YAN Chao-Gan 121220. Also support T-test or F-test for a given contrast.
                    % Have contrast
                    if strcmpi(TF_Flag,'T')
                        std_e = sqrt(SSE/(n-ncolX));        % Standard deviation of the noise
                        d = sqrt(Contrast*(X'*X)^(-1)*Contrast');
                        TF_ForContrast = (Contrast*b)./(std_e*d);           % T-test
                        
                    elseif strcmpi(TF_Flag,'F')
                        X0 = X(:,~Contrast);
                        ncolX0 = size(X0,2);
                        if ncolX0>0
                            b0 = (X0'*X0)^(-1)*X0'*y; % Regression coefficients (restricted model)
                            r0 = y-X0*b0;
                            SSE0 = sum(r0.^2); % Estimate of the residual sum-of-square of the restricted model (SSE0)
                        else
                            SSE0 = sum(y.^2,1);
                        end
                        TF_ForContrast = ((SSE0-SSE)/(ncolX-ncolX0))./(SSE/(n-ncolX)); % F-Test
                        
                    end
                    
                    if nargout >= 7
                        %YAN Chao-Gan 170714. Added Cohen's f squared (Effect Size)
                        X0 = X(:,~Contrast);
                        ncolX0 = size(X0,2);
                        if ncolX0>0
                            b0 = (X0'*X0)^(-1)*X0'*y; % Regression coefficients (restricted model)
                            r0 = y-X0*b0;
                            SSE0 = sum(r0.^2); % Estimate of the residual sum-of-square of the restricted model (SSE0)
                        else
                            SSE0 = sum(y.^2,1);
                        end
                        Cohen_f2 = (SSE0-SSE)/SSE; % Cohen's f squared (Effect Size)
                    end
                end
                
            end
            
        end
    end
end
end

