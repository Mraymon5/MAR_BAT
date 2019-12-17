
% %Load data
% load fisheriris
% 
% %The column vector, species, consists of iris flowers of three different
% %species: setosa, versicolor, virginica. The double matrix meas consists of
% %four types of measurements on the flowers: the length and width of sepals
% %and petals in centimeters, respectively.
% t = table(species,meas(:,1),meas(:,2),meas(:,3),meas(:,4),...
% 'VariableNames',{'species','meas1','meas2','meas3','meas4'});
% Meas = table([1 2 3 4]','VariableNames',{'Measurements'});

%Flip through structure and create new structure with all data wanted
%Establish number of days to analyze for loops
days = fieldnames(analyze_struct); trials =90;
num_animals = size(fieldnames(analyze_struct.(cell2mat(days(1)))),1); %establish number of animals (assuming at least one day)
all_animals = fieldnames(analyze_struct.(cell2mat(days(1))));
lick_data=[];latency_data=[];

%Flip through structure and grab metrics 
%Initiate loop and store data by (day,animal,data)
for day=1:size(days,1)
    animals = fieldnames(analyze_struct.(cell2mat(days(day))));
    for animal=1:size(animals,1)
        %Dataset Variable
        data_set = analyze_struct.(cell2mat(days(day))).(cell2mat(animals(animal)));
        
        %Get dose info (this will only occur on test days)
        day_read = cell2mat(days(day));
        if day_read(end-3:end-1)=='DAY'
            day_num = str2num(day_read(end:end));
            dose(day_num+1,animal) = str2num(regexprep(data_set.dose,'(\(|\))','')); %extracts only the numeric values; the added two is to account for habdays
        end
        
        if day==1
            dose_col = 1; %Assign data to first column
            %lick_data(end+1:(animal*trials),1) = data_set.trial_data(:,6);
        elseif str2num(regexprep(data_set.dose,'(\(|\))','')) == 0.05
            dose_col = 2;
        elseif str2num(regexprep(data_set.dose,'(\(|\))','')) == 0.10
            dose_col = 3;     
        elseif str2num(regexprep(data_set.dose,'(\(|\))','')) == 0.20
            dose_col = 4;     
        end
        
        %Establish start row based on animal
        start_row=trials*(animal-1)+1;
        
        %Place data in appropriate place (columns = doses ascending, rows =
        %trials by animal)
        lick_data(start_row:start_row+(trials-1),dose_col) = data_set.trial_data(:,6);
        latency_data(start_row:start_row+(trials-1),dose_col) = data_set.trial_data(:,7);
    end
end  

%Create mean arrays
n = trials; mean_lick_session =[];first_lick_latency =[];cummulative_latency=[];
for dose=1:size(lick_data,2)
    mean_lick_session(:,dose) = arrayfun(@(i) mean(lick_data(i:i+n-1,dose)),1:n:length(lick_data)-n+1)';
    for animal=1:size(animals,1)
        %Establish start row based on animal
        start_row=trials*(animal-1)+1;
        animal_lat_data = latency_data(start_row:start_row+(trials-1),dose);
        lat_log = find(animal_lat_data~=60000);
        first_lick_latency(animal,dose) = animal_lat_data(lat_log(1)); %Get first latency lick in session
        cummulative_latency(animal,dose) = sum(animal_lat_data); 
    end
end

%Create Box/Whisker plot for Lick data (replace 0s with NaN)
%lick_data(lick_data==0) = NaN; %Replace 0s with NaN
figure; boxplot(lick_data); xlabel('Nicotine Dose (mg/kg)'); ylabel('Lick count');
title('Nicotine Dose Response Effect on Lick Count');
%filtered_data = lick_data[~np.isnan(lick_data)];

%Grab binned data
binning_set = lick_data; %duplicate data set to cross check
trial_binning = 15;
n = trial_binning;  % grab first n rows in each data set
c = size(binning_set,2);  % total columns
binned_lick_matrix = zeros(trials/trial_binning,num_animals*trial_binning,size(binning_set,2)); %binsXbin*animalsXdoses

%flip through and grab data to store
for bin=1:trials/trial_binning
    r = length(binning_set); % total rows
    bin_fix = bin-1;
    d = trials-(trial_binning*bin_fix); % rows in each data set 
    
    if bin==6
        binned_lick_matrix(bin,:,:)= binning_set(:,:); %store data
    else
        binned_lick_matrix(bin,:,:)= binning_set(mod(1:r,d)<=n & mod(1:r,d)>0,:); %store data
        binning_set(mod(1:r,d)<=n & mod(1:r,d)>0,:) =[]; %remove the data you just stored
    end
end

%Create grouping sets
dose_1_bin =binned_lick_matrix(1:6,:,1)';
dose_2_bin =binned_lick_matrix(1:6,:,2)';
dose_3_bin =binned_lick_matrix(1:6,:,3)';
dose_4_bin =binned_lick_matrix(1:6,:,4)';
%figure(3); boxplot(dose_1_bin); %Plots 0.0mg/kg dose for first 15 trials

%Plots grouped boxplots with dose as grouping variable
g1=[dose_1_bin(:,1), dose_2_bin(:,1), dose_3_bin(:,1), dose_4_bin(:,1)];
v1=[repmat('A',1,numel(dose_1_bin(:,1))),repmat('B',1,numel(dose_2_bin(:,1))),repmat('C',1,numel(dose_3_bin(:,1))),repmat('D',1,numel(dose_4_bin(:,1)))];

g2=[dose_1_bin(:,2), dose_2_bin(:,2), dose_3_bin(:,2), dose_4_bin(:,2)];
v2=[repmat('A',1,numel(dose_1_bin(:,2))),repmat('B',1,numel(dose_2_bin(:,2))),repmat('C',1,numel(dose_3_bin(:,2))),repmat('D',1,numel(dose_4_bin(:,2)))];

g3=[dose_1_bin(:,3), dose_2_bin(:,3), dose_3_bin(:,3), dose_4_bin(:,3)];
v3=[repmat('A',1,numel(dose_1_bin(:,3))),repmat('B',1,numel(dose_2_bin(:,3))),repmat('C',1,numel(dose_3_bin(:,3))),repmat('D',1,numel(dose_4_bin(:,3)))];

g4=[dose_1_bin(:,4), dose_2_bin(:,4), dose_3_bin(:,4), dose_4_bin(:,4)];
v4=[repmat('A',1,numel(dose_1_bin(:,4))),repmat('B',1,numel(dose_2_bin(:,4))),repmat('C',1,numel(dose_3_bin(:,4))),repmat('D',1,numel(dose_4_bin(:,4)))];

g5=[dose_1_bin(:,5), dose_2_bin(:,5), dose_3_bin(:,5), dose_4_bin(:,5)];
v5=[repmat('A',1,numel(dose_1_bin(:,5))),repmat('B',1,numel(dose_2_bin(:,5))),repmat('C',1,numel(dose_3_bin(:,5))),repmat('D',1,numel(dose_4_bin(:,5)))];

g6=[dose_1_bin(:,6), dose_2_bin(:,6), dose_3_bin(:,6), dose_4_bin(:,6)];
v6=[repmat('A',1,numel(dose_1_bin(:,6))),repmat('B',1,numel(dose_2_bin(:,6))),repmat('C',1,numel(dose_3_bin(:,6))),repmat('D',1,numel(dose_4_bin(:,6)))];

G=[g1,g2,g3,g4,g5,g6];
vg1 = [repmat('1',1,numel(v1)),repmat('2',1,numel(v2)),repmat('3',1,numel(v3)),repmat('4',1,numel(v4)),repmat('5',1,numel(v5)),repmat('6',1,numel(v6))];
vg2=[v1,v2,v3,v4,v5,v6];

figure(666); hold on; boxplot(G', {vg1';vg2'}, 'factorseparator',1 , 'factorgap',30,...
    'colorgroup',vg2','labelverbosity','majorminor'); title('Nicotine Effect on Lick Count');
ylabel('Lick Count');xlabel([num2str(trial_binning) '- trial bins']);

%Plots grouped boxplots with binning as grouping variable
g1=[dose_1_bin(:,1), dose_1_bin(:,2), dose_1_bin(:,3), dose_1_bin(:,4), dose_1_bin(:,5), dose_1_bin(:,6)];
v1=[repmat('A',1,numel(dose_1_bin(:,1))),repmat('B',1,numel(dose_1_bin(:,2))),repmat('C',1,numel(dose_1_bin(:,3))),repmat('D',1,numel(dose_1_bin(:,4))),repmat('E',1,numel(dose_1_bin(:,5))),repmat('F',1,numel(dose_1_bin(:,6)))];

g2=[dose_2_bin(:,1), dose_2_bin(:,2), dose_2_bin(:,3), dose_2_bin(:,4), dose_2_bin(:,5), dose_2_bin(:,6)];
v2=[repmat('A',1,numel(dose_2_bin(:,1))),repmat('B',1,numel(dose_2_bin(:,2))),repmat('C',1,numel(dose_2_bin(:,3))),repmat('D',1,numel(dose_2_bin(:,4))),repmat('E',1,numel(dose_2_bin(:,5))),repmat('F',1,numel(dose_2_bin(:,6)))];

g3=[dose_3_bin(:,1), dose_3_bin(:,2), dose_3_bin(:,3), dose_3_bin(:,4), dose_3_bin(:,5), dose_3_bin(:,6)];
v3=[repmat('A',1,numel(dose_3_bin(:,1))),repmat('B',1,numel(dose_3_bin(:,2))),repmat('C',1,numel(dose_3_bin(:,3))),repmat('D',1,numel(dose_3_bin(:,4))),repmat('E',1,numel(dose_3_bin(:,5))),repmat('F',1,numel(dose_3_bin(:,6)))];

g4=[dose_4_bin(:,1), dose_4_bin(:,2), dose_4_bin(:,3), dose_4_bin(:,4), dose_4_bin(:,5), dose_4_bin(:,6)];
v4=[repmat('A',1,numel(dose_4_bin(:,1))),repmat('B',1,numel(dose_4_bin(:,2))),repmat('C',1,numel(dose_4_bin(:,3))),repmat('D',1,numel(dose_4_bin(:,4))),repmat('E',1,numel(dose_4_bin(:,5))),repmat('F',1,numel(dose_4_bin(:,6)))];

G=[g1,g2,g3,g4];
vg1 = [repmat('1',1,numel(v1)),repmat('2',1,numel(v2)),repmat('3',1,numel(v3)),repmat('4',1,numel(v4))];
vg2=[v1,v2,v3,v4];
figure(777); hold on; boxplot(G', {vg1';vg2'}, 'factorseparator',1 , 'factorgap',30,...
    'colorgroup',vg2','labelverbosity','majorminor'); title('Nicotine Effect on Lick Count');
ylabel('Lick Count');xlabel(['Doses across ' num2str(trial_binning) '- trial bins']);

%Plot means by bins
figure(); hold on; plot(nanmean(g1));plot(nanmean(g2));plot(nanmean(g3));plot(nanmean(g4));
title('Nicotine Effect on Mean Lick Count');ylabel('Lick Count');xlabel([num2str(trial_binning) '- trial bins']);
legend('0.0mg/kg','0.05mg/kg','0.1mg/kg','0.2mg/kg');

%Plot median by bins
figure(); hold on; plot(nanmedian(g1));plot(nanmedian(g2));plot(nanmedian(g3));plot(nanmedian(g4));
hold on; xlim([0 7]); xticks([0 1 2 3 4 5 6 7]);
title('Nicotine Effect on Median Lick Count');ylabel('Lick Count');xlabel([num2str(trial_binning) '- trial bins']);
legend('0.0mg/kg','0.05mg/kg','0.1mg/kg','0.2mg/kg');ylim([0 90]);

%BeeSwarm Plots with all data
figure(); UnivarScatter(dose_1_bin, 'MarkerFaceColor','m','SEMColor','w','StdColor','w');hold on; plot(nanmean(dose_1_bin),'m');
hold on; UnivarScatter(dose_2_bin, 'MarkerFaceColor','c','SEMColor','w','StdColor','w'); plot(nanmean(dose_2_bin),'c');
hold on; UnivarScatter(dose_3_bin, 'MarkerFaceColor','g','SEMColor','w','StdColor','w'); plot(nanmean(dose_3_bin),'g');
hold on; UnivarScatter(dose_4_bin, 'MarkerFaceColor','b','SEMColor','w','StdColor','w'); plot(nanmean(dose_4_bin),'b');

%BeeSwarm Plots
figure(3);subplot(4,1,1); UnivarScatter(dose_1_bin, 'MarkerFaceColor','m','SEMColor','w','StdColor','w');hold on; plot(nanmean(dose_1_bin),'m'); ylim([-1 100]); title('Dose: 0.0mg/kg');
subplot(4,1,2); UnivarScatter(dose_2_bin, 'MarkerFaceColor','c','SEMColor','w','StdColor','w'); hold on; plot(nanmean(dose_2_bin),'c');ylim([-1 100]); title('Dose: 0.05mg/kg');
subplot(4,1,3); UnivarScatter(dose_3_bin, 'MarkerFaceColor','g','SEMColor','w','StdColor','w'); hold on; plot(nanmean(dose_3_bin),'g');ylim([-1 100]);title('Dose: 0.1mg/kg');
subplot(4,1,4); UnivarScatter(dose_4_bin, 'MarkerFaceColor','b','SEMColor','w','StdColor','w'); hold on; plot(nanmean(dose_4_bin),'b');ylim([-1 100]);title('Dose: 0.2mg/kg');xlabel([num2str(trial_binning) '- trial bins']);
suptitle('Nicotine Effect on Lick Count'); 

%Replace 60000 with NaN
latency_data(latency_data==60000) = NaN; %Replace 0s with NaN

%Grab binned data
lat_binning_set = latency_data; %duplicate data set to cross check
trial_binning = 15;
n = trial_binning;  % grab first n rows in each data set
c = size(lat_binning_set,2);  % total columns
binned_lat_matrix = zeros(trials/trial_binning,num_animals*trial_binning,size(lat_binning_set,2)); %binsXbin*animalsXdoses

%flip through and grab data to store
for bin=1:trials/trial_binning
    r = length(lat_binning_set); % total rows
    bin_fix = bin-1;
    d = trials-(trial_binning*bin_fix); % rows in each data set 
    
    if bin==6
        binned_lat_matrix(bin,:,:)= lat_binning_set(:,:); %store data
    else
        binned_lat_matrix(bin,:,:)= lat_binning_set(mod(1:r,d)<=n & mod(1:r,d)>0,:); %store data
        lat_binning_set(mod(1:r,d)<=n & mod(1:r,d)>0,:) =[]; %remove the data you just stored
    end
end

%Create grouping sets
dose_1_bin_lat =binned_lat_matrix(1:6,:,1)';
dose_2_bin_lat =binned_lat_matrix(1:6,:,2)';
dose_3_bin_lat =binned_lat_matrix(1:6,:,3)';
dose_4_bin_lat =binned_lat_matrix(1:6,:,4)';

%Plots grouped boxplots with dose as grouping variable
g1=[dose_1_bin_lat(:,1), dose_2_bin_lat(:,1), dose_3_bin_lat(:,1), dose_4_bin_lat(:,1)];
v1=[repmat('A',1,numel(dose_1_bin_lat(:,1))),repmat('B',1,numel(dose_2_bin_lat(:,1))),repmat('C',1,numel(dose_3_bin_lat(:,1))),repmat('D',1,numel(dose_4_bin_lat(:,1)))];

g2=[dose_1_bin_lat(:,2), dose_2_bin_lat(:,2), dose_3_bin_lat(:,2), dose_4_bin_lat(:,2)];
v2=[repmat('A',1,numel(dose_1_bin_lat(:,2))),repmat('B',1,numel(dose_2_bin_lat(:,2))),repmat('C',1,numel(dose_3_bin_lat(:,2))),repmat('D',1,numel(dose_4_bin_lat(:,2)))];

g3=[dose_1_bin_lat(:,3), dose_2_bin_lat(:,3), dose_3_bin_lat(:,3), dose_4_bin_lat(:,3)];
v3=[repmat('A',1,numel(dose_1_bin_lat(:,3))),repmat('B',1,numel(dose_2_bin_lat(:,3))),repmat('C',1,numel(dose_3_bin_lat(:,3))),repmat('D',1,numel(dose_4_bin_lat(:,3)))];

g4=[dose_1_bin_lat(:,4), dose_2_bin_lat(:,4), dose_3_bin_lat(:,4), dose_4_bin_lat(:,4)];
v4=[repmat('A',1,numel(dose_1_bin_lat(:,4))),repmat('B',1,numel(dose_2_bin_lat(:,4))),repmat('C',1,numel(dose_3_bin_lat(:,4))),repmat('D',1,numel(dose_4_bin_lat(:,4)))];

g5=[dose_1_bin_lat(:,5), dose_2_bin_lat(:,5), dose_3_bin_lat(:,5), dose_4_bin_lat(:,5)];
v5=[repmat('A',1,numel(dose_1_bin_lat(:,5))),repmat('B',1,numel(dose_2_bin_lat(:,5))),repmat('C',1,numel(dose_3_bin_lat(:,5))),repmat('D',1,numel(dose_4_bin_lat(:,5)))];

g6=[dose_1_bin_lat(:,6), dose_2_bin_lat(:,6), dose_3_bin_lat(:,6), dose_4_bin_lat(:,6)];
v6=[repmat('A',1,numel(dose_1_bin_lat(:,6))),repmat('B',1,numel(dose_2_bin_lat(:,6))),repmat('C',1,numel(dose_3_bin_lat(:,6))),repmat('D',1,numel(dose_4_bin_lat(:,6)))];

G=[g1,g2,g3,g4,g5,g6];
vg1 = [repmat('1',1,numel(v1)),repmat('2',1,numel(v2)),repmat('3',1,numel(v3)),repmat('4',1,numel(v4)),repmat('5',1,numel(v5)),repmat('6',1,numel(v6))];
vg2=[v1,v2,v3,v4,v5,v6];

figure(888); hold on; boxplot(G', {vg1';vg2'}, 'factorseparator',1 , 'factorgap',30,...
    'colorgroup',vg2','labelverbosity','majorminor');

%Plots grouped boxplots with binning as grouping variable
g1=[dose_1_bin_lat(:,1), dose_1_bin_lat(:,2), dose_1_bin_lat(:,3), dose_1_bin_lat(:,4), dose_1_bin_lat(:,5), dose_1_bin_lat(:,6)];
v1=[repmat('A',1,numel(dose_1_bin_lat(:,1))),repmat('B',1,numel(dose_1_bin_lat(:,2))),repmat('C',1,numel(dose_1_bin_lat(:,3))),repmat('D',1,numel(dose_1_bin_lat(:,4))),repmat('E',1,numel(dose_1_bin_lat(:,5))),repmat('F',1,numel(dose_1_bin_lat(:,6)))];

g2=[dose_2_bin_lat(:,1), dose_2_bin_lat(:,2), dose_2_bin_lat(:,3), dose_2_bin_lat(:,4), dose_2_bin_lat(:,5), dose_2_bin_lat(:,6)];
v2=[repmat('A',1,numel(dose_2_bin_lat(:,1))),repmat('B',1,numel(dose_2_bin_lat(:,2))),repmat('C',1,numel(dose_2_bin_lat(:,3))),repmat('D',1,numel(dose_2_bin_lat(:,4))),repmat('E',1,numel(dose_2_bin_lat(:,5))),repmat('F',1,numel(dose_2_bin_lat(:,6)))];

g3=[dose_3_bin_lat(:,1), dose_3_bin_lat(:,2), dose_3_bin_lat(:,3), dose_3_bin_lat(:,4), dose_3_bin_lat(:,5), dose_3_bin_lat(:,6)];
v3=[repmat('A',1,numel(dose_3_bin_lat(:,1))),repmat('B',1,numel(dose_3_bin_lat(:,2))),repmat('C',1,numel(dose_3_bin_lat(:,3))),repmat('D',1,numel(dose_3_bin_lat(:,4))),repmat('E',1,numel(dose_3_bin_lat(:,5))),repmat('F',1,numel(dose_3_bin_lat(:,6)))];

g4=[dose_4_bin_lat(:,1), dose_4_bin_lat(:,2), dose_4_bin_lat(:,3), dose_4_bin_lat(:,4), dose_4_bin_lat(:,5), dose_4_bin_lat(:,6)];
v4=[repmat('A',1,numel(dose_4_bin_lat(:,1))),repmat('B',1,numel(dose_4_bin_lat(:,2))),repmat('C',1,numel(dose_4_bin_lat(:,3))),repmat('D',1,numel(dose_4_bin_lat(:,4))),repmat('E',1,numel(dose_4_bin_lat(:,5))),repmat('F',1,numel(dose_4_bin_lat(:,6)))];

G=[g1,g2,g3,g4];
vg1 = [repmat('1',1,numel(v1)),repmat('2',1,numel(v2)),repmat('3',1,numel(v3)),repmat('4',1,numel(v4))];
vg2=[v1,v2,v3,v4];
figure(999); hold on; boxplot(G', {vg1';vg2'}, 'factorseparator',1 , 'factorgap',30,...
    'colorgroup',vg2','labelverbosity','majorminor');

%BeeSwarm Plots
figure(1787);subplot(4,1,1); UnivarScatter(dose_1_bin_lat, 'MarkerFaceColor','m','SEMColor','w','StdColor','w');hold on; plot(nanmean(dose_1_bin_lat),'m'); ylim([-1 60000]); title('Dose: 0.0mg/kg');
subplot(4,1,2); UnivarScatter(dose_2_bin_lat, 'MarkerFaceColor','c','SEMColor','w','StdColor','w'); hold on; plot(nanmean(dose_2_bin_lat),'c');ylim([-1 60000]); title('Dose: 0.05mg/kg');
subplot(4,1,3); UnivarScatter(dose_3_bin_lat, 'MarkerFaceColor','g','SEMColor','w','StdColor','w'); hold on; plot(nanmean(dose_3_bin_lat),'g');ylim([-1 60000]);title('Dose: 0.1mg/kg');
subplot(4,1,4); UnivarScatter(dose_4_bin_lat, 'MarkerFaceColor','b','SEMColor','w','StdColor','w'); hold on; plot(nanmean(dose_4_bin_lat),'b');ylim([-1 60000]);title('Dose: 0.2mg/kg');xlabel([num2str(trial_binning) '- trial bins']);
suptitle('Nicotine Effect on Latency to First Lick'); 

%Plot latency means
figure(); plot(nanmean(dose_1_bin_lat)); hold on; 
plot(nanmean(dose_2_bin_lat)); hold on;
plot(nanmean(dose_3_bin_lat)); hold on;
plot(nanmean(dose_4_bin_lat)); hold on;
xlim([0 7]); xticks([0 1 2 3 4 5 6 7]);xlabel([num2str(trial_binning) '- trial bins']);
legend(doses);

%Plot box whiskers of first lick latency
figure(); boxplot(first_lick_latency); title('Nicotine Effect on Latency to First Lick');
ylabel('Latency to Lick (ms)'); xlabel('Doses (mg/kg)'); xticklabels(doses);

%Plot box whiskers of lick count
figure(); boxplot(mean_lick_session); title('Nicotine Effect on Lick Count');
ylabel('Mean Lick Count'); xlabel('Doses (mg/kg)'); xticklabels(doses);


%Create tables for repeated measure analyses
mean_lick_one_col = mean_lick_session(:); %Stack all mean licks atop one another
dose_col = repmat(doses,1,4)'; dose_col = dose_col(:);%Organize and stack doses
consumption_matrix2 = [11 12 8 10; 12 11 9 6; 9 10 6 6; 6 7 10 4]'; %Create consumption matrix and stack
consumption_matrix2=consumption_matrix2(:); %Stack consumptions
first_lick_lat_one_col = first_lick_latency(:); %Stack latency data

combined_metrics = [mean_lick_one_col consumption_matrix2 first_lick_lat_one_col cummulative_latency(:)];
gplotmatrix(combined_metrics,[],dose_col,[],'+xo');

[d,p,stats] = manova1(combined_metrics,dose_col);
c1 = stats.canon(:,1);
c2 = stats.canon(:,2);
c3 = stats.canon(:,3);
c4 = stats.canon(:,4);

figure(3);
gscatter(c2,c3,dose_col,[],'oxs');




dose_col2 = repmat(doses,1,90*4)';

combined_whole_metrics= [lick_data(:) latency_data(:)];
gplotmatrix(combined_whole_metrics,[],dose_col2(:),[],'+xo');

[d,p,stats] = manova1(combined_whole_metrics,dose_col2(:));

manovacluster(stats);

table3 = table(dose_col2(:),combined_whole_metrics(:,1),combined_whole_metrics(:,2),...
    'VariableNames',{'Dose','meas1','meas2'});
lick_Meas_new2 = table([1 2]','VariableNames',{'Measurements'});
rm_new2 = fitrm(table3,'meas1-meas2~Dose','WithinDesign',lick_Meas_new2);
ranovatbl_new = ranova(rm_new2);
manovatbl_new = manova(rm_new2);

table2 = table(dose_col,combined(:,1),combined(:,2),...
    'VariableNames',{'Dose','meas1','meas2'});
lick_Meas_new = table([1 2]','VariableNames',{'Measurements'});
rm_new = fitrm(table2,'meas1-meas2~Dose','WithinDesign',lick_Meas_new);
ranovatbl_new = ranova(rm_new);
manovatbl_new = manova(rm_new);

check=mean_lick_session';
lick_table_2 = table(doses,check(:,1),check(:,2),check(:,3),check(:,4),...
    'VariableNames',{'Dose','meas1','meas2','meas3','meas4'});
lick_Meas2 = table([1 2 3 4]','VariableNames',{'Measurements'});
rm2 = fitrm(lick_table_2,'meas1-meas4~Dose','WithinDesign',lick_Meas2);
ranovatbl2 = ranova(rm2);
manovatbl2 = manova(rm2);

check2=first_lick_latency';
lick_table_3 = table(doses,check2(:,1),check2(:,2),check2(:,3),check2(:,4),...
    'VariableNames',{'Dose','meas1','meas2','meas3','meas4'});
lick_Meas3 = table([1 2 3 4]','VariableNames',{'Measurements'});
rm3 = fitrm(lick_table_3,'meas1-meas4~Dose','WithinDesign',lick_Meas3);
ranovatbl3 = ranova(rm3);

consumption_matrix = [11 12 8 10; 12 11 9 6; 9 10 6 6; 6 7 10 4];
consum_table = table(doses,consumption_matrix(:,1),consumption_matrix(:,2),consumption_matrix(:,3),consumption_matrix(:,4),...
    'VariableNames',{'Dose','meas1','meas2','meas3','meas4'});
consum_Meas = table([1 2 3 4]','VariableNames',{'Measurements'});
rm4 = fitrm(consum_table,'meas1-meas4~Dose','WithinDesign',consum_Meas);
ranovatbl4 = ranova(rm4);
manovatbl4 = manova(rm4);

lick_table = table(animals,mean_lick_session(:,1),mean_lick_session(:,2),mean_lick_session(:,3),mean_lick_session(:,4),...
    'VariableNames',{'Rat','meas1','meas2','meas3','meas4'});
lick_Meas = table([1 2 3 4]','VariableNames',{'Measurements'});

%Fit a repeated measures model, where the measurements are the responses
%and the species is the predictor variable.
rm = fitrm(lick_table,'meas1-meas4~Rat','WithinDesign',lick_Meas)
ranovatbl = ranova(lick_rm)