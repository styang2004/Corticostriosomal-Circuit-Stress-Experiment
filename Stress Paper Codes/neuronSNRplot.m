function neuronSNRplot(twdb,DBtype,plot_,start,check_id, ROOT_DIR)
%NEURONSNRPLOT makes a figure that visualizes features of the mean spike
%waveform of a neuron given by check_id.
%
%INPUTS:
%twdb(struct array)- DB to be used (for fast loading purposes)
%DBtype(integer)- DB to be used (2:Stress 2, others not included because lack of
%data) (not fast loading) 
%plot_(integer) - tells the function what type of plot (0:none, 1:velocity and
%acceleration, 2: snr parameters)
%start(integer) - to observe a specific neuron one can start in the desired index (1
%for checking all)
%check_ids(array or integer) - specific neuron IDs to be observed (0 to observe all)
%ROOT_DIR - the directory to save the figure

%% DataBase Search
if DBtype == 2
    DB_string = 'Stress 2';
elseif DBtype == 0
    DB_string = 'Control';
elseif DBtype == 1
    DB_string = 'Stress';
end
%% Debugging
%Specific neuron IDs to check. If not, check all
check = check_id;
%% SNR Parameters
%values for later use
peak_width = zeros(1,length(check)); %width of peak
valley_width = zeros(1,length(check)); %width of valley after peak
half_peak_width = zeros(1,length(check)); %half peak width
peakRise_slope = zeros(1,length(check)); %slope of the peak rise
peakFall_slope = zeros(1,length(check)); %slope of the peak fall
valleyRise_slope = zeros(1,length(check)); %slope of the rise of the valley after peak
snr_nan = zeros(1,length(check)); %indicates if any of the parameters above are not able to be calculated
bad_ids = [];

%% Signal To Noise Ratio

for n=start:length(check) %starts at input index
    %% Spike Waveform with Interpolation, Velocity and Acceleration
    
    %Neuron Parameters
    id = check(n);
    tetrodeID = twdb(id).tetrodeID;
    neuronNum = str2double(twdb(id).neuronN);
    sessionDir = twdb(id).sessionDir;
    
    %Load Mean Spike Wafeform for Neurons
    sessionDir = strrep(sessionDir,'/Users/Seba/Dropbox/UROP/stress_project','../Final Stress Data/Data');
    sessionDir = strrep(sessionDir,'D:\UROP','../Final Stress Data/Data');
    tetrodeInfo = load([sessionDir,'/',tetrodeID,'_info.mat']);
    means = tetrodeInfo.means;
    if neuronNum > max(size(means))
        continue
    end
    MSW = means{1,neuronNum};%Mean Spike Waveform for Neuron
    
    %Obtaining Closest Recording from Tetrode
    dif = zeros(1,size(MSW,1));
    for i=1:size(MSW,1)
        dif(i) = max(MSW(i,:)) - min(MSW(i,:));%Highest difference between peak and valley
    end
    [~,I] = max(dif);%Index for closest recording
    
    
    %Interpolation
    x = 1:150;
    s = size(MSW);
    if s(2) ~= 150
        MSW = MSW';
    end
    v = MSW(I,x);%Closest Recording to Tetrode
    v = dg_smoothFreqTrace(v, 3);
    xq = 1:0.25:150;%values for interpolation
    vq = interp1(x,v,xq,'spline');%interpolated waveform
    sample_tops = dg_findFlattops(abs(vq),0.0015);%Interpolation Peaks and Valleys
    
    %Velocity of Spike w/ Peaks and Valleys    
    vel = [NaN diff(vq)];
    smooth_vel = dg_smoothFreqTrace(vel, 50); %Smoothing of Velocity
    vel_tops = dg_findFlattops(abs(smooth_vel),0.0015);%peaks and valleys of velocity
    
    %Acceleration
    acc = [NaN diff(smooth_vel)];
    acc_tops = dg_findFlattops(abs(acc),0.0015);%peaks and valleys of acceleration
    
    %% Parameters for Signal to Noise Ratio(SNR)
    
    [peak,peak_I] = max(vq);%highest point in the waveform (peak)
    peak_topsI = find(sample_tops==peak_I); %peak tops index
    if isempty(peak_topsI)
        peak_topsI = 0;
    end
    [acc_min,acc_minI] = min(acc); %tops index
    min_acc_topsI = find(acc_tops==acc_minI); %minimum acceleration index
    [vel_max,vel_maxI] = max(smooth_vel); %tops index
    vel_max_topsI = find(vel_tops==vel_max); %peak tops index
    [vel_min,vel_minI] = min(smooth_vel); %tops index
    
    %Spike Peak Width
    %Using waveform acceleration changes to find peak start and peak end
    if length(acc_tops)>=(min_acc_topsI+1) && peak_topsI>1
        peak_startI = sample_tops(peak_topsI-1);
        % first acc top after peak is peak end
        acc_tops_after_peakI = acc_tops(acc_tops>peak_I);
        for a = acc_tops_after_peakI'
            if acc(a) < 0
                continue
            else
                acc_top_after_peakI = a;
                break
            end
        end
