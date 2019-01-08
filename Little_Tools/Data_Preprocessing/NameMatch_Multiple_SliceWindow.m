function IfMatch=NameMatch_Multiple_SliceWindow(Name,Name_Fragment_Cell)
% 用途：确定Name中是否同时出现了多个预设的字段Name_Fragment_Struct
% 以滑动窗的形式将多个或者一个字段Name_Fragment_Struct与Name进行比较，类似卷积操作，有为1的项，则模糊匹配成功（但不保证真实成功，因此Name_Fragment_Struct越精确越好）
% input：
% Name：一个字符串
% Name_Fragment：一个cell，包含多个字符串，其可能是Name字符串中的多个潜在字符串片段
% output：
% IfMatch：一个逻辑值，1表示在Name出现了字段Name_Fragment。0表示Name中没有Name_Fragment字段
%% ==============================================================
%当没有字段首先输入时，根据提示输入
if nargin<2
    Name_Fragment_Char=input('请输入一或多个匹配字段，多个字段以*号隔开：','s');
    Name_Fragment_Char=['*',Name_Fragment_Char,'*'];
    loc_star=find(Name_Fragment_Char=='*');
    for i=1:length(loc_star)-1
        Name_Fragment_Cell{i}=Name_Fragment_Char(loc_star(i)+1:loc_star(i+1)-1);
    end
end
%% ==============================================================
fun=@(x) NameMatch_Single_SliceWindow(Name,x);
result_cmp=cellfun(fun,Name_Fragment_Cell);
IfMatch=sum(result_cmp)==length(Name_Fragment_Cell);
end
