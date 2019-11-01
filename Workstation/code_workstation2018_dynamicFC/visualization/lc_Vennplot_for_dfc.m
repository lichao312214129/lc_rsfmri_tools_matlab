% used for plot Venn diagram

% state1
share123_state1 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state1\result1\shared_1and2and3_fdr.mat');
share12_state1 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state1\result1\shared_1and2_fdr.mat');
share13_state1 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state1\result1\shared_1and3_fdr.mat');
share23_state1 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state1\result1\shared_2and3_fdr.mat');

distinctsz_state1 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state1\result1\distinct_1_fdr.mat');
distinctbd_state1 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state1\result1\distinct_2_fdr.mat');
distinctmdd_state1 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state1\result1\distinct_3_fdr.mat');

sz_state1 = [find(share123_state1); find(share12_state1); find(share13_state1); find(distinctsz_state1)];
bd_state1 = [find(share123_state1); find(share12_state1); find(share23_state1); find(distinctbd_state1)];
mdd_state1 = [find(share123_state1); find(share13_state1); find(share23_state1); find(distinctmdd_state1)];

% state2
share123_state2 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state2\result1\shared_1and2and3_fdr.mat');
share12_state2 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state2\result1\shared_1and2_fdr.mat');
share13_state2 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state2\result1\shared_1and3_fdr.mat');
share23_state2 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state2\result1\shared_2and3_fdr.mat');

distinctsz_state2 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state2\result1\distinct_1_fdr.mat');
distinctbd_state2 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state2\result1\distinct_2_fdr.mat');
distinctmdd_state2 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state2\result1\distinct_3_fdr.mat');

sz_state2 = [find(share123_state2); find(share12_state2); find(share13_state2); find(distinctsz_state2)];
bd_state2 = [find(share123_state2); find(share12_state2); find(share23_state2); find(distinctbd_state2)];
mdd_state2 = [find(share123_state2); find(share13_state2); find(share23_state2); find(distinctmdd_state2)];

% state4
share123_state4 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state4\result1\shared_1and2and3_fdr.mat');
share12_state4 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state4\result1\shared_1and2_fdr.mat');
share13_state4 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state4\result1\shared_1and3_fdr.mat');
share23_state4 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state4\result1\shared_2and3_fdr.mat');

distinctsz_state4 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state4\result1\distinct_1_fdr.mat');
distinctbd_state4 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state4\result1\distinct_2_fdr.mat');
distinctmdd_state4 = importdata('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\state4\result1\distinct_3_fdr.mat');

sz_state4 = [find(share123_state4); find(share12_state4); find(share13_state4); find(distinctsz_state4)];
bd_state4 = [find(share123_state4); find(share12_state4); find(share23_state4); find(distinctbd_state4)];
mdd_state4 = [find(share123_state4); find(share13_state4); find(share23_state4); find(distinctmdd_state4)];

%% save
% state1
f = fopen ('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\sz_state1.txt','w');
A = fprintf(f,'%d\n',sz_state1);
fclose(f);

f = fopen ('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\bd_state1.txt','w');
A = fprintf(f,'%d\n',bd_state1);
fclose(f);

f = fopen ('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\mdd_state1.txt','w');
A = fprintf(f,'%d\n',mdd_state1);
fclose(f);

% state2
f = fopen ('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\sz_state2.txt','w');
A = fprintf(f,'%d\n',sz_state2);
fclose(f);

f = fopen ('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\bd_state2.txt','w');
A = fprintf(f,'%d\n',bd_state2);
fclose(f);

f = fopen ('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\mdd_state2.txt','w');
A = fprintf(f,'%d\n',mdd_state2);
fclose(f);

% state4
f = fopen ('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\sz_state4.txt','w');
A = fprintf(f,'%d\n',sz_state4);
fclose(f);

f = fopen ('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\bd_state4.txt','w');
A = fprintf(f,'%d\n',bd_state4);
fclose(f);

f = fopen ('D:\WorkStation_2018\Workstation_dynamic_FC_V2\Data\Dynamic\mdd_state4.txt','w');
A = fprintf(f,'%d\n',mdd_state4);
fclose(f);