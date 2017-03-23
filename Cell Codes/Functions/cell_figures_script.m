%% NOTES ON ORGANIZATION:
% These scripts are organized by data type rather than order of the figures
% in paper. Scripts are saved in the same directory as the figures they
% generate. Figures are split into 10 directories: 
%   1. Striosomes - containing all population based analyses of putative
%       striosomal SPNs
%   2. Matrix - containing all population based analyses of putative matrix
%       SPNs
%   3. PFC-PLs - containing all population based analyses of putative
%       PFC-PLs neurons
%   4. non-PFC-PLs - containing all population based analyses of PFC-PL
%       neurons determined quantitatively not to be PFC-PLs neurons
%   5. HFN - containing all population based analyses of HFNs
%   6. Stimulation Responses - containing examples of (a) PFC-PLs response
%       to antidromic stimulation, (b) Striosome response to orthodromic
%       stimulation, and (c) Matrix response to orthodromic stimulation.
%       Also contains bar graphs of striosome/matrix responder counts 
%       against distance from striosomes.
%   7. Task Switch - containing all analyses of task switches (laser
%       experiment, benefit-benefit to cost-benefit experiment, and control
%       analyses from cost-benefit and benefit-benefit experiments).
%   8. Pair Analysis - containing all pair-based analyses of interactions
%       between HFN neurons and both PFC-PLs and striosomal SPN neurons.
%   9. Laser/Electrical Stimulation - containing all analyses of HFN versus
%       strisomal SPN responses to PFC-PL stimulation, with and without
%       added optical stimulation
%   10. Bursts - containing figures used in explanation of methods for
%       detecting bursts. 

%% GLOBAL SETUP 

twdb_main_file = 'D:\UROP\Cell Figures and Data\Data\Behavioral_Data\twdb_behavior.mat';
twdb_laser_file = 'D:\UROP\Cell Figures and Data\Data\Behavior_Laser_Data\twdb_laser.mat';
twdb_training_file = 'D:\UROP\Cell Figures and Data\Data\Training Data Striosomality\twdb_training.mat';

twdb_main = load(twdb_main_file);
twdb_main = twdb_main.twdb;

twdb_laser = load(twdb_laser_file);
twdb_laser = twdb_laser.twdb;

twdb_training = load(twdb_training_file);
twdb_training = twdb_training.twdb;

figs_dir = 'D:\UROP\Cell Figures and Data\Figures';

%% Figure Script 1: Striosomes (maze + firing rate population + bursts + bar graph)
fig_dir = [figs_dir, '\Striosomes'];
bar_graph_means = [0; 0; 0; 0; 0]; bar_graph_stds = [0; 0; 0; 0; 0];
    %% Cost-benefit (conflict)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'CB', 'key', 'tetrodeType', 'dms', ...
    'grade', 'removable', 0, 0, 'grade', 'striosomality_type', 4, 5, 'grade', 'sqr_neuron_type', 3, 5);
toKeep = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    if twdb_main(index).striosomality_grade > 0 && twdb_main(index).striosomality_data(3) < .015 && twdb_main(index).striosomality_data(4) < .04
        toKeep(end+1) = iter;
    end