%         peak_endI = acc_tops(min_acc_topsI+1);
        peak_endI = acc_top_after_peakI;
        peak_width(n) = xq(peak_endI)-xq(peak_startI);
    else
        peak_width(n) = NaN;
        peak_startI = NaN;
        peak_endI = NaN;
        snr_nan(n) = NaN;
    end
    
    %After Spike Valley Width
    %Using waveform acceleration changes to find peak end and valley end
    if ~isnan(peak_endI)
        valley_endI = vel_tops(find(vel_tops>peak_endI,1));
        if ~isempty(valley_endI)
            valley_width(n) = xq(valley_endI)-xq(peak_endI);
        else
            valley_width(n) = NaN;
            snr_nan(n) = NaN;
        end
    else 
        valley_width(n) = NaN;
        snr_nan(n) = NaN;
    end
    
    %Half Peak Width
    %Using waveform velocity changes to find half peak start and half peak end
    %Maximum Velocity corresponds to half peak start
    %Minimum Velocity corresponds to halp peak end
    if acc_minI>vel_maxI && acc_minI<vel_minI && vel_maxI>peak_startI && peak_endI>vel_minI
        half_peak_width(n) = xq(vel_minI)-xq(vel_maxI);
    else
        half_peak_width(n) = NaN;
        snr_nan(n) = NaN;
    end
    
    %Peak Rise and Fall Slope
    if ~isnan(half_peak_width(n)) && ~isnan(peak_width(n))
        %Slope from peak start to half peak start
        peakRise_slope(n) = (vq(vel_maxI)-vq(peak_startI))/(xq(vel_maxI)-xq(peak_startI));
        %Slope from peak to half peak end
        peakFall_slope(n) = (vq(vel_minI)-vq(peak_I))/(xq(vel_minI)-xq(peak_I)); 
    else
        peakRise_slope(n) = NaN;
        peakFall_slope(n) = NaN;
        snr_nan(n) = NaN;
    end
    
    %Valley Rise Slope and Peak to Valley Width
    if ~isnan(valley_width(n))
        [~,min_valleyI] = min(vq(peak_I:end));
        min_valleyI = min_valleyI + peak_I-1;
        %Slope from minimum point of valley to valley end
        valleyRise_slope(n) = (vq(valley_endI)-vq(min_valleyI))/(xq(valley_endI)-xq(min_valleyI));
        %Length from Highest Peak to Lowest Valley Point
        peakToValley_length(n) = xq(min_valleyI)-xq(peak_I);
    else
        min_valleyI = NaN;
        valleyRise_slope(n) = NaN;
        peakToValley_length(n) = NaN;
        snr_nan(n) = NaN;
    end
    
    %Full Spike Width
    %Length from start of peak to end of valley
    if ~isnan(peak_width(n)) && ~isnan(valley_width(n))
        full_spike_width(n) = xq(valley_endI)-xq(peak_startI);
    else
        full_spike_width(n) = NaN;
        snr_nan(n) = NaN;
    end
    
    %% Bad Neuron Detection
    %Detection of neurons that have parameters that are already determined
    %to be noise parameters
    
    %Small Peak Threshold
    % Any waveform under 60 is considered unusable
    if peak<60
        bad_ids = [bad_ids n];
    end
    
    %Dendritic Spike Detection
    %Detects dendritic spikes (valley before peak has very sharp slope)
    %using velocity changes before the peak
    if vel_max_topsI>1
        den_vel = abs(smooth_vel(vel_tops(vel_max_tops-1)));
        %if the velocity of the valley is to big then dendritic spike detected
