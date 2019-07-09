data_path = 'D:\data.txt';
data_stuct = importdata(data_path);
data = data_stuct.data;
data = 1-data;
str = data_stuct.textdata;
header = ['q_A','q_A_unmedicated','q_A_medicated',...
             'q_B','q_B_unmedicated','q_B_medicated',...
             'q_C','q_C_unmedicated','q_C_medicated'];


xvalues = str(1,2:end);
yvalues = str(2:end,1);
h = heatmap(xvalues,yvalues,data);
% imagesc(data);
% colormap(gray)
h.FontSize = 6;
h.Position = [0.1 0.1 0.3 0.8];
caxis([0.95 1]);
print(gcf,'-dtiff', '-r300','s5.tif')

