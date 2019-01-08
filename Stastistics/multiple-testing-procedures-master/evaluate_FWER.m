% evaluate_FWER.m
%
% Estimates the FWER of several multiple comparisons correction functions, to
% assess whether these functions and methods are controlling the FWER in
% the expected way.
%
% All tests are evaluating paired-samples effects, as implemented in DDTBox.
% However, several MC correction methods could also be used for between-groups
% comparisons, particularly those that only rely on p-values.
%
% Note: False Discovery Rate (FDR) corresponds to the expected(average) proportion of all
% discoveries (rejected null hypotheses) that are false positives. For
% example, with a FDR of 0.05 this means that 5% of all rejected null
% hypotheses are tolerated to be false positives. (FDR / nFalseDiscoveries / nTotalDiscoveries)
% Conversely, the False Null Rate (FNR) corresponds to the expeted
% proportion of all accepted null hypotheses that are false negatives. 
%
% Written by Daniel Feuerriegel 10/16


% Houskeeping
% clear all;
close all;

% Seed random number generator based on computer clock
rng('shuffle');

% Simulation Settings
Settings.sampleSizesToUse = [30]; % Sample size per test
Settings.nTestsToUse = [10]; % Number of tests
Settings.trueEffectProportion = 0; % Proportion of hypotheses that are real effects (between 0 and 1)
Settings.meanEffect = 1; % Mean magnitude of the effect (note: SD is on average 1)
Settings.nIterations = 1000; % Number of iterations
Settings.alphaLevel = 0.05; % Nominal alpha level

% Resampling method settings
Settings.blairKarniskiIterations = 1000; % Number of permutation samples to draw for the blair-Karniski correction
Settings.clusterIterations = 1000; % Number of permutation samples to draw for the maximum cluster mass null distribution
Settings.clusteringAlphaLevel = 0.05; % Alpha level for detecting individual tests to include within a cluster
Settings.ktmsIterations = 1000; % Number of iterations for ktms GFWER control procedure
Settings.ktms_u = 0; % u parameter for ktms GFWER control procedure

% Preallocate FWER false positive count matrices
FWER.FalsePositives.AllTests.uncorrected = zeros(Settings.nIterations, length(Settings.sampleSizesToUse), length(Settings.nTestsToUse));
FWER.FalsePositives.AllTests.bonferroni = zeros(Settings.nIterations, length(Settings.sampleSizesToUse), length(Settings.nTestsToUse));
FWER.FalsePositives.AllTests.holm = zeros(Settings.nIterations, length(Settings.sampleSizesToUse), length(Settings.nTestsToUse));
FWER.FalsePositives.AllTests.bh = zeros(Settings.nIterations, length(Settings.sampleSizesToUse), length(Settings.nTestsToUse));
FWER.FalsePositives.AllTests.bky = zeros(Settings.nIterations, length(Settings.sampleSizesToUse), length(Settings.nTestsToUse));
FWER.FalsePositives.AllTests.by = zeros(Settings.nIterations, length(Settings.sampleSizesToUse), length(Settings.nTestsToUse));
FWER.FalsePositives.AllTests.blairKarniski = zeros(Settings.nIterations, length(Settings.sampleSizesToUse), length(Settings.nTestsToUse));
FWER.FalsePositives.AllTests.cluster = zeros(Settings.nIterations, length(Settings.sampleSizesToUse), length(Settings.nTestsToUse));
FWER.FalsePositives.AllTests.ktms = zeros(Settings.nIterations, length(Settings.sampleSizesToUse), length(Settings.nTestsToUse));

% Calculate number of true effects and true negatives within all tests
Settings.nTrueEffects = round(Settings.nTestsToUse * Settings.trueEffectProportion);
Settings.nTrueNegatives = Settings.nTestsToUse - Settings.nTrueEffects;

% Preallocate matrices of cutoff values for test statistics/p-values
Cutoffs.bkp_critical_t = zeros(Settings.nIterations, length(Settings.sampleSizesToUse), length(Settings.nTestsToUse));
Cutoffs.bonferroni_corrected_alpha = zeros(Settings.nIterations, length(Settings.sampleSizesToUse), length(Settings.nTestsToUse));
Cutoffs.holm_corrected_alpha = zeros(Settings.nIterations, length(Settings.sampleSizesToUse), length(Settings.nTestsToUse));
Cutoffs.benhoch_critical_alpha = zeros(Settings.nIterations, length(Settings.sampleSizesToUse), length(Settings.nTestsToUse));
Cutoffs.bky_stage2_critical_alpha = zeros(Settings.nIterations, length(Settings.sampleSizesToUse), length(Settings.nTestsToUse));
Cutoffs.benyek_critical_alpha = zeros(Settings.nIterations, length(Settings.sampleSizesToUse), length(Settings.nTestsToUse));


