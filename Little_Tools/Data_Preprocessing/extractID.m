%extract scan ID of oldname
% ID 位于最后两个'_'之间，其他情况自行修改
name=OldName';
    for i=1:length(name)
        loc_=find(name{i}=='_');%所有下划线位置
        loc_star=loc_(end-1)+1;%ID
        loc_end=loc_(end)-1;
        ID{i}=name{i}(loc_star: loc_end);
    end
    %save
path_ID=uigetdir({},'ID存放位置');
path_ID=[path_ID,filesep,'ID.mat'];
save(path_ID,'ID')