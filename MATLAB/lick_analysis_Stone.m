% Construct a Question Dialog Box with 3 options 
analyze_type = questdlg('Are you wanting to analyze Habituation Data, Testing Data, or Both?', ...
	'Analyzing Menu', ...
	'Habituation','Testing', 'Both','');

%Extract data from text files based on users choice
switch analyze_type
    case 'Habituation'
        hab_folder_name = uigetdir('','Choose folder where the HABITUATION .txt files are'); 
        [analyze_struct] = nico_hab_decode_Stone(hab_folder_name);
    case 'Testing'
        test_folder_name = uigetdir('','Choose folder where the TESTING .txt files are'); 
        [analyze_struct] = nico_testing_decode_Stone(test_folder_name);
    case 'Both'
        hab_folder_name = uigetdir('','Choose folder where the HABITUATION .txt files are'); 
        test_folder_name = uigetdir('','Choose folder where the TESTING .txt files are'); 
        [analyze_hab] = nico_hab_decode_Stone(hab_folder_name);[analyze_test] = nico_testing_decode_Stone(test_folder_name);
        
        %Combine all data into one structure
        names = [fieldnames(analyze_hab); fieldnames(analyze_test)];
        analyze_struct = cell2struct([struct2cell(analyze_hab); struct2cell(analyze_test)], names, 1);
end

%Establish number of days to analyze for loops
days = fieldnames(analyze_struct); trials =90; 
num_animals = size(fieldnames(analyze_struct.(cell2mat(days(1)))),1); %establish number of animals (assuming at least one day)
full_data_set = zeros(size(days,1),num_animals,trials); %Create zero matrix to store data
full_data_set_latency = zeros(size(days,1),num_animals,trials); %Create zero matrix to store data
bottle_1_logic_set = zeros(size(days,1),num_animals,trials/2); bottle_2_logic_set = zeros(size(days,1),num_animals,trials/2);
dose =zeros(5,num_animals,1); %5 = 2Hab days+3Test days CHANGE THIS NUMBER IF YOU ONLY WANT HAB5
full_licks_session=zeros(size(days,1),num_animals,1);
cumsum_licks_session = zeros(size(days,1),num_animals,90);
bottle_set = zeros(size(days,1),num_animals,trials);

all_animals = fieldnames(analyze_struct.(cell2mat(days(1))));

%Initiate loop and store data by (day,animal,data)
for day=1:size(days,1)
    animals = fieldnames(analyze_struct.(cell2mat(days(day))));
    for animal=1:size(animals,1)
        
        %Dataset Variable
        data_set = analyze_struct.(cell2mat(days(day))).(cell2mat(animals(animal)));
        
        %Build bottle logic matrices
        bottle_1_logic_set(day,animal,:) = find(data_set.trial_data(:,2)==1);
        bottle_2_logic_set(day,animal,:) = find(data_set.trial_data(:,2)==2);
        
        %Build lick count and latency matrices
        full_data_set(day,animal,:) = data_set.trial_data(:,6);
        full_data_set_latency(day,animal,:) = data_set.trial_data(:,7);
        
        %Build licks per session total matrix
        full_licks_session(day,animal,:) = size(data_set.licks_per_trial(:,:),1);
        
        %Build cumsum licks per session matrix
        cumsum_licks_session(day,animal,:) = cumsum(data_set.licks_session(:,1));
                
        %Get dose info (this will only occur on test days)
        day_read = cell2mat(days(day));
        if day_read(end-3:end-1)=='DAY'
            day_num = str2num(day_read(end:end));
            dose(day_num+2,animal) = str2num(regexprep(data_set.dose,'(\(|\))','')); %extracts only the numeric values; the added two is to account for habdays
        end
        
    end    
end    

%Concatenate bottle logics and grab lick data by bottle
comb_bottle_logic = cat(3,bottle_1_logic_set,bottle_2_logic_set); %stacks 2nd half of trials below first

%Loop through structure to perform logic indexing
bottle_set = zeros(size(days,1),num_animals,trials);
for day=1:size(days,1)
    for animal=1:size(animals,1)
        bottle_set(day,animal,:) = full_data_set(day,animal,comb_bottle_logic(day,animal,:));
    end    
end  