end
neuron_ids = neuron_ids(toKeep);
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
maxlength = length(neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([1 5.5]); title(['Cost Benefit (Conflict) Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\strio_costBenefit_firingRate'], 'fig')
saveas(gca, [fig_dir, '\strio_costBenefit_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\strio_costBenefit_firingRate.xlsx'], fullData)
save([fig_dir, '\strio_costBenefit_firingRate.mat'], 'fullData')
        %% Maze
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Cost Benefit (Conflict) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\strio_costBenefit_maze'], 'fig')
saveas(gca, [fig_dir, '\strio_costBenefit_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 20, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [20 100 .075 9 maxlength 0.8 0 1 0.5 0 0]);
title(['Cost Benefit (Conflict): ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\strio_costBenefit_bursts'], 'fig');
saveas(gca, [fig_dir, '\strio_costBenefit_bursts'], 'eps');
xlswrite([fig_dir, '\strio_costBenefit_bursts.xlsx'], allBursts)
save([fig_dir, '\strio_costBenefit_bursts.mat'], 'allBursts')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(1) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(1) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Benefit-benefit (combined)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'dms', ...
    'grade', 'removable', 0, 0, 'grade', 'striosomality_type', 4, 5, 'grade', 'sqr_neuron_type', 3, 5);
toKeep = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    if twdb_main(index).striosomality_grade > 0 && twdb_main(index).striosomality_data(3) < .015 && twdb_main(index).striosomality_data(4) < .04
        toKeep(end+1) = iter;
    end
end
neuron_ids = neuron_ids(toKeep);
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([1 5.5]); title(['Benefit Benefit (Combined) Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\strio_benefitBenefitCombined_firingRate'], 'fig')
saveas(gca, [fig_dir, '\strio_benefitBenefitCombined_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\strio_benefitBenefitCombined_firingRate.xlsx'], fullData)
save([fig_dir, '\strio_benefitBenefitCombined_firingRate.mat'], 'fullData')
        %% Maze
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Benefit Benefit (Combined) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\strio_benefitBenefitCombined_maze'], 'fig')
saveas(gca, [fig_dir, '\strio_benefitBenefitCombined_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 20, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [20 100 .075 9 maxlength 0.8 0 1 0.5 0 0]);
title(['Benefit Benefit (Combined): ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\strio_benefitBenefitCombined_bursts'], 'fig');
saveas(gca, [fig_dir, '\strio_benefitBenefitCombined_bursts'], 'eps');
xlswrite([fig_dir, '\strio_benefitBenefitCombined_bursts.xlsx'], allBursts)
save([fig_dir, '\strio_benefitBenefitCombined_bursts.mat'], 'allBursts')
    %% Benefit-benefit (similar)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'dms', ...
    'grade', 'removable', 0, 0, 'grade', 'striosomality_type', 4, 5, 'grade', 'sqr_neuron_type', 3, 5, 'grade', 'conc', 60, 70);
toKeep = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    if twdb_main(index).striosomality_grade > 0 && twdb_main(index).striosomality_data(3) < .015 && twdb_main(index).striosomality_data(4) < .04
        toKeep(end+1) = iter;
    end
end
neuron_ids = neuron_ids(toKeep);
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([1 5.5]); title(['Benefit Benefit (Similar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\strio_benefitBenefitSimilar_firingRate'], 'fig')
saveas(gca, [fig_dir, '\strio_benefitBenefitSimilar_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\strio_benefitBenefitSimilar_firingRate.xlsx'], fullData)
save([fig_dir, '\strio_benefitBenefitSimilar_firingRate.mat'], 'fullData')
        %% Maze
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Benefit Benefit (Similar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\strio_benefitBenefitSimilar_maze'], 'fig')
saveas(gca, [fig_dir, '\strio_benefitBenefitSimilar_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 20, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [20 100 .075 9 maxlength 0.8 0 1 0.5 0 0]);
title(['Benefit Benefit (Similar): ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\strio_benefitBenefitSimilar_bursts'], 'fig');
saveas(gca, [fig_dir, '\strio_benefitBenefitSimilar_bursts'], 'eps');
xlswrite([fig_dir, '\strio_benefitBenefitSimilar_bursts.xlsx'], allBursts)
save([fig_dir, '\strio_benefitBenefitSimilar_bursts.mat'], 'allBursts')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(2) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(2) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Benefit-benefit (dissimilar)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'dms', ...
    'grade', 'removable', 0, 0, 'grade', 'striosomality_type', 4, 5, 'grade', 'sqr_neuron_type', 3, 5, 'grade', 'conc', 5, 45);
toKeep = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    if twdb_main(index).striosomality_grade > 0 && twdb_main(index).striosomality_data(3) < .015 && twdb_main(index).striosomality_data(4) < .04
        toKeep(end+1) = iter;
    end
end
neuron_ids = neuron_ids(toKeep);
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([1 5.5]); title(['Benefit Benefit (Dissimilar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\strio_benefitBenefitDissimilar_firingRate'], 'fig')
saveas(gca, [fig_dir, '\strio_benefitBenefitDissimilar_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\strio_benefitBenefitDissimilar_firingRate.xlsx'], fullData)
save([fig_dir, '\strio_benefitBenefitDissimilar_firingRate.mat'], 'fullData')
        %% Maze
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Benefit Benefit (Dissimilar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\strio_benefitBenefitDissimilar_maze'], 'fig')
saveas(gca, [fig_dir, '\strio_benefitBenefitDissimilar_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 20, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [20 100 .075 9 maxlength 0.8 0 1 0.5 0 0]);
title(['Benefit Benefit (Dissimilar): ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\strio_benefitBenefitDissimilar_bursts'], 'fig');
saveas(gca, [fig_dir, '\strio_benefitBenefitDissimilar_bursts'], 'eps');
xlswrite([fig_dir, '\strio_benefitBenefitDissimilar_bursts.xlsx'], allBursts)
save([fig_dir, '\strio_benefitBenefitDissimilar_bursts.mat'], 'allBursts')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(3) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(3) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Non-conflict cost-benefit
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'Rev CB', 'key', 'tetrodeType', 'dms', ...
    'grade', 'removable', 0, 0, 'grade', 'striosomality_type', 4, 5, 'grade', 'sqr_neuron_type', 3, 5);
toKeep = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    if twdb_main(index).striosomality_grade > 0 && twdb_main(index).striosomality_data(3) < .015 && twdb_main(index).striosomality_data(4) < .04
        toKeep(end+1) = iter;
    end
end
neuron_ids = neuron_ids(toKeep);
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([1 5.5]); title(['Non-conflict Cost Benefit Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\strio_nonconflictCostBenefit_firingRate'], 'fig')
saveas(gca, [fig_dir, '\strio_nonconflictCostBenefit_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\strio_nonconflictCostBenefit_firingRate.xlsx'], fullData)
save([fig_dir, '\strio_nonconflictCostBenefit_firingRate.mat'], 'fullData')
        %% Maze
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Non-conflict Cost Benefit Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\strio_nonconflictCostBenefit_maze'], 'fig')
saveas(gca, [fig_dir, '\strio_nonconflictCostBenefit_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 20, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [20 100 .075 9 maxlength 0.8 0 1 0.5 0 0]);
title(['Non-conflict Cost Benefit: ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\strio_nonconflictCostBenefit_bursts'], 'fig');
saveas(gca, [fig_dir, '\strio_nonconflictCostBenefit_bursts'], 'eps');
xlswrite([fig_dir, '\strio_nonconflictCostBenefit_bursts.xlsx'], allBursts)
save([fig_dir, '\strio_nonconflictCostBenefit_bursts.mat'], 'allBursts')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(4) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(4) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Cost-cost
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'EQR', 'key', 'tetrodeType', 'dms', ...
    'grade', 'removable', 0, 0, 'grade', 'striosomality_type', 4, 5, 'grade', 'sqr_neuron_type', 3, 5);
toKeep = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    ses_evt_timings = twdb_main(index).trial_evt_timings;
    bins = ah_fill_spike_plotting_bins(twdb_main(index).trial_spikes, {twdb_main(index).trial_evt_timings}, ...
        [1 100 twdb_main(index).baseline_firing_rate_data], {[3 2020]}, {}, [200, 1, 2, .3, .6], [0 0]);
    if twdb_main(index).striosomality_grade > 0 && twdb_main(index).striosomality_data(3) < .015 && twdb_main(index).striosomality_data(4) < .04 && ...
            ~isempty(find(ses_evt_timings(:,3)==2020)) && ~isempty(find(ses_evt_timings(:,5)==2011)) && mean(bins(121:end,1))/mean(bins(:,1)) < 4/3
        toKeep(end+1) = iter;
    end
end
neuron_ids = neuron_ids(toKeep);
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([1 5.5]); title(['Cost Cost Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\strio_costCost_firingRate'], 'fig')
saveas(gca, [fig_dir, '\strio_costCost_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\strio_costCost_firingRate.xlsx'], fullData)
save([fig_dir, '\strio_costCost_firingRate.mat'], 'fullData')
        %% Maze
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Cost Cost Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\strio_costCost_maze'], 'fig')
saveas(gca, [fig_dir, '\strio_costCost_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 20, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [20 100 .075 9 maxlength 0.8 0 1 0.5 0 0]);
title(['Cost Cost: ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\strio_costCost_bursts'], 'fig');
saveas(gca, [fig_dir, '\strio_costCost_bursts'], 'eps');
xlswrite([fig_dir, '\strio_costCost_bursts.xlsx'], allBursts)
save([fig_dir, '\strio_costCost_bursts.mat'], 'allBursts')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(5) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(5) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Bar graph of 5 tasks:
ah_barsWithErrors(bar_graph_means,bar_graph_stds,{'Cost Benefit (Conflict)', 'Benefit Benefit (Similar)', 'Benefit Benefit (Dissimilar)', 'Non-conflict Cost Benefit', 'Cost Cost'},{[1 0 0]},1)
ylabel('Z-score Compared to Baseline')
saveas(gca, [fig_dir, '\strio_bar_plot'], 'fig')
saveas(gca, [fig_dir, '\strio_bar_plot'], 'eps')
close all;

%% Figure Script 2: Matrix (split/unsplit mazes)
fig_dir = [figs_dir, '\Matrix'];
bar_graph_means = [0; 0; 0; 0; 0]; bar_graph_stds = [0; 0; 0; 0; 0];
    %% Cost-benefit (conflict)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'CB', 'key', 'tetrodeType', 'dms',...
    'grade', 'striosomality_type', 0, 0, 'grade', 'sqr_neuron_type', 3, 3, 'grade', 'final_michael_grade', 3, 5);
neuron_ids2 = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'CB', 'key', 'tetrodeType', 'dms',...
    'grade', 'striosomality_type', 1, 5, 'grade', 'sqr_neuron_type', 5, 5, 'grade', 'final_michael_grade', 3, 5);
neuron_ids = [neuron_ids neuron_ids2];
numNeurons = num2str(length(neuron_ids));

tmp = {};
for iter = 1:length(neuron_ids)
    index = str2num(neuron_ids{iter});
    [plotting_bins, ~, ~, ~] = ah_fill_spike_plotting_bins(twdb_main(index).trial_spikes, ...
        {twdb_main(index).trial_evt_timings}, [1 100 twdb_main(index).baseline_firing_rate_data], {}, {}, [200, 1, 2, .3, .6], [0 0]);
    m = mean(plotting_bins(:,1)); M = mean(plotting_bins(61:end,1)); M2 = mean(plotting_bins(121:end,1)); M3 = mean(plotting_bins(1:60,1));
    if M2 < m && M > 0 && m < 1.5 && M3 < 1.3
        tmp{end+1} = neuron_ids{iter};
    end
end
neuron_ids = tmp;
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Unsplit Maze
[plotting_bins2, ~, ~, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Cost Benefit (Conflict) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\matrix_costBenefit_unsplitMaze'], 'fig')
saveas(gca, [fig_dir, '\matrix_costBenefit_unsplitMaze'], 'eps')
        %% Split Maze
[right_bins, ~, ~, numTrials2, fullData_mix] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {[5 1001]}, {}, [500, 1, 2, .35, .65], [0 0], 1);
[left_bins, ~, ~, numTrials1, fullData_choc] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {[5 2011]}, {}, [500, 1, 2, .35, .65], [0 0], 1);
tmp = conv(right_bins(:,1), ones(1,43)/43); tmp1 = smooth(right_bins(:,1),43); right_bins = [tmp1(1:42); tmp(43:500)];
tmp = conv(left_bins(:,1), ones(1,43)/43); tmp1 = smooth(left_bins(:,1),43); left_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_split_maze(right_bins, left_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(64.8,0,'-2 stds','VerticalAlignment','bottom'); text(64.8, 17.5, '0 stds'); text(64.8, 35, '+2 stds','VerticalAlignment','top');
title({['Cost Benefit Task - ', num2str(length(neuron_ids)), ' responders out of ', numNeurons, ' neurons']; 'Chocolate Choice on Left'})
saveas(gca,[fig_dir, '\matrix_costBenefit_splitMaze'],'fig')
saveas(gca,[fig_dir, '\matrix_costBenefit_splitMaze'],'eps')
fullData_choc = fullData_choc(fullData_choc(:,2)>-1,:);
fullData_choc = [mean(fullData_choc); std(fullData_choc)/sqrt(numTrials1); fullData_choc];
fullData_mix = fullData_mix(fullData_mix(:,2)>-1,:);
fullData_mix = [mean(fullData_mix); std(fullData_mix)/sqrt(numTrials2); fullData_mix];
xlswrite([fig_dir, '\matrix_costBenefit.xlsx'], fullData_choc, 1)
xlswrite([fig_dir, '\matrix_costBenefit.xlsx'], fullData_mix, 2)
save([fig_dir, '\matrix_costBenefit.mat'], 'fullData_choc', 'fullData_mix')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(1) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(1) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Benefit-benefit (similar)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'dms', 'grade', 'conc', 60, 70, ...
    'grade', 'striosomality_type', 0, 0, 'grade', 'final_michael_grade', 1, 5, 'grade', 'sqr_neuron_type', 3, 3);
neuron_ids2 = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'dms', 'grade', 'conc', 60, 70, ...
    'grade', 'striosomality_type', 0, 0, 'grade', 'final_michael_grade', 1, 5, 'grade', 'sqr_neuron_type', 5, 5);
neuron_ids = [neuron_ids, neuron_ids2];
numNeurons = num2str(length(neuron_ids));

tmp = {};
for iter = 1:length(neuron_ids)
    index = str2num(neuron_ids{iter});
    [plotting_bins, ~, ~, ~] = ah_fill_spike_plotting_bins(twdb_main(index).trial_spikes, ...
        {twdb_main(index).trial_evt_timings}, [1 100 twdb_main(index).baseline_firing_rate_data], {}, {}, [200, 1, 2, .3, .6], [0 0]);
    m = mean(plotting_bins(:,1)); M = mean(plotting_bins(61:end,1)); M2 = mean(plotting_bins(121:end,1)); M3 = mean(plotting_bins(1:60,1));
    if M2 < m && M > 0 && m < 1.5 && M3 < 1.3
        tmp{end+1} = neuron_ids{iter};
    end
end
neuron_ids = tmp;
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Unsplit Maze
[plotting_bins2, ~, ~, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Benefit Benefit (Similar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\matrix_benefitBenefitSimilar_unsplitMaze'], 'fig')
saveas(gca, [fig_dir, '\matrix_benefitBenefitSimilar_unsplitMaze'], 'eps')
        %% Split Maze
[right_bins, ~, ~, numTrials2, fullData_mix] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {[5 1001]}, {}, [500, 1, 2, .35, .65], [0 0], 1);
[left_bins, ~, ~, numTrials1, fullData_choc] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {[5 2011]}, {}, [500, 1, 2, .35, .65], [0 0], 1);
tmp = conv(right_bins(:,1), ones(1,43)/43); tmp1 = smooth(right_bins(:,1),43); right_bins = [tmp1(1:42); tmp(43:500)];
tmp = conv(left_bins(:,1), ones(1,43)/43); tmp1 = smooth(left_bins(:,1),43); left_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_split_maze(right_bins, left_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(64.8,0,'-2 stds','VerticalAlignment','bottom'); text(64.8, 17.5, '0 stds'); text(64.8, 35, '+2 stds','VerticalAlignment','top');
title({['Benefit Benefit (Similar) Task - ', num2str(length(neuron_ids)), ' responders out of ', numNeurons, ' neurons']; 'Chocolate Choice on Left'})
saveas(gca,[fig_dir, '\matrix_benefitBenefitSimilar_splitMaze'],'fig')
saveas(gca,[fig_dir, '\matrix_benefitBenefitSimilar_splitMaze'],'eps')
fullData_choc = fullData_choc(fullData_choc(:,2)>-1,:);
fullData_choc = [mean(fullData_choc); std(fullData_choc)/sqrt(numTrials1); fullData_choc];
fullData_mix = fullData_mix(fullData_mix(:,2)>-1,:);
fullData_mix = [mean(fullData_mix); std(fullData_mix)/sqrt(numTrials2); fullData_mix];
xlswrite([fig_dir, '\matrix_benefitBenefitSimilar.xlsx'], fullData_choc, 1)
xlswrite([fig_dir, '\matrix_benefitBenefitSimilar.xlsx'], fullData_mix, 2)
save([fig_dir, '\matrix_benefitBenefitSimilar.mat'], 'fullData_choc', 'fullData_mix')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(2) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(2) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Benefit-benefit (dissimilar)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'dms', 'grade', 'conc', 5, 45, ...
    'grade', 'striosomality_type', 0, 0, 'grade', 'final_michael_grade', 1, 5, 'grade', 'sqr_neuron_type', 3, 3);
neuron_ids2 = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'dms', 'grade', 'conc', 5, 45, ...
    'grade', 'striosomality_type', 0, 0, 'grade', 'final_michael_grade', 1, 5, 'grade', 'sqr_neuron_type', 5, 5);
neuron_ids = [neuron_ids, neuron_ids2];
numNeurons = num2str(length(neuron_ids));

tmp = {};
for iter = 1:length(neuron_ids)
    index = str2num(neuron_ids{iter});
    [plotting_bins, ~, ~, ~] = ah_fill_spike_plotting_bins(twdb_main(index).trial_spikes, ...
        {twdb_main(index).trial_evt_timings}, [1 100 twdb_main(index).baseline_firing_rate_data], {}, {}, [200, 1, 2, .3, .6], [0 0]);
    m = mean(plotting_bins(:,1)); M = mean(plotting_bins(61:end,1)); M2 = mean(plotting_bins(121:end,1)); M3 = mean(plotting_bins(1:60,1));
    if M2 < m && M > 0 && m < 1.5 && M3 < 1.3
        tmp{end+1} = neuron_ids{iter};
    end
end
neuron_ids = tmp;
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Unsplit Maze
[plotting_bins2, ~, ~, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Benefit Benefit (Dissimilar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\matrix_benefitBenefitDissimilar_unsplitMaze'], 'fig')
saveas(gca, [fig_dir, '\matrix_benefitBenefitDissimilar_unsplitMaze'], 'eps')
        %% Split Maze
[right_bins, ~, ~, numTrials2, fullData_mix] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {[5 1001]}, {}, [500, 1, 2, .35, .65], [0 0], 1);
[left_bins, ~, ~, numTrials1, fullData_choc] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {[5 2011]}, {}, [500, 1, 2, .35, .65], [0 0], 1);
tmp = conv(right_bins(:,1), ones(1,43)/43); tmp1 = smooth(right_bins(:,1),43); right_bins = [tmp1(1:42); tmp(43:500)];
tmp = conv(left_bins(:,1), ones(1,43)/43); tmp1 = smooth(left_bins(:,1),43); left_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_split_maze(right_bins, left_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(64.8,0,'-2 stds','VerticalAlignment','bottom'); text(64.8, 17.5, '0 stds'); text(64.8, 35, '+2 stds','VerticalAlignment','top');
title({['Benefit Benefit (Dissimilar) Task - ', num2str(length(neuron_ids)), ' responders out of ', numNeurons, ' neurons']; 'Chocolate Choice on Left'})
saveas(gca,[fig_dir, '\matrix_benefitBenefitDissimilar_splitMaze'],'fig')
saveas(gca,[fig_dir, '\matrix_benefitBenefitDissimilar_splitMaze'],'eps')
fullData_choc = fullData_choc(fullData_choc(:,2)>-1,:);
fullData_choc = [mean(fullData_choc); std(fullData_choc)/sqrt(numTrials1); fullData_choc];
fullData_mix = fullData_mix(fullData_mix(:,2)>-1,:);
fullData_mix = [mean(fullData_mix); std(fullData_mix)/sqrt(numTrials2); fullData_mix];
xlswrite([fig_dir, '\matrix_benefitBenefitDissimilar.xlsx'], fullData_choc, 1)
xlswrite([fig_dir, '\matrix_benefitBenefitDissimilar.xlsx'], fullData_mix, 2)
save([fig_dir, '\matrix_benefitBenefitDissimilar.mat'], 'fullData_choc', 'fullData_mix')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(3) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(3) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Non-conflict cost-benefit
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'Rev CB', 'key', 'tetrodeType', 'dms', ...
    'grade', 'striosomality_type', 0, 0, 'grade', 'final_michael_grade', 1, 5, 'grade', 'sqr_neuron_type', 3, 3);
neuron_ids2 = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'Rev CB', 'key', 'tetrodeType', 'dms', ...
    'grade', 'striosomality_type', 0, 0, 'grade', 'final_michael_grade', 1, 5, 'grade', 'sqr_neuron_type', 5, 5);
neuron_ids = [neuron_ids, neuron_ids2];
numNeurons = num2str(length(neuron_ids));

tmp = {};
for iter = 1:length(neuron_ids)
    index = str2num(neuron_ids{iter});
    ses_evt_timings = twdb_main(index).trial_evt_timings;
    choc = length(find(ses_evt_timings(:,5)==2011));
    mix = length(find(ses_evt_timings(:,5)==1001));
    if choc/mix > 1.5 && twdb_main(index).baseline_firing_rate_data(5) < 1.5
        tmp{end+1} = neuron_ids{iter};
    end
end
neuron_ids = tmp;
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Unsplit Maze
[plotting_bins2, ~, ~, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Non-conflict Cost Benefit Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\matrix_nonconflictCostBenefit_unsplitMaze'], 'fig')
saveas(gca, [fig_dir, '\matrix_nonconflictCostBenefit_unsplitMaze'], 'eps')
        %% Split Maze
[right_bins, ~, ~, numTrials2, fullData_mix] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {[5 1001]}, {}, [500, 1, 2, .35, .65], [0 0], 1);
[left_bins, ~, ~, numTrials1, fullData_choc] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {[5 2011]}, {}, [500, 1, 2, .35, .65], [0 0], 1);
tmp = conv(right_bins(:,1), ones(1,43)/43); tmp1 = smooth(right_bins(:,1),43); right_bins = [tmp1(1:42); tmp(43:500)];
tmp = conv(left_bins(:,1), ones(1,43)/43); tmp1 = smooth(left_bins(:,1),43); left_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_split_maze(right_bins, left_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(64.8,0,'-2 stds','VerticalAlignment','bottom'); text(64.8, 17.5, '0 stds'); text(64.8, 35, '+2 stds','VerticalAlignment','top');
title({['Non-conflict Cost Benefit Task - ', num2str(length(neuron_ids)), ' responders out of ', numNeurons, ' neurons']; 'Chocolate Choice on Left'})
saveas(gca,[fig_dir, '\matrix_nonconflictCostBenefit_splitMaze'],'fig')
saveas(gca,[fig_dir, '\matrix_nonconflictCostBenefit_splitMaze'],'eps')
fullData_choc = fullData_choc(fullData_choc(:,2)>-1,:);
fullData_choc = [mean(fullData_choc); std(fullData_choc)/sqrt(numTrials1); fullData_choc];
fullData_mix = fullData_mix(fullData_mix(:,2)>-1,:);
fullData_mix = [mean(fullData_mix); std(fullData_mix)/sqrt(numTrials2); fullData_mix];
xlswrite([fig_dir, '\matrix_nonconflictCostBenefit.xlsx'], fullData_choc, 1)
xlswrite([fig_dir, '\matrix_nonconflictCostBenefit.xlsx'], fullData_mix, 2)
save([fig_dir, '\matrix_nonconflictCostBenefit.mat'], 'fullData_choc', 'fullData_mix')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(4) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(4) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Cost-cost
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'EQR', 'key', 'tetrodeType', 'dms', ...
    'grade', 'striosomality_type', 0, 0, 'grade', 'final_michael_grade', 1, 5, 'grade', 'sqr_neuron_type', 3, 3);
neuron_ids2 = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'EQR', 'key', 'tetrodeType', 'dms', ...
    'grade', 'striosomality_type', 0, 0, 'grade', 'final_michael_grade', 1, 5, 'grade', 'sqr_neuron_type', 5, 5);
neuron_ids = [neuron_ids, neuron_ids2];
numNeurons = num2str(length(neuron_ids));

tmp = {};
for iter = 1:length(neuron_ids)
    index = str2num(neuron_ids{iter});
    [plotting_bins, ~, ~, ~] = ah_fill_spike_plotting_bins(twdb_main(index).trial_spikes, ...
        {twdb_main(index).trial_evt_timings}, [1 100 twdb_main(index).baseline_firing_rate_data], {}, {}, [200, 1, 2, .3, .6], [0 0]);
    m = mean(plotting_bins(:,1)); M = mean(plotting_bins(61:end,1)); M2 = mean(plotting_bins(121:end,1));
    ses_evt_timings = twdb_main(index).trial_evt_timings;
    dim = sum(ses_evt_timings(:,5)==2011);
    strong = sum(ses_evt_timings(:,5)==1001);
    left = sum(ses_evt_timings(:,3)==1010);
    right = sum(ses_evt_timings(:,3)==2020);
    if M2 < m && left > 0 && right > 0
        tmp{end+1} = neuron_ids{iter};
    end
end
neuron_ids = tmp;
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Unsplit Maze
[plotting_bins2, ~, ~, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Cost Cost Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\matrix_costCost_unsplitMaze'], 'fig')
saveas(gca, [fig_dir, '\matrix_costCost_unsplitMaze'], 'eps')
        %% Split Maze
[right_bins, ~, ~, numTrials2, fullData_mix] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {[5 1001]}, {}, [500, 1, 2, .35, .65], [0 0], 1);
[left_bins, ~, ~, numTrials1, fullData_choc] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {[5 2011]}, {}, [500, 1, 2, .35, .65], [0 0], 1);
tmp = conv(right_bins(:,1), ones(1,43)/43); tmp1 = smooth(right_bins(:,1),43); right_bins = [tmp1(1:42); tmp(43:500)];
tmp = conv(left_bins(:,1), ones(1,43)/43); tmp1 = smooth(left_bins(:,1),43); left_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_split_maze(right_bins, left_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(64.8,0,'-2 stds','VerticalAlignment','bottom'); text(64.8, 17.5, '0 stds'); text(64.8, 35, '+2 stds','VerticalAlignment','top');
title({['Cost Cost Task - ', num2str(length(neuron_ids)), ' responders out of ', numNeurons, ' neurons']; 'Chocolate Choice on Left'})
saveas(gca,[fig_dir, '\matrix_costCost_splitMaze'],'fig')
saveas(gca,[fig_dir, '\matrix_costCost_splitMaze'],'eps')
fullData_choc = fullData_choc(fullData_choc(:,2)>-1,:);
fullData_choc = [mean(fullData_choc); std(fullData_choc)/sqrt(numTrials1); fullData_choc];
fullData_mix = fullData_mix(fullData_mix(:,2)>-1,:);
fullData_mix = [mean(fullData_mix); std(fullData_mix)/sqrt(numTrials2); fullData_mix];
xlswrite([fig_dir, '\matrix_costCost.xlsx'], fullData_choc, 1)
xlswrite([fig_dir, '\matrix_costCost.xlsx'], fullData_mix, 2)
save([fig_dir, '\matrix_costCost.mat'], 'fullData_choc', 'fullData_mix')
close all;
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(5) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(5) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Bar graph of 5 tasks:
ah_barsWithErrors(bar_graph_means,bar_graph_stds,{'Cost Benefit (Conflict)', 'Benefit Benefit (Similar)', 'Benefit Benefit (Dissimilar)', 'Non-conflict Cost Benefit', 'Cost Cost'},{[1 0 0]},1)
ylabel('Z-score Compared to Baseline')
saveas(gca, [fig_dir, '\matrix_bar_plot'], 'fig')
saveas(gca, [fig_dir, '\matrix_bar_plot'], 'eps')
close all;

%% Figure Script 3: PFC-PLs (maze + firing rate population + bursts + bar graph)
fig_dir = [figs_dir, '\PFC-PLs'];
bar_graph_means = [0; 0; 0; 0; 0]; bar_graph_stds = [0; 0; 0; 0; 0];
    %% Cost-benefit (conflict)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'CB', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5,...
    'grade', 'strio_projecting_spikes', 10, NaN, 'grade', 'strio_projecting_grade', 5, NaN);
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
maxlength = length(neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([0 8]); title(['Cost Benefit (Conflict) Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\pls_costBenefit_firingRate'], 'fig')
saveas(gca, [fig_dir, '\pls_costBenefit_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\pls_costBenefit_firingRate.xlsx'], fullData)
save([fig_dir, '\pls_costBenefit_firingRate.mat'], 'fullData')
        %% Maze
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Cost Benefit (Conflict) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\pls_costBenefit_maze'], 'fig')
saveas(gca, [fig_dir, '\pls_costBenefit_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 100, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [100 250 .075 9 length(neuron_ids) 0.8 0 1 0.5 0 0]);
title(['Cost Benefit (Conflict): ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\pls_costBenefit_bursts'], 'fig');
saveas(gca, [fig_dir, '\pls_costBenefit_bursts'], 'eps');
xlswrite([fig_dir, '\pls_costBenefit_bursts.xlsx'], allBursts)
save([fig_dir, '\pls_costBenefit_bursts.mat'], 'allBursts')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(1) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(1) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Benefit-benefit (combined)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5,...
    'grade', 'strio_projecting_spikes', 10, NaN, 'grade', 'strio_projecting_grade', 5, NaN);
tmp = {};
for iter = 1:length(neuron_ids)
    index = str2num(neuron_ids{iter});
    if twdb_main(index).baseline_firing_rate_data(1) < 20
        tmp{end+1} = neuron_ids{iter};
    end
end
neuron_ids = tmp;
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([0 8]); title(['Benefit Benefit (Combined) Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\pls_benefitBenefitCombined_firingRate'], 'fig')
saveas(gca, [fig_dir, '\pls_benefitBenefitCombined_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\pls_benefitBenefitCombined_firingRate.xlsx'], fullData)
save([fig_dir, '\pls_benefitBenefitCombined_firingRate.mat'], 'fullData')
        %% Maze
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Benefit Benefit (Combined) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\pls_benefitBenefitCombined_maze'], 'fig')
saveas(gca, [fig_dir, '\pls_benefitBenefitCombined_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 100, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [100 250 .075 9 length(neuron_ids) 0.8 0 1 0.5 0 0]);
title(['Benefit Benefit (Combined): ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\pls_benefitBenefitCombined_bursts'], 'fig');
saveas(gca, [fig_dir, '\pls_benefitBenefitCombined_bursts'], 'eps');
xlswrite([fig_dir, '\pls_benefitBenefitCombined_bursts.xlsx'], allBursts)
save([fig_dir, '\pls_benefitBenefitCombined_bursts.mat'], 'allBursts')
    %% Benefit-benefit (similar)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5, 'grade', 'conc', 60, 70,...
    'grade', 'strio_projecting_spikes', 10, NaN, 'grade', 'strio_projecting_grade', 5, NaN);
tmp = {};
for iter = 1:length(neuron_ids)
    index = str2num(neuron_ids{iter});
    if twdb_main(index).baseline_firing_rate_data(1) < 20
        tmp{end+1} = neuron_ids{iter};
    end
end
neuron_ids = tmp;
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([0 8]); title(['Benefit Benefit (Similar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\pls_benefitBenefitSimilar_firingRate'], 'fig')
saveas(gca, [fig_dir, '\pls_benefitBenefitSimilar_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\pls_benefitBenefitSimilar_firingRate.xlsx'], fullData)
save([fig_dir, '\pls_benefitBenefitSimilar_firingRate.mat'], 'fullData')
        %% Maze
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Benefit Benefit (Similar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\pls_benefitBenefitSimilar_maze'], 'fig')
saveas(gca, [fig_dir, '\pls_benefitBenefitSimilar_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 100, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [100 250 .075 9 length(neuron_ids) 0.8 0 1 0.5 0 0]);
title(['Benefit Benefit (Similar): ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\pls_benefitBenefitSimilar_bursts'], 'fig');
saveas(gca, [fig_dir, '\pls_benefitBenefitSimilar_bursts'], 'eps');
xlswrite([fig_dir, '\pls_benefitBenefitSimilar_bursts.xlsx'], allBursts)
save([fig_dir, '\pls_benefitBenefitSimilar_bursts.mat'], 'allBursts')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(2) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(2) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Benefit-benefit (dissimilar)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5, 'grade', 'conc', 5, 45,...
    'grade', 'strio_projecting_spikes', 10, NaN, 'grade', 'strio_projecting_grade', 5, NaN);

tmp = {};
for iter = 1:length(neuron_ids)
    index = str2num(neuron_ids{iter});
    if twdb_main(index).baseline_firing_rate_data(1) < 20
        tmp{end+1} = neuron_ids{iter};
    end
end
neuron_ids = tmp;
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([0 8]); title(['Benefit Benefit (Dissimilar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\pls_benefitBenefitDissimilar_firingRate'], 'fig')
saveas(gca, [fig_dir, '\pls_benefitBenefitDissimilar_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\pls_benefitBenefitDissimilar_firingRate.xlsx'], fullData)
save([fig_dir, '\pls_benefitBenefitDissimilar_firingRate.mat'], 'fullData')
        %% Maze
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Benefit Benefit (Dissimilar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\pls_benefitBenefitDissimilar_maze'], 'fig')
saveas(gca, [fig_dir, '\pls_benefitBenefitDissimilar_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 100, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [100 250 .075 9 length(neuron_ids) 0.8 0 1 0.5 0 0]);
title(['Benefit Benefit (Dissimilar): ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\pls_benefitBenefitDissimilar_bursts'], 'fig');
saveas(gca, [fig_dir, '\pls_benefitBenefitDissimilar_bursts'], 'eps');
xlswrite([fig_dir, '\pls_benefitBenefitDissimilar_bursts.xlsx'], allBursts)
save([fig_dir, '\pls_benefitBenefitDissimilar_bursts.mat'], 'allBursts')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(3) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(3) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Non-conflict cost-benefit
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'Rev CB', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 2, 5,...
    'grade', 'strio_projecting_spikes', 10, NaN, 'grade', 'strio_projecting_grade', 5, NaN);
tmp = {};
for iter = 1:length(neuron_ids)
    index = str2num(neuron_ids{iter});
    if twdb_main(index).baseline_firing_rate_data(1) < 20
        tmp{end+1} = neuron_ids{iter};
    end
end
neuron_ids = tmp;
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([0 8]); title(['Non-conflict Cost Benefit Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\pls_nonconflictCostBenefit_firingRate'], 'fig')
saveas(gca, [fig_dir, '\pls_nonconflictCostBenefit_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\pls_nonconflictCostBenefit_firingRate.xlsx'], fullData)
save([fig_dir, '\pls_nonconflictCostBenefit_firingRate.mat'], 'fullData')
        %% Maze
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Non-conflict Cost Benefit Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\pls_nonconflictCostBenefit_maze'], 'fig')
saveas(gca, [fig_dir, '\pls_nonconflictCostBenefit_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 100, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [100 250 .075 9 length(neuron_ids) 0.8 0 1 0.5 0 0]);
title(['Non-conflict Cost Benefit: ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\pls_nonconflictCostBenefit_bursts'], 'fig');
saveas(gca, [fig_dir, '\pls_nonconflictCostBenefit_bursts'], 'eps');
xlswrite([fig_dir, '\pls_nonconflictCostBenefit_bursts.xlsx'], allBursts)
save([fig_dir, '\pls_nonconflictCostBenefit_bursts.mat'], 'allBursts')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(4) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(4) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Cost-cost
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'EQR', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5,...
    'grade', 'strio_projecting_spikes', 10, NaN, 'grade', 'strio_projecting_grade', 5, NaN);
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([0 8]); title(['Cost Cost Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\pls_costCost_firingRate'], 'fig')
saveas(gca, [fig_dir, '\pls_costCost_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\pls_costCost_firingRate.xlsx'], fullData)
save([fig_dir, '\pls_costCost_firingRate.mat'], 'fullData')
        %% Maze
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Cost Cost Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\pls_costCost_maze'], 'fig')
saveas(gca, [fig_dir, '\pls_costCost_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 100, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [100 250 .075 9 length(neuron_ids) 0.8 0 1 0.5 0 0]);
title(['Cost Cost: ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\pls_costCost_bursts'], 'fig');
saveas(gca, [fig_dir, '\pls_costCost_bursts'], 'eps');
xlswrite([fig_dir, '\pls_costCost_bursts.xlsx'], allBursts)
save([fig_dir, '\pls_costCost_bursts.mat'], 'allBursts')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(5) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(5) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Bar graph of 5 tasks:
ah_barsWithErrors(bar_graph_means,bar_graph_stds,{'Cost Benefit (Conflict)', 'Benefit Benefit (Similar)', 'Benefit Benefit (Dissimilar)', 'Non-conflict Cost Benefit', 'Cost Cost'},{[1 0 0]},1)
ylabel('Z-score Compared to Baseline')
saveas(gca, [fig_dir, '\pls_bar_plot'], 'fig')
saveas(gca, [fig_dir, '\pls_bar_plot'], 'eps')
close all;

%% Figure Script 4: non-PFC-PLs (maze + firing rate population)
fig_dir = [figs_dir, '\non-PFC-PLs'];
    %% Cost-benefit (conflict)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'CB', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5);
neuron_ids2 = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'CB', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5,...
    'grade', 'strio_projecting_spikes', 10, NaN, 'grade', 'strio_projecting_grade', 5, NaN);
neuron_ids = setdiff(neuron_ids, neuron_ids2);
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([1 5.5]); title(['Cost Benefit (Conflict) Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\plNots_costBenefit_firingRate'], 'fig')
saveas(gca, [fig_dir, '\plNots_costBenefit_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\plNots_costBenefit_firingRate.xlsx'], fullData)
save([fig_dir, '\plNots_costBenefit_firingRate.mat'], 'fullData')
        %% Maze
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-12*baseline_std, baseline_mean+12*baseline_std, .35, .65])
text(58.8,0,'-12 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+12 stds','VerticalAlignment','top');
title(['Cost Benefit (Conflict) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\plNots_costBenefit_maze'], 'fig')
saveas(gca, [fig_dir, '\plNots_costBenefit_maze'], 'eps')
        %% Burst Plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 100, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [100 250 .075 9 54 0.8 0 1 0.5 0 0]);
title(['Cost Benefit (Conflict): ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\plNots_costBenefit_bursts'], 'fig');
saveas(gca, [fig_dir, '\plNots_costBenefit_bursts'], 'eps');
xlswrite([fig_dir, '\plNots_costBenefit_bursts.xlsx'], allBursts)
save([fig_dir, '\plNots_costBenefit_bursts.mat'], 'allBursts')
    %% Benefit-benefit (combined)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5);
neuron_ids2 = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5,...
    'grade', 'strio_projecting_spikes', 10, NaN, 'grade', 'strio_projecting_grade', 5, NaN);
neuron_ids = setdiff(neuron_ids, neuron_ids2);
        %% Burst Plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, 54, 100, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [100 250 .075 9 54 0.8 0 1 0.5 0 0]);
title(['Benefit Benefit (Combined): ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\plNots_benefitBenefit_bursts'], 'fig');
saveas(gca, [fig_dir, '\plNots_benefitBenefit_bursts'], 'eps');
xlswrite([fig_dir, '\plNots_benefitBenefit_bursts.xlsx'], allBursts)
save([fig_dir, '\plNots_benefitBenefit_bursts.mat'], 'allBursts')
    %% Benefit-benefit (similar)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5, 'grade', 'conc', 60, 70);
neuron_ids2 = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5, 'grade', 'conc', 60, 70,...
    'grade', 'strio_projecting_spikes', 10, NaN, 'grade', 'strio_projecting_grade', 5, NaN);
neuron_ids = setdiff(neuron_ids, neuron_ids2);
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([1 5.5]); title(['Benefit Benefit (Similar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\plNots_benefitBenefitSimilar_firingRate'], 'fig')
saveas(gca, [fig_dir, '\plNots_benefitBenefitSimilar_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\plNots_benefitBenefitSimilar_firingRate.xlsx'], fullData)
save([fig_dir, '\plNots_benefitBenefitSimilar_firingRate.mat'], 'fullData')
        %% Maze
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-12*baseline_std, baseline_mean+12*baseline_std, .35, .65])
text(58.8,0,'-12 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+12 stds','VerticalAlignment','top');
title(['Benefit Benefit (Similar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\plNots_benefitBenefitSimilar_maze'], 'fig')
saveas(gca, [fig_dir, '\plNots_benefitBenefitSimilar_maze'], 'eps')
    %% Benefit-benefit (dissimilar)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5, 'grade', 'conc', 5, 45);
