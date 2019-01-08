function IfMatch=NameMatch_Single_SliceWindow(Name,Name_Fragment)
% 用途：确定Name中是否有字段Name_Fragment
% 以滑动窗的形式将Name_Fragment与Name进行比较，类似卷积操作，有为1的项，则模糊匹配成功（但不保证真实成功，因此Name_Fragment越精确越好）
% input：
    % Name：一个字符串
    % Name_Fragment：一个字符串，其可能是Name字符串中的一个潜在字符串片段
% output：
    % IfMatch：一个逻辑值，1表示在Name出现了字段Name_Fragment。0表示Name中没有Name_Fragment字段。
%% ==============================================================
window_length=length(Name_Fragment);
%滑动比较
loc_start=1;loc_end=loc_start+window_length-1;
result_cmp=0;
while loc_end<=length(Name)
    result_cmp(loc_start)=strcmp(Name_Fragment,Name(loc_start:loc_end));%所有file_name2中与第i个旧名字匹配的结果。
    loc_start=loc_start+1;loc_end=loc_end+1;%每次向后滑动一个字母
end
IfMatch=any(result_cmp);%当某个Name中有>=1处于旧名字重叠，则认为模糊匹配成功***，copy_*为位置
end