%Loop through bottle_data and grab First/Second 1/2 sums
bottle_split_sum = zeros(size(days,1),num_animals,2); split_session_sum = zeros(size(days,1),num_animals,2);
for day=1:size(days,1)
    for animal=1:size(all_animals,1)
        bottle_split_sum(day,animal,1) =sum(bottle_set(day,animal,1:45));
        bottle_split_sum(day,animal,2) =sum(bottle_set(day,animal,46:90));
        split_session_sum(day,animal,1) =sum(full_data_set(day,animal,1:45));
        split_session_sum(day,animal,2) =sum(full_data_set(day,animal,46:90));
    end    
end

%Plotting
%Bottle Analysis
%Rearrange array to (animal,day,data)
bottle_set_arranged = permute(bottle_set, [2 1 3]); bottle_split_sum_arranged = permute(bottle_split_sum, [2 1 3]);
split_session_sum_arranged = permute(split_session_sum, [2 1 3]); full_data_set_arranged = permute(full_data_set, [2 1 3]);
full_data_set_lat_arranged = permute(full_data_set_latency, [2 1 3]);

%Plot 1: Stacked-Grouped Bar by animal (X-axis) and condition (bar: in
%order of days), with each line indicating licks within trial
groupLabels = all_animals; [xvals yvals] =plotBarStackGroups_stone(bottle_set_arranged, groupLabels); 
ylabel('Lick count'); xlabel('Animal'); title('Effect of Nicotine on Lick Count'); legend_text_fig1=[];
for animal=1:size(full_data_set_arranged,1)
    legend_text_fig1_build = [];
    for day=1:size(full_data_set_arranged,2)
        legend_text_fig1_build{day,1} = ([num2str(dose(day,animal)) 'mg/kg']);
    end
    legend_text_fig1 = horzcat(legend_text_fig1_build,legend_text_fig1);
end

%Flip horizontally to put into correct order
legend_text_fig1=fliplr(legend_text_fig1);

%Loop through days by animal and input appropriate data labels
for animal=1:size(full_data_set_arranged,1)
   for day=1:size(full_data_set_arranged,2)
       x_axis_shift =size(full_data_set_arranged,2)-day;
       text((xvals(animal)-(yvals*(x_axis_shift))),squeeze(sum(bottle_set_arranged(animal,day,:)))+90,legend_text_fig1{day,animal});
    end
end

%Plot 1.5: Stacked-Grouped Bar by animal (X-axis) and condition (bar: in
%order of days), with each line indicating licks within trial
groupLabels = all_animals; [xvals yvals] =plotBarStackGroups_stone(full_data_set_arranged, groupLabels);
ylabel('Lick count'); xlabel('Animal'); title('Effect of Nicotine on Lick Count');

%Plot 2: Stacked-Grouped Bar by animal (X-axis) and condition (bar: in
%order of days), with each color indicating bottle 1 and 2 sums
groupLabels = all_animals; plotBarStackGroups(bottle_split_sum_arranged, groupLabels); 
ylabel('Lick count'); xlabel('Animal'); title('Effect of Nicotine on Lick Count');
legend('Bottle 1', 'Bottle 2');

%Plot 3: Stacked-Grouped Bar by animal (X-axis) and condition (bar: in
%order of days), with each color indicating 1/2 trial sum
groupLabels = all_animals;  plotBarStackGroups(split_session_sum_arranged, groupLabels); 
ylabel('Lick count'); xlabel('Animal'); title('Effect of Nicotine on Lick Count');
legend('First 1/2', 'Second 1/2');

%create time vector for time course plotting (in seconds)
cum_sess_time(1:trials,1)=40; cum_sess_time = cumsum(cum_sess_time);

%Plot habituation days based on trials/time
figure(41); 
for animal=1:size(full_data_set_arranged,1)
    subplot(size(full_data_set_arranged,1),1,animal); legend_text =[];
    for day=1:2
        plot(cum_sess_time,squeeze(full_data_set_arranged(animal,day,:))); hold on;
       legend_text{day,1} = (['Dose: ' num2str(dose(day,animal)) 'mg/kg']);
    end
    xlim([0 3600]); xticks(0:200:3600);xticklabels({'0','5','10','15','20','25','30','35','40','45','50','55','60','65','70','75','80','85','90'});
    ylabel('Lick count'); xlabel('Trials Post-Injection'); title([all_animals(animal)]);legend('Hab. Day 1','Hab. Day 2');
end

