%% ======================================================
handles.img_path=pwd;
handles.img_path_name={};
handles.mask_data=[];
handles.how_stand='Zstandard';
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
handles.mask_data=y_Read(fullfile(mask_path,mask_name));
% 不等于0的为mask
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
    %     [img,h]=y_Read(handles.opt.img_path_name{i});
    if iscell(handles.img_path_name)
        [~,name,suffix]=fileparts(handles.img_path_name{i});
        img_strut = load_nii(handles.img_path_name{i});
    else
        [~,name,suffix]=fileparts(handles.img_path_name);
        img_strut = load_nii(handles.img_path_name);
    end
    img = double(img_strut.img);
    
    if strcmp(handles.how_stand,'Zstandard')
        if  ~isempty(handles.mask_data)
            disp('Have Mask');
            img_inmask=img(handles.mask_data);
        else
            img_inmask=img;
        end
        mean_inmask=mean(img_inmask);
        mystd=std(img_inmask);
        zvalues=(img_inmask-mean_inmask)./mystd;
        if  ~isempty(handles.mask_data)  % make sure out mask data is zeros
            zvalues(~handles.mask_data)=0;
        end
        %save
        name=fullfile(handles.save_folder,strcat('z_', name, suffix));
        %         y_Write(zvalues,h,name)
        img_strut.img = zvalues;
        save_nii(img_strut,name);
        
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
        %         y_Write(svalues,h,name)
        img_strut.img = svalues;
        save_nii(img_strut,name);
        
    elseif strcmp(handles.how_stand,'Fisher-Z transformation')
        fisherzvalue=0.5*log((1+img)./(1-img));
        if  ~isempty(handles.mask_data)  % make sure out mask data is zeros
            fisherzvalue(~handles.mask_data)=0;
        end
        %save
        name=fullfile(handles.save_folder,strcat('fisherz_', name, suffix));
        %         y_Write(fisherzvalue,h,name)
        img_strut.img = fisherzvalue;
        save_nii(img_strut,name);
        
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
        %         y_Write(divmean_values,h,name);
        img_strut.img = divmean_values;
        save_nii(img_strut,name);
        
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
        %         y_Write(demean_values,h,name)
        img_strut.img = demean_values;
        save_nii(img_strut,name);
        
    else
        fprintf('This standardization method: %s not supported\n',handles.how_stand)
        return
    end
end
fprintf('All done!\n')