neuron_ids2 = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5, 'grade', 'conc', 5, 45,...
    'grade', 'strio_projecting_spikes', 10, NaN, 'grade', 'strio_projecting_grade', 5, NaN);
neuron_ids = setdiff(neuron_ids, neuron_ids2);
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([1 5.5]); title(['Benefit Benefit (Dissimilar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\plNots_benefitBenefitDissimilar_firingRate'], 'fig')
saveas(gca, [fig_dir, '\plNots_benefitBenefitDissimilar_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\plNots_benefitBenefitDissimilar_firingRate.xlsx'], fullData)
save([fig_dir, '\plNots_benefitBenefitDissimilar_firingRate.mat'], 'fullData')
        %% Maze
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-12*baseline_std, baseline_mean+12*baseline_std, .35, .65])
text(58.8,0,'-12 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+12 stds','VerticalAlignment','top');
title(['Benefit Benefit (Dissimilar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\plNots_benefitBenefitDissimilar_maze'], 'fig')
saveas(gca, [fig_dir, '\plNots_benefitBenefitDissimilar_maze'], 'eps')
    %% Non-conflict cost-benefit
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'Rev CB', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5);
neuron_ids2 = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'Rev CB', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5,...
    'grade', 'strio_projecting_spikes', 10, NaN, 'grade', 'strio_projecting_grade', 5, NaN);
neuron_ids = setdiff(neuron_ids, neuron_ids2);
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([1 5.5]); title(['Non-conflict Cost Benefit Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\plNots_nonconflictCostBenefit_firingRate'], 'fig')
saveas(gca, [fig_dir, '\plNots_nonconflictCostBenefit_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\plNots_nonconflictCostBenefit_firingRate.xlsx'], fullData)
save([fig_dir, '\plNots_nonconflictCostBenefit_firingRate.mat'], 'fullData')
        %% Maze
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-12*baseline_std, baseline_mean+12*baseline_std, .35, .65])
text(58.8,0,'-12 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+12 stds','VerticalAlignment','top');
title(['Non-conflict Cost Benefit Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\plNots_nonconflictCostBenefit_maze'], 'fig')
saveas(gca, [fig_dir, '\plNots_nonconflictCostBenefit_maze'], 'eps')
    %% Cost-cost
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'EQR', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5);
neuron_ids2 = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'EQR', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5,...
    'grade', 'strio_projecting_spikes', 10, NaN, 'grade', 'strio_projecting_grade', 5, NaN);
neuron_ids = setdiff(neuron_ids, neuron_ids2);
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([1 5.5]); title(['Cost Cost Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\plNots_costCost_firingRate'], 'fig')
saveas(gca, [fig_dir, '\plNots_costCost_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\plNots_costCost_firingRate.xlsx'], fullData)
save([fig_dir, '\plNots_costCost_firingRate.mat'], 'fullData')
        %% Maze
[middle_bins,~,~,numTrials] = ah_fill_spike_plotting_bins(spikes_array, ses_evt_timings, neuron_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
baseline_mean = mean(plotting_bins2(60:240,1))*numTrials0/numTrials;
baseline_std = std(plotting_bins2(60:240,1))*numTrials0/numTrials;
tmp = conv(middle_bins(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins(:,1),43); middle_bins = [tmp1(1:42); tmp(43:500)];
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-12*baseline_std, baseline_mean+12*baseline_std, .35, .65])
text(58.8,0,'-12 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+12 stds','VerticalAlignment','top');
title(['Cost Cost Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\plNots_costCost_maze'], 'fig')
saveas(gca, [fig_dir, '\plNots_costCost_maze'], 'eps')
close all;

%% Figure Script 5: HFN (maze + firing rate population + bursts + bar graph)
fig_dir = [figs_dir, '\HFN'];
bar_graph_means = [0; 0; 0; 0; 0]; bar_graph_stds = [0; 0; 0; 0; 0];
    %% Cost-benefit (conflict)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'CB', 'key', 'tetrodeType', 'dms', 'grade', 'final_michael_grade', 1, 5, ...
    'grade', 'sqr_neuron_type', 1, 1, 'grade', 'striosomality_type', 1, 5);