% Generate random samples for multiple hypothesis tests and record FWER for
% each method:
for nTests = 1:length(Settings.nTestsToUse)    
    for sampleSize = 1:length(Settings.sampleSizesToUse)
        for i = 1:Settings.nIterations
            fprintf('Running for %i tests with sample size %i iteration %i \n', Settings.nTestsToUse(nTests), Settings.sampleSizesToUse(sampleSize), i);
            
            % Generate a random samples from a normal distribution (SD = 1)
            tempSample1 = zeros(Settings.sampleSizesToUse(sampleSize), Settings.nTestsToUse(nTests)); % Preallocate
            tempSample2 = zeros(Settings.sampleSizesToUse(sampleSize), Settings.nTestsToUse(nTests)); % Preallocate
            
            for j = 1:Settings.nTestsToUse(nTests)
                tempSample1(:,j) = randn(Settings.sampleSizesToUse(sampleSize), 1);
                tempSample2(:,j) = randn(Settings.sampleSizesToUse(sampleSize), 1);
            end

            % Make vector of the ground truths (null or alternative hypothesis). 
            % 0 = true null, 1 = true alternative
            trueNullOrAlt = zeros(1, Settings.nTestsToUse(nTests));
            
            % Randomly allocate true effects
            trueEffectLocations = randi(Settings.nTestsToUse(nTests), 1, Settings.nTrueEffects(nTests));
            tempSample1(:, trueEffectLocations) = tempSample1(:, trueEffectLocations) + Settings.meanEffect;
            trueNullOrAlt(1, trueEffectLocations) = 1;
            
            % Perform paired-samples t test
            [temp_h, temp_p] = ttest(tempSample1, tempSample2, 'Alpha', Settings.alphaLevel); 
            
            % Blair-Karniski Maximum Statistic Permutation-Based
            % Correction
            [Results] = multcomp_blair_karniski_permtest(tempSample1, tempSample2, 'alpha', Settings.alphaLevel, 'iterations', Settings.blairKarniskiIterations);
            blairKarniski_corrected_h = Results.corrected_h;
            bkp_corrected_p = Results.corrected_p;
            Cutoffs.bkp_critical_t(i, sampleSize, nTests) = Results.critical_t;
            
            % Cluster-based correction
            [Results] = multcomp_cluster_permtest(tempSample1, tempSample2, 'alpha', Settings.alphaLevel, 'iterations', Settings.clusterIterations, 'clusteringalpha', Settings.clusteringAlphaLevel);
            cluster_corrected_h = Results.corrected_h;
            
            % Generalised FWER control procedure (KTMS)
            [Results] = multcomp_ktms(tempSample1, tempSample2, 'alpha', Settings.alphaLevel, 'iterations', Settings.ktmsIterations, 'ktms_u', Settings.ktms_u);
            ktms_h = Results.corrected_h;
            
            % Bonferroni correction
            [Results] = multcomp_bonferroni(temp_p, 'alpha', Settings.alphaLevel);
            bonferroni_corrected_h = Results.corrected_h;
            Cutoffs.bonferroni_corrected_alpha(i, sampleSize, nTests) = Results.corrected_alpha;
            
            % Holm-Bonferroni correction
            [Results] = multcomp_holm_bonferroni(temp_p, 'alpha', Settings.alphaLevel);
            holm_corrected_h = Results.corrected_h;
            Cutoffs.holm_corrected_alpha(i, sampleSize, nTests) = Results.critical_alpha;
            
            % Benjamini-Hochberg FDR control procedure
            [Results] = multcomp_fdr_bh(temp_p, 'alpha', Settings.alphaLevel);
            fdr_bh_corrected_h = Results.corrected_h;
            Cutoffs.benhoch_critical_alpha(i, sampleSize, nTests) = Results.critical_alpha;

            % Benjamini-Krieger-Yekutieli FDR control procedure
            [Results] = multcomp_fdr_bky(temp_p, 'alpha', Settings.alphaLevel);
            fdr_bky_corrected_h = Results.corrected_h;
            Cutoffs.bky_stage2_critical_alpha(i, sampleSize, nTests) = Results.critical_alpha;

            % Benjamini-Yekutieli FDR control procedure
            [Results] = multcomp_fdr_by(temp_p, 'alpha', Settings.alphaLevel);
            fdr_by_corrected_h = Results.corrected_h;
            Cutoffs.benyek_critical_alpha(i, sampleSize, nTests) = Results.critical_alpha;
            
            % Calculate the number of "hits" (true positives) using each method
            FWER.TruePositives.uncorrected(i, sampleSize, nTests) = sum(temp_h(trueNullOrAlt == 1));
            FWER.TruePositives.bonferroni(i, sampleSize, nTests) = sum(bonferroni_corrected_h(trueNullOrAlt == 1));
            FWER.TruePositives.holm(i, sampleSize, nTests) = sum(holm_corrected_h(trueNullOrAlt == 1));
            FWER.TruePositives.bh(i, sampleSize, nTests) = sum(fdr_bh_corrected_h(trueNullOrAlt == 1));
            FWER.TruePositives.bky(i, sampleSize, nTests) = sum(fdr_bky_corrected_h(trueNullOrAlt == 1));
            FWER.TruePositives.by(i, sampleSize, nTests) = sum(fdr_by_corrected_h(trueNullOrAlt == 0));
            FWER.TruePositives.blairKarniski(i, sampleSize, nTests) = sum(blairKarniski_corrected_h(trueNullOrAlt == 1));
            FWER.TruePositives.cluster(i, sampleSize, nTests) = sum(cluster_corrected_h(trueNullOrAlt == 1));
            FWER.TruePositives.ktms(i, sampleSize, nTests) = sum(ktms_h(trueNullOrAlt == 1));
            
            % Calculate the number of "correct rejections" (true negatives) using each method
            FWER.TrueNegatives.uncorrected(i, sampleSize, nTests) = Settings.nTrueNegatives(nTests) - sum(temp_h(trueNullOrAlt == 0));
            FWER.TrueNegatives.bonferroni(i, sampleSize, nTests) = Settings.nTrueNegatives(nTests) - sum(bonferroni_corrected_h(trueNullOrAlt == 0));
            FWER.TrueNegatives.holm(i, sampleSize, nTests) = Settings.nTrueNegatives(nTests) - sum(holm_corrected_h(trueNullOrAlt == 0));
            FWER.TrueNegatives.bh(i, sampleSize, nTests) = Settings.nTrueNegatives(nTests) - sum(fdr_bh_corrected_h(trueNullOrAlt == 0));
            FWER.TrueNegatives.bky(i, sampleSize, nTests) = Settings.nTrueNegatives(nTests) - sum(fdr_bky_corrected_h(trueNullOrAlt == 0));
            FWER.TrueNegatives.by(i, sampleSize, nTests) = Settings.nTrueNegatives(nTests) - sum(fdr_by_corrected_h(trueNullOrAlt == 0));
            FWER.TrueNegatives.blairKarniski(i, sampleSize, nTests) = Settings.nTrueNegatives(nTests) - sum(blairKarniski_corrected_h(trueNullOrAlt == 0));
            FWER.TrueNegatives.cluster(i, sampleSize, nTests) = Settings.nTrueNegatives(nTests) - sum(cluster_corrected_h(trueNullOrAlt == 0));
            FWER.TrueNegatives.ktms(i, sampleSize, nTests) = Settings.nTrueNegatives(nTests) - sum(ktms_h(trueNullOrAlt == 0));
            
            % Calculate the number of false positives using each method
            FWER.FalsePositives.uncorrected(i, sampleSize, nTests) = sum(temp_h(trueNullOrAlt == 0));
            FWER.FalsePositives.bonferroni(i, sampleSize, nTests) = sum(bonferroni_corrected_h(trueNullOrAlt == 0));
            FWER.FalsePositives.holm(i, sampleSize, nTests) = sum(holm_corrected_h(trueNullOrAlt == 0));
            FWER.FalsePositives.bh(i, sampleSize, nTests) = sum(fdr_bh_corrected_h(trueNullOrAlt == 0));
            FWER.FalsePositives.bky(i, sampleSize, nTests) = sum(fdr_bky_corrected_h(trueNullOrAlt == 0));
            FWER.FalsePositives.by(i, sampleSize, nTests) = sum(fdr_by_corrected_h(trueNullOrAlt == 0));
            FWER.FalsePositives.blairKarniski(i, sampleSize, nTests) = sum(blairKarniski_corrected_h(trueNullOrAlt == 0));
            FWER.FalsePositives.cluster(i, sampleSize, nTests) = sum(cluster_corrected_h(trueNullOrAlt == 0));
            FWER.FalsePositives.ktms(i, sampleSize, nTests) = sum(ktms_h(trueNullOrAlt == 0));

            % Calculate the number of false negatives using each method
            FWER.FalseNegatives.uncorrected(i, sampleSize, nTests) = Settings.nTrueEffects(nTests) - sum(temp_h(trueNullOrAlt == 1));
            FWER.FalseNegatives.bonferroni(i, sampleSize, nTests) = Settings.nTrueEffects(nTests) - sum(bonferroni_corrected_h(trueNullOrAlt == 1));
            FWER.FalseNegatives.holm(i, sampleSize, nTests) = Settings.nTrueEffects(nTests) - sum(holm_corrected_h(trueNullOrAlt == 1));
            FWER.FalseNegatives.bh(i, sampleSize, nTests) = Settings.nTrueEffects(nTests) - sum(fdr_bh_corrected_h(trueNullOrAlt == 1));
            FWER.FalseNegatives.bky(i, sampleSize, nTests) = Settings.nTrueEffects(nTests) - sum(fdr_bky_corrected_h(trueNullOrAlt == 1));
            FWER.FalseNegatives.by(i, sampleSize, nTests) = Settings.nTrueEffects(nTests) - sum(fdr_by_corrected_h(trueNullOrAlt == 1));
            FWER.FalseNegatives.blairKarniski(i, sampleSize, nTests) = Settings.nTrueEffects(nTests) - sum(blairKarniski_corrected_h(trueNullOrAlt == 1));
            FWER.FalseNegatives.cluster(i, sampleSize, nTests) = Settings.nTrueEffects(nTests) - sum(cluster_corrected_h(trueNullOrAlt == 1));
            FWER.FalseNegatives.ktms(i, sampleSize, nTests) = Settings.nTrueEffects(nTests) - sum(ktms_h(trueNullOrAlt == 1));
            
            % Calculate the False Discovery Proportion (FDP) for each
            % method. This is the proportion of false discoveries compared to
            % the number of total discoveries (rejections of the null
            % hypothesis).
            FDP.uncorrected(i, sampleSize, nTests) = FWER.FalsePositives.uncorrected(i, sampleSize, nTests) / (FWER.FalsePositives.uncorrected(i, sampleSize, nTests) + FWER.TruePositives.uncorrected(i, sampleSize, nTests));
            FDP.bonferroni(i, sampleSize, nTests) = FWER.FalsePositives.bonferroni(i, sampleSize, nTests) / (FWER.FalsePositives.bonferroni(i, sampleSize, nTests) + FWER.TruePositives.bonferroni(i, sampleSize, nTests));
            FDP.holm(i, sampleSize, nTests) = FWER.FalsePositives.holm(i, sampleSize, nTests) / (FWER.FalsePositives.holm(i, sampleSize, nTests) + FWER.TruePositives.holm(i, sampleSize, nTests));
            FDP.bh(i, sampleSize, nTests) = FWER.FalsePositives.bh(i, sampleSize, nTests) / (FWER.FalsePositives.bh(i, sampleSize, nTests) + FWER.TruePositives.bh(i, sampleSize, nTests));
            FDP.bky(i, sampleSize, nTests) = FWER.FalsePositives.bky(i, sampleSize, nTests) / (FWER.FalsePositives.bky(i, sampleSize, nTests) + FWER.TruePositives.bky(i, sampleSize, nTests));
            FDP.by(i, sampleSize, nTests) = FWER.FalsePositives.by(i, sampleSize, nTests) / (FWER.FalsePositives.by(i, sampleSize, nTests) + FWER.TruePositives.by(i, sampleSize, nTests));
            FDP.blairKarniski(i, sampleSize, nTests) = FWER.FalsePositives.blairKarniski(i, sampleSize, nTests) / (FWER.FalsePositives.blairKarniski(i, sampleSize, nTests) + FWER.TruePositives.blairKarniski(i, sampleSize, nTests));
            FDP.cluster(i, sampleSize, nTests) = FWER.FalsePositives.cluster(i, sampleSize, nTests) / (FWER.FalsePositives.cluster(i, sampleSize, nTests) + FWER.TruePositives.cluster(i, sampleSize, nTests));
            FDP.ktms(i, sampleSize, nTests) = FWER.FalsePositives.ktms(i, sampleSize, nTests) / (FWER.FalsePositives.ktms(i, sampleSize, nTests) + FWER.TruePositives.ktms(i, sampleSize, nTests));

            % Calculate the False Negative Proportion (FNP) for each
            % method. This is the proportion of false negatives compared
            % to the number of all accepted null hypotheses.
            FNP.uncorrected(i, sampleSize, nTests) = FWER.FalseNegatives.uncorrected(i, sampleSize, nTests) / (FWER.FalseNegatives.uncorrected(i, sampleSize, nTests) + FWER.TrueNegatives.uncorrected(i, sampleSize, nTests));
            FNP.bonferroni(i, sampleSize, nTests) = FWER.FalseNegatives.bonferroni(i, sampleSize, nTests) / (FWER.FalseNegatives.bonferroni(i, sampleSize, nTests) + FWER.TrueNegatives.bonferroni(i, sampleSize, nTests));
            FNP.holm(i, sampleSize, nTests) = FWER.FalseNegatives.holm(i, sampleSize, nTests) / (FWER.FalseNegatives.holm(i, sampleSize, nTests) + FWER.TrueNegatives.holm(i, sampleSize, nTests));
            FNP.bh(i, sampleSize, nTests) = FWER.FalseNegatives.bh(i, sampleSize, nTests) / (FWER.FalseNegatives.bh(i, sampleSize, nTests) + FWER.TrueNegatives.bh(i, sampleSize, nTests));
            FNP.bky(i, sampleSize, nTests) = FWER.FalseNegatives.bky(i, sampleSize, nTests) / (FWER.FalseNegatives.bky(i, sampleSize, nTests) + FWER.TrueNegatives.bky(i, sampleSize, nTests));
            FNP.by(i, sampleSize, nTests) = FWER.FalseNegatives.by(i, sampleSize, nTests) / (FWER.FalseNegatives.by(i, sampleSize, nTests) + FWER.TrueNegatives.by(i, sampleSize, nTests));
            FNP.blairKarniski(i, sampleSize, nTests) = FWER.FalseNegatives.blairKarniski(i, sampleSize, nTests) / (FWER.FalseNegatives.blairKarniski(i, sampleSize, nTests) + FWER.TrueNegatives.blairKarniski(i, sampleSize, nTests));
            FNP.cluster(i, sampleSize, nTests) = FWER.FalseNegatives.cluster(i, sampleSize, nTests) / (FWER.FalseNegatives.cluster(i, sampleSize, nTests) + FWER.TrueNegatives.cluster(i, sampleSize, nTests));
            FNP.ktms(i, sampleSize, nTests) = FWER.FalseNegatives.ktms(i, sampleSize, nTests) / (FWER.FalseNegatives.ktms(i, sampleSize, nTests) + FWER.TrueNegatives.ktms(i, sampleSize, nTests));

            
            
        end % of for i = 1:Settings.nIterations loop

        % Calculate the number of false positives using each method
        FWER.FalsePositives.AllTests.uncorrected(FWER.FalsePositives.uncorrected > 0) = 1;
        FWER.FalsePositives.AllTests.bonferroni(FWER.FalsePositives.bonferroni > 0) = 1;
        FWER.FalsePositives.AllTests.holm(FWER.FalsePositives.holm > 0) = 1;
        FWER.FalsePositives.AllTests.bh(FWER.FalsePositives.bh > 0) = 1;
        FWER.FalsePositives.AllTests.bky(FWER.FalsePositives.bky > 0) = 1;
        FWER.FalsePositives.AllTests.by(FWER.FalsePositives.by > 0) = 1;
        FWER.FalsePositives.AllTests.blairKarniski(FWER.FalsePositives.blairKarniski > 0) = 1;
        FWER.FalsePositives.AllTests.cluster(FWER.FalsePositives.cluster > 0) = 1;
        FWER.FalsePositives.AllTests.ktms(FWER.FalsePositives.ktms > 0) = 1; % No. of false positives needs to be above ktms_u parameter for GFWER

        % Calculate the FWER (type 1 error rate)
        FWER.uncorrected(sampleSize, nTests) = sum(FWER.FalsePositives.AllTests.uncorrected(:, sampleSize, nTests)) / Settings.nIterations;
        FWER.bonferroni(sampleSize, nTests) = sum(FWER.FalsePositives.AllTests.bonferroni(:, sampleSize, nTests)) / Settings.nIterations;
        FWER.holm(sampleSize, nTests) = sum(FWER.FalsePositives.AllTests.holm(:, sampleSize, nTests)) / Settings.nIterations;
        FWER.bh(sampleSize, nTests) = sum(FWER.FalsePositives.AllTests.bh(:, sampleSize, nTests)) / Settings.nIterations;
        FWER.bky(sampleSize, nTests) = sum(FWER.FalsePositives.AllTests.bky(:, sampleSize, nTests)) / Settings.nIterations;
        FWER.by(sampleSize, nTests) = sum(FWER.FalsePositives.AllTests.by(:, sampleSize, nTests)) / Settings.nIterations;
        FWER.blairKarniski(sampleSize, nTests) = sum(FWER.FalsePositives.AllTests.blairKarniski(:, sampleSize, nTests)) / Settings.nIterations;
        FWER.cluster(sampleSize, nTests) = sum(FWER.FalsePositives.AllTests.cluster(:, sampleSize, nTests)) / Settings.nIterations;
        FWER.GFWER_ktms(sampleSize, nTests) = sum(FWER.FalsePositives.AllTests.ktms(:, sampleSize, nTests)) / Settings.nIterations;

        % Estimate the expected (average) number of false positives within
        % a given family of tests as percentage of all nulls
        FalsePosRate.uncorrected(sampleSize, nTests) = nanmean(FWER.FalsePositives.uncorrected(:, sampleSize, nTests));
        FalsePosRate.bonferroni(sampleSize, nTests) = nanmean(FWER.FalsePositives.bonferroni(:, sampleSize, nTests));
        FalsePosRate.holm(sampleSize, nTests) = nanmean(FWER.FalsePositives.holm(:, sampleSize, nTests));
        FalsePosRate.bh(sampleSize, nTests) = nanmean(FWER.FalsePositives.bh(:, sampleSize, nTests));
        FalsePosRate.bky(sampleSize, nTests) = nanmean(FWER.FalsePositives.bky(:, sampleSize, nTests));
        FalsePosRate.by(sampleSize, nTests) = nanmean(FWER.FalsePositives.by(:, sampleSize, nTests));
        FalsePosRate.blairKarniski(sampleSize, nTests) = nanmean(FWER.FalsePositives.blairKarniski(:, sampleSize, nTests));
        FalsePosRate.cluster(sampleSize, nTests) = nanmean(FWER.FalsePositives.cluster(:, sampleSize, nTests));
        FalsePosRate.ktms(sampleSize, nTests) = nanmean(FWER.FalsePositives.ktms(:, sampleSize, nTests));

        % Estimate the expected (average) number of false negatives within
        % a given family of tests
        FalseNegRate.uncorrected(sampleSize, nTests) = nanmean(FWER.FalseNegatives.uncorrected(:, sampleSize, nTests));
        FalseNegRate.bonferroni(sampleSize, nTests) = nanmean(FWER.FalseNegatives.bonferroni(:, sampleSize, nTests));
        FalseNegRate.holm(sampleSize, nTests) = nanmean(FWER.FalseNegatives.holm(:, sampleSize, nTests));
        FalseNegRate.bh(sampleSize, nTests) = nanmean(FWER.FalseNegatives.bh(:, sampleSize, nTests));
        FalseNegRate.bky(sampleSize, nTests) = nanmean(FWER.FalseNegatives.bky(:, sampleSize, nTests));
        FalseNegRate.by(sampleSize, nTests) = nanmean(FWER.FalseNegatives.by(:, sampleSize, nTests));
        FalseNegRate.blairKarniski(sampleSize, nTests) = nanmean(FWER.FalseNegatives.blairKarniski(:, sampleSize, nTests));
        FalseNegRate.cluster(sampleSize, nTests) = nanmean(FWER.FalseNegatives.cluster(:, sampleSize, nTests));
        FalseNegRate.ktms(sampleSize, nTests) = nanmean(FWER.FalseNegatives.ktms(:, sampleSize, nTests));
        
        % Estimate the expected (average) number of true positives within a
        % given family of tests as a percentage of all true effects
        TruePosRate.uncorrected(sampleSize, nTests) = nanmean(FWER.TruePositives.uncorrected(:, sampleSize, nTests)) / Settings.nTrueEffects(nTests);
        TruePosRate.bonferroni(sampleSize, nTests) = nanmean(FWER.TruePositives.bonferroni(:, sampleSize, nTests)) / Settings.nTrueEffects(nTests);
        TruePosRate.holm(sampleSize, nTests) = nanmean(FWER.TruePositives.holm(:, sampleSize, nTests)) / Settings.nTrueEffects(nTests);
        TruePosRate.bh(sampleSize, nTests) = nanmean(FWER.TruePositives.bh(:, sampleSize, nTests)) / Settings.nTrueEffects(nTests);
        TruePosRate.bky(sampleSize, nTests) = nanmean(FWER.TruePositives.bky(:, sampleSize, nTests)) / Settings.nTrueEffects(nTests);
        TruePosRate.by(sampleSize, nTests) = nanmean(FWER.TruePositives.by(:, sampleSize, nTests)) / Settings.nTrueEffects(nTests);
        TruePosRate.blairKarniski(sampleSize, nTests) = nanmean(FWER.TruePositives.blairKarniski(:, sampleSize, nTests)) / Settings.nTrueEffects(nTests);
        TruePosRate.cluster(sampleSize, nTests) = nanmean(FWER.TruePositives.cluster(:, sampleSize, nTests)) / Settings.nTrueEffects(nTests);
        TruePosRate.ktms(sampleSize, nTests) = nanmean(FWER.TruePositives.ktms(:, sampleSize, nTests)) / Settings.nTrueEffects(nTests);

        % Estimate the expected (average) number of true negatives (nulls) within a
        % given family of tests
        TrueNegRate.uncorrected(sampleSize, nTests) = nanmean(FWER.TrueNegatives.uncorrected(:, sampleSize, nTests)) / Settings.nTrueNegatives(nTests);
        TrueNegRate.bonferroni(sampleSize, nTests) = nanmean(FWER.TrueNegatives.bonferroni(:, sampleSize, nTests)) / Settings.nTrueNegatives(nTests);
        TrueNegRate.holm(sampleSize, nTests) = nanmean(FWER.TrueNegatives.holm(:, sampleSize, nTests)) / Settings.nTrueNegatives(nTests);
        TrueNegRate.bh(sampleSize, nTests) = nanmean(FWER.TrueNegatives.bh(:, sampleSize, nTests)) / Settings.nTrueNegatives(nTests);
        TrueNegRate.bky(sampleSize, nTests) = nanmean(FWER.TrueNegatives.bky(:, sampleSize, nTests)) / Settings.nTrueNegatives(nTests);
        TrueNegRate.by(sampleSize, nTests) = nanmean(FWER.TrueNegatives.by(:, sampleSize, nTests)) / Settings.nTrueNegatives(nTests);
        TrueNegRate.blairKarniski(sampleSize, nTests) = nanmean(FWER.TrueNegatives.blairKarniski(:, sampleSize, nTests)) / Settings.nTrueNegatives(nTests);
        TrueNegRate.cluster(sampleSize, nTests) = nanmean(FWER.TrueNegatives.cluster(:, sampleSize, nTests)) / Settings.nTrueNegatives(nTests);
        TrueNegRate.ktms(sampleSize, nTests) = nanmean(FWER.TrueNegatives.ktms(:, sampleSize, nTests)) / Settings.nTrueNegatives(nTests);
        
        
        % Estimate the False Discovery Rate (average of False Discovery
        % Proportion across iterations)
        FDR.uncorrected(sampleSize, nTests) = nanmean(FDP.uncorrected(:, sampleSize, nTests));
        FDR.bonferroni(sampleSize, nTests) = nanmean(FDP.bonferroni(:, sampleSize, nTests));
        FDR.holm(sampleSize, nTests) = nanmean(FDP.holm(:, sampleSize, nTests));
        FDR.bh(sampleSize, nTests) = nanmean(FDP.bh(:, sampleSize, nTests));
        FDR.bky(sampleSize, nTests) = nanmean(FDP.bky(:, sampleSize, nTests));
        FDR.by(sampleSize, nTests) = nanmean(FDP.by(:, sampleSize, nTests));
        FDR.blairKarniski(sampleSize, nTests) = nanmean(FDP.blairKarniski(:, sampleSize, nTests));
        FDR.cluster(sampleSize, nTests) = nanmean(FDP.cluster(:, sampleSize, nTests));
        FDR.ktms(sampleSize, nTests) = nanmean(FDP.ktms(:, sampleSize, nTests));

        % Estimate the False Null Rate (Average of False Negative
        % Proportion across iterations)
        FNR.uncorrected(sampleSize, nTests) = nanmean(FNP.uncorrected(:, sampleSize, nTests));
        FNR.bonferroni(sampleSize, nTests) = nanmean(FNP.bonferroni(:, sampleSize, nTests));
        FNR.holm(sampleSize, nTests) = nanmean(FNP.holm(:, sampleSize, nTests));
        FNR.bh(sampleSize, nTests) = nanmean(FNP.bh(:, sampleSize, nTests));
        FNR.bky(sampleSize, nTests) = nanmean(FNP.bky(:, sampleSize, nTests));
        FNR.by(sampleSize, nTests) = nanmean(FNP.by(:, sampleSize, nTests));
        FNR.blairKarniski(sampleSize, nTests) = nanmean(FNP.blairKarniski(:, sampleSize, nTests));
        FNR.cluster(sampleSize, nTests) = nanmean(FNP.cluster(:, sampleSize, nTests));
        FNR.ktms(sampleSize, nTests) = nanmean(FNP.ktms(:, sampleSize, nTests));
        
    end % of for sampleSize

