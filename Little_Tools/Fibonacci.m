function   Fibonacci
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
initial=input('初始兔子对数:','s');
initial=str2double(initial);
month=input('经历的月数:','s');
month=str2double(month);%总共繁殖多少个月=经历的月数
room=ones(1,initial)+1;%初始时间的兔子妈妈数量
for i=1:month
   old=find(room>=2); 
   addition=length(old);
   room =[room zeros(1,addition)];%月初，生小兔子
   room=room+1;%月末，所有的兔子都长大了一个月
end
total=length(room);
disp(['最后的兔子数是：', num2str(total)]);
end

