X=rand(10000,'single'); %定义在CPU上的一个10x10的随机初始化数组
   GX=gpuArray(X);      %在GPU开始数组GX，并且将X的值赋给GX
tic;GX2=GX.*GX;toc

tic;X.*X;toc


    [data_inmask]=gpuArray(data_inmask);
    [dataTest]=gpuArray(dataTest);