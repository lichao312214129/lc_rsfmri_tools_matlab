function groupfile(isubjpath,file_to_move, outdir)
% Group produced file to another outdir
[~, foldername] = fileparts(isubjpath);
outsubdir = fullfile(outdir,foldername);
if ~(exist(outsubdir,'dir') == 7)
    mkdir(outsubdir);
end
nf = numel(file_to_move);
for j = 1:nf
    try
        [~,outfile,suffix] = fileparts(file_to_move{j});
        movefile(file_to_move{j}, outsubdir);
    catch
        disp('No such file');
    end
end
end