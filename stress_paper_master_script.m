%% This is the main script used to generate figures for the paper.
%  The figures are saved in the following folders:
%
%  01) ../Final Stress Figures/Algorithm Visualizations
%
%  02) ../Final Stress Figures/Behavioural
%           - includes analysis of how neuron activity directly relates to
%           behaviour of animals during the task
%
%  03) ../Final Stress Figures/Classification
%           - includes figures relating to the classification of SWNs/HFNs
%
%  04) ../Final Stress Figures/Correlation Using Phasic Activity
%           - includes analyses correlating burst activity of pairs of neurons
%
%  05) ../Final Stress Figures/Example Individual Traces
%
%  06) ../Final Stress Figures/Firing Rate CDFs
%
%  07) ../Final Stress Figures/Model
%           - includes analysis of data generated by our model of the circuit
%
%  08) ../Final Stress Figures/Model Comparison
%           - includes comparison of model data and real data
%
%  09) ../Final Stress Figures/PV Experiment
%
%  10) ../Final Stress Figures/Response to Simultation
%           - includes analysis of orthodromic stimulation of DMS
%
%  11) ../Final Stress Figures/Stimulation Examples
%           - includes examples of individual neurons that respond to
%           stimulation
%
%  12) ../Final Stress Figures/Time of Peak Activity Line Plots
%           - includes analysis of peak activity of groups of neurons at
%           the individual and population level
%
%  13) ../Final Stress Figures/Traces
%
%  14) ../Final Stress Figures/Triplet
%           - includes an example of a triplet of neurons in which the
%           firing rate of the SWN affects the connectivity between the PLs
%           neuron and the striosome
%% Set up by adding all codes, data, and figure directories to the path
%  Additionally, load main database for the Control, Stress, and Stress2
%  groups. 
%  Note: Stress  -> Immobilization
%        Stress2 -> Foot Shock
if ~exist('loaded','var')
    addpath(genpath('../'),'-end');
    load('twdbs.mat');
    loaded = true;
end
dbs = {'control', 'stress', 'stress2'}; strs = {'Control', 'Stress', 'Stress2'}; 
twdbs = {twdb_control, twdb_stress, twdb_stress2};
neuron_types = {'PL Neurons', 'PLS Neurons', 'Striosomes', 'Matrix Neurons', 'HFNs', 'SWNs'};
clearvars -except min_num twdb_control twdb_stress twdb_stress2 dbs loaded dbs twdbs neuron_types strs
%% Root location of figures
ROOT_DIR = '../Final Stress Figures/';
%% Find indices in database corresponding to PL Neurons, PLs Neurons, 
%  Striosomes, Matrix Neurons, Short Width Neurons, and HFNs. 
%  We find indices corresponding to neurons recorded during any task ('all_ids')
%     and we find indices corresponding to neurons recorded only during the
%     cost benefit task ('cb_ids')
%  Indicies are stored in groups in the order dictacted by 'neuron_types'.
%     i.e. cb_ids{1} corresponds to indicies of PL Neurons in the CB task.
%  Additionally, neuron indices are segmented across experimental groups.
%  The order is the same as in 'dbs'.
%     i.e. cb_ids{6}{2} corresponds to indicies of HFNs in CB and in the
%     Stress (immobilization) group.

% The following variables indicate the minimum Final Michael Grade of each
% neuron type that we will analyze.
min_pls_fmg = -Inf;
min_plNotS_fmg = min_pls_fmg;
min_strio_fmg = -Inf;
min_matrix_fmg = min_strio_fmg;
min_hfn_fmg = 1;

% Find indices corresponding to each neuron type
[all_pls_ids, all_plNotS_ids, all_strio_ids, all_matrix_ids, ...
           all_swn_ids, all_swn_not_hfn_ids, all_hfn_ids] ...
           = find_neuron_ids(twdbs, 'ALL', [min_pls_fmg,min_plNotS_fmg,min_strio_fmg,min_matrix_fmg,min_hfn_fmg]);
[cb_pls_ids, cb_plNotS_ids, cb_strio_ids, cb_matrix_ids, ...
           cb_swn_ids, cb_swn_not_hfn_ids, cb_hfn_ids] ...
           = find_neuron_ids(twdbs, 'CB', [min_pls_fmg,min_plNotS_fmg,min_strio_fmg,min_matrix_fmg,min_hfn_fmg]);  
all_pl_ids = arrayfun(@(x) [all_pls_ids{x} all_plNotS_ids{x}],1:length(dbs),'uni',false);
cb_pl_ids = arrayfun(@(x) [cb_pls_ids{x} cb_plNotS_ids{x}],1:length(dbs),'uni',false);