end % of for nTests

% Save all results and settings to the workspace
save(['Workspace Saves/workspace_save' datestr(now, 30)]);


% Plot FWER of each method
figure('Name', 'FWER for each method');
plot(FWER.uncorrected);
hold on;
plot(FWER.bonferroni);
plot(FWER.holm);
plot(FWER.bh);
plot(FWER.bky);
plot(FWER.by);
plot(FWER.blairKarniski);
plot(FWER.cluster);
plot(FWER.GFWER_ktms);

% Plot FDR of each method
figure('Name', 'FDR for each method');
plot(FDR.uncorrected);
hold on;
plot(FDR.bonferroni);
plot(FDR.holm);
plot(FDR.bh);
plot(FDR.bky);
plot(FDR.by);
plot(FDR.blairKarniski);
plot(FDR.cluster);
plot(FDR.ktms);

% Plot average number of false positives for each method
figure('Name', 'Average number of false positives for each method');
plot(FalsePosRate.uncorrected);
hold on;
plot(FalsePosRate.bonferroni);
plot(FalsePosRate.holm);
plot(FalsePosRate.bh);
plot(FalsePosRate.bky);
plot(FalsePosRate.by);
plot(FalsePosRate.blairKarniski);
plot(FalsePosRate.cluster);

% Plot average number of false negatives for each method
figure('Name', 'Average number of false negatives for each method');
plot(FalseNegRate.uncorrected);
hold on;
plot(FalseNegRate.bonferroni);
plot(FalseNegRate.holm);
plot(FalseNegRate.bh);
plot(FalseNegRate.bky);
plot(FalseNegRate.by);
plot(FalseNegRate.blairKarniski);
plot(FalseNegRate.cluster);

% Plot average percentage of true positives for each method
figure('Name', 'Average percentage of true positives for each method');
plot(TruePosRate.uncorrected);
hold on;
plot(TruePosRate.bonferroni);
plot(TruePosRate.holm);
plot(TruePosRate.bh);
plot(TruePosRate.bky);
plot(TruePosRate.by);
plot(TruePosRate.blairKarniski);
plot(TruePosRate.cluster);

% Plot average percentage of true negatives for each method
figure('Name', 'Average percentage of true negatives for each method');
plot(TrueNegRate.uncorrected);
hold on;
plot(TrueNegRate.bonferroni);
plot(TrueNegRate.holm);
plot(TrueNegRate.bh);
plot(TrueNegRate.bky);
plot(TrueNegRate.by);
plot(TrueNegRate.blairKarniski);
plot(TrueNegRate.cluster);