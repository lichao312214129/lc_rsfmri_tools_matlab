Gama1 = normrnd(2,0.1,30,20);
Gama2 = normrnd(2,0.1,30,20);

errorbar(mean(Gama1),std(Gama1),'-s','MarkerSize',15,...
    'MarkerEdgeColor','g','MarkerFaceColor','b','LineWidth',2)%画病人组,Gama1表示你相应的值
hold on;
errorbar(mean(Gama2),std(Gama2),'-s','MarkerSize',15,...
    'MarkerEdgeColor','r','MarkerFaceColor','r','LineWidth',2)%画病人组,Gama1表示你相应的值
h=legend('Patients','Controls');
set(h,'Orientation','horizon');
grid on
