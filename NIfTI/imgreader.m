function [imgs,niiout] = imgreader(filenames,pathnames)
% reads in nifti images
if iscell(filenames{1})
    levsize = size(filenames);
    imgs = cell(levsize);
    nsub = length(filenames{1});
    for i = 1:levsize(1)
        for j = 1:levsize(2)
            curfiles = filenames{i,j};
            curpath = pathnames{i,j};
            for s = 1:nsub
                curnii = load_nii([curpath curfiles{s}]);
                if s == 1
                    curimgs = NaN([size(curnii.img) nsub]);
                    niiout = curnii;
                end
                curimgs(:,:,:,s) = curnii.img;
            end
            imgs{i,j} = curimgs;
        end
    end  
else
    nsub = length(filenames);
    if ischar(pathnames)
        for s = 1:nsub
            curnii = load_nii([pathnames filenames{s}]);
            if s == 1
                imgs = NaN([size(curnii.img) nsub]);
                niiout = curnii;
            end
            imgs(:,:,:,s) = curnii.img;
        end
    elseif length(pathnames) == length(filenames)
        for s = 1:nsub
            curnii = load_nii([pathnames{s} filenames{s}]);
            if s == 1
                imgs = NaN([size(curnii.img) nsub]);
                niiout = curnii;
            end
            imgs(:,:,:,s) = curnii.img;
        end
    else
        error('Files must all originate from same directory or a different directory for each file');
    end
end
end