%Plot based on trials/time
figure(4); 
for animal=1:size(full_data_set_arranged,1)
    subplot(size(full_data_set_arranged,1),1,animal); legend_text =[];
    for day=1:size(full_data_set_arranged,2)
        plot(cum_sess_time,squeeze(full_data_set_arranged(animal,day,:))); hold on;
       legend_text{day,1} = (['Dose: ' num2str(dose(day,animal)) 'mg/kg']);
    end
    xlim([0 3600]); xticks(0:200:3600);xticklabels({'0','5','10','15','20','25','30','35','40','45','50','55','60','65','70','75','80','85','90'});
    ylabel('Lick count'); xlabel('Trials Post-Injection'); title([all_animals(animal)]);legend(legend_text);
end

%Plot based on binned trials and lick frequency
figure(10); x_val_array = []; n = 10; % average every n values
%create time vector for time course plotting (in seconds)
x_val_array(1:trials/n,1)=1; cum_sess_time_binned = cumsum(x_val_array);

for animal=1:size(full_data_set_arranged,1)
    subplot(size(full_data_set_arranged,1),1,animal); legend_text =[];
    for day=1:size(full_data_set_arranged,2)
        data_grab =squeeze(full_data_set_arranged(animal,day,:));
        binned_data = arrayfun(@(i) mean(data_grab(i:i+n-1)),1:n:length(data_grab)-n+1)'; % the averaged vector
        plot(cum_sess_time_binned,binned_data); hold on;
       legend_text{day,1} = (['Dose: ' num2str(dose(day,animal)) 'mg/kg']);
    end
    xlim([0 (trials/n) + 1]);
    ylabel('Mean Lick Rate (Hz)'); xlabel([num2str(n) '-Trial Blocks Post-Injection']); title([all_animals(animal)]);legend(legend_text);
end

%Plot latency to first lick based on trials/time
figure(5); 
for animal=1:size(full_data_set_lat_arranged,1)
    subplot(size(full_data_set_lat_arranged,1),1,animal); 
    for day=1:size(full_data_set_lat_arranged,2)
       plot(cum_sess_time,squeeze(full_data_set_lat_arranged(animal,day,:))); hold on;
    end
    xlim([0 3600]); xticks(0:200:3600);xticklabels({'0','5','10','15','20','25','30','35','40','45','50','55','60','65','70','75','80','85','90'});
    ylabel('Time to first Lick (ms)'); xlabel('Trials Post-Injection'); title([all_animals(animal)]);legend(legend_text_fig1(:,animal)); ylim([0 65000]);
end

%Plot based on trials/time
figure(6); 
for animal=1:size(full_data_set_lat_arranged,1)
    subplot(1,size(full_data_set_lat_arranged,1),animal); 
    for day=1:size(full_data_set_lat_arranged,2)
       scatter(squeeze(full_data_set_lat_arranged(animal,day,:)),squeeze(full_data_set_arranged(animal,day,:))); hold on;
    end
    %xlim([0 3600]); xticks(0:200:3600);xticklabels({'0','5','10','15','20','25','30','35','40','45','50','55','60','65','70','75','80','85','90'});
    ylabel('Lick Count in Trial'); xlabel('Time to first Lick (ms)'); title([all_animals(animal)]);legend(legend_text_fig1(:,animal)); %ylim([0 65000]);
end

%Plot number of trials-licked per session
full_licks_session_arranged = permute(full_licks_session,[2 1 3]);
plotBarStackGroups(full_licks_session_arranged, groupLabels);
%Loop through days by animal and input appropriate data labels
for animal=1:size(full_licks_session_arranged,1)
   for day=1:size(full_licks_session_arranged,2)
       x_axis_shift =size(full_licks_session_arranged,2)-day;
       text((xvals(animal)-(yvals*(x_axis_shift))),full_licks_session_arranged(animal,day,:)+2,legend_text_fig1{day,animal});
    end
end
ylabel('Trials Licked (out of 90)'); xlabel('Animal'); title('Effect of Nicotine on Lick Count');

%Plot cumssum trials licked over session
cumsum_licks_session_arranged = permute(cumsum_licks_session,[2 1 3]);
figure(8); 
for animal=1:size(cumsum_licks_session_arranged,1)
    subplot(size(cumsum_licks_session_arranged,1),1,animal); 
    for day=1:size(cumsum_licks_session_arranged,2)
       plot(cum_sess_time,squeeze(cumsum_licks_session_arranged(animal,day,:))); hold on;
    end
    xlim([0 3600]); xticks(0:200:3600);xticklabels({'0','5','10','15','20','25','30','35','40','45','50','55','60','65','70','75','80','85','90'});
    ylabel('Cummulative trials licked'); xlabel('Trials Post-Injection'); title([all_animals(animal)]);legend(legend_text_fig1{:,animal});
end