%        if den_vel>%set parameter here
              %if dentridtic spike containing neuron is to be considered a bad neuron
%             bad_ids = [bad_ids n];
%        end
    end
    
    if 1.5*min(vq(1:peak_I)) < min(vq(peak_I+1:end))
        bad_ids = [bad_ids n];
        err = '!!!';
    else
        err = 'good';
    end
    
    % Firing Rates and ISI
    tetrodefile=fullfile(sessionDir,strcat(tetrodeID,'.mat'));
    tetrodeMat=load(tetrodefile);
    
    list=tetrodeMat.output(:,1);
    tstamps=list(tetrodeMat.output(:,2)==neuronNum);
    FiringRate=1/mean(diff(tstamps));
    MedianISI=median(diff(tstamps));
    MeanMedianRatio=log(1/FiringRate/MedianISI);
    
    firing_rates(n) = FiringRate; %twdb(id).inRun_firing_rate; % twdb(id).firing_rate
    if ~isnan(peak_I) && ~isnan(min_valleyI)
        max_min_ratio(n) = log(vq(peak_I)/-vq(min_valleyI));
        disp(max_min_ratio(n));
        %         max_min_ratio(n) = log(-vq(min_valleyI));
    else
        max_min_ratio(n) = NaN;
        snr_nan(n) = NaN;
    end
    
%     first = find(abs(vq) < .05 & xq < xq(peak_I),1,'last');
%     last = find(abs(vq) < .05 & xq > xq(peak_I),1);
%     max_min_ratio(n) = xq(last) - xq(first);
    %% Plotting 
    if plot_ == 1
        %Plots Interpolated Sample Waveform, Velocity and Acceleration with
        %significant points
        f = figure;
        hold on

        x1 = plot(xq,vq,'b'); %interpolated waveform
        x2 = plot(xq(sample_tops),vq(sample_tops),'bo','MarkerFaceColor','b');%peaks and valleys
        
        v1 = plot(xq,10*smooth_vel-238,'r'); %velocity scaled by 40 to be visible
        v2 = plot(xq(vel_tops),vq(vel_tops),'ro','MarkerFaceColor','r');%peaks and valleys
        plot(xq(vel_tops),10*smooth_vel(vel_tops)-238,'ro','MarkerFaceColor','r');

        plot([xq(vel_maxI) xq(vel_maxI)], [-200 vq(vel_maxI)], '--', 'Color', 'm', 'LineWidth', 2);
        plot([xq(vel_minI) xq(vel_minI)], [-200 vq(vel_minI)], '--', 'Color', 'm', 'LineWidth', 2);
        l1 = line([xq(vel_maxI) xq(vel_minI)], [-195 -195], 'Color', 'm', 'LineWidth', 2);
        
        l2 = plot([xq(peak_I),xq(min_valleyI)],[vq(peak_I),vq(peak_I)],'g','LineWidth',3);
        plot([xq(min_valleyI),xq(min_valleyI)],[vq(peak_I),vq(min_valleyI)],'g--','LineWidth',3);
        
        plot([xq(min_valleyI) xq(min_valleyI)], [-200 vq(min_valleyI)], '--', 'Color', 'c', 'LineWidth', 2);
        plot([xq(valley_endI) xq(valley_endI)], [-200 vq(valley_endI)], '--', 'Color', 'c', 'LineWidth', 2);
        l3 = line([xq(min_valleyI) xq(valley_endI)], [-195 -195], 'Color', 'c', 'LineWidth', 2);

        hold off
        title([DB_string,' ',tetrodeID,' Neuron #',twdb(id).neuronN])
        legend([x1, x2, v1, v2, l1, l2, l3], ...
        'Samples','Sample Tops', 'Velocity', 'Velocity Tops', 'Half Peak Width', 'Peak To Valley Length', 'Valley Width')

        disp(id);
        saveas(f,[ROOT_DIR 'Classification/Sample Spike Waveform With Features.fig']);
        saveas(f,[ROOT_DIR 'Classification/Sample Spike Waveform With Features.eps'],'epsc2');
        saveas(f,[ROOT_DIR 'Classification/Sample Spike Waveform With Features.jpg'],'jpg');        
    end
end