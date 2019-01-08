program_path='/gpfs2/training/shared_data/program';
addpath(program_path);
mc='uncorr';%% multiple comparision 'bonf','fdr','uncorr'
sig=0.05;
steps=[1 0 0];% 1st=FC calculation,2nd=ttest1,3rd=ANOVA.
workdir='E:\Lichao_research\天津医科大学培训2015-10\script_template\FC';
data_dir='E:\Lichao_research\天津医科大学培训2015-10\script_template\FC';
result_dir=[workdir,filesep,'FCROI1'];mkdir(result_dir);cd(result_dir);
[cov,subjlist]=xlsread('E:\Lichao_research\天津医科大学培训2015-10\script_template\FC\test.xlsx');
subj=subjlist(2:end,:);
 %ROI_name=[1:116];
ROI_name={'lh_amyg','lh_hipp','lh_tha','sphere'};
%% Step 1:  FC calculate
if steps(1)==1
    tic
    for s=1:length(subj)
       ROISignals=load([data_dir,filesep,'ROI_FCMap_',subj{s,1},'.txt']);%% the name of  the Time course
        R=corrcoef(ROISignals);
        Z=0.5*log((1+R)./(1-R));
        ZFC(s,:,:)=Z(:,:);
    end
    FC_path=[result_dir,filesep,'zFC.mat'];
    save(FC_path,'ZFC','cov', 'subj','ROI_name');
    fprintf('==================================\n');
    fprintf('...Finish FC calculate... \n');
    toc
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if steps(2)==1
    %% Step 2: one-sample ttest statictics
    tic
    FC_path=[result_dir,filesep,'zFC.mat'];
    load(FC_path);
    % Grouping
    grps_name=unique(subj(:,2));
    for i=1:length(grps_name)
        grps_id=strcmp(subj(:,2),grps_name(i));
        
    end
    grps;
    strcmp(grps_name,'p');
    % One sample t-test
    ZFC_2D=reshape(ZFC,length(subj),length(ROI_name)*length(ROI_name));%N_sub=length(subj),N_colnum=numel(ZFC)/length(subj).
    mask_tri=ones(length(ROI_name),length(ROI_name));
    mask_tri=triu(mask_tri);
    mask_tri=mask_tri==0;%三角矩阵mask，不包括对角线
    mask_tri_2D=reshape(mask_tri',1,length(ROI_name)*length(ROI_name));%2D三角矩阵，因为上面ZFC是逐行reshape，所以mask_tri需要转置
    %因此在映射回3D空间时，也要注意转置！！！
    mask_tri_2D=repmat(mask_tri_2D,length(subj),1);
    ZFC_2D_tri=ZFC_2D(mask_tri_2D);
    ZFC_2D_tri=reshape(ZFC_2D_tri,length(subj),numel(ZFC_2D_tri)/length(subj));
    [h1,p1,CI1,stat1]=ttest(ZFC_2D_tri);
    % Multiple comparision
    switch mc
        case 'bonf'
            num_comp=length(ROI_name)*(length(ROI_name)-1)/2;
            P1_corr=sig/num_comp;
        case 'fdr'
            p_vec=unique(P1);p_vec(p_vec==0)=[];
            P1_corr=BAT_fdr(p_vec,sig);
        case 'uncorr'
            P1_corr=sig;
    end
    a=-log10(P1_corr);
    % filter out significant values
    H1=-log10(P1);H1(isinf(H1))=0;H1(H1<a)=0;H1(H1>0)=1;
    meanFC_sig=meanFC.*H1;
    T1_sig=T1.*H1;
    H1_total=zeros(length(ROI_name));
    for g=1:length(grps)
        H1_total=H1(:,:,g)+H1_total;
    end
    H1_total(H1_total>0)=1;
    ttest1_path=[result_dir,filesep,mc,'_one_sample_ttest'];
    save(ttest1_path,'grps','P1','T1','meanFC','T1_sig','meanFC_sig','H1','H1_total','P1_corr');
    fprintf('==================================\n');
    fprintf('...Finish one sample t-test... \n');
    toc
end

%% Step3: ANOVA
if steps(3)==1
    tic
    FC_path=[result_dir,filesep,'zFC.mat'];
    ttest1_path=[result_dir,filesep,mc,'_one_sample_ttest'];
    load(FC_path);
    load(ttest1_path);
    for i = 1:length(ROI_name)
        for j = 1:length(ROI_name)
            if i~=j
                tmpdata=ZFC(:,i,j);
                % regress out nuisance covariate
                reg=[ones(length(tmpdata),1) cov(:,1:2)];
                b=regress(tmpdata,reg);
                data=tmpdata-cov(:,1)*b(2)-cov(:,2)*b(3);
                % ANOVA1
                [P_ANOVA(i,j),table]=anova1(data,subj(:,1),'off');
                F_ANOVA(i,j)=table{2,5};
                % Post Hoc (Paired-wise two sample ttest);
                for g1=1:length(grps)-1
                    for g2=g1+1:length(grps)
                        x=data(grps{g1,2});
                        y=data(grps{g2,2});
                        eval(['[H,P2_',grps{g1,1},'_',grps{g2,1},'(i,j),CI,STATS]=ttest2(x,y);']);
                        eval(['T2_',grps{g1,1},'_',grps{g2,1},'(i,j)=STATS.tstat;']);
                    end
                end
            end
        end
    end
    
    % Multiple comparision for ANOVA
    switch mc
        case 'bonf'
            num_comp=sum(H1_total(:)/2);
            PANOVA_corr=sig/num_comp;
        case 'fdr'
            p_vec=unique(P_ANOVA.*H1_total);p_vec(p_vec==0)=[];
            PANOVA_corr=BAT_fdr(p_vec,sig);
        case 'uncorr'
            PANOVA_corr=sig;
    end
    a=-log10(PANOVA_corr);
    H_ANOVA=-log10(P_ANOVA);
    H_ANOVA(isinf(H_ANOVA))=0;
    H_ANOVA(H_ANOVA<a)=0;
    H_ANOVA(H_ANOVA>0)=1;
    F_ANOVA_sig=F_ANOVA.*H_ANOVA;%%
    
    % Multiple comparision for Post Hoc
    switch mc
        case 'bonf'
            num_comp=sum(H_ANOVA(:)/2);
            P2_corr=sig/num_comp;
        case 'fdr'
            p2_vec=[];
            for g1=1:length(grps)-1
                for g2=g1+1:length(grps)
                    eval(['P2=P2_',grps{g1,1},'_',grps{g2,1},';']);
                    P2(isinf(P2))=0;
                    P2(isnan(P2))=0;
                    P2=P2.*H_ANOVA;
                    p2_vec=[p2_vec;unique(P2)];
                end
            end
            P2_corr=BAT_fdr(p2_vec,sig);
        case 'uncorr'
            P2_corr=sig;
    end
    
    for g1=1:length(grps)-1
        for g2=g1+1:length(grps)
            eval(['P2=P2_',grps{g1,1},'_',grps{g2,1},';']);
            if ~isempty(P2_corr)
                a=-log10(P2_corr);
                H2=-log10(P2);
                H2(isinf(H2))=0;
                H2(isnan(H2))=0;
                H2=H2.*H_ANOVA;
                H2(H2<a)=0;
                H2(H2>0)=1;
                eval(['T2_',grps{g1,1},'_',grps{g2,1},'_sig=H2.*T2_',grps{g1,1},'_',grps{g2,1},';']);
            else
                fprintf('the post hoc of %s-%s is not survived under fdr correction \n',grps{g1,1},grps{g2,1});
            end
        end
    end
    ANOVA_path=[result_dir,filesep,mc,'_ANOVA'];
    clear Ci g FC_path p2_vec Z p_vec s stats1 data_order std1 H H1 H2 P2 STATS a b data g1 g2 i j num_comp reg table tmpdata ttest1_path x y ans
    save(ANOVA_path);
    fprintf('==================================\n');
    fprintf('...Finish ANOVA... \n');
end








