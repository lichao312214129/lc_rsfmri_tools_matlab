%% ======================================================
handles.img_path=pwd;
handles.img_path_name={};
handles.mask_data=[];
handles.how_stand='demean';
% Zstandard
% scale to ([-1,1])
% Fisher-Z transformation
% divmean
% demean
handles.save_folder=pwd;
%% ======================================================

[file,path] = uigetfile('*.nii;*.img;*.nii.gz','Select source data',pwd,'MultiSelect','on');
try
    fun=@(a) fullfile(path,a);
    img_path_name = cellfun(fun,file, 'UniformOutput',false);
catch
    img_path_name = fullfile(path,file);
end
handles.img_path_name=img_path_name;


[mask_name,mask_path]=uigetfile('*.nii;*.img;*.nii.gz','Select mask',pwd);
mask_data=load_nii(fullfile(mask_path,mask_name));
handles.mask_data = mask_data.img;
% mask
handles.mask_data=handles.mask_data~=0;


save_folder=uigetdir('save_folder','Save folder');
handles.save_folder=save_folder;


if iscell(handles.img_path_name)
    len_img = length(handles.img_path_name);
else
    len_img = 1;
end
for i=1:len_img
    fprintf('%d/%d\n',i,len_img)
    %     [img,h]=load_nii(handles.opt.img_path_name{i});
    if iscell(handles.img_path_name)
        [~,name,suffix]=fileparts(handles.img_path_name{i});
        img_struct = load_nii(handles.img_path_name{i});
        img = double(img_struct.img);
    else
        [~,name,suffix]=fileparts(handles.img_path_name);
        img_struct = load_nii(handles.img_path_name);
        img = double(img_struct.img);
    end
    
    if strcmp(handles.how_stand,'Zstandard')
        if  ~isempty(handles.mask_data)
            img_inmask=img(handles.mask_data);
        else
            img_inmask=img;
        end
        mean_inmask=mean(img_inmask);
        mystd=std(img_inmask);
        zvalues=(img-mean_inmask)./mystd;
        if  ~isempty(handles.mask_data)  % make sure out mask data is zeros
            zvalues(~handles.mask_data)=0;
        end
        %save
        name=fullfile(handles.save_folder,strcat('z_', name, suffix));
        %         save_nii(img_struct,zvalues,h,name)
        img = zvalues;
        img_struct.img = img;   
        save_nii(img_struct,name);
        
    elseif strcmp(handles.how_stand,'scale to ([-1,1])')
        svalues=zeros(size(img));
        if  ~isempty(handles.mask_data)
            % Note that: MATLAB have BUG of mapminmax, I fix the BUG
            % directly using the Algorithms (ymax-ymin)*(img_inmask-xmin)/(xmax-xmin) + ymin;
            img_inmask = img(handles.mask_data);
            xmax = max(img_inmask);
            xmin = min(img_inmask);
            ymin = -1;
            ymax = 1;
            svalues(handles.mask_data) = (ymax-ymin)*(img_inmask-xmin)/(xmax-xmin) + ymin;
            svalues(~ handles.mask_data) = 0;  % make sure out mask data is zeros
        else
            xmax = max(img(:));
            xmin = min(img(:));
            ymin = -1;
            ymax = 1;
            svalues = (ymax-ymin)*(img-xmin)/(xmax-xmin) + ymin;
        end
        %save
        name=fullfile(handles.save_folder,strcat('scale_', name, suffix));
        %         save_nii(img_struct,svalues,h,name)
        img = svalues;
        img_struct.img = img;
        save_nii(img_struct,name);
        
    elseif strcmp(handles.how_stand,'Fisher-Z transformation')
        fisherzvalue=0.5*log((1+img)./(1-img));
        if  ~isempty(handles.mask_data)  % make sure out mask data is zeros
            fisherzvalue(~handles.mask_data)=0;
        end
        %save
        name=fullfile(handles.save_folder,strcat('fisherz_', name, suffix));
        %         save_nii(img_struct,fisherzvalue,h,name)
        img = fisherzvalue;
        img_struct.img = img;
        save_nii(img_struct,name);
        
    elseif strcmp(handles.how_stand,'divmean')
        if  ~isempty(handles.mask_data)
            img_inmask=img(handles.mask_data);
        else
            img_inmask=img;
        end
        mean_inmask=mean(img_inmask);
        divmean_values=img./mean_inmask;
        if  ~isempty(handles.mask_data)  % make sure out mask data is zeros
            divmean_values(~handles.mask_data)=0;
        end
        %save
        name=fullfile(handles.save_folder,strcat('divmean_', name, suffix));
        %         save_nii(img_struct,divmean_values,h,name);
        img = divmean_values;
        img_struct.img = img;
        save_nii(img_struct,name);
        
    elseif strcmp(handles.how_stand,'demean')
        if  ~isempty(handles.mask_data)
            img_inmask=img(handles.mask_data);
        else
            img_inmask=img;
        end
        mean_inmask=mean(img_inmask);
        demean_values=img-mean_inmask;
        if  ~isempty(handles.mask_data)  % make sure out mask data is zeross
            demean_values(~handles.mask_data)=0;
        end
        %save
        name=fullfile(handles.save_folder,strcat('demean_', name,suffix));
        %         save_nii(img_struct,demean_values,h,name)
        img = demean_values;
        img_struct.img = img;
        save_nii(img_struct,name);
        
    else
        fprintf('This standardization method: %s not supported\n',handles.how_stand)
        return
    end
end
fprintf('All done!\n')