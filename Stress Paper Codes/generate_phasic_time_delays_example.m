%% This script generates figure visualizing the detection of correlated pairs
%  of bursts, correlated pairs of burst->inhibition periods, and the
%  detection of tonic periods.
%% Visualization of Detection of Correlated Bursts
f = figure;
max_delay = 1.5;

% Plot first PLs burst
pls_burst1_start = .3;
pls_burst1_end = .4;
pls_burst1_num_spikes = 20;
pls_burst1 = linspace(pls_burst1_start, pls_burst1_end,pls_burst1_num_spikes)';

pls_spikes = pls_burst1;
line([pls_spikes, pls_spikes]', repmat([1-.4; 1-.1],[1,length(pls_spikes)]),'Color','black');
xlim([0 2.5]); ylim([0.5 1]);

patch([pls_burst1_start, pls_burst1_end, pls_burst1_end, pls_burst1_start],...
    [1-.4, 1-.4, 1-.1, 1-.1], 'red', 'FaceColor', 'none', 'EdgeColor', 'red', 'LineWidth',2)

patch([pls_burst1_end, pls_burst1_end+max_delay, pls_burst1_end+max_delay, pls_burst1_end],...
    [1-.4, 1-.4, 1-.9, 1-.9], 'yellow', 'FaceColor', 'yellow', 'EdgeColor', 'none', 'LineWidth',1);

% Plot first correlated striosomal burst
strio_burst1_start = .8;
strio_burst1_end = .85;
strio_burst1_num_spikes = 10;
strio_burst1 = linspace(strio_burst1_start, strio_burst1_end,strio_burst1_num_spikes)';

strio_spikes = strio_burst1;
line([strio_spikes, strio_spikes]', repmat([1-.9; 1-.6],[1,length(strio_spikes)]),'Color','black');

patch([strio_burst1_start, strio_burst1_end, strio_burst1_end, strio_burst1_start],...
    [1-.9, 1-.9, 1-.6, 1-.6], 'red', 'FaceColor', 'none', 'EdgeColor', 'blue', 'LineWidth',2);
line([pls_burst1_end, pls_burst1_end], [1-.4, 1-.6], 'Color','black', 'LineWidth',2);
arrow([pls_burst1_end,1-.6], [strio_burst1_start, 1-.6],'LineWidth',2);

% Plot second correlated striosomal burst
strio_burst1_start = 1.5;
strio_burst1_end = 1.5 + .05/2;
strio_burst1_num_spikes = 5;
strio_burst1 = linspace(strio_burst1_start, strio_burst1_end,strio_burst1_num_spikes)';

strio_spikes = strio_burst1;
line([strio_spikes, strio_spikes]', repmat([1-.9; 1-.6],[1,length(strio_spikes)]),'Color','black');
xlim([0 2.5]); ylim([0 1]);

patch([strio_burst1_start, strio_burst1_end, strio_burst1_end, strio_burst1_start],...
    [1-.9, 1-.9, 1-.6, 1-.6], 'red', 'FaceColor', 'none', 'EdgeColor', 'blue', 'LineWidth',2);

line([pls_burst1_end, pls_burst1_end], [1-.4, 1-.6], 'Color','black', 'LineWidth',2);
arrow([pls_burst1_end,1-.6+.05], [strio_burst1_start, 1-.6+.05],'LineWidth',2);

xlabel('Time (s)');

% Plot a patch indicating time period we are searching for correlated
% bursts in
strio_burst1_start = .1;
strio_burst1_end = .1 + .05/2;
strio_burst1_num_spikes = 5;
strio_burst1 = linspace(strio_burst1_start, strio_burst1_end,strio_burst1_num_spikes)';

strio_spikes = strio_burst1;
line([strio_spikes, strio_spikes]', repmat([1-.9; 1-.6],[1,length(strio_spikes)]),'Color','black');
xlim([0 2.5]); ylim([0 1]);

patch([strio_burst1_start, strio_burst1_end, strio_burst1_end, strio_burst1_start],...
    [1-.9, 1-.9, 1-.6, 1-.6], 'red', 'FaceColor', 'none', 'EdgeColor', 'blue', 'LineWidth',2);

% Plot first non correlated striosomal burst
strio_burst1_start = 2.3;
strio_burst1_end = 2.3 + .05/2;
strio_burst1_num_spikes = 5;
strio_burst1 = linspace(strio_burst1_start, strio_burst1_end,strio_burst1_num_spikes)';

strio_spikes = strio_burst1;
line([strio_spikes, strio_spikes]', repmat([1-.9; 1-.6],[1,length(strio_spikes)]),'Color','black');
xlim([0 2.5]); ylim([0 1]);

patch([strio_burst1_start, strio_burst1_end, strio_burst1_end, strio_burst1_start],...
    [1-.9, 1-.9, 1-.6, 1-.6], 'red', 'FaceColor', 'none', 'EdgeColor', 'blue', 'LineWidth',2);


% Plot second non correleated striosomal burst
strio_burst1_start = 1.5;
strio_burst1_end = 1.5 + .05/2;
strio_burst1_num_spikes = 5;
strio_burst1 = linspace(strio_burst1_start, strio_burst1_end,strio_burst1_num_spikes)';

strio_spikes = strio_burst1;
line([strio_spikes, strio_spikes]', repmat([1-.9; 1-.6],[1,length(strio_spikes)]),'Color','black');
xlim([0 2.5]); ylim([0 1]);

patch([strio_burst1_start, strio_burst1_end, strio_burst1_end, strio_burst1_start],...
    [1-.9, 1-.9, 1-.6, 1-.6], 'red', 'FaceColor', 'none', 'EdgeColor', 'blue', 'LineWidth',2);

fig_dir = [ROOT_DIR 'Algorithm Visualizations/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveas(f,[fig_dir 'Correlated Bursts'], 'fig');
saveas(f,[fig_dir 'Correlated Bursts'], 'epsc2');
saveas(f,[fig_dir 'Correlated Bursts'], 'jpg');

%% Visualization of Detection of Bursts Correlated With an Inhibition Period
f = figure; subplot(3,1,1);

% Plot first PLs burst
pls_burst1_start = .3;
pls_burst1_end = .4;
pls_burst1_num_spikes = 20;
pls_burst1 = linspace(pls_burst1_start, pls_burst1_end,pls_burst1_num_spikes)';

pls_spikes = pls_burst1;
line([pls_spikes, pls_spikes]', repmat([1-.4; 1-.1],[1,length(pls_spikes)]),'Color','black');
xlim([0 2.5]); ylim([0.5 1]);

patch([pls_burst1_start, pls_burst1_end, pls_burst1_end, pls_burst1_start],...
    [1-.4, 1-.4, 1-.1, 1-.1], 'red', 'FaceColor', 'none', 'EdgeColor', 'red', 'LineWidth',2)

all_strio_spikes = [];
% Strio random spikes, high fr
strio_spikes = unifrnd(0,.3,10,1); all_strio_spikes = [all_strio_spikes; strio_spikes];
line([strio_spikes, strio_spikes]', repmat([1-.9; 1-.6],[1,length(strio_spikes)]),'Color','black');
strio_spikes = unifrnd(1,2.5,30,1); all_strio_spikes = [all_strio_spikes; strio_spikes];
line([strio_spikes, strio_spikes]', repmat([1-.9; 1-.6],[1,length(strio_spikes)]),'Color','black');
% Strio random spikes, low fr
strio_spikes = unifrnd(.4,1,3,1); all_strio_spikes = [all_strio_spikes; strio_spikes];
line([strio_spikes, strio_spikes]', repmat([1-.9; 1-.6],[1,length(strio_spikes)]),'Color','black');

% First strio burst
% strio_burst1_start = 1;
xlim([0 2.5]); ylim([0 1]);


all_strio_spikes = sort(all_strio_spikes);
ISI_thresholds = [mean(diff(all_strio_spikes)), mean(diff(all_strio_spikes))];
subplot(3,1,2);
hold on;
stairs(all_strio_spikes(1:end-1),log10(diff(all_strio_spikes)),'LineWidth',1,'Color','red');

[xb,yb] = stairs(all_strio_spikes(1:end-1),log10(diff(all_strio_spikes)));
aboveThreshold = (yb >= log10(ISI_thresholds(1)));
bottomLine = yb;
topLine = yb;
bottomLine(aboveThreshold) = NaN;
topLine(~aboveThreshold) = NaN;
plot(xb,bottomLine,'r','LineWidth',2);
plot(xb,topLine,'b','LineWidth',2);
line([0 2.5], log10(ISI_thresholds),'LineWidth',2,'Color','black');
xlim([0 2.5]);
xlabel('Time (s)'); ylabel('log ISI (s)');

hold off;

% arrow to strio inhibition end
subplot(3,1,1);
all_strio_spikes = all_strio_spikes(1:end-1);
strio_burst1_start = all_strio_spikes(find(diff([all_strio_spikes; 2.5]) < ISI_thresholds(1) & all_strio_spikes > pls_burst1_end,1));
line([pls_burst1_end, pls_burst1_end], [1-.4, 1-.6], 'Color','black', 'LineWidth',2,'LineStyle','-.');
arrow([pls_burst1_end,1-.6], [strio_burst1_start, 1-.6],'LineWidth',2,'LineStyle','-.');

fig_dir = [ROOT_DIR 'Algorithm Visualizations/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveas(f,[fig_dir 'Correlated Burst Inhibition Periods'], 'fig');
saveas(f,[fig_dir 'Correlated Burst Inhibition Periods'], 'epsc2');
saveas(f,[fig_dir 'Correlated Burst Inhibition Periods'], 'jpg');
%% Visualization of Detection of Tonic Periods
f = figure;

% First pls burst
pls_burst1_start = .3;
pls_burst1_end = .4;
pls_burst1_num_spikes = 20;
pls_burst1 = linspace(pls_burst1_start, pls_burst1_end,pls_burst1_num_spikes)';

pls_spikes = pls_burst1;
line([pls_spikes, pls_spikes]', repmat([1-.4; 1-.1],[1,length(pls_spikes)]),'Color','black');
xlim([0 2.5]); ylim([0.5 1]);

patch([pls_burst1_start, pls_burst1_end, pls_burst1_end, pls_burst1_start],...
    [1-.4, 1-.4, 1-.1, 1-.1], 'red', 'FaceColor', 'none', 'EdgeColor', 'red', 'LineWidth',2)


% Second pls burst
pls_burst1_start = 1.75;
pls_burst1_end = 1.8;
pls_burst1_num_spikes = 15;
pls_burst1 = linspace(pls_burst1_start, pls_burst1_end,pls_burst1_num_spikes)';

pls_spikes = pls_burst1;
line([pls_spikes, pls_spikes]', repmat([1-.4; 1-.1],[1,length(pls_spikes)]),'Color','black');
xlim([0 2.5]); ylim([0.5 1]);

patch([pls_burst1_start, pls_burst1_end, pls_burst1_end, pls_burst1_start],...
    [1-.4, 1-.4, 1-.1, 1-.1], 'red', 'FaceColor', 'none', 'EdgeColor', 'red', 'LineWidth',2)

% Random pls spikes
pls_spikes = unifrnd(0,2.5,20,1); 
pls_spikes = pls_spikes(pls_spikes < .3 | pls_spikes > .4 | pls_spikes < 1.75 | pls_spikes > 1.8);
line([pls_spikes, pls_spikes]', repmat([1-.4; 1-.1],[1,length(pls_spikes)]),'Color','black');

% Tonic period
tonic_period_start = .4 + .2;
tonic_period_end = 1.75 - .2;
p = patch([tonic_period_start, tonic_period_end, tonic_period_end, tonic_period_start],...
    [1-.4, 1-.4, 1-.1, 1-.1], 'yellow', 'FaceColor', 'yellow', 'EdgeColor', 'none', 'LineWidth',2);
uistack(p,'bottom');

% Arrow showing 'clearence time' of 200 ms before and after bursts
arrow([.4, 1-.4], [.4+.2, 1-.4],'Length',10); arrow([.4+.2, 1-.4], [.4, 1-.4],'Length',10);
text(.4, 1-.45, '200 ms');
arrow([1.75, 1-.4], [1.75-.2, 1-.4],'Length',10); arrow([1.75-.2, 1-.4], [1.75, 1-.4],'Length',10);
text(1.57, 1-.45, '200 ms');

xlim([0 2.5]); ylim([.4  1]);

fig_dir = [ROOT_DIR 'Algorithm Visualizations/'];
if ~exist(fig_dir, 'dir')
    mkdir(fig_dir);
end
saveas(f,[fig_dir 'Tonic Period Identification'], 'fig');
saveas(f,[fig_dir 'Tonic Period Identification'], 'epsc2');
saveas(f,[fig_dir 'Tonic Period Identification'], 'jpg');
