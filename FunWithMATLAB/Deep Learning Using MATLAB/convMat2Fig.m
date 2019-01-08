% 
matFilder='E:\Deep Learning Using MATLAB\fc';
resutlFilder='E:\Deep Learning Using MATLAB\fig';
% extract name
cd (matFilder);
fileStrut=dir(matFilder);
fileName={fileStrut.name};
fileName=fileName(3:end)';
% mat to  figure
for i=1:length(fileName)
    fprintf('正在进行第%d个\n',i);
    mat=importdata(fileName{i});
    imagesc(mat);
    % save figure
    nameOfFig=strcat(fileName{i}(1:end-4),'.tif');
    print(gcf,'-dtiff','-r300',[resutlFilder,filesep,nameOfFig]);
end
fprintf('完成！\n');