% Combine the lists of indices into one cell array will indices for all
% neuron types.
all_ids = {all_pl_ids, all_pls_ids, all_strio_ids, all_matrix_ids, all_hfn_ids, all_swn_ids};
cb_ids = {cb_pl_ids, cb_pls_ids, cb_strio_ids, cb_matrix_ids, cb_hfn_ids, cb_swn_ids};
%% Traces of All Neuron Types During the Cost Benefit Task
generate_traces; close all;                                                                             % OK
%% CDFs and Bar Graphs of Firing Rate of Neurons Across Different Time Periods
generate_inTask_CDFs_bars; close all;                                                                   % OK
generate_nonInTask_CDFs_bars; close all;                                                                % OK
%% Analysis of PL baseline vs Strio/FSI baseline firing rate
generate_strio_response_to_swn; close all;                                                              % OK
response_to_pl_phasic_activity_swn_master_script; close all;                                            % OK
response_to_pl_phasic_activity_strio_master_script; close all;                                          % OK
%% Classification of SWNs and MSNs in DMS
fig_dir = [ROOT_DIR 'Clustering/'];
if ~exist(fig_dir,'dir')
    mkdir(fig_dir);
end
generate_swn_classification_figures; close all;                                                         % OK
generate_neruon_distributions; close all;                                                               % OK
generate_swn_proportions; close all;                                                                    % OK
generate_fsi_vs_effect_of_stress; close all;                                                            % OK
%% Line Plots Showing Activity of Individual Neurons During the Cost Benefit Task
% Remove neurons with no spikes from analysis
cb_swn_ids{1} = setdiff(cb_swn_ids{1}, [3863 3875]);
cb_ids = {cb_pl_ids, cb_pls_ids, cb_strio_ids, cb_matrix_ids, cb_hfn_ids, cb_swn_ids};
generate_line_plots; close all;                                                                         % OK
% Add the removed neurons back; they are still okay for other analyses
cb_swn_ids{1} = [cb_swn_ids{1}, 3863, 3875];
cb_ids = {cb_pl_ids, cb_pls_ids, cb_strio_ids, cb_matrix_ids, cb_hfn_ids, cb_swn_ids};
%% Analysis of Stimulation Experiments
generate_stimulation_plots; close all;                                                                  % OK
generate_antidromic_orthodromic_example; close all;                                                     % OK
%% Creation and Analysis of Hodgekin Huxley Model for the Circuit
% Generate simulation data - this is commented out because this can take a
% LONG time.
% pls_strio_gsyn=.25;pls_swn_gsyn=1;swn_strio_gsyn=1.3;stress_gsyn_factor=30;num_reps=40;
% model;
% pls_strio_gsyn=.25;pls_swn_gsyn=1;swn_strio_gsyn=1.3;stress_gsyn_factor=40;num_reps=40;
% model;

% Load simulation data
load('spike_times_1000_30.mat');
pls_spikes_stress = pls_spikes{2};
strio_spikes_stress = strio_spikes{2};
swn_spikes_stress = swn_spikes{2};
Ts_stress = Ts{ 2};
load('spike_times_1000_40.mat');
pls_spikes{2} = pls_spikes_stress;
strio_spikes{2} = strio_spikes_stress;
swn_spikes{2} = swn_spikes_stress;
Ts{2} = Ts_stress;
% Analyze simulation data
generate_model_analysis; close all;                                                                     % OK
generate_real_model_comparison; close all;                                                              % OK
generate_model_stimulation; close all;                                                                  % OK
%% PV Experiment
pv_simple; close all;                                                                                   % OK
% Generate examples of neurons under the influence of the excitatory and
% inhibitory viruses.

% Initialize parameters
p_threshold = 1/1000000.0;                                                                              % OK
dendritic_filter = true;
min_firing_rate = 0.05;
min_peak_height = 80;
min_final_michael_grade = -Inf;
% Make histogram showing response to stimulation for the inhibitory virus
load('../Final Stress Data/PV Experiment/twdb_inhibition.mat');
[~, inhibited_ids, ~, ~, inhibited_peakToValley_lengths, inhibited_firing_rates, inhibited_peak_heights, inhibited_MSWs] = ...
    find_responders_simple(twdb, 740, 'trough', 'Tim', p_threshold, dendritic_filter, min_firing_rate, min_peak_height, min_final_michael_grade, true, ROOT_DIR);
% Make histogram showing response to stimulation for the excitatory virus
load('../Final Stress Data/PV Experiment/twdb_excitation.mat');
[stimulated_ids, ~, ~, ~, stimulated_peakToValley_lengths, stimulated_firing_rates, stimulated_peak_heights, stimulated_MSWs] = ...
    find_responders_simple(twdb, 460, 'peak', 'Tim', p_threshold, dendritic_filter, min_firing_rate, min_peak_height, min_final_michael_grade, true, ROOT_DIR);
%% Figures to Visualize Custom Algorithms
generate_entropy_windows_example; close all;                                                            % OK
generate_phasic_time_delays_example; close all;                                                         % OK
generate_time_delays_distribution_examples; close all;                                                  % OK
generate_burst_detection_example; close all;                                                            % OK
%% Example of A Possible Triplet of Connected Neurons
generate_triplet_example; close all;                                                                    % OK