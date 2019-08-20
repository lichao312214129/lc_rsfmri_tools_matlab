function lc_NBSstat()
% Revised and combinated from NBS
% Refer and thanks to NBS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
g1=rand(50,5)+1;
g2=rand(50,5)+0.5;
cov = rand(100,3);

GLM.perms = 100;
GLM.X = [[ones(50,1);zeros(50,1)], [zeros(50,1);ones(50,1)],cov];  % global mean-independent-covariance
GLM.y = [g1;g2];
GLM.contrast = [1 1 0 0 0];
GLM.test = 'ftest';
[test_stat,P1]=NBSglm(GLM);

[F P]=y_ancova1(GLM.y(:,2),[zeros(50,1);ones(50,1)],cov);
end