[~, ~, ~, ~, bursts_array, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
maxlength = length(neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_burst_plotting_bins(bursts_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6, 0], [1 0], [12 0 5], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([0 .08]); title(['Cost Benefit (Conflict) Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\hfn_costBenefit_firingRate'], 'fig')
saveas(gca, [fig_dir, '\hfn_costBenefit_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\hfn_costBenefit_firingRate.xlsx'], fullData)
save([fig_dir, '\hfn_costBenefit_firingRate.mat'], 'fullData')
        %% Maze
middle_bins = plotting_bins2;
baseline_mean = mean(plotting_bins2(60:240,1));
baseline_std = std(plotting_bins2(60:240,1));
tmp = conv(middle_bins(:,1), ones(1,31)/31); tmp1 = smooth(middle_bins(:,1),31); middle_bins = tmp(231:430);
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Cost Benefit (Conflict) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\hfn_costBenefit_maze'], 'fig')
saveas(gca, [fig_dir, '\hfn_costBenefit_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 900, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [900 1800 .046 9 length(neuron_ids) 2.3 0 1 0.5 0 0]);
title(['Cost Benefit (Conflict): ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\hfn_costBenefit_bursts'], 'fig');
saveas(gca, [fig_dir, '\hfn_costBenefit_bursts'], 'eps');
xlswrite([fig_dir, '\hfn_costBenefit_bursts.xlsx'], allBursts)
save([fig_dir, '\hfn_costBenefit_bursts.mat'], 'allBursts')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(1) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(1) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Benefit-benefit (combined)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR',  'key', 'tetrodeType', 'dms', 'grade', 'final_michael_grade', 1, 5, ...
    'grade', 'sqr_neuron_type', 1, 1, 'grade', 'striosomality_type', 1, 5);
[~, ~, ~, ~, bursts_array, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_burst_plotting_bins(bursts_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6, 0], [1 0], [12 0 5], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([0 .08]); title(['Benefit Benefit (Combined) Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\hfn_benefitBenefitCombined_firingRate'], 'fig')
saveas(gca, [fig_dir, '\hfn_benefitBenefitCombined_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\hfn_benefitBenefitCombined_firingRate.xlsx'], fullData)
save([fig_dir, '\hfn_benefitBenefitCombined_firingRate.mat'], 'fullData')
        %% Maze
middle_bins = plotting_bins2;
baseline_mean = mean(plotting_bins2(60:240,1));
baseline_std = std(plotting_bins2(60:240,1));
tmp = conv(middle_bins(:,1), ones(1,31)/31); tmp1 = smooth(middle_bins(:,1),31); middle_bins = tmp(231:430);
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Benefit Benefit (Combined) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\hfn_benefitBenefitCombined_maze'], 'fig')
saveas(gca, [fig_dir, '\hfn_benefitBenefitCombined_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 900, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [900 1800 .046 9 length(neuron_ids) 2.3 0 1 0.5 0 0]);
title(['Benefit Benefit (Combined): ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\hfn_benefitBenefitCombined_bursts'], 'fig');
saveas(gca, [fig_dir, '\hfn_benefitBenefitCombined_bursts'], 'eps');
xlswrite([fig_dir, '\hfn_benefitBenefitCombined_bursts.xlsx'], allBursts)
save([fig_dir, '\hfn_benefitBenefitCombined_bursts.mat'], 'allBursts')
    %% Benefit-benefit (similar)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'grade', 'conc', 60, 70, 'key', 'tetrodeType', 'dms', 'grade', 'final_michael_grade', 1, 5, ...
    'grade', 'sqr_neuron_type', 1, 1, 'grade', 'striosomality_type', 1, 5);
[~, ~, ~, ~, bursts_array, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_burst_plotting_bins(bursts_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6, 0], [1 0], [12 0 5], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([0 .08]); title(['Benefit Benefit (Similar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\hfn_benefitBenefitSimilar_firingRate'], 'fig')
saveas(gca, [fig_dir, '\hfn_benefitBenefitSimilar_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\hfn_benefitBenefitSimilar_firingRate.xlsx'], fullData)
save([fig_dir, '\hfn_benefitBenefitSimilar_firingRate.mat'], 'fullData')
        %% Maze
middle_bins = plotting_bins2;
baseline_mean = mean(plotting_bins2(60:240,1));
baseline_std = std(plotting_bins2(60:240,1));
tmp = conv(middle_bins(:,1), ones(1,31)/31); tmp1 = smooth(middle_bins(:,1),31); middle_bins = tmp(231:430);
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Benefit Benefit (Similar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\hfn_benefitBenefitSimilar_maze'], 'fig')
saveas(gca, [fig_dir, '\hfn_benefitBenefitSimilar_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 900, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [900 1800 .046 9 length(neuron_ids) 2.3 0 1 0.5 0 0]);
title(['Benefit Benefit (Similar): ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\hfn_benefitBenefitSimilar_bursts'], 'fig');
saveas(gca, [fig_dir, '\hfn_benefitBenefitSimilar_bursts'], 'eps');
xlswrite([fig_dir, '\hfn_benefitBenefitSimilar_bursts.xlsx'], allBursts)
save([fig_dir, '\hfn_benefitBenefitSimilar_bursts.mat'], 'allBursts')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(2) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(2) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Benefit-benefit (dissimilar)
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'grade', 'conc', 5, 45, 'key', 'tetrodeType', 'dms', 'grade', 'final_michael_grade', 1, 5, ...
    'grade', 'sqr_neuron_type', 1, 1, 'grade', 'striosomality_type', 1, 5);
[~, ~, ~, ~, bursts_array, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_burst_plotting_bins(bursts_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6, 0], [1 0], [12 0 5], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([0 .08]); title(['Benefit Benefit (Dissimilar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\hfn_benefitBenefitDissimilar_firingRate'], 'fig')
saveas(gca, [fig_dir, '\hfn_benefitBenefitDissimilar_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\hfn_benefitBenefitDissimilar_firingRate.xlsx'], fullData)
save([fig_dir, '\hfn_benefitBenefitDissimilar_firingRate.mat'], 'fullData')
        %% Maze
middle_bins = plotting_bins2;
baseline_mean = mean(plotting_bins2(60:240,1));
baseline_std = std(plotting_bins2(60:240,1));
tmp = conv(middle_bins(:,1), ones(1,31)/31); tmp1 = smooth(middle_bins(:,1),31); middle_bins = tmp(231:430);
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Benefit Benefit (Dissimilar) Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\hfn_benefitBenefitDissimilar_maze'], 'fig')
saveas(gca, [fig_dir, '\hfn_benefitBenefitDissimilar_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 900, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [900 1800 .046 9 length(neuron_ids) 2.3 0 1 0.5 0 0]);
title(['Benefit Benefit (Dissimilar): ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\hfn_benefitBenefitDissimilar_bursts'], 'fig');
saveas(gca, [fig_dir, '\hfn_benefitBenefitDissimilar_bursts'], 'eps');
xlswrite([fig_dir, '\hfn_benefitBenefitDissimilar_bursts.xlsx'], allBursts)
save([fig_dir, '\hfn_benefitBenefitDissimilar_bursts.mat'], 'allBursts')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(3) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(3) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Non-conflict cost-benefit
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'Rev CB', 'key', 'tetrodeType', 'dms', 'grade', 'final_michael_grade', 1, 5, ...
    'grade', 'sqr_neuron_type', 1, 1, 'grade', 'striosomality_type', 1, 5);
[~, ~, ~, ~, bursts_array, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_burst_plotting_bins(bursts_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6, 0], [1 0], [12 0 5], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([0 .08]); title(['Non-conflict Cost Benefit Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\hfn_nonconflictCostBenefit_firingRate'], 'fig')
saveas(gca, [fig_dir, '\hfn_nonconflictCostBenefit_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\hfn_nonconflictCostBenefit_firingRate.xlsx'], fullData)
save([fig_dir, '\hfn_nonconflictCostBenefit_firingRate.mat'], 'fullData')
        %% Maze
middle_bins = plotting_bins2;
baseline_mean = mean(plotting_bins2(60:240,1));
baseline_std = std(plotting_bins2(60:240,1));
tmp = conv(middle_bins(:,1), ones(1,31)/31); tmp1 = smooth(middle_bins(:,1),31); middle_bins = tmp(231:430);
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Non-conflict Cost Benefit Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\hfn_nonconflictCostBenefit_maze'], 'fig')
saveas(gca, [fig_dir, '\hfn_nonconflictCostBenefit_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 900, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [900 1800 .046 9 length(neuron_ids) 2.3 0 1 0.5 0 0]);
title(['Non-conflict Cost Benefit: ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\hfn_nonconflictCostBenefit_bursts'], 'fig');
saveas(gca, [fig_dir, '\hfn_nonconflictCostBenefit_bursts'], 'eps');
xlswrite([fig_dir, '\hfn_nonconflictCostBenefit_bursts.xlsx'], allBursts)
save([fig_dir, '\hfn_nonconflictCostBenefit_bursts.mat'], 'allBursts')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(4) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(4) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Cost-cost
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'EQR', 'key', 'tetrodeType', 'dms', 'grade', 'final_michael_grade', 1, 5, ...
    'grade', 'sqr_neuron_type', 1, 1, 'grade', 'striosomality_type', 1, 5);
[~, ~, ~, ~, bursts_array, ses_evt_timings, neuron_idsAndData] = ...
    ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Firing Rate
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_burst_plotting_bins(bursts_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6, 0], [1 0], [12 0 5], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([0 .08]); title(['Cost Cost Task - ', num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\hfn_costCost_firingRate'], 'fig')
saveas(gca, [fig_dir, '\hfn_costCost_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\hfn_costCost_firingRate.xlsx'], fullData)
save([fig_dir, '\hfn_costCost_firingRate.mat'], 'fullData')
        %% Maze
middle_bins = plotting_bins2;
baseline_mean = mean(plotting_bins2(60:240,1));
baseline_std = std(plotting_bins2(60:240,1));
tmp = conv(middle_bins(:,1), ones(1,31)/31); tmp1 = smooth(middle_bins(:,1),31); middle_bins = tmp(231:430);
ah_plot_unsplit_maze(middle_bins, middle_bins, middle_bins, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
title(['Cost Cost Task - ', num2str(length(neuron_ids)), ' Neurons']);
saveas(gca, [fig_dir, '\hfn_costCost_maze'], 'fig')
saveas(gca, [fig_dir, '\hfn_costCost_maze'], 'eps')
        %% Burst plot
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 900, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [900 1800 .046 9 length(neuron_ids) 2.3 0 1 0.5 0 0]);
title(['Cost Cost: ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\hfn_costCost_bursts'], 'fig');
saveas(gca, [fig_dir, '\hfn_costCost_bursts'], 'eps');
xlswrite([fig_dir, '\hfn_costCost_bursts.xlsx'], allBursts)
save([fig_dir, '\hfn_costCost_bursts.mat'], 'allBursts')
        %% Bar graph computation
BL_mean = mean(plotting_bins2(60:240,1));
BL_std = std(plotting_bins2(60:240,1));
bar_graph_means(5) = (mean(plotting_bins2(301:315,1))-BL_mean)/BL_std;
bar_graph_stds(5) = 1/sqrt(15)*std(plotting_bins2(301:315,1))/BL_std;
    %% Bar graph of 5 tasks:
ah_barsWithErrors(bar_graph_means,bar_graph_stds,{'Cost Benefit (Conflict)', 'Benefit Benefit (Similar)', 'Benefit Benefit (Dissimilar)', 'Non-conflict Cost Benefit', 'Cost Cost'},{[1 0 0]},1)
ylabel('Z-score Compared to Baseline')
saveas(gca, [fig_dir, '\hfn_bar_plot'], 'fig')
saveas(gca, [fig_dir, '\hfn_bar_plot'], 'eps')
close all;

%% Figure Script 6: Examples of responses to orthodromic/antidromic stimulation
fig_dir = [figs_dir, '\Stimulation_Responses'];
    %% Striosome: 
idx = 9051;
        %% Set up spikes array
events = load([twdb_main(idx).sessionDir, '\events6.EVTSAV'], '-mat');
events = events.lfp_save_events;

unitnum = str2double(twdb_main(idx).neuronN);
spikes = load(twdb_main(idx).clusterDataLoc);
spikes = spikes.output;
spikes = spikes(spikes(:,2)==unitnum,1);

stim_spikes = ah_build_spikes_array(spikes,events,4,[-1 1],4);
data = twdb_main(idx).striosomality_data;
numTrials = length(stim_spikes);
        %% Draw raster plot
figure; hold all;
line([0 0], [0 numTrials], 'LineWidth', 2, 'Color', 'Red')
patch(1000*[data(3:4) data(4:-1:3)], [0 0 numTrials numTrials], [1.00 0.75 0.75], 'EdgeColor', 'none')
patch(1000*[data(7:8) data(8:-1:7)], [0 0 numTrials numTrials], [0.75 0.75 0.75], 'EdgeColor', 'none')
for trial_idx = 1:numTrials
    for spike_idx = 1:length(stim_spikes{trial_idx})
        spike_time = stim_spikes{trial_idx}(spike_idx)*1000;
        line([spike_time spike_time], [trial_idx-1 trial_idx], 'LineWidth', 2.5, 'Color', 'Black')
    end
end
        %% Plot formatting
set(gca, 'ydir', 'reverse')
xlim([-300 300]);
xlabel('Time (ms)');
ylim([0 numTrials]);
ylabel('Trial Number');
saveas(gca, [fig_dir, '\Striosome_rep_ras'], 'fig')
saveas(gca, [fig_dir, '\Striosome_rep_ras'], 'eps')
save([fig_dir, '\rep_strio_spikes_array.mat'], 'stim_spikes')
for trial_idx = 1:numTrials
    xlswrite([fig_dir, '\rep_strio_spikes_array'], stim_spikes{trial_idx}', 1, ['A' num2str(trial_idx)])
end
        %% Draw/format histogram
figure; hold all
spike = cell2mat(stim_spikes)*1000;
tvals = -995:10:995; binwidth = tvals(2) - tvals(1); numBins = length(tvals);
bins = hist(spike,tvals); bins = bins*1000/(numTrials*binwidth);
bar(tvals,bins,1)
xlim([-300 300]);
xlabel('Time (ms)');
ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\Striosome_rep_his'], 'fig')
saveas(gca, [fig_dir, '\Striosome_rep_his'], 'eps')
hist_data = [tvals; bins];
save([fig_dir, '\rep_strio_histogram.mat'], 'hist_data')
xlswrite([fig_dir, '\rep_strio_histogram'], hist_data)
    %% Matrix:
idx = 11066;
        %% Set up spikes array
events = load([twdb_main(idx).sessionDir, '\events6.EVTSAV'], '-mat');
events = events.lfp_save_events;

unitnum = str2double(twdb_main(idx).neuronN);
spikes = load(twdb_main(idx).clusterDataLoc);
spikes = spikes.output;
spikes = spikes(spikes(:,2)==unitnum,1);

stim_spikes = ah_build_spikes_array(spikes,events,4,[-1 1],4);
data = twdb_main(idx).striosomality_data;
numTrials = length(stim_spikes);
        %% Draw raster plot
figure; hold all;
line([0 0], [0 numTrials], 'LineWidth', 2, 'Color', 'Red')
for trial_idx = 1:numTrials
    for spike_idx = 1:length(stim_spikes{trial_idx})
        spike_time = stim_spikes{trial_idx}(spike_idx)*1000;
        line([spike_time spike_time], [trial_idx-1 trial_idx], 'LineWidth', 2.5, 'Color', 'Black')
    end
end
        %% Plot formatting
set(gca, 'ydir', 'reverse')
xlim([-300 300]);
xlabel('Time (ms)');
ylim([0 numTrials]);
ylabel('Trial Number');
saveas(gca, [fig_dir, '\Matrix_rep_ras'], 'fig')
saveas(gca, [fig_dir, '\Matrix_rep_ras'], 'eps')
save([fig_dir, '\rep_matrix_spikes_array.mat'], 'stim_spikes')
for trial_idx = 1:numTrials
    if ~isempty(stim_spikes{trial_idx})
        xlswrite([fig_dir, '\rep_matrix_spikes_array'], stim_spikes{trial_idx}', 1, ['A' num2str(trial_idx)])
    end
end
        %% Draw/format histogram
figure; hold all
spike = cell2mat(stim_spikes)*1000;
tvals = -995:10:995; binwidth = tvals(2) - tvals(1); numBins = length(tvals);
bins = hist(spike,tvals); bins = bins*1000/(numTrials*binwidth);
bar(tvals,bins,1)
xlim([-300 300]);
xlabel('Time (ms)');
ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\Matrix_rep_his'], 'fig')
saveas(gca, [fig_dir, '\Matrix_rep_his'], 'eps')
hist_data = [tvals; bins];
save([fig_dir, '\rep_matrix_histogram.mat'], 'hist_data')
xlswrite([fig_dir, '\rep_matrix_histogram'], hist_data)
    %% PFC-PLs:
idx = 8628;
        %% Set up spikes array
events = load([twdb_main(idx).sessionDir, '\events6.EVTSAV'], '-mat');
events = events.lfp_save_events;
block_idx = find(events(:,2)==43);
block_end = find(events(block_idx+2:end,2)==100,1,'first') + block_idx + 1;
events = events(block_idx:block_end,:);
events(events==6)=4;

unitnum = str2double(twdb_main(idx).neuronN);
spikes = load(twdb_main(idx).clusterDataLoc);
spikes = spikes.output;
spikes = spikes(spikes(:,2)==unitnum,1);

stim_spikes = ah_build_spikes_array(spikes,events,4,[-1 1],4);
data = twdb_main(idx).striosomality_data;
numTrials = length(stim_spikes);
        %% Draw raster plot
figure; hold all;
line([0 0], [0 numTrials], 'LineWidth', 2, 'Color', 'Red')
patch([1 10 10 1], [0 0 numTrials numTrials], [1.00 0.75 0.75], 'EdgeColor', 'none')
for trial_idx = 1:numTrials
    for spike_idx = 1:length(stim_spikes{trial_idx})
        spike_time = stim_spikes{trial_idx}(spike_idx)*1000;
        line([spike_time spike_time], [trial_idx-1 trial_idx], 'LineWidth', 2, 'Color', 'Black')
    end
end
        %% Plot formatting
set(gca, 'ydir', 'reverse')
xlim([-20 20]);
xlabel('Time (ms)');
ylim([0 numTrials]);
ylabel('Trial Number');
saveas(gca, [fig_dir, '\StrioProjPL_rep_ras'], 'fig')
saveas(gca, [fig_dir, '\StrioProjPL_rep_ras'], 'eps')
save([fig_dir, '\rep_plS_spikes_array.mat'], 'stim_spikes')
for trial_idx = 1:numTrials
    if ~isempty(stim_spikes{trial_idx})
        xlswrite([fig_dir, '\rep_plS_spikes_array'], stim_spikes{trial_idx}', 1, ['A' num2str(trial_idx)])
    end
end
        %% Draw/format histogram
figure; hold all
spike = cell2mat(stim_spikes)*1000;
tvals = -999.75:.5:999.75; binwidth = tvals(2) - tvals(1); numBins = length(tvals);
bins = hist(spike,tvals); bins = bins*1000/(numTrials*binwidth);
bar(tvals,bins,1)
xlim([-20 20]);
xlabel('Time (ms)');
ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\StrioProjPL_rep_his'], 'fig')
saveas(gca, [fig_dir, '\StrioProjPL_rep_his'], 'eps')
hist_data = [tvals; bins];
save([fig_dir, '\rep_plS_histogram.mat'], 'hist_data')
xlswrite([fig_dir, '\rep_plS_histogram.xlsx'], hist_data')
close all;

%% Figure Script 7: Task switch (BB --> CBC, Laser, BB -> BB, CBC -> CBC)
fig_dir = [figs_dir, '\Task_Switch_and_Laser'];
    %% Laser
neuron_ids = twdb_lookup(twdb_main, 'index', 'grade', 'striosomality_type', 1, 5, 'grade', 'sqr_neuron_type', 3, 5, 'grade', 'laser', 1, 1);
neuron_ids2 = twdb_lookup(twdb_laser, 'index', 'grade', 'striosomality_type', 1, 5, 'grade', 'sqr_neuron_type', 3, 5);
numNeurons = length(neuron_ids);
        %% Determine neurons with change between blocks in-run.
new_ids = {};
new_ids2 = {};
count = 0;
for idx = 1:numNeurons
    index = str2double(neuron_ids{idx});
    index2 = str2double(neuron_ids2{idx});
    [plotting_bins1, ~, ~, ~] = ah_fill_spike_plotting_bins(twdb_main(index).trial_spikes, ...
        {twdb_main(index).trial_evt_timings}, [1 100 twdb_main(index).baseline_firing_rate_data], {}, {}, [600, 1, 2, .5, .6], [0 0]);
    [plotting_bins2, ~, ~, ~] = ah_fill_spike_plotting_bins(twdb_laser(index2).trial_spikes, ...
        {twdb_laser(index2).trial_evt_timings}, [1 100 twdb_laser(index2).baseline_firing_rate_data], {}, {}, [600, 1, 2, .5, .6], [0 0]);
    if (mean(plotting_bins1(60:240,1))/mean(plotting_bins2(60:240,1)) < 1.5 && mean(plotting_bins1(60:240,1))/mean(plotting_bins2(60:240,1)) > .667) && ...
            mean(plotting_bins1(301:320,1))/mean(plotting_bins2(301:320,1)) < .85 && mean(plotting_bins2(301:320,1))/mean(plotting_bins2(60:240,1)) > 1
        new_ids{end+1} = neuron_ids{idx};
        new_ids2{end+1} = neuron_ids2{idx};
    elseif mean(plotting_bins1(60:240,1))/mean(plotting_bins2(60:240,1)) < 1.5 && mean(plotting_bins1(60:240,1))/mean(plotting_bins2(60:240,1)) > .667
        count = count + 1;
    end
end
        %% Plotting Prelaser Block
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ah_extractDataFromTWDB(twdb_main, new_ids);
[plotting_bins, evt_times_distribution, timeOfBins, numTrials, fullData] = ah_fill_spike_plotting_bins(spikes_array,...
    ses_evt_timings,neuron_idsAndData,{},{},[600 1 2 .5 .6],[0 0],1);
ah_plot_double_aligned_population_analysis(plotting_bins,evt_times_distribution,timeOfBins,numTrials,[1 2],.53,15,1,[1 0 0])
title(['Prelaser Block - ', num2str(length(new_ids)), ' neurons'])
xlim([-5 5])
saveas(gca, [fig_dir, '\prelaser_block_popanal'], 'fig')
saveas(gca, [fig_dir, '\prelaser_block_popanal'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials); fullData];
xlswrite([fig_dir, '\prelaser_block_data.xlsx'], fullData)
save([fig_dir, '\prelaser_block_data.mat'], 'fullData')
tmp = conv(plotting_bins(:,1), ones(1,31)/31); maze_bins = tmp(231:430);
BL_mean = mean(plotting_bins(60:240,1)); BL_std = std(plotting_bins(60:240,1));
ah_plot_unsplit_maze(maze_bins, maze_bins, maze_bins, 1, [54, 33, 8, 33, 54, 1, 1, BL_mean - 4.5*BL_std, BL_mean + 4.5*BL_std, .35, .65])
title(['Prelaser Block - ', num2str(length(new_ids)), ' neurons'])
saveas(gca,[fig_dir, '\prelaser_block_maze'],'fig')
saveas(gca,[fig_dir, '\prelaser_block_maze'],'eps')
        %% Prelaser block bursts
allBursts = [];
for iter = 1:length(new_ids)
    index = str2double(new_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(new_ids),13, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [13 26 .088 9 length(new_ids) 0.6 0 1 0.5 0 0]);
title(['Before Laser:' num2str(length(new_ids)) ' neurons']);
saveas(gca, [fig_dir, '\prelaser_block_bursts'],'fig')
saveas(gca, [fig_dir, '\prelaser_block_bursts'],'eps')
save([fig_dir, '\prelaser_block_bursts.mat'], 'selectedBursts')
xlswrite([fig_dir, '\prelaser_block_bursts.xlsx'], selectedBursts)
        %% Plotting Laser Block
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ah_extractDataFromTWDB(twdb_laser, new_ids2);
[plotting_bins, evt_times_distribution, timeOfBins, numTrials, fullData] = ah_fill_spike_plotting_bins(spikes_array,...
    ses_evt_timings,neuron_idsAndData,{},{},[600 1 2 .5 .6],[0 0],1);
ah_plot_double_aligned_population_analysis(plotting_bins,evt_times_distribution,timeOfBins,numTrials,[1 2],.53,15,1,[0 0 1])
title(['Laser Block - ', num2str(length(new_ids)), ' neurons'])
xlim([-5 5])
saveas(gca, [fig_dir, '\laser_block_thresholdMethod'], 'fig')
saveas(gca, [fig_dir, '\laser_block_thresholdMethod'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials); fullData];
xlswrite([fig_dir, '\laser_block_data.xlsx'], fullData)
save([fig_dir, '\laser_block_data.mat'], 'fullData')
tmp = conv(plotting_bins(:,1), ones(1,31)/31); maze_bins = tmp(231:430);
BL_mean = mean(plotting_bins(60:240,1)); BL_std = std(plotting_bins(60:240,1));
ah_plot_unsplit_maze(maze_bins, maze_bins, maze_bins, 1, [54, 33, 8, 33, 54, 1, 1, BL_mean - 4.5*BL_std, BL_mean + 4.5*BL_std, .35, .65])
title(['Laser Block - ', num2str(length(new_ids)), ' neurons'])
saveas(gca,[fig_dir, '\laser_block_maze'],'fig')
saveas(gca,[fig_dir, '\laser_block_maze'],'eps')
        %% Laser Block bursts
allBursts = [];
for iter = 1:length(new_ids2)
    index = str2double(new_ids2{iter});
    bursts = twdb_laser(index).trial_bursts;
    evt_times = twdb_laser(index).trial_evt_timings;
    for trial = 1:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(new_ids),13, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [13 26 .088 9 length(new_ids) 0.6 0 1 0.5 0 0]);
title(['Laser:' num2str(length(new_ids)) ' neurons']);
saveas(gca, [fig_dir, '\laser_block_bursts'],'fig')
saveas(gca, [fig_dir, '\laser_block_bursts'],'eps')
save([fig_dir, '\laser_block_bursts.mat'], 'selectedBursts')
xlswrite([fig_dir, '\laser_block_bursts.xlsx'], selectedBursts)
        %% Trial bar graph
windows1=[];
for j=1:20
    spikes=[];
    evt_timings={};
    idsAndData=[];
    count=0;
    for i = 1:length(new_ids)
        index = str2double(new_ids{i});
        if length(twdb_main(index).trial_spikes)<j
            continue
        end
        spikes = [spikes; twdb_main(index).trial_spikes(j)];
        evt_timings{end+1} = twdb_main(index).trial_evt_timings(j,:);
        count=count+1;
        idsAndData(end+1,:) = [count, length(spikes), twdb_main(index).baseline_firing_rate_data];
    end
    
    [plotting_bins, ~, ~, numTrials, ~] = ah_fill_spike_plotting_bins(spikes,...
    evt_timings, idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
    window = mean(plotting_bins(301:367,1));
    windows1 = [windows1 window];
end

for j=1:20
    spikes=[];
    evt_timings={};
    idsAndData=[];
    count=0;
    for i = 1:length(new_ids2)
        index = str2double(new_ids2{i});
        if length(twdb_laser(index).trial_spikes)<j
            continue
        end
        spikes = [spikes; twdb_laser(index).trial_spikes(j)];
        evt_timings{end+1} = twdb_laser(index).trial_evt_timings(j,:);
        count=count+1;
        idsAndData(end+1,:) = [count, length(spikes), twdb_laser(index).baseline_firing_rate_data];
    end
    
    [plotting_bins, ~, ~, numTrials, ~] = ah_fill_spike_plotting_bins(spikes,...
    evt_timings, idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
    window = mean(plotting_bins(301:367,1));
    windows1 = [windows1 window];
end
figure;
bar(windows1);
xlim([0 41]);
title('CB')
xlabel('# Trial');
ylabel('Hz');
ylim([1 6]);
saveas(gca, [fig_dir, '\laserSession_trial_bargraph'],'fig')
saveas(gca, [fig_dir, '\laserSession_trial_bargraph'],'eps')
        %% Accumulation of strio baseline data
strio_data = zeros(length(new_ids),4);
for i = 1:length(new_ids)
    index = str2double(new_ids{i});
    index2 = str2double(new_ids2{i});
    
    [plotting_bins1, ~, ~, ~] = ah_fill_spike_plotting_bins(twdb_main(index).trial_spikes, ...
        {twdb_main(index).trial_evt_timings}, [1 100 twdb_main(index).baseline_firing_rate_data], {}, {}, [600, 1, 2, .5, .6], [0 0]);
    [plotting_bins2, ~, ~, ~] = ah_fill_spike_plotting_bins(twdb_laser(index2).trial_spikes, ...
        {twdb_laser(index2).trial_evt_timings}, [1 100 twdb_laser(index2).baseline_firing_rate_data], {}, {}, [600, 1, 2, .5, .6], [0 0]);
    strio_data(i,:) = [mean(plotting_bins1(60:240,1)), mean(plotting_bins1(301:320,1)), mean(plotting_bins2(60:240,1)), mean(plotting_bins2(301:320,1))];
end
        %% Accumulation of all baseline data
all_data = zeros(length(neuron_ids),4);
for i = 1:length(neuron_ids)
    index = str2double(neuron_ids{i});
    index2 = str2double(neuron_ids2{i});
    
    [plotting_bins1, ~, ~, ~] = ah_fill_spike_plotting_bins(twdb_main(index).trial_spikes, ...
        {twdb_main(index).trial_evt_timings}, [1 100 twdb_main(index).baseline_firing_rate_data], {}, {}, [600, 1, 2, .5, .6], [0 0]);
    [plotting_bins2, ~, ~, ~] = ah_fill_spike_plotting_bins(twdb_laser(index2).trial_spikes, ...
        {twdb_laser(index2).trial_evt_timings}, [1 100 twdb_laser(index2).baseline_firing_rate_data], {}, {}, [600, 1, 2, .5, .6], [0 0]);
    all_data(i,:) = [mean(plotting_bins1(60:240,1)), mean(plotting_bins1(301:320,1)), mean(plotting_bins2(60:240,1)), mean(plotting_bins2(301:320,1))];
end
        %% Plotting laser baseline firing rates
goodIds = ~isnan(all_data(:,1));

m11 = mean(strio_data(:,1));
s11 = std(strio_data(:,1))/sqrt(length(new_ids));
m12 = mean(all_data(goodIds,1));
s12 = std(all_data(goodIds,1))/sqrt(sum(goodIds));

m21 = mean(strio_data(:,3));
s21 = std(strio_data(:,3))/sqrt(length(new_ids));
m22 = mean(all_data(goodIds,3));
s22 = std(all_data(goodIds,3))/sqrt(sum(goodIds));

means = [m11 m12; m21 m22]; stds = [s11 s12; s21 s22]; labels = {'Prelaser Block', 'Laser Block'}; colors = {[1 0 0], [0 0 1]};
ah_barsWithErrors(means,stds,labels,colors,1)
saveas(gca, [fig_dir, '\laser_baseline_frs'], 'fig');
saveas(gca, [fig_dir, '\laser_baseline_frs'], 'eps');
save([fig_dir, '\laser_baseline_frs_data'], 'strio_data', 'all_data');
xlswrite([fig_dir, '\laser_baseline_frs_data.xlsx'], strio_data, 1)
xlswrite([fig_dir, '\laser_baseline_frs_data.xlsx'], all_data, 2)
    %% Laser example
id = 5;
        %% Prelaser Block
main_id = str2double(new_ids{id});
spikes_array = twdb_main(main_id).trial_spikes;
ses_evt_timings = twdb_main(main_id).trial_evt_timings;
neuron_idsAndData = [1, length(spikes_array), twdb_main(main_id).baseline_firing_rate_data];
[plotting_bins, evt_times_distribution, timeOfBins, numTrials, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    {ses_evt_timings}, neuron_idsAndData, {}, {}, [600, 1, 2, .3, .6], [0 0], 1);

figure;
ah_plot_double_aligned_population_analysis(plotting_bins,evt_times_distribution,timeOfBins,numTrials,[1 2], .5, 45, 0, [1 0 0])
title('Prelaser Block Neuron (Example)')
xlim([-3 6])
ylim([0 5])
xlabel('Time (seconds)')
ylabel('Firing Rate (Hz)')
saveas(gca,[fig_dir, '\prelaser_example'],'fig')
saveas(gca,[fig_dir, '\prelaser_example'],'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials); fullData];
xlswrite([fig_dir, '\prelaser_example.xlsx'], fullData)
save([fig_dir, '\prelaser_example.mat'], 'fullData')
        %% Laser Block
laser_id = str2double(new_ids2{id});
spikes_array = twdb_laser(laser_id).trial_spikes;
ses_evt_timings = twdb_laser(laser_id).trial_evt_timings;
neuron_idsAndData = [1, length(spikes_array), twdb_laser(laser_id).baseline_firing_rate_data];
[plotting_bins, evt_times_distribution, timeOfBins, numTrials, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    {ses_evt_timings}, neuron_idsAndData, {}, {}, [600, 1, 2, .3, .6], [0 0], 1);

figure;
ah_plot_double_aligned_population_analysis(plotting_bins,evt_times_distribution,timeOfBins,numTrials,[1 2], .5, 45, 0, [1 0 0])
title('Laser Block Neuron (Example)')
xlim([-3 6])
ylim([0 5])
xlabel('Time (seconds)')
ylabel('Firing Rate (Hz)')
saveas(gca,[fig_dir, '\laser_example'],'fig')
saveas(gca,[fig_dir, '\laser_example'],'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials); fullData];
xlswrite([fig_dir, '\laser_example.xlsx'], fullData)
save([fig_dir, '\laser_example.mat'], 'fullData')
    %% BB -> CBC
neuron_ids = {'8157','8163','8211','8214','8215','8221','8222','8228','8232','11245'};
block1_spikes = {}; block1_evt_timings = {}; block1_idsAndData = [];
block2_spikes = {}; block2_evt_timings = {}; block2_idsAndData = [];
        %% Setting up Cost Benefit/Benefit Benefit Arrays
for i = 1:length(neuron_ids)
    index = str2double(neuron_ids{i});
    load([twdb_main(index).sessionDir, '\events6.EVTSAV'], '-mat')
    ID = find(ismember(lfp_save_events(:,2),[29 222]));
    evtsTR = lfp_save_events(1:ID,2);
    block1_trials = sum(evtsTR==31);
    block1_spikes = [block1_spikes; twdb_main(index).trial_spikes(1:block1_trials)];
    block1_evt_timings{end+1} = twdb_main(index).trial_evt_timings(1:block1_trials,:);
    block1_idsAndData(end+1,:) = [i, length(block1_spikes), twdb_main(index).baseline_firing_rate_data];
    block2_spikes = [block2_spikes; twdb_main(index).trial_spikes(1+block1_trials:end)];
    block2_evt_timings{end+1} = twdb_main(index).trial_evt_timings(1+block1_trials:end,:);
    block2_idsAndData(end+1,:) = [i, length(block2_spikes), twdb_main(index).baseline_firing_rate_data];
end
        %% Benefit Benefit Block Bins
[plotting_bins1, ~, ~, numTrials1_1, fullData1] = ah_fill_spike_plotting_bins(block1_spikes, block1_evt_timings, block1_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
[middle_bins1, ~, ~, numTrials1_2] = ah_fill_spike_plotting_bins(block1_spikes, block1_evt_timings, block1_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
tmp = conv(middle_bins1(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins1(:,1),43); middle_bins1 = [tmp1(1:42); tmp(43:500)];
        %% Cost Benefit Block Bins
[plotting_bins2, ~, ~, numTrials2_1, fullData2] = ah_fill_spike_plotting_bins(block2_spikes, block2_evt_timings, block2_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
[middle_bins2, ~, ~, numTrials2_2] = ah_fill_spike_plotting_bins(block2_spikes, block2_evt_timings, block2_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
tmp = conv(middle_bins2(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins2(:,1),43); middle_bins2 = [tmp1(1:42); tmp(43:500)];
        %% Computation of Baseline Values
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ah_extractDataFromTWDB(twdb_main, neuron_ids);
[plotting_bins, evt_times_distribution, timeOfBins, numTrials] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0]);
baseline_mean = mean(plotting_bins(60:240,1))*(numTrials/(numTrials1_2+numTrials2_2));
baseline_std = std(plotting_bins(60:240,1))*(numTrials/(numTrials1_2+numTrials2_2));
        %% Benefit Benefit Block Population Analysis
ah_plot_double_aligned_population_analysis(plotting_bins1, evt_times_distribution, timeOfBins, numTrials1_1, [1 2], .53, 15, 1, [1 0 0])
title('Benefit Benefit Block - 10 Neurons')
xlabel('Time (seconds)');   xlim([-10 10]);
ylabel('Firing Rate (Hz)'); ylim([0 4.5]);
saveas(gca, [fig_dir, '\cb_tr_benefitBenefit_popanal'], 'fig')
saveas(gca, [fig_dir, '\cb_tr_benefitBenefit_popanal'], 'eps')
fullData1 = fullData1(fullData1(:,2)>-1,:);
fullData1 = [mean(fullData1); std(fullData1)/sqrt(numTrials); fullData1];
xlswrite([fig_dir, '\cb_tr_benefitBenefitData.xlsx'], fullData1)
save([fig_dir, '\cb_tr_benefitBenefitData.mat'], 'fullData1')
        %% Cost Benefit Block Population Analysis
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials2_1, [1 2], .53, 15, 1, [1 0 0])
title('Cost Benefit Block - 10 Neurons')
xlabel('Time (seconds)');   xlim([-10 10]);
ylabel('Firing Rate (Hz)'); ylim([0 4.5]);
saveas(gca, [fig_dir, '\cb_tr_costBenefit_popanal'], 'fig')
saveas(gca, [fig_dir, '\cb_tr_costBenefit_popanal'], 'eps')
fullData2 = fullData2(fullData2(:,2)>-1,:);
fullData2 = [mean(fullData2); std(fullData2)/sqrt(numTrials); fullData2];
xlswrite([fig_dir, '\cb_tr_costBenefitData.xlsx'], fullData2)
save([fig_dir, '\cb_tr_costBenefitData.mat'], 'fullData2')
        %% Benefit Benefit Block Maze
ah_plot_unsplit_maze(middle_bins1, middle_bins1, middle_bins1, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
title('Benefit Benefit Block - 10 Neurons')
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
saveas(gca, [fig_dir, '\cb_tr_benefitBenefit_maze'], 'fig')
saveas(gca, [fig_dir, '\cb_tr_benefitBenefit_maze'], 'eps')
allBinsTR = middle_bins1;
        %% Cost Benefit Block Maze
ah_plot_unsplit_maze(middle_bins2, middle_bins2, middle_bins2, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
title('Cost Benefit Block - 10 Neurons')
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
saveas(gca, [fig_dir, '\cb_tr_costBenefit_maze'], 'fig')
saveas(gca, [fig_dir, '\cb_tr_costBenefit_maze'], 'eps')
allBinsCB = middle_bins2;
        %% Benefit Benefit Block Bursts
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 1:20
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 6, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [6 20 .4 9 length(neuron_ids) 0.5 .25 .75 0.5 0 0]);
title(['TR Block (Trial #1-20): ' num2str(length(neuron_ids)) ' neurons']);
maxlength = length(neuron_ids);
saveas(gca, [fig_dir, '\cb_tr_benefitBenefit_bursts'],'fig')
saveas(gca, [fig_dir, '\cb_tr_benefitBenefit_bursts'],'eps')
save([fig_dir, '\cb_tr_benefitBenefit_bursts.mat'], 'selectedBursts')
xlswrite([fig_dir, '\cb_tr_benefitBenefit_bursts.xlsx'], selectedBursts)
        %% Cost Benefit Block Bursts
allBursts = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    bursts = twdb_main(index).trial_bursts;
    evt_times = twdb_main(index).trial_evt_timings;
    for trial = 21:length(bursts)
        click = evt_times(trial,2);
        lick = evt_times(trial,4);
        if lick-click > 0
            for burst = 1:size(bursts{trial},1)
                burst_start = (bursts{trial}(burst,1)-click)/(lick-click);
                burst_end = (bursts{trial}(burst,2)-click)/(lick-click);
                burst_size = (bursts{trial}(burst,3))/(lick-click);
                burstFR = burst_size/(burst_end - burst_start);
                allBursts(end+1,:) = [burstFR, (burst_start+burst_end)/2, iter, bursts{trial}(burst,3)];
            end
        end
    end
end

selectedBursts = ah_select_bursts(allBursts, length(neuron_ids), 6, 0, 1, 1, 1);
ah_plot_bursts(selectedBursts, [6 20 .4 9 maxlength 0.5 .25 .75 0.5 0 0]);
title(['CB Block (Trial #21-40): ' num2str(length(neuron_ids)) ' neurons']);
saveas(gca, [fig_dir, '\cb_tr_costBenefit_bursts'],'fig')
saveas(gca, [fig_dir, '\cb_tr_costBenefit_bursts'],'eps')
save([fig_dir, '\cb_tr_costBenefit_bursts.mat'], 'selectedBursts')
xlswrite([fig_dir, '\cb_tr_costBenefit_bursts.xlsx'], selectedBursts)
        %% Trial Bar Graph
windows1=[];
for j=1:40
    spikes=[];
    evt_timings={};
    idsAndData=[];
    count=0;
    for i = 1:length(neuron_ids)
        index = str2double(neuron_ids{i});
        if length(twdb_main(index).trial_spikes)<j
            continue
        end
        spikes = [spikes; twdb_main(index).trial_spikes(j)];
        evt_timings{end+1} = twdb_main(index).trial_evt_timings(j,:);
        count=count+1;
        idsAndData(end+1,:) = [count, length(spikes), twdb_main(index).baseline_firing_rate_data];
    end
    
    [plotting_bins, ~, ~, numTrials, ~] = ah_fill_spike_plotting_bins(spikes,...
    evt_timings, idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
    window = mean(plotting_bins(301:360,1));
    windows1 = [windows1 window];
end

figure;
bar(windows1);
xlim([0 40]);
title('Task Switch')
xlabel('# Trial');
ylabel('Hz');
ylim([0 2.5]);
saveas(gca, [fig_dir, '\cb_tr_trial_bargraph'],'fig')
saveas(gca, [fig_dir, '\cb_tr_trial_bargraph'],'eps')
    %% BB -> CBC example
id = str2double(neuron_ids{10});
        %%% BB Block
spikes_array = twdb_main(id).trial_spikes;
ses_evt_timings = twdb_main(id).trial_evt_timings;
neuron_idsAndData = [1, length(spikes_array), twdb_main(id).baseline_firing_rate_data];
[plotting_bins, evt_times_distribution, timeOfBins, numTrials, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    {ses_evt_timings}, neuron_idsAndData, {}, {[ones(1,19), zeros(1,30)]}, [600, 1, 2, .3, .6], [0 0], 1);

figure;
ah_plot_double_aligned_population_analysis(plotting_bins,evt_times_distribution,timeOfBins,numTrials,[1 2], .5, 30, 0, [1 0 0])
title('Benefit Benefit Block Neuron (Example)')
xlim([-3 6])
ylim([0 4.5])
xlabel('Time (seconds)')
ylabel('Firing Rate (Hz)')
saveas(gca,[fig_dir, '\bbBlock_example'],'fig')
saveas(gca,[fig_dir, '\bbBlock_example'],'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials); fullData];
xlswrite([fig_dir, '\bbBlock_example.xlsx'], fullData)
save([fig_dir, '\bbBlock_example.mat'], 'fullData')
        %%% CB Block
spikes_array = twdb_main(id).trial_spikes;
ses_evt_timings = twdb_main(id).trial_evt_timings;
neuron_idsAndData = [1, length(spikes_array), twdb_main(id).baseline_firing_rate_data];
[plotting_bins, evt_times_distribution, timeOfBins, numTrials, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    {ses_evt_timings}, neuron_idsAndData, {}, {[zeros(1,19), ones(1,30)]}, [600, 1, 2, .3, .6], [0 0], 1);

figure;
ah_plot_double_aligned_population_analysis(plotting_bins,evt_times_distribution,timeOfBins,numTrials,[1 2], .5, 30, 0, [1 0 0])
title('Cost Benefit Block Neuron (Example)')
xlim([-3 6])
ylim([0 4.5])
xlabel('Time (seconds)')
ylabel('Firing Rate (Hz)')
saveas(gca,[fig_dir, '\cbblock_example'],'fig')
saveas(gca,[fig_dir, '\cbblock_example'],'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials); fullData];
xlswrite([fig_dir, '\cbblock_example.xlsx'], fullData)
save([fig_dir, '\cbblock_example.mat'], 'fullData')
    %% CBC -> CBC
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'CB', 'key', 'tetrodeType', 'dms', ...
    'grade', 'removable', 0, 0, 'grade', 'striosomality_type', 4, 5, 'grade', 'sqr_neuron_type', 3, 5);
toKeep = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    if twdb_main(index).striosomality_grade > 0 && twdb_main(index).striosomality_data(3) < .015 && twdb_main(index).striosomality_data(4) < .04
        toKeep(end+1) = iter;
    end
end
neuron_ids = neuron_ids(toKeep);
block1_spikes = {}; block1_evt_timings = {}; block1_idsAndData = [];
block2_spikes = {}; block2_evt_timings = {}; block2_idsAndData = [];
        %% Setting up Block1/Block2 Arrays
for i = 1:length(neuron_ids)
    index = str2double(neuron_ids{i});
    load([twdb_main(index).sessionDir, '\events6.EVTSAV'], '-mat')
    ID = find(ismember(lfp_save_events(:,2),[29 222]));
    evtsTR = lfp_save_events(1:ID,2);
    block1_trials = 20;
    block1_spikes = [block1_spikes; twdb_main(index).trial_spikes(1:block1_trials)];
    block1_evt_timings{end+1} = twdb_main(index).trial_evt_timings(1:block1_trials,:);
    block1_idsAndData(end+1,:) = [i, length(block1_spikes), twdb_main(index).baseline_firing_rate_data];
    block2_spikes = [block2_spikes; twdb_main(index).trial_spikes(1+block1_trials:end)];
    block2_evt_timings{end+1} = twdb_main(index).trial_evt_timings(1+block1_trials:end,:);
    block2_idsAndData(end+1,:) = [i, length(block2_spikes), twdb_main(index).baseline_firing_rate_data];
end
        %% Block 1 Bins
[plotting_bins1, ~, ~, numTrials1_1, fullData1] = ah_fill_spike_plotting_bins(block1_spikes, block1_evt_timings, block1_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
[middle_bins1, ~, ~, numTrials1_2] = ah_fill_spike_plotting_bins(block1_spikes, block1_evt_timings, block1_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
tmp = conv(middle_bins1(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins1(:,1),43); middle_bins1 = [tmp1(1:42); tmp(43:500)];
        %% Block 2 Bins
[plotting_bins2, ~, ~, numTrials2_1, fullData2] = ah_fill_spike_plotting_bins(block2_spikes, block2_evt_timings, block2_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
[middle_bins2, ~, ~, numTrials2_2] = ah_fill_spike_plotting_bins(block2_spikes, block2_evt_timings, block2_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
tmp = conv(middle_bins2(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins2(:,1),43); middle_bins2 = [tmp1(1:42); tmp(43:500)];
        %% Computation of Baseline Values
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ah_extractDataFromTWDB(twdb_main, neuron_ids);
[plotting_bins, evt_times_distribution, timeOfBins, numTrials] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0]);
baseline_mean = mean(plotting_bins(60:240,1))*(numTrials/(numTrials1_2+numTrials2_2));
baseline_std = std(plotting_bins(60:240,1))*(numTrials/(numTrials1_2+numTrials2_2));
        %% Block 1 Population Analysis
ah_plot_double_aligned_population_analysis(plotting_bins1, evt_times_distribution, timeOfBins, numTrials1_1, [1 2], .53, 15, 1, [1 0 0])
title('Block 1 - 54 Neurons')
xlabel('Time (seconds)');   xlim([-10 10]);
ylabel('Firing Rate (Hz)'); ylim([0 4.5]);
saveas(gca, [fig_dir, '\cb_cb_block1_popanal'], 'fig')
saveas(gca, [fig_dir, '\cb_cb_block1_popanal'], 'eps')
fullData1 = fullData1(fullData1(:,2)>-1,:);
fullData1 = [mean(fullData1); std(fullData1)/sqrt(numTrials); fullData1];
xlswrite([fig_dir, '\cb_cb_block1Data.xlsx'], fullData1)
save([fig_dir, '\cb_cb_block1Data.mat'], 'fullData1')
        %% Block 2 Population Analysis
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials2_1, [1 2], .53, 15, 1, [1 0 0])
title('Block  2 - 54 Neurons')
xlabel('Time (seconds)');   xlim([-10 10]);
ylabel('Firing Rate (Hz)'); ylim([0 4.5]);
saveas(gca, [fig_dir, '\cb_cb_block2_popanal'], 'fig')
saveas(gca, [fig_dir, '\cb_cb_block2_popanal'], 'eps')
fullData2 = fullData2(fullData2(:,2)>-1,:);
fullData2 = [mean(fullData2); std(fullData2)/sqrt(numTrials); fullData2];
xlswrite([fig_dir, '\cb_cb_block2Data.xlsx'], fullData2)
save([fig_dir, '\cb_cb_block2Data.mat'], 'fullData2')
        %% Block 1 Maze
ah_plot_unsplit_maze(middle_bins1, middle_bins1, middle_bins1, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
title('Block 1 - 54 Neurons')
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
saveas(gca, [fig_dir, '\cb_cb_block1_maze'], 'fig')
saveas(gca, [fig_dir, '\cb_cb_block1_maze'], 'eps')
        %% Block 2 Maze
ah_plot_unsplit_maze(middle_bins2, middle_bins2, middle_bins2, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
title('Block  2 - 54 Neurons')
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
saveas(gca, [fig_dir, '\cb_cb_block2_maze'], 'fig')
saveas(gca, [fig_dir, '\cb_cb_block2_maze'], 'eps')
    %% BB -> BB 
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'dms', ...
    'grade', 'removable', 0, 0, 'grade', 'striosomality_type', 4, 5, 'grade', 'sqr_neuron_type', 3, 5);
toKeep = [];
for iter = 1:length(neuron_ids)
    index = str2double(neuron_ids{iter});
    if twdb_main(index).striosomality_grade > 0 && twdb_main(index).striosomality_data(3) < .015 && twdb_main(index).striosomality_data(4) < .04
        toKeep(end+1) = iter;
    end
end
neuron_ids = neuron_ids(toKeep);
block1_spikes = {}; block1_evt_timings = {}; block1_idsAndData = [];
block2_spikes = {}; block2_evt_timings = {}; block2_idsAndData = [];
        %% Setting up Block1/Block2 Arrays
for i = 1:length(neuron_ids)
    index = str2double(neuron_ids{i});
    load([twdb_main(index).sessionDir, '\events6.EVTSAV'], '-mat')
    ID = find(ismember(lfp_save_events(:,2),[29 222]));
    evtsTR = lfp_save_events(1:ID,2);
    block1_trials = 20;
    block1_spikes = [block1_spikes; twdb_main(index).trial_spikes(1:block1_trials)];
    block1_evt_timings{end+1} = twdb_main(index).trial_evt_timings(1:block1_trials,:);
    block1_idsAndData(end+1,:) = [i, length(block1_spikes), twdb_main(index).baseline_firing_rate_data];
    block2_spikes = [block2_spikes; twdb_main(index).trial_spikes(1+block1_trials:end)];
    block2_evt_timings{end+1} = twdb_main(index).trial_evt_timings(1+block1_trials:end,:);
    block2_idsAndData(end+1,:) = [i, length(block2_spikes), twdb_main(index).baseline_firing_rate_data];
end
        %% Block 1 Bins
[plotting_bins1, ~, ~, numTrials1_1, fullData1] = ah_fill_spike_plotting_bins(block1_spikes, block1_evt_timings, block1_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
[middle_bins1, ~, ~, numTrials1_2] = ah_fill_spike_plotting_bins(block1_spikes, block1_evt_timings, block1_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
tmp = conv(middle_bins1(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins1(:,1),43); middle_bins1 = [tmp1(1:42); tmp(43:500)];
        %% Block 2 Bins
[plotting_bins2, ~, ~, numTrials2_1, fullData2] = ah_fill_spike_plotting_bins(block2_spikes, block2_evt_timings, block2_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
[middle_bins2, ~, ~, numTrials2_2] = ah_fill_spike_plotting_bins(block2_spikes, block2_evt_timings, block2_idsAndData, {}, {}, [500, 1, 2, .35, .65], [0 0]);
tmp = conv(middle_bins2(:,1), ones(1,43)/43); tmp1 = smooth(middle_bins2(:,1),43); middle_bins2 = [tmp1(1:42); tmp(43:500)];
        %% Computation of Baseline Values
[~, ~, ~, spikes_array, ~, ses_evt_timings, neuron_idsAndData] = ah_extractDataFromTWDB(twdb_main, neuron_ids);
[plotting_bins, evt_times_distribution, timeOfBins, numTrials] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0]);
baseline_mean = mean(plotting_bins(60:240,1))*(numTrials/(numTrials1_2+numTrials2_2));
baseline_std = std(plotting_bins(60:240,1))*(numTrials/(numTrials1_2+numTrials2_2));
        %% Block 1 Population Analysis
ah_plot_double_aligned_population_analysis(plotting_bins1, evt_times_distribution, timeOfBins, numTrials1_1, [1 2], .53, 15, 1, [1 0 0])
title('Block 1 - 106 Neurons')
xlabel('Time (seconds)');   xlim([-10 10]);
ylabel('Firing Rate (Hz)'); ylim([0 4.5]);
saveas(gca, [fig_dir, '\tr_tr_block1_popanal'], 'fig')
saveas(gca, [fig_dir, '\tr_tr_block1_popanal'], 'eps')
fullData1 = fullData1(fullData1(:,2)>-1,:);
fullData1 = [mean(fullData1); std(fullData1)/sqrt(numTrials); fullData1];
xlswrite([fig_dir, '\tr_tr_block1Data.xlsx'], fullData1)
save([fig_dir, '\tr_tr_block1Data.mat'], 'fullData1')
        %% Block 2 Population Analysis
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials2_1, [1 2], .53, 15, 1, [1 0 0])
title('Block  2 - 106 Neurons')
xlabel('Time (seconds)');   xlim([-10 10]);
ylabel('Firing Rate (Hz)'); ylim([0 4.5]);
saveas(gca, [fig_dir, '\tr_tr_block2_popanal'], 'fig')
saveas(gca, [fig_dir, '\tr_tr_block2_popanal'], 'eps')
fullData2 = fullData2(fullData2(:,2)>-1,:);
fullData2 = [mean(fullData2); std(fullData2)/sqrt(numTrials); fullData2];
xlswrite([fig_dir, '\tr_tr_block2Data.xlsx'], fullData2)
save([fig_dir, '\tr_tr_block2Data.mat'], 'fullData2')
        %% Block 1 Maze
ah_plot_unsplit_maze(middle_bins1, middle_bins1, middle_bins1, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
title('Block 1 - 106 Neurons')
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
saveas(gca, [fig_dir, '\tr_tr_block1_maze'], 'fig')
saveas(gca, [fig_dir, '\tr_tr_block1_maze'], 'eps')
        %% Block 2 Maze
ah_plot_unsplit_maze(middle_bins2, middle_bins2, middle_bins2, 1, [43, 22, 8, 33, 54, 1, 1, baseline_mean-2*baseline_std, baseline_mean+2*baseline_std, .35, .65])
title('Block 2 - 106 Neurons')
text(58.8,0,'-2 stds','VerticalAlignment','bottom'); text(58.8, 17.5, '0 stds'); text(58.8, 35, '+2 stds','VerticalAlignment','top');
saveas(gca, [fig_dir, '\tr_tr_block2_maze'], 'fig')
saveas(gca, [fig_dir, '\tr_tr_block2_maze'], 'eps')
close all;

%% Figure Script 8: Pair analysis: 
fig_dir = [figs_dir, '\Pair_Analysis'];
    %% Population of SPN aligned to HFN activation.
hfn_ids = [1210 1284 1284 1385 1385 1385 1392 1518 5917 5917 5918 5918 5982 5982 5982 6867 6867 11073 11073 11317 11317 11317 11317];
spn_ids = [1209 1283 1290 1383 1387 1390 1393 1516 5913 5914 5913 5914 5979 5980 5983 6866 6868 11071 11072 11315 11318 11319 11320];
numPairs = length(hfn_ids);
newdata = zeros(400,2);
allData = [];
numTrialsTot = 0;
evt_times_distribution_tot = {[];[];[];[];[]};
        %% Alignment and computation of HFN-Aligned SPN bins
for pair_idx = 1:numPairs
    hfn_idx = hfn_ids(pair_idx);
    spn_idx = spn_ids(pair_idx);
    
    hfn_spikes_array = twdb_main(hfn_idx).trial_spikes;
    ses_evt_timings = twdb_main(hfn_idx).trial_evt_timings;
    neuron_idsAndData = [1, length(hfn_spikes_array), twdb_main(hfn_idx).baseline_firing_rate_data];
    [hfn_plotting_bins, evt_times_distribution, timeOfBins, numTrials] = ah_fill_spike_plotting_bins(hfn_spikes_array, ...
        {ses_evt_timings}, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0]);
    
    spn_spikes_array = twdb_main(spn_idx).trial_spikes;
    ses_evt_timings = twdb_main(hfn_idx).trial_evt_timings;
    neuron_idsAndData = [1, length(spn_spikes_array), twdb_main(hfn_idx).baseline_firing_rate_data];
    [spn_plotting_bins, ~, ~, ~, fullData] = ah_fill_spike_plotting_bins(spn_spikes_array, ...
        {ses_evt_timings}, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
    
    [~,id] = max(smooth(hfn_plotting_bins(281:320,1),5));
    shift = id - 20;
    newdata = newdata + numTrials*spn_plotting_bins(101+shift:500+shift,:);
    allData = [allData; pair_idx*ones(size(fullData,1),1) fullData(:,102+shift:501+shift)];
    numTrialsTot = numTrialsTot + numTrials;
    for evt = 1:5
        evt_times_distribution_tot{evt} = [evt_times_distribution_tot{evt} evt_times_distribution{evt}+1/2*(timeOfBins(300+shift)+timeOfBins(301+shift))];
    end
end
avgFirstEventTime = mean(evt_times_distribution_tot{1});
avgSecondEventTime = mean(evt_times_distribution_tot{2});
windowStartTime = avgFirstEventTime - .5/(.65 - .5)*(avgSecondEventTime - avgFirstEventTime);
windowEndTime = avgSecondEventTime + (1-.65)/(.65 - .5)*(avgSecondEventTime - avgFirstEventTime);
tmp_timeOfBins = linspace(windowStartTime,windowEndTime,400+1);
tmp_timeOfBins = conv(tmp_timeOfBins, [.5 .5]);
timeOfBins = tmp_timeOfBins(2:400+1);
newdata = newdata/numTrialsTot;
        %% Drawing the population Analysis
figure;
ah_plot_double_aligned_population_analysis(newdata,evt_times_distribution_tot,timeOfBins,numTrialsTot,[1 2], .55, 9, 0, [1 0 0])
title('Cost Benefit SPN Neurons Aligned to Peak of HFN')
xlabel('Time (seconds)')
ylabel('Firing Rate (Hz)')
saveas(gca,[fig_dir, '\SPN_alignedtoHFN_popanal'],'fig')
saveas(gca,[fig_dir, '\SPN_alignedtoHFN_popanal'],'eps')
allData = allData(allData(:,2)>-1,:);
allData = [mean(allData); std(allData)/sqrt(numTrialsTot); allData];
xlswrite([fig_dir, '\SPN_aligntoHFN_alignedData.xlsx'], allData)
save([fig_dir, '\SPN_aligntoHFN_alignedData.mat'],'allData')
    %% Example of SPN aligned to HFN
hfn_idx = 11073;
spn_idx = 11071;
newdata = zeros(400,2);
numTrialsTot = 0;
evt_times_distribution_tot = {[];[];[];[];[]};
        %% Alignment and computation of HFN-Aligned SPN bins
hfn_spikes_array = twdb_main(hfn_idx).trial_spikes;
ses_evt_timings = twdb_main(hfn_idx).trial_evt_timings;
neuron_idsAndData = [1, length(hfn_spikes_array), twdb_main(hfn_idx).baseline_firing_rate_data];
[hfn_plotting_bins, evt_times_distribution, timeOfBins, numTrials, fullDataHFN] = ah_fill_spike_plotting_bins(hfn_spikes_array, ...
    {ses_evt_timings}, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);

figure;
ah_plot_double_aligned_population_analysis(hfn_plotting_bins,evt_times_distribution,timeOfBins,numTrials,[1 2], .53, 9, 0, [1 0 0])
title('Cost Benefit HFN Neuron (Example)')
xlabel('Time (seconds)')
ylabel('Firing Rate (Hz)')
saveas(gca,[fig_dir, '\HFN_example'],'fig')
saveas(gca,[fig_dir, '\HFN_example'],'eps')
fullDataHFN = fullDataHFN(fullDataHFN(:,2)>-1,:);
fullDataHFN = [mean(fullDataHFN); std(fullDataHFN)/sqrt(numTrials); fullDataHFN];
xlswrite([fig_dir, '\HFN_example.xlsx'], fullDataHFN)
save([fig_dir, '\HFN_example.mat'], 'fullDataHFN')

spn_spikes_array = twdb_main(spn_idx).trial_spikes;
ses_evt_timings = twdb_main(hfn_idx).trial_evt_timings;
neuron_idsAndData = [1, length(spn_spikes_array), twdb_main(hfn_idx).baseline_firing_rate_data];
[spn_plotting_bins, ~, ~, ~, fullData] = ah_fill_spike_plotting_bins(spn_spikes_array, ...
    {ses_evt_timings}, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);

[~,id] = max(smooth(hfn_plotting_bins(281:320,1),5));
shift = id - 20;
newdata = newdata + numTrials*spn_plotting_bins(101+shift:500+shift,:);
hfn_plotting_bins = hfn_plotting_bins(101+shift:500+shift,:);
fullData = fullData(:,102+shift:501+shift);
numTrialsTot = numTrialsTot + numTrials;
for evt = 1:5
    evt_times_distribution_tot{evt} = [evt_times_distribution_tot{evt} evt_times_distribution{evt}+1/2*(timeOfBins(300+shift)+timeOfBins(301+shift))];
end

avgFirstEventTime = mean(evt_times_distribution_tot{1});
avgSecondEventTime = mean(evt_times_distribution_tot{2});
windowStartTime = avgFirstEventTime - .5/(.65 - .5)*(avgSecondEventTime - avgFirstEventTime);
windowEndTime = avgSecondEventTime + (1-.65)/(.65 - .5)*(avgSecondEventTime - avgFirstEventTime);
tmp_timeOfBins = linspace(windowStartTime,windowEndTime,400+1);
tmp_timeOfBins = conv(tmp_timeOfBins, [.5 .5]);
timeOfBins = tmp_timeOfBins(2:400+1);
newdata = newdata/numTrialsTot;
        %% Drawing the population Analysis
figure;
ah_plot_double_aligned_population_analysis(newdata,evt_times_distribution_tot,timeOfBins,numTrialsTot,[1 2], .55, 9, 0, [1 0 0])
title('Cost Benefit SPN Neuron Aligned to Peak of HFN (Example)')
xlabel('Time (seconds)')
ylabel('Firing Rate (Hz)')
saveas(gca,[fig_dir, '\SPN_alignedtoHFN_example'],'fig')
saveas(gca,[fig_dir, '\SPN_alignedtoHFN_example'],'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrialsTot); fullData];
xlswrite([fig_dir, '\SPN_alignedtoHFN_alignedExample.xlsx'], fullData)
save([fig_dir, '\SPN_alignedtoHFN_alignedExample.mat'], 'fullData')
    %% Cascades (Work done by Qinru Shi)
        %% Draw Figure
load([fig_dir, '\scatter_info.mat'])
[~,indices]=sort(scatter_info(:,1));
pl_ids = [10 11 23 27:30];
spn_ids = [1:9 12:22 24:26];
ids_array = zeros(30,1);
ids_array(pl_ids) = 1;
ids_array(spn_ids) = 2;
figure; hold all;
scatter(scatter_info(indices,1),(1:30)',400,[1 0 0],'.')
scatter(scatter_info(indices(pl_ids),2),pl_ids',400,[0 1 0],'.')
scatter(scatter_info(indices(spn_ids),2),spn_ids',400,[0 0 1],'.')

legend('hfn','pl','spn')
xlabel('Peak Time(s)')
ylabel('Index')
for t=1:30
    plot(scatter_info(indices(t),:),[t t],'Color',[0 0 0])
end
saveas(gca, [fig_dir, '\spn-pl_alignmentToHFN_cascades'], 'fig')
saveas(gca, [fig_dir, '\spn-pl_alignmentToHFN_cascades'], 'eps')
xlswrite([fig_dir, '\spn-pl_alignmentToHFN_cascades_data.xlsx'], [scatter_info ids_array])
    %% Burst vs. tonic firing example (Work done by Qinru Shi, Suthee Ruangwises
window=0.1; %% period after each burst
moving_win=0.1;
bin_size=5; %% bin size of red (burst)
bin_size2=bin_size/1; %% bin size of blue (non-burst)
magicvalue = 5; %% minimum number of spikes in a burst
magicvalue2 = 3; %% minimum number of samples in a bin

fsi_list=[1210 1518];
msn_list=[1209 1516];
        %% Alignment to bursts. 
Y1=[];
X1=[];
burstAligned=[];
burst_lengths=[];
for m=1:2
    index1=fsi_list(m);
    index2=msn_list(m);
    spikes1 = twdb_main(index1).trial_spikes;
    bursts1 = twdb_main(index1).trial_bursts;
    spikes2 = twdb_main(index2).trial_spikes;
    bursts2 = twdb_main(index2).trial_bursts;

    ntrials = length(bursts1); % number of trials 
    burst_msn_window_activity1={};
    for j = 1:ntrials
        t       = bursts1{j}; % Spike timings in the jth trial
        v       = spikes2{j};
        nbursts   = size(t);
        nbursts   = nbursts(1);
        for i = 1:nbursts % for every burst
            if  t(i,3)>magicvalue
                burst_density=t(i,3)/(t(i,2)-t(i,1));
                burst_lengths=[burst_lengths t(i,2)-t(i,1)];

                id1=find(v>=t(i,1),1,'first');        
                id2=find(v<t(i,2)+window,1,'last');
                if isempty(id1) || isempty(id2) || id1>id2
                    id1=1;
                    id2=0;
                end
                window_activity=(id2-id1+1)/(t(i,2)-t(i,1)+window);

                burstAligned=[burstAligned;burst_density window_activity];
            end
        end
    end
end
maxlength=length(burstAligned);
    
num_bins=ceil(150/bin_size);
    
for i=1:num_bins
    K=[];
    for k=1:length(burstAligned)        
        if burstAligned(k,1)<i*bin_size && burstAligned(k,1)>=(i-1)*bin_size
            K=[K burstAligned(k,2)];
        end        
    end
    if ~isempty(K) && length(K)>=magicvalue2
        Y1=[Y1 mean(K)];
        X1=[X1 (i-0.5)*bin_size];
    end
end
        %% Alignment to tonic firing
average_burst_lenth=mean(burst_lengths);
tonicAligned=[];
X2=[];
Y2=[];
for m=1:2
    index1=fsi_list(m);
    index2=msn_list(m);
    spikes1 = twdb_main(index1).trial_spikes;
    bursts1 = twdb_main(index1).trial_bursts;

    spikes2 = twdb_main(index2).trial_spikes;
    bursts2 = twdb_main(index2).trial_bursts;

    ntrials = length(bursts1); % number of trials 
    burst_msn_window_activity1={};
    
    for j = 1:ntrials
        t       = spikes1{j}; % Spike timings in the jth trial
        v       = spikes2{j};
        nbursts   = ceil(40/average_burst_lenth);
        for i = 1:nbursts % for every burst
            randfac=0.1*(rand-0.5); % yes random
            
            startpoint = (i-1)*average_burst_lenth-20;
            endpoint = i*average_burst_lenth-20+window+randfac;
            
            idd1=find(bursts1{j}(:,2) >= startpoint,1,'first');        
            idd2=find(bursts1{j}(:,1) < endpoint,1,'last');
            if isempty(idd1) || isempty(idd2) || idd1>idd2
                idd1=1;
                idd2=0;
            end
            
            tominus=0;
            if idd2-idd1+1>0 %% DELETING ALL SPIKES IN EVERY BURST
                if bursts1{j}(idd1,3)>magicvalue
                    if bursts1{j}(idd1,1)>=startpoint %% first burst is entirely in window
                        tominus=tominus+bursts1{j}(idd1,3);
                    else %% first burst is partially in window
                        numspikesinwindow = find(t <= bursts1{j}(idd1,1),1,'last')-find(t >= startpoint,1,'first')+1;
                        tominus=tominus+numspikesinwindow;
                    end
                end
                    
                for ii=idd1+1:idd2-1 %% delete spikes in each burst
                    if bursts1{j}(ii,3)>magicvalue
                        tominus=tominus+bursts1{j}(ii,3);
                    end
                end
                
                if bursts1{j}(idd2,3)>magicvalue
                    if bursts1{j}(idd2,2)<=endpoint %% last burst is entirely in window
                        tominus=tominus+bursts1{j}(idd2,3);
                    else %% last burst is partially in window
                        numspikesinwindow = find(t <= endpoint,1,'last')-find(t >= bursts1{j}(idd2,2),1,'first')+1;
                        tominus=tominus+numspikesinwindow;
                    end
                end
            end
            if idd2-idd1+1>9999
                continue
            end
            
            id1=find(t >= startpoint,1,'first');        
            id2=find(t < endpoint,1,'last');
            if isempty(id1) || isempty(id2) || id1>id2
                id1=1;
                id2=0;
            end
            totalspikes = max(0,id2-id1+1-tominus);
            fsi_window_density=totalspikes/(average_burst_lenth+window+randfac);
            
            id3=find(v >= startpoint,1,'first');        
            id4=find(v < endpoint,1,'last');
            if isempty(id3) || isempty(id4) || id3>id4
                id3=1;
                id4=0;
            end
            msn_window_density = id4-id3+1/(average_burst_lenth+window+randfac);

            tonicAligned=[tonicAligned;fsi_window_density msn_window_density];
        end
    end
end

num_bins=ceil(150/bin_size2);
for i=1:num_bins
    K=[];
    for k=1:length(tonicAligned)        
        if tonicAligned(k,1)<i*bin_size2 && tonicAligned(k,1)>=(i-1)*bin_size2
            K=[K tonicAligned(k,2)];
        end        
    end
    if ~isempty(K) && length(K)>=magicvalue2
        Y2=[Y2 mean(K)];
        X2=[X2 (i-0.5)*bin_size2];
    end
end
        %% Plotting

m1=min(X1);
M1=max(X1);
m2=min(Y1);
M2=max(Y1);

mm1=min(X2);
MM1=max(X2);
mm2=min(Y2);
MM2=max(Y2);

m1=min(m1,mm1);
M1=max(M1,MM1)-m1;
m2=min(m2,mm2);
M2=max(M2,MM2)-m2;

X2=(X2-m1)./M1;
Y2=(Y2-m2)./M2;
X1=(X1-m1)./M1;
Y1=(Y1-m2)./M2;

figure
hold on
scatter(X1,Y1,'r')
[r1,m1,b1]=regression(X1,Y1);
X3=min(X1):0.01:max(X1);
Y3=X3*m1+b1;
plot(X3,Y3,'r')
cor1 = corr2(X1,Y1);

hold on
scatter(X2,Y2,'b')
[r2,m2,b2]=regression(X2,Y2);
X3=min(X2):0.01:max(X2);
Y3=X3*m2+b2;
plot(X3,Y3,'b')
cor2 = corr2(X2,Y2);
title(['Pearson Corr Coef: R = ' num2str(cor1) ', B = ' num2str(cor2) ' /// Slope: R = ' num2str(m1) ', B = ' num2str(m2)]);

xlabel(['Normalized HFN firing rate']);
ylabel(['Normalized SPN firing rate']);
saveas(gca, [fig_dir, '\spn_align2hfn_burst_and_tonic_example'], 'fig');
saveas(gca, [fig_dir, '\spn_align2hfn_burst_and_tonic_example'], 'eps');
save([fig_dir, '\spn_align2hfn_burst_and_tonic_example.mat'], 'burstAligned', 'tonicAligned');
xlswrite([fig_dir, '\spn_align2hfn_burst_and_tonic_example.xlsx'], burstAligned, 1)
xlswrite([fig_dir, '\spn_align2hfn_burst_and_tonic_example.xlsx'], tonicAligned, 2)
    %% Burst vs. tonic firing population (Work done by Suthee Ruangwises)
window=0.1; %% period after each burst
moving_win=0.1;
bin_size=5; %% bin size of red (burst)
bin_size2=bin_size/1; %% bin size of blue (non-burst)
magicvalue = 5; %% minimum number of spikes in a burst
magicvalue2 = 3; %% minimum number of samples in a bin

fsi_list=[1210 1518 5918 5982 6867 11073];
msn_list=[1209 1516 5913 5979 6866 11072];
        %% Alignment to bursts. 
Y1=[];
X1=[];
burstAligned=[];
burst_lengths=[];
for m=1:2
    index1=fsi_list(m);
    index2=msn_list(m);
    spikes1 = twdb_main(index1).trial_spikes;
    bursts1 = twdb_main(index1).trial_bursts;
    spikes2 = twdb_main(index2).trial_spikes;
    bursts2 = twdb_main(index2).trial_bursts;

    ntrials = length(bursts1); % number of trials 
    burst_msn_window_activity1={};
    for j = 1:ntrials
        t       = bursts1{j}; % Spike timings in the jth trial
        v       = spikes2{j};
        nbursts   = size(t);
        nbursts   = nbursts(1);
        for i = 1:nbursts % for every burst
            if  t(i,3)>magicvalue
                burst_density=t(i,3)/(t(i,2)-t(i,1));
                burst_lengths=[burst_lengths t(i,2)-t(i,1)];

                id1=find(v>=t(i,1),1,'first');        
                id2=find(v<t(i,2)+window,1,'last');
                if isempty(id1) || isempty(id2) || id1>id2
                    id1=1;
                    id2=0;
                end
                window_activity=(id2-id1+1)/(t(i,2)-t(i,1)+window);

                burstAligned=[burstAligned;burst_density window_activity];
            end
        end
    end
end
maxlength=length(burstAligned);
    
num_bins=ceil(150/bin_size);
    
for i=1:num_bins
    K=[];
    for k=1:length(burstAligned)        
        if burstAligned(k,1)<i*bin_size && burstAligned(k,1)>=(i-1)*bin_size
            K=[K burstAligned(k,2)];
        end        
    end
    if ~isempty(K) && length(K)>=magicvalue2
        Y1=[Y1 mean(K)];
        X1=[X1 (i-0.5)*bin_size];
    end
end
        %% Alignment to tonic firing
average_burst_lenth=mean(burst_lengths);
tonicAligned=[];
X2=[];
Y2=[];
for m=1:2
    index1=fsi_list(m);
    index2=msn_list(m);
    spikes1 = twdb_main(index1).trial_spikes;
    bursts1 = twdb_main(index1).trial_bursts;

    spikes2 = twdb_main(index2).trial_spikes;
    bursts2 = twdb_main(index2).trial_bursts;

    ntrials = length(bursts1); % number of trials 
    burst_msn_window_activity1={};
    
    for j = 1:ntrials
        t       = spikes1{j}; % Spike timings in the jth trial
        v       = spikes2{j};
        nbursts   = ceil(40/average_burst_lenth);
        for i = 1:nbursts % for every burst
            randfac=0.1*(rand-0.5); % yes random
            
            startpoint = (i-1)*average_burst_lenth-20;
            endpoint = i*average_burst_lenth-20+window+randfac;
            
            idd1=find(bursts1{j}(:,2) >= startpoint,1,'first');        
            idd2=find(bursts1{j}(:,1) < endpoint,1,'last');
            if isempty(idd1) || isempty(idd2) || idd1>idd2
                idd1=1;
                idd2=0;
            end
            
            tominus=0;
            if idd2-idd1+1>0 %% DELETING ALL SPIKES IN EVERY BURST
                if bursts1{j}(idd1,3)>magicvalue
                    if bursts1{j}(idd1,1)>=startpoint %% first burst is entirely in window
                        tominus=tominus+bursts1{j}(idd1,3);
                    else %% first burst is partially in window
                        numspikesinwindow = find(t <= bursts1{j}(idd1,1),1,'last')-find(t >= startpoint,1,'first')+1;
                        tominus=tominus+numspikesinwindow;
                    end
                end
                    
                for ii=idd1+1:idd2-1 %% delete spikes in each burst
                    if bursts1{j}(ii,3)>magicvalue
                        tominus=tominus+bursts1{j}(ii,3);
                    end
                end
                
                if bursts1{j}(idd2,3)>magicvalue
                    if bursts1{j}(idd2,2)<=endpoint %% last burst is entirely in window
                        tominus=tominus+bursts1{j}(idd2,3);
                    else %% last burst is partially in window
                        numspikesinwindow = find(t <= endpoint,1,'last')-find(t >= bursts1{j}(idd2,2),1,'first')+1;
                        tominus=tominus+numspikesinwindow;
                    end
                end
            end
            if idd2-idd1+1>9999
                continue
            end
            
            id1=find(t >= startpoint,1,'first');        
            id2=find(t < endpoint,1,'last');
            if isempty(id1) || isempty(id2) || id1>id2
                id1=1;
                id2=0;
            end
            totalspikes = max(0,id2-id1+1-tominus);
            fsi_window_density=totalspikes/(average_burst_lenth+window+randfac);
            
            id3=find(v >= startpoint,1,'first');        
            id4=find(v < endpoint,1,'last');
            if isempty(id3) || isempty(id4) || id3>id4
                id3=1;
                id4=0;
            end
            msn_window_density = id4-id3+1/(average_burst_lenth+window+randfac);

            tonicAligned=[tonicAligned;fsi_window_density msn_window_density];
        end
    end
end

num_bins=ceil(150/bin_size2);
for i=1:num_bins
    K=[];
    for k=1:length(tonicAligned)        
        if tonicAligned(k,1)<i*bin_size2 && tonicAligned(k,1)>=(i-1)*bin_size2
            K=[K tonicAligned(k,2)];
        end        
    end
    if ~isempty(K) && length(K)>=magicvalue2
        Y2=[Y2 mean(K)];
        X2=[X2 (i-0.5)*bin_size2];
    end
end
        %% Plotting

m1=min(X1);
M1=max(X1);
m2=min(Y1);
M2=max(Y1);

mm1=min(X2);
MM1=max(X2);
mm2=min(Y2);
MM2=max(Y2);

m1=min(m1,mm1);
M1=max(M1,MM1)-m1;
m2=min(m2,mm2);
M2=max(M2,MM2)-m2;

X2=(X2-m1)./M1;
Y2=(Y2-m2)./M2;
X1=(X1-m1)./M1;
Y1=(Y1-m2)./M2;

figure
hold on
scatter(X1,Y1,'r')
[r1,m1,b1]=regression(X1,Y1);
X3=min(X1):0.01:max(X1);
Y3=X3*m1+b1;
plot(X3,Y3,'r')
cor1 = corr2(X1,Y1);

hold on
scatter(X2,Y2,'b')
[r2,m2,b2]=regression(X2,Y2);
X3=min(X2):0.01:max(X2);
Y3=X3*m2+b2;
plot(X3,Y3,'b')
cor2 = corr2(X2,Y2);
title(['Pearson Corr Coef: R = ' num2str(cor1) ', B = ' num2str(cor2) ' /// Slope: R = ' num2str(m1) ', B = ' num2str(m2)]);

xlabel(['Normalized HFN firing rate']);
ylabel(['Normalized SPN firing rate']);
saveas(gca, [fig_dir, '\spn_align2hfn_burst_and_tonic_population'], 'fig');
saveas(gca, [fig_dir, '\spn_align2hfn_burst_and_tonic_population'], 'eps');
save([fig_dir, '\spn_align2hfn_burst_and_tonic_population.mat'], 'burstAligned', 'tonicAligned');
xlswrite([fig_dir, '\spn_align2hfn_burst_and_tonic_population.xlsx'], burstAligned, 1)
xlswrite([fig_dir, '\spn_align2hfn_burst_and_tonic_population.xlsx'], tonicAligned, 2)
close all;

%% Figure Script 9: Laser/Electrical Stimulation (Work done by Qinru Shi)
fig_dir = [figs_dir, '\Laser_and_Electrical_Stimulation']; 
    %% Timeline
x=-0.0615:0.0006:0.0579;

Sum301=zeros(200,1);

SumHF301=zeros(200,1);
SumHF303=zeros(200,1);
        %% Compute SPN Average
load([fig_dir, '\finalSPNUpList.mat'])
for i=1:length(indices)
    idx = indices(i);
    unitnum = str2double(twdb_training(idx).neuronN);
    evtFileLoc = [twdb_training(idx).sessionDir, '\events2.nev'];
    [TS, TTL] = dg_readEvents(evtFileLoc);
    events = [TS'/1000000, TTL'];
    output = load(twdb_training(idx).clusterDataLoc); output = output.output;
    spikes = output(output(:,2)==unitnum,1);
    
    block1_spikes_array = ah_build_spikes_array(spikes, events, 301, [-.06 .06], 301);
    
    results = hist(cell2mat(block1_spikes_array),x);
    results = results'/(length(block1_spikes_array)*0.0006);
    
    Sum301=Sum301+results;
end
Average301=Sum301/length(indices);
        %% Compute HighFiring Average
load([fig_dir, '\finalHighFiringDownList.mat'])
for i=1:length(indices)
    idx = indices(i);
    unitnum = str2double(twdb_training(idx).neuronN);
    evtFileLoc = [twdb_training(idx).sessionDir, '\events2.nev'];
    [TS, TTL] = dg_readEvents(evtFileLoc);
    events = [TS'/1000000, TTL'];
    output = load(twdb_training(idx).clusterDataLoc); output = output.output;
    spikes = output(output(:,2)==unitnum,1);
    
    block1_spikes_array = ah_build_spikes_array(spikes, events, 301, [-.06 .06], 301);
    
    results = hist(cell2mat(block1_spikes_array),x);
    results = results'/(length(block1_spikes_array)*0.0006);
    
    SumHF301=SumHF301+results;
end
AverageHF301=SumHF301/length(indices);
        %% Plot Time Line
Smooth_AverageHF301= smooth(AverageHF301,7);
Smooth_Average301= smooth(Average301,7);

SPNMin=min(Smooth_Average301);
SPNMax=max(Smooth_Average301);
HFMin=min(Smooth_AverageHF301);
HFMax=max(Smooth_AverageHF301);

Timeline301=(Smooth_Average301-SPNMin)/(SPNMax-SPNMin);
TimelineHF301=(Smooth_AverageHF301-HFMin)/(HFMax-HFMin);

figure; hold all;
plot(x,Timeline301,'LineWidth',2,'Color',[0 0 1]);
plot(x,TimelineHF301,'LineWidth',2,'Color',[0 .5 0]);
title('Timeline of SPN and HighFiring');
legend('SPN','HighFiring');
xlabel('second');
xlim([-0.01 0.03]);
hx = graph2d.constantline(0.0057, 'LineStyle',':', 'Color','k');
changedependvar(hx,'x');
hx = graph2d.constantline(0.0093, 'LineStyle',':', 'Color','k');
changedependvar(hx,'x');
saveas(gca, [fig_dir, '\SPN-HFN_stimulation_timeline'], 'fig')
saveas(gca, [fig_dir, '\SPN-HFN_stimulation_timeline'], 'eps')
allHistograms = [Average301 AverageHF301];
save([fig_dir, '\SPN-HFN_stimulation_timeline_data'], 'allHistograms')
xlswrite([fig_dir, '\SPN-HFN_stimulation_timeline_data.xlsx'], allHistograms)
    %% Histogram
x=-0.05934:0.00133348:0.05934;

Sum301=zeros(90,1);
Sum303=zeros(90,1);
SumHalf1=zeros(45,1);
SumHalf2=zeros(45,1);

SumHF301=zeros(90,1);
SumHF303=zeros(90,1);
SumHFHalf1=zeros(45,1);
SumHFHalf2=zeros(45,1);
        %% Compute SPN Average
load([fig_dir, '\finalSPNUpList.mat'])

X1 = zeros(length(indices),1);
Y1 = zeros(length(indices),1);

for i=1:length(indices)
    idx = indices(i);
    unitnum = str2double(twdb_training(idx).neuronN);
    evtFileLoc = [twdb_training(idx).sessionDir, '\events2.nev'];
    [TS, TTL] = dg_readEvents(evtFileLoc);
    events = [TS'/1000000, TTL'];
    output = load(twdb_training(idx).clusterDataLoc); output = output.output;
    spikes = output(output(:,2)==unitnum,1);
    
    block1_spikes_array = ah_build_spikes_array(spikes, events, 301, [-.06 .06], 301);
    
    results1 = hist(cell2mat(block1_spikes_array),x);
    results1 = results1'/(length(block1_spikes_array)*0.00133348);
    
    block3_spikes_array = ah_build_spikes_array(spikes, events, 303, [-.06 .06], 303);
    
    results2 = hist(cell2mat(block3_spikes_array),x);
    results2 = results2'/(length(block3_spikes_array)*0.00133348);
    
    Sum301=Sum301+results1;
    SumHalf1=SumHalf1+results1(1:45);
    Sum303=Sum303+results2;
    SumHalf2=SumHalf2+results2(1:45);
    
    X1(i) = max(results1);
    Y1(i) = max(results2);
end
Average301=Sum301/length(indices);
Average303=Sum303/length(indices);
        %% Plot SPN figure
figure; hold all;
bar(x, Average303,'FaceColor','y','EdgeColor','y');
bar(x, Average301,'FaceColor','Black');
title('SPN: 56 out of 64');
xlabel('second');
ylabel('Hz');
legend('Laser and Electric','Electric');
xlim([-0.06,0.06]);
ylim([0,50]);
saveas(gca, [fig_dir, '\SPN_responseToStimulations'], 'fig')
saveas(gca, [fig_dir, '\SPN_responseToStimulations'], 'eps')
        %% Compute HighFiring Average
load([fig_dir, '\finalHighFiringDownList.mat'])

X2 = zeros(length(indices),1);
Y2 = zeros(length(indices),1);

for i=1:length(indices)
    idx = indices(i);
    unitnum = str2double(twdb_training(idx).neuronN);
    evtFileLoc = [twdb_training(idx).sessionDir, '\events2.nev'];
    [TS, TTL] = dg_readEvents(evtFileLoc);
    events = [TS'/1000000, TTL'];
    output = load(twdb_training(idx).clusterDataLoc); output = output.output;
    spikes = output(output(:,2)==unitnum,1);
    
    block1_spikes_array = ah_build_spikes_array(spikes, events, 301, [-.06 .06], 301);
    
    results1 = hist(cell2mat(block1_spikes_array),x);
    results1 = results1'/(length(block1_spikes_array)*0.00133348);
    
    block3_spikes_array = ah_build_spikes_array(spikes, events, 303, [-.06 .06], 303);
    
    results2 = hist(cell2mat(block3_spikes_array),x);
    results2 = results2'/(length(block3_spikes_array)*0.00133348);
    
    SumHF301=SumHF301+results1;
    SumHFHalf1=SumHFHalf1+results1(1:45);
    SumHF303=SumHF303+results2;
    SumHFHalf2=SumHFHalf2+results2(1:45);
    
    X2(i) = max(results1);
    Y2(i) = max(results2);
end
AverageHF301=SumHF301/length(indices);
AverageHF303=SumHF303/length(indices);
        %% Save data
allHistograms = [Average301 Average303 AverageHF301 AverageHF303];
save([fig_dir, '\SPN-HFN_responseToStim_Histograms.mat'], 'allHistograms')
xlswrite([fig_dir, '\SPN-HFN_responseToStim_Histograms.xlsx'], allHistograms)
        %% Plot HFN figure
figure; hold all;
bar(x, AverageHF301,'FaceColor','Black');
bar(x, AverageHF303,'FaceColor','y','EdgeColor','y');
title('HighFiring: 19 out of 21');
xlabel('second');
ylabel('Hz');
legend('Electric','Laser and Electric');
xlim([-0.06,0.06]);
ylim([0,100]);
saveas(gca, [fig_dir, '\HFN_responseToStimulations'], 'fig')
saveas(gca, [fig_dir, '\HFN_responseToStimulations'], 'eps')
close all;

%% Figure Script 10: Bursts: 
fig_dir = [figs_dir, '\Bursts'];
    %% Pipeline
        %% Figure setup
trial_spikes = [.001 .013 .016 .028 .049 .055 .063 .080  .082 .091 .092 .100 .5 .7 1.01 1.5 1.65 2 2.1 2.15 2.940 2.949 2.966 3.015 3.026 3.094 3.128 3.162 3.197 3.210];
baseline_firing_rate = 6;
figure; hold all;
line([0 0], [-1 12], 'LineWidth', 2, 'Color', [1 0 1])
line([1 1], [-1 12], 'LineWidth', 2, 'Color', [1 0 1])
line([2.9 2.9], [-1 12], 'LineWidth', 2, 'Color', [1 0 1])
text(-.02, -.9, 'Click Time', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top')
text(0.98, -.9, 'Turn Time', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top')
text(2.88, -.9, 'Lick Time', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top')
        %% First Row of Figures - Firing Rate of Spikes
xvals = -0.95:.1:3.95;
yvals = ah_smoothed_data(trial_spikes, xvals, .05);
yvals = 1-yvals/max(yvals);
plot(xvals,yvals, 'Color', 'Blue', 'LineWidth', 2)
text(-.98, 0.5, 'Trial Activity:', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle')
        %% Second Row of Figure - Spikes
for spike = 1:length(trial_spikes)
    line([trial_spikes(spike) trial_spikes(spike)], [2 3], 'Color', 'Black', 'LineWidth', 2)
    line([trial_spikes(spike) trial_spikes(spike)], [4 5], 'Color', 'Black', 'LineWidth', 2)
end
text(-.98, 2.5, 'Trial Spikes:', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle')
        %% Third Row of Figure - Burst Finding
[bursts, indices] = ah_find_trial_bursts(trial_spikes, baseline_firing_rate);
for burst = 1:size(bursts,1)
    patch([bursts(burst,1)-.03, bursts(burst,1)-.03 bursts(burst,1)-.1], [3.9 5.1 4.5], 'Red', 'EdgeColor', 'None')
    patch([bursts(burst,2)+.03, bursts(burst,2)+.03 bursts(burst,2)+.1], [3.9 5.1 4.5], 'Red', 'EdgeColor', 'None')
end
text(-.98, 4.5, 'Burst Finding:', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle')
        %% Fourth Row of Figure - Isolate Bursts
for burst = 1:size(indices,1)
    for spike = indices(burst,1):indices(burst,2)
        line([trial_spikes(spike) trial_spikes(spike)], [6 7], 'Color', 'Black', 'LineWidth', 2)
        firing_rate = round((bursts(burst,3)-1)/(bursts(burst,2)-bursts(burst,1)));
        burst_mid = 1/2*(bursts(burst,1)+bursts(burst,2));
        text(burst_mid,5.5,[num2str(firing_rate), ' Hz'],'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
    end
end
text(-.98, 6.5, 'Burst Isolation:', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle')
        %% Fifth Row of Figure - Threshold Bursts
final_spikes = [];
for burst = 1:size(indices,1)
    if (bursts(burst,3)-1)/(bursts(burst,2)-bursts(burst,1)) > 4*baseline_firing_rate
        final_spikes = [final_spikes, trial_spikes(indices(burst,1):indices(burst,2))];
        for spike = indices(burst,1):indices(burst,2)
            line([trial_spikes(spike) trial_spikes(spike)], [8 9], 'Color', 'Black', 'LineWidth', 2)
        end
    end
end
text(-.98, 8.5, 'Burst Thresholding (3 STDs = 24 Hz):', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle')
        %% Sixth Row of Figure - Minimaxed Bins
bins = hist(final_spikes, xvals);
bins = 11 - bins/max(bins);
for bin = 1:length(bins)
    patch([xvals(bin)-.05, xvals(bin)-.05 xvals(bin)+.05 xvals(bin)+.05], [11 bins(bin) bins(bin) 11], 'Green')
end
text(-.98, 10.5, 'Min-max Normalization:', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle')
        %% Figure formatting
set(gca, 'ydir', 'Reverse')
set(gca, 'YTickLabel', '')
xlim([-1 4])
ylim([-1 12])
xlabel('Time (seconds)')
saveas(gca, [fig_dir, '\burst_pipeline'], 'fig')
saveas(gca, [fig_dir, '\burst_pipeline'], 'eps')
save([fig_dir, '\burst_pipeline_data.mat'], 'trial_spikes', 'bursts', 'indices')
xlswrite([fig_dir, '\burst_pipeline_data.xlsx'], trial_spikes, 1)
xlswrite([fig_dir, '\burst_pipeline_data.xlsx'], bursts, 2)
xlswrite([fig_dir, '\burst_pipeline_data.xlsx'], indices, 3)
    %% Example neuron: raster and firing rate
neuron_idx = 1224;
        %% Draw raster plot with bursts
spikes_array = twdb_main(neuron_idx).trial_spikes;
bursts_array = twdb_main(neuron_idx).trial_bursts;
ses_evt_timings = twdb_main(neuron_idx).trial_evt_timings;
avg_lick_time = mean(ses_evt_timings(:,4));
figure; hold all;
line([0 0], [0 length(spikes_array)], 'LineWidth', 2', 'Color', [1 0 1])
line([1 1], [0 length(spikes_array)], 'LineWidth', 2', 'Color', [1 0 1])
line([avg_lick_time avg_lick_time], [0 length(spikes_array)], 'LineWidth', 2', 'Color', [1 0 1])
for trial_idx = 1:length(spikes_array)
    for spike_idx = 1:length(spikes_array{trial_idx})
        spike_time = spikes_array{trial_idx}(spike_idx);
        if spike_time > -1 && spike_time < 4
            line([spike_time spike_time], [trial_idx-1 trial_idx], 'LineWidth', 2, 'Color', [0 0 0])
        end
    end
    for burst_idx = 1:size(bursts_array{trial_idx},1)
        burst_start = bursts_array{trial_idx}(burst_idx,1);
        burst_end = bursts_array{trial_idx}(burst_idx,2);
        burst_spikes = bursts_array{trial_idx}(burst_idx,3);
        burst_FR = burst_spikes/(burst_end-burst_start);
        if burst_start > -1 && burst_end < 4
            if burst_FR > max(10,4*twdb_main(neuron_idx).baseline_firing_rate_data(1))
                color = [1 0 0];
            else
                color = [0 1 0];
            end
            h1 = patch([burst_start-.03 burst_start-.03 burst_start-.1], [trial_idx-1 trial_idx trial_idx-.5], color, 'EdgeColor', 'None');
            h2 = patch([burst_end+.03 burst_end+.03 burst_end+.1], [trial_idx-1 trial_idx trial_idx-.5], color, 'EdgeColor', 'None');
            if burst_FR <= max(10,4*twdb_main(neuron_idx).baseline_firing_rate_data(1))
                uistack(h1, 'bottom')
                uistack(h2, 'bottom')
            else
                patch([burst_start-.03 burst_start-.03 burst_end+.03 burst_end+.03], [trial_idx-1 trial_idx-.8 trial_idx-.8 trial_idx-1], color, 'EdgeColor', 'None')
                patch([burst_start-.03 burst_start-.03 burst_end+.03 burst_end+.03], [trial_idx trial_idx-.2 trial_idx-.2 trial_idx], color, 'EdgeColor', 'None')
            end
        end
    end
end
set(gca, 'ydir', 'Reverse')
xlim([-1 4])
xlabel('Time (seconds)')
ylabel('Trial Number')
saveas(gca, [fig_dir, '\neuronalBurstRaster'], 'fig')
saveas(gca, [fig_dir, '\neuronalBurstRaster'], 'eps')
save([fig_dir, '\neuronalBurstRasterData.mat'], 'spikes_array', 'bursts_array')
numTrials = length(spikes_array);
for trial_idx = 1:numTrials
    xlswrite([fig_dir, '\neuronalBurstRaster.xlsx'], spikes_array{trial_idx}', 1, ['A' num2str(5*trial_idx-4)])
    xlswrite([fig_dir, '\neuronalBurstRaster.xlsx'], bursts_array{trial_idx}', 1, ['A' num2str(5*trial_idx-3)])
end
        %% Draw minimax analysis of neuron
[plotting_bins, evt_times_distribution, timeOfBins, numTrials, fullData] = ah_fill_burst_plotting_bins(bursts_array,...
    {ses_evt_timings},[1 length(bursts_array) twdb_main(neuron_idx).baseline_firing_rate_data], {}, {}, [600 1 2 .5 .6 0], [1 0], [10 0 4], 1);
ah_plot_double_aligned_population_analysis(plotting_bins,evt_times_distribution,timeOfBins,numTrials,[1 2], .53, 15, 1, [0 1 1])
xlim([-1 4])
xlabel('Time (seconds)')
ylabel('Normalized Firing Rate')
saveas(gca, [fig_dir, '\neuronBurstsExample'], 'fig')
saveas(gca, [fig_dir, '\neuronBurstsExample'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials); fullData];
xlswrite([fig_dir, '\neuronBurstsExampleData.xlsx'], fullData)
save([fig_dir, '\neuronBurstsExampleData.mat'], 'fullData')
    %% Example populations
        %% Setup
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'CB', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5,...
    'grade', 'strio_projecting_spikes', 10, NaN, 'grade', 'strio_projecting_grade', 5, NaN);
[~, ~, ~, spikes_array, bursts_array, ses_evt_timings, neuron_idsAndData] = ah_extractDataFromTWDB(twdb_main, neuron_ids);
        %% Spike firing rate plot
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_spike_plotting_bins(spikes_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6], [0 0], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([0 8]); title([num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\spike_firingRate'], 'fig')
saveas(gca, [fig_dir, '\spike_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\spike_firingRate.xlsx'], fullData)
save([fig_dir, '\spike_firingRate.mat'], 'fullData')
        %% Burst firing rate plot
[plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, fullData] = ah_fill_burst_plotting_bins(bursts_array, ...
    ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6, 0], [0 0], [10 0 4], 1);
ah_plot_double_aligned_population_analysis(plotting_bins2, evt_times_distribution, timeOfBins, numTrials0, [1 2], .53, 15, 1)
xlim([-10 10]); ylim([0 2]); title([num2str(length(neuron_ids)), ' Neurons']);
xlabel('Time (seconds)');   ylabel('Firing Rate (Hz)');
saveas(gca, [fig_dir, '\spike_firingRate'], 'fig')
saveas(gca, [fig_dir, '\spike_firingRate'], 'eps')
fullData = fullData(fullData(:,2)>-1,:);
fullData = [mean(fullData); std(fullData)/sqrt(numTrials0); fullData];
xlswrite([fig_dir, '\spike_firingRate.xlsx'], fullData)
save([fig_dir, '\spike_firingRate.mat'], 'fullData')
close all;

%% Figure Script 11: Other (Bayesian Predictions, Trial Durations, Striosomality)
fig_dir = [figs_dir, '\Other'];
    %% Bayesian Predictions
means = zeros(5,6);
stds = zeros(5,6);
        %% Cost Benefit Conflict
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'CB', 'key', 'tetrodeType', 'dms');
[~, ~, ~, ~, ~, ses_evt_timings] = ah_extractDataFromTWDB(twdb_main, neuron_ids);

choc = 0;
mix = 0;
same1 = zeros(2,5);
change1 = zeros(2,5);
% Mapping from choice to ID = 1010*(3-choice) - 9 = 3021 - 1010*choice
% Mapping from choice to opposite idea = 1010*choice - 9
for i = 1:length(ses_evt_timings)
    evts = ses_evt_timings{i};
    chocs = length(find(evts(:,5)==2011));
    mixes = length(find(evts(:,5)==1001));
    if (chocs/(chocs+mixes) > .5)
        continue;
    end
    for j = 1:size(evts,1)
        choice = 0;
        if evts(j,5) == 2011
            choice = 1;
            choc = choc + 1;
        elseif evts(j,5) == 1001
            choice = 2;
            mix = mix + 1;
        end
        if choice==0
            continue;
        end
        
        for k = 1:5
            if k+j < size(evts,1) && evts(k+j,5)==3021-1010*choice
                same1(choice,k) = same1(choice,k) + 1;
            elseif k+j < size(evts,1) && evts(k+j,5)== 1010*choice -9
                change1(choice,k) = change1(choice,k) + 1;
            end
        end
        
    end
end

tots = same1 + change1;
ratios = same1./tots;
row_means = [choc/(choc+mix) ratios(1,:)];

std = sqrt(choc*mix/(choc+mix)^3);
row_stds = [std 0 0 0 0 0];
for i = 1:5
    row_stds(i+1) = sqrt(same1(1,i)*change1(1,i)/tots(1,i)^3);
end

means(1,:) = row_means;
stds(1,:) = row_stds;
        %% Benefit Benefit Similar
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'dms', 'grade', 'conc', 60, 70);
[~, ~, ~, ~, ~, ses_evt_timings] = ah_extractDataFromTWDB(twdb_main, neuron_ids);

choc = 0;
mix = 0;
same1 = zeros(2,5);
change1 = zeros(2,5);
% Mapping from choice to ID = 1010*(3-choice) - 9 = 3021 - 1010*choice
% Mapping from choice to opposite idea = 1010*choice - 9
for i = 1:length(ses_evt_timings)
    evts = ses_evt_timings{i};
    chocs = length(find(evts(:,5)==2011));
    mixes = length(find(evts(:,5)==1001));
    if (chocs/(chocs+mixes) < .5)
        continue;
    end
    for j = 1:size(evts,1)
        choice = 0;
        if evts(j,5) == 2011
            choice = 1;
            choc = choc + 1;
        elseif evts(j,5) == 1001
            choice = 2;
            mix = mix + 1;
        end
        if choice==0
            continue;
        end
        
        for k = 1:5
            if k+j < size(evts,1) && evts(k+j,5)==3021-1010*choice
                same1(choice,k) = same1(choice,k) + 1;
            elseif k+j < size(evts,1) && evts(k+j,5)== 1010*choice -9
                change1(choice,k) = change1(choice,k) + 1;
            end
        end
        
    end
end

tots = same1 + change1;
ratios = same1./tots;
row_means = [choc/(choc+mix) ratios(1,:)];

std = sqrt(choc*mix/(choc+mix)^3);
row_stds = [std 0 0 0 0 0];
for i = 1:5
    row_stds(i+1) = sqrt(same1(1,i)*change1(1,i)/tots(1,i)^3);
end

means(2,:) = row_means;
stds(2,:) = row_stds;
        %% Benefit Benefit Dissimilar
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'dms', 'grade', 'conc', 5, 45);
[~, ~, ~, ~, ~, ses_evt_timings] = ah_extractDataFromTWDB(twdb_main, neuron_ids);

choc = 0;
mix = 0;
same1 = zeros(2,5);
change1 = zeros(2,5);
% Mapping from choice to ID = 1010*(3-choice) - 9 = 3021 - 1010*choice
% Mapping from choice to opposite idea = 1010*choice - 9
for i = 1:length(ses_evt_timings)
    evts = ses_evt_timings{i};
    chocs = length(find(evts(:,5)==2011));
    mixes = length(find(evts(:,5)==1001));
    if (chocs/(chocs+mixes) < .5)
        continue;
    end
    for j = 1:size(evts,1)
        choice = 0;
        if evts(j,5) == 2011
            choice = 1;
            choc = choc + 1;
        elseif evts(j,5) == 1001
            choice = 2;
            mix = mix + 1;
        end
        if choice==0
            continue;
        end
        
        for k = 1:5
            if k+j < size(evts,1) && evts(k+j,5)==3021-1010*choice
                same1(choice,k) = same1(choice,k) + 1;
            elseif k+j < size(evts,1) && evts(k+j,5)== 1010*choice -9
                change1(choice,k) = change1(choice,k) + 1;
            end
        end
        
    end
end

tots = same1 + change1;
ratios = same1./tots;
row_means = [choc/(choc+mix) ratios(1,:)];

std = sqrt(choc*mix/(choc+mix)^3);
row_stds = [std 0 0 0 0 0];
for i = 1:5
    row_stds(i+1) = sqrt(same1(1,i)*change1(1,i)/tots(1,i)^3);
end

means(3,:) = row_means;
stds(3,:) = row_stds;
        %% Non-conflict Cost Benefit
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'Rev CB', 'key', 'tetrodeType', 'dms');
[~, ~, ~, ~, ~, ses_evt_timings] = ah_extractDataFromTWDB(twdb_main, neuron_ids);

choc = 0;
mix = 0;
same1 = zeros(2,5);
change1 = zeros(2,5);
% Mapping from choice to ID = 1010*(3-choice) - 9 = 3021 - 1010*choice
% Mapping from choice to opposite idea = 1010*choice - 9
for i = 1:length(ses_evt_timings)
    evts = ses_evt_timings{i};
    chocs = length(find(evts(:,5)==2011));
    mixes = length(find(evts(:,5)==1001));
    if (chocs/(chocs+mixes) < .5)
        continue;
    end
    for j = 1:size(evts,1)
        choice = 0;
        if evts(j,5) == 2011
            choice = 1;
            choc = choc + 1;
        elseif evts(j,5) == 1001
            choice = 2;
            mix = mix + 1;
        end
        if choice==0
            continue;
        end
        
        for k = 1:5
            if k+j < size(evts,1) && evts(k+j,5)==3021-1010*choice
                same1(choice,k) = same1(choice,k) + 1;
            elseif k+j < size(evts,1) && evts(k+j,5)== 1010*choice -9
                change1(choice,k) = change1(choice,k) + 1;
            end
        end
        
    end
end

tots = same1 + change1;
ratios = same1./tots;
row_means = [choc/(choc+mix) ratios(1,:)];

std = sqrt(choc*mix/(choc+mix)^3);
row_stds = [std 0 0 0 0 0];
for i = 1:5
    row_stds(i+1) = sqrt(same1(1,i)*change1(1,i)/tots(1,i)^3);
end

means(4,:) = row_means;
stds(4,:) = row_stds;
        %% Cost Cost
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'EQR', 'key', 'tetrodeType', 'dms');
[~, ~, ~, ~, ~, ses_evt_timings] = ah_extractDataFromTWDB(twdb_main, neuron_ids);

choc = 0;
mix = 0;
same1 = zeros(2,5);
change1 = zeros(2,5);
% Mapping from choice to ID = 1010*(3-choice) - 9 = 3021 - 1010*choice
% Mapping from choice to opposite idea = 1010*choice - 9
for i = 1:length(ses_evt_timings)
    evts = ses_evt_timings{i};
    chocs = length(find(evts(:,5)==2011));
    mixes = length(find(evts(:,5)==1001));
    if (chocs/(chocs+mixes) < .5)
        continue;
    end
    for j = 1:size(evts,1)
        choice = 0;
        if evts(j,5) == 2011
            choice = 1;
            choc = choc + 1;
        elseif evts(j,5) == 1001
            choice = 2;
            mix = mix + 1;
        end
        if choice==0
            continue;
        end
        
        for k = 1:5
            if k+j < size(evts,1) && evts(k+j,5)==3021-1010*choice
                same1(choice,k) = same1(choice,k) + 1;
            elseif k+j < size(evts,1) && evts(k+j,5)== 1010*choice -9
                change1(choice,k) = change1(choice,k) + 1;
            end
        end
        
    end
end

tots = same1 + change1;
ratios = same1./tots;
row_means = [choc/(choc+mix) ratios(1,:)];

std = sqrt(choc*mix/(choc+mix)^3);
row_stds = [std 0 0 0 0 0];
for i = 1:5
    row_stds(i+1) = sqrt(same1(1,i)*change1(1,i)/tots(1,i)^3);
end

means(5,:) = row_means;
stds(5,:) = row_stds;
        %% Plotting
means2 = zeros(5,5);
stds2 = zeros(5,5);
for i = 1:5
    means2(i,:) = 100*(means(i,2:6) - means(i,1));
    stds2(i,:) = 100*stds(i,2:6);
end

colors = {[1 0 0], [.75 .75 .75], [.75 .75 .75], [.75 .75 .75], [.75 .75 .75]};
labels = {'CBC', 'BBS', 'BBD', 'NCB', 'EQR'};
ah_barsWithErrors(means2,stds2,labels,colors,1)
saveas(gca, [fig_dir, '\bayesian_predictions'], 'fig');
saveas(gca, [fig_dir, '\basesian_predictions'], 'eps');
save([fig_dir, '\bayesian_predictions_means'], 'means');
xlswrite([fig_dir, '\bayesian_predictions_means'], means);
    %% Trial Durations
clear std;
means = zeros(5,1);
stds = zeros(5,1);
data = {[], [], [], [], []};
        %% Cost Benefit
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'CB', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5);
[~, ~, ~, ~, bursts_array, ses_evt_timings, neuron_idsAndData] = ah_extractDataFromTWDB(twdb_main, neuron_ids);
[~, evt_times_distribution] = ah_fill_burst_plotting_bins(bursts_array, ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6, 0], [1 0], [10 0 4], 1);
means(1) = mean(evt_times_distribution{2});
stds(1) = std(evt_times_distribution{2});
data{1} = evt_times_distribution{2};
        %% Benefit Benefit Similar Rewards
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5, 'grade', 'conc', 60, 70);
[~, ~, ~, ~, bursts_array, ses_evt_timings, neuron_idsAndData] = ah_extractDataFromTWDB(twdb_main, neuron_ids);
[~, evt_times_distribution] = ah_fill_burst_plotting_bins(bursts_array, ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6, 0], [1 0], [10 0 4], 1);
means(2) = mean(evt_times_distribution{2});
stds(2) = std(evt_times_distribution{2});
data{2} = evt_times_distribution{2};
        %% Benefit Benefit Dissimilar Rewards
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'TR', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5, 'grade', 'conc', 5, 45);
[~, ~, ~, ~, bursts_array, ses_evt_timings, neuron_idsAndData] = ah_extractDataFromTWDB(twdb_main, neuron_ids);
[~, evt_times_distribution] = ah_fill_burst_plotting_bins(bursts_array, ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6, 0], [1 0], [10 0 4], 1);
means(3) = mean(evt_times_distribution{2});
stds(3) = std(evt_times_distribution{2});
data{3} = evt_times_distribution{2};
        %% Cost Cost
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'EQR', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5);
[~, ~, ~, ~, bursts_array, ses_evt_timings, neuron_idsAndData] = ah_extractDataFromTWDB(twdb_main, neuron_ids);
[~, evt_times_distribution] = ah_fill_burst_plotting_bins(bursts_array, ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6, 0], [1 0], [10 0 4], 1);
means(4) = mean(evt_times_distribution{2});
stds(4) = std(evt_times_distribution{2});
data{4} = evt_times_distribution{2};
        %% Non-Conflict Cost Benefit
neuron_ids = twdb_lookup(twdb_main, 'index', 'key', 'taskType', 'Rev CB', 'key', 'tetrodeType', 'pl', 'grade', 'final_michael_grade', 1, 5);
[~, ~, ~, ~, bursts_array, ses_evt_timings, neuron_idsAndData] = ah_extractDataFromTWDB(twdb_main, neuron_ids);
[~, evt_times_distribution] = ah_fill_burst_plotting_bins(bursts_array, ses_evt_timings, neuron_idsAndData, {}, {}, [600, 1, 2, .5, .6, 0], [1 0], [10 0 4], 1);
means(5) = mean(evt_times_distribution{2});
stds(5) = std(evt_times_distribution{2});
data{5} = evt_times_distribution{2};
        %% Draw bar graph
ah_barsWithErrors(means,stds,{'Cost Benefit', 'Benefit Benefit Similar Rewards', 'Benefit Benefit Dissimilar Rewards', 'Cost Cost', 'Non-Conflict Cost Benefit'},{[1 0 0]},1)
ylabel('Average Trial Length (seconds)')
saveas(gca, [fig_dir, '\trialLength_barGraph'], 'fig')
saveas(gca, [fig_dir, '\trialLength_barGraph'], 'eps')
save([fig_dir, '\trialLengthsData.mat'], 'data')
for task_idx = 1:5
    xlswrite([fig_dir, '\trialLengthsData.xlsx'], data{1}', 1, ['A', num2str(task_idx)])
end
    %% Striosomality
        %% Computation
strio_distances = [];
strio_data = [];
strio_units = {};
other_distances = [];
nr_distances = [];
for i = 1:length(twdb_training)
    if twdb_training(i).final_michael_grade >= 2 || twdb_training(i).distanceFromStriosome <= 0 || twdb_training(i).distanceFromStriosome >= 100
        dist = twdb_training(i).distanceFromStriosome;
        type = twdb_training(i).striosomality2_type;
        grade = twdb_training(i).striosomality2_grade;
        data = twdb_training(i).striosomality2_data;
        neuronType = twdb_training(i).sqr_neuron_type;
        michael_grade = twdb_training(i).final_michael_grade;
        % Filtered out due to untrustworthy measurements. 
        if (isequal(twdb_training(i).ratID, 'strio2')&& ismember(str2double(twdb_training(i).tetrodeN), 8)) || ...
                (isequal(twdb_training(i).ratID, 'strio3')&& ismember(str2double(twdb_training(i).tetrodeN),[4, 8, 15, 16, 19])) || ...
                (isequal(twdb_training(i).ratID, 'strio10')&& ismember(str2double(twdb_training(i).tetrodeN),[1, 4])) || ...
                isequal(twdb_training(i).ratID, 'strio4') || isnan(dist) 
            continue;
        end
        if type > 3 && ismember(neuronType,[3 4 5]) && grade > 0 && data(3) < .019 && data(2) > 5
            strio_distances(end+1,:) = dist;
            strio_data(end+1,:) = [dist data(1:4)];
            strio_units{end+1,1} = [twdb_training(i).ratID, '  ', twdb_training(i).tetrodeN, '  ', num2str(dist)];
        elseif type == 0 && ismember(neuronType,[3 5]) && michael_grade >= 3
            nr_distances(end+1,:) = dist;
        elseif michael_grade >=3 && ismember(neuronType,[3 4 5])
            other_distances(end+1,:) = dist; 
        end
    end
end
        %% Plotting 
xvalues = [15 45 75 105 135]+.1;
strio_bins = hist(strio_distances(:,1),xvalues);
figure; bar(1:5, strio_bins)
saveas(gca, [fig_dir, '\striosomality_striosomes'], 'fig')
saveas(gca, [fig_dir, '\striosomality_striosomes'], 'eps')
matrix_bins = hist(nr_distances,xvalues);
figure; bar(1:5, matrix_bins)
saveas(gca, [fig_dir, '\striosomality_matrix'], 'fig')
saveas(gca, [fig_dir, '\striosomality_matrix'], 'eps')
save([fig_dir, '\striosomality_distances'], 'strio_distances', 'nr_distances')
xlswrite([fig_dir, '\striosomality_distances.xlsx'], strio_distances, 1)
xlswrite([fig_dir, '\striosomality_distances.xlsx'], nr_distances, 2)
    %% DMS Classification
        %% Extract Relevant Data From TWDB
HalfPeakTimes=zeros(length(twdb_training),1);
MeanMedianRatios=zeros(length(twdb_training),1);
FiringRates=zeros(length(twdb_training),1);
Types=zeros(length(twdb_training),1);

for i=1:length(twdb_training)
    FiringRates(i)=twdb_training(1,i).FiringRate;
    MeanMedianRatios(i)=twdb_training(1,i).MeanMedianRatio;
    HalfPeakTimes(i)=twdb_training(1,i).HalfPeakTime;
    Types(i)=twdb_training(1,i).sqr_neuron_type;
end   

Data=[Types HalfPeakTimes MeanMedianRatios FiringRates];

cluster0 = Data(Types == 0,2:4);
cluster1 = Data(Types == 1,2:4);
cluster2 = Data(Types == 2,2:4);
cluster3 = Data(Types == 3,2:4);
cluster4 = Data(Types == 4,2:4);
cluster5 = Data(Types == 5,2:4);
        %% Draw Scatter Plot
figure; hold all;
scatter3(cluster1(:,1),cluster1(:,2),cluster1(:,3),100,'r','Marker','.')
scatter3(cluster3(:,1),cluster3(:,2),cluster3(:,3),100,'b','Marker','.')
scatter3(cluster2(:,1),cluster2(:,2),cluster2(:,3),100,[0 0.9 0],'Marker','.')
scatter3(cluster0(:,1),cluster0(:,2),cluster0(:,3),100,[0.5 0.5 0.5],'Marker','.')
scatter3(cluster4(:,1),cluster4(:,2),cluster4(:,3),100,'b','Marker','.')
scatter3(cluster5(:,1),cluster5(:,2),cluster5(:,3),100,'b','Marker','.')
zlim([0 35])
xlim([0 0.45])
ylim([0 7])
xlabel('Half-peak time(s)');
ylabel('log(median ISI/mean ISI)');
zlabel('Firing Rate(Hz)')
legend('FastFiring','MSN','TAN','Unclassified');
        %% Save Plot/Data
saveas(gca, [fig_dir, '\neuronTypeClassification3DPlot'], 'fig')
saveas(gca, [fig_dir, '\neuronTypeClassification3DPlot'], 'eps')
save([fig_dir, '\neuronTypeClassification3DPlotData.mat'], 'Data')
xlswrite([fig_dir, '\neuronTypeClassification3DPlotData.xlsx'], Data)
close all;
    %% Trial Choices in Laser Manipulation
        %% Prelaser Block
laser_off=nan(24, 20);

laser_off(1,:)='mmmmmmmmcmmmmcmmmmcm'% laser_offfr21
laser_off(2,:)='mmmmcmmmccmmmcmmmmmc'
laser_off(3,:)='mmmmmcmmmmmmcmmmccmm' % laser_offfr 22
laser_off(4,:)='mcmcmccmmmmcmmmcmmcm'
laser_off(5,:)='mmcmcmmmmmmmmmmmmcmc'
laser_off(6,:)='mmcmmmcmmcmccmmmmmmm'
laser_off(7,:)='mmccmccmmmmmmmcmmmcm'
laser_off(8,:)='mmmmmmcmmmmmmcmmmmmm'
laser_off(9,:)='mmmcmmmmmccmmmmmcmmm'
laser_off(10,:)='mmmmcmmmmmcmmmmcmmmm'
laser_off(11,:)='cmcmmmmmcmmmcmmcmmmc'
laser_off(12,:)='mmmcmmmmmmmmmmmmmmmm' % laser_offfr 25
laser_off(13,:)='mmmmmmmmcmmmmmmmmmcm'
laser_off(14,:)='cmmcmmmmcmmmcmmmmcmm'
laser_off(15,:)='mmmmcmmmcmmmmmccmmmm'
laser_off(16,:)='cccccmcmcmcmmmmmmcmm'  % strio 15  % cmccmmm
laser_off(17,:)='mccmcmmmmcmmmcmmcmmm'
laser_off(18,:)='mcmmmcmmmmmcmcmmmcmm'
laser_off(19,:)='mcmmccmmmcmmcmcmmmcm' % mccmmmmXmcm
laser_off(20,:)='cmmmcmmmmccmmcmmmmmc'
laser_off(21,:)='mcmmmccmmmmcmcmmcmmm'
laser_off(22,:)='mcmmcmcmmmmmmcmmmmmc'
laser_off(23,:)='mcmcmcmccXmmmXmccmcm'% strio 14
laser_off(24,:)='cccmcmmcmmmcccmccmmc'


for ind=1:20
    base(ind)=sum(laser_off(:,ind)=='c')/24*100;
end
figure
bar (base)
ylim([0 70] )
xlim([0 21] )
saveas(gca, [fig_dir, '\laserOff_choices'], 'fig')
saveas(gca, [fig_dir, '\laserOff_choices'], 'eps')
save([fig_dir, '\laserOff_choices.mat'], 'laser_off')
xlswrite([fig_dir, '\laserOff_choices.xlsx'], laser_off)
        %% Laser Block
laser_onn(1,:)='ccmccmmcmcmmccmcmmcc'
laser_onn(2,:)='mmcmmcccmmccmcmmcccc'
laser_onn(3,:)='mccmmmmcmcmmcccmmcmm'
laser_onn(4,:)='cmcmmmmmmmmcmmmmcmmm'
laser_onn(5,:)='cmccccccmccmcmccccmm'
laser_onn(6,:)='mmcmccmcccccmcccmmcm'
laser_onn(7,:)='mmmcmmmmmmmccmccmmcm'
laser_onn(8,:)='mmmmcmcmccmmmmmmccmc'
laser_onn(9,:)='mmmmmmccmmmccmmcmcmc'
laser_onn(10,:)='mmcmmcccmmmmcmcmcmcc'
laser_onn(11,:)='mmmcmmmcmmmccmcmmmmc'
laser_onn(12,:)='mmmcmmmccmcmmmcmmmmm'
laser_onn(13,:)='mmmcmccmcmmmcmccmmcm'
laser_onn(14,:)='ccmmmmcmccmcmmmmmcmm'
laser_onn(14,:)='mcmccmccmcmmcmcmcmcc'
laser_onn(15,:)='mcmcmcmmcmcmcmcmmmcc'
laser_onn(16,:)='ccmcmmcmcmcmmcmcmmmm'
laser_onn(17,:)='ccccmcmcmcmcmcmccccc'
laser_onn(18,:)='mccmcmcmcmcmcmccmmcc'
laser_onn(19,:)='ccmmcmcmcmccmcmccmcm'
laser_onn(20,:)='cccmcmmcmcmcmmcccmcc'
laser_onn(21,:)='cmmmmmmmmmmmmmmmmmmm' % strio 14 
laser_onn(22,:)='ccccmcmccccmcccccccc'

for ind=1:20
    laser(ind)= sum(laser_onn(:,ind)=='c')/22*100;
end

figure
bar (laser)
ylim([0 70] )
xlim([0 21] )
saveas(gca, [fig_dir, '\laserOn_choices'], 'fig')
saveas(gca, [fig_dir, '\laserOn_choices'], 'eps')
save([fig_dir, '\laserOn_choices.mat'], 'laser_off')
xlswrite([fig_dir, '\laserOn_choices.xlsx'], laser_off)
close all;

























