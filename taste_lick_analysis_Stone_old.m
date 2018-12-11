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
full_data_set = zeros(4,num_animals,trials); %Create zero matrix to store data (4=2hab days+4testdays)
full_data_set_latency = zeros(4,num_animals,trials); %Create zero matrix to store data (4=2hab days+4testdays)

%Create matrices for habituation logics
hab_bottles = 2;
bottle_1_logic_set = zeros(2,num_animals,trials/hab_bottles); bottle_2_logic_set = zeros(2,num_animals,trials/hab_bottles); %Divided by 2 bc only 2 bottles

%Create matrices for test trial logics
taste_bottles = 6;
test_bottle_1_logic_set = zeros(2,num_animals,trials/taste_bottles);test_bottle_2_logic_set = zeros(2,num_animals,trials/taste_bottles);
test_bottle_3_logic_set = zeros(2,num_animals,trials/taste_bottles);test_bottle_4_logic_set = zeros(2,num_animals,trials/taste_bottles);
test_bottle_5_logic_set = zeros(2,num_animals,trials/taste_bottles);test_bottle_6_logic_set = zeros(2,num_animals,trials/taste_bottles);

%Create matrix for doses
hab_days=2; %change if you need
test_days=2;
dose =zeros(4,num_animals,1); %4 = 2Hab days+2Test days CHANGE THIS NUMBER IF YOU ONLY WANT HAB5
full_licks_session=zeros(size(days,1),num_animals,1);
cumsum_licks_session = zeros(size(days,1),num_animals,90);
bottle_set = zeros(hab_days,num_animals,trials); %we have 2 Hab days
tastants = zeros(size(days,1),num_animals,trials);

all_animals = fieldnames(analyze_struct.(cell2mat(days(1))));

%Initiate loop and store data by (day,animal,data)
for day=1:size(days,1)
    animals = fieldnames(analyze_struct.(cell2mat(days(day))));
    for animal=1:size(animals,1)
        
        %Dataset Variable
        data_set = analyze_struct.(cell2mat(days(day))).(cell2mat(animals(animal)));
        
        %Get hab (this will only occur on HAB days)
        day_read = cell2mat(days(day));
        if day_read(1:end-1)=='HAB'
            %Build bottle logic matrices
            bottle_1_logic_set(day,animal,:) = find(data_set.trial_data(:,2)==1);
            bottle_2_logic_set(day,animal,:) = find(data_set.trial_data(:,2)==2);

        elseif day_read(end-3:end-1)=='DAY'
            day_num = str2num(day_read(end:end));
            dose(day_num+hab_days,animal) = str2num(regexprep(data_set.dose,'(\(|\))','')); %extracts only the numeric values; the added two is to account for habdays
            
            if str2num(regexprep(data_set.dose,'(\(|\))','')) >0
                drug_day=2;
            else
                drug_day=1;
            end
            
            %Store data with saline data in first stored day
            test_bottle_1_logic_set(drug_day,animal,:) = find(data_set.trial_data(:,3)==1);
            test_bottle_2_logic_set(drug_day,animal,:) = find(data_set.trial_data(:,3)==2);
            test_bottle_3_logic_set(drug_day,animal,:) = find(data_set.trial_data(:,3)==3);
            test_bottle_4_logic_set(drug_day,animal,:) = find(data_set.trial_data(:,3)==4);
            test_bottle_5_logic_set(drug_day,animal,:) = find(data_set.trial_data(:,3)==5);
            test_bottle_6_logic_set(drug_day,animal,:) = find(data_set.trial_data(:,3)==6);
        end
               
        %Build tastant, lick count, and latency matrices
        tastants(day,animal,:) = data_set.trial_data(:,3);
        full_data_set(day,animal,:) = data_set.trial_data(:,6);
        full_data_set_latency(day,animal,:) = data_set.trial_data(:,7);
        
        %Build licks per session total matrix
        full_licks_session(day,animal,:) = size(data_set.licks_per_trial(:,:),1);
        
        %Build cumsum licks per session matrix
        cumsum_licks_session(day,animal,:) = cumsum(data_set.licks_session(:,1));
        
    end    
end    

%%%HABITUATION CALCULATION STUFF%%%

%Concatenate bottle logics and grab lick data by bottle
comb_bottle_logic = cat(3,bottle_1_logic_set,bottle_2_logic_set); %stacks 2nd half of trials below first

%Loop through structure to perform logic indexing for HAB days
bottle_set = zeros(hab_days,num_animals,trials); %habdays, animals, trials
for day=1:2
    for animal=1:size(animals,1)
        bottle_set(day,animal,:) = full_data_set(day,animal,comb_bottle_logic(day,animal,:));
    end    
end  

%Loop through bottle_data and grab First/Second 1/2 sums
bottle_split_sum = zeros(2,num_animals,2); split_session_sum = zeros(2,num_animals,2);
for day=1:2
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
ylabel('Lick count'); xlabel('Animal'); title('Habituation and Lick Count'); legend_text_fig1=[];
for animal=1:size(full_data_set_arranged,1)
    legend_text_fig1_build = [];
    for day=1:size(full_data_set_arranged,2)
        legend_text_fig1_build{day,1} = ([num2str(dose(day,animal)) 'mg/kg']);
    end
    legend_text_fig1 = horzcat(legend_text_fig1_build,legend_text_fig1);
end

%Plot 2: Stacked-Grouped Bar by animal (X-axis) and condition (bar: in
%order of days), with each color indicating bottle 1 and 2 sums
groupLabels = all_animals; plotBarStackGroups(bottle_split_sum_arranged, groupLabels); 
ylabel('Lick count'); xlabel('Animal'); title('Effect of Nicotine on Lick Count');
legend('Bottle 1', 'Bottle 2');

%Plot 1.5: Stacked-Grouped Bar by animal (X-axis) and condition (bar: in
%order of days), with each line indicating licks within trial
groupLabels = all_animals; [xvals yvals] =plotBarStackGroups_stone(full_data_set_arranged, groupLabels);
ylabel('Lick count'); xlabel('Animal'); title('Effect of Nicotine on Lick Count');

%%%TESTING CALCULATION STUFF%%%

%Concatenate bottle logics and grab lick data by bottle
test_comb_bottle_logic = cat(3,test_bottle_1_logic_set,test_bottle_2_logic_set,test_bottle_3_logic_set,test_bottle_4_logic_set,test_bottle_5_logic_set,test_bottle_6_logic_set); %stacks bottles on top of eachother (e.g. 15trials after 15 trials of each bottle)

%Loop through structure to perform logic indexing for TEST days
test_bottle_set = zeros(test_days,num_animals,trials); %testdays, animals, trials
for day=1:2
    for animal=1:size(animals,1)
        test_bottle_set(day,animal,:) = full_data_set(hab_days+day,animal,test_comb_bottle_logic(day,animal,:)); %hab_days+day because you need to skip the hab day data
    end    
end  

%Rearrange array to (animal,day,data)
test_bottle_arranged = permute(test_bottle_set, [2 1 3]);

%Plot 1: Stacked-Grouped Bar by animal (X-axis) and condition (bar: in
%order of days), with each line indicating licks within trial
groupLabels = all_animals; [xvals yvals] =plotBarStackGroups_stone(test_bottle_arranged, groupLabels); 
ylabel('Lick count'); xlabel('Animal'); title('Habituation and Lick Count');

%Loop through bottle_data and grab First/Second 1/2 sums
test_bottle_split_sum = zeros(2,num_animals,6); 
for animal=1:size(all_animals,1)
    for day=1:2
        test_bottle_split_sum(animal,day,1) =sum(test_bottle_arranged(animal,day,1:15));
        test_bottle_split_sum(animal,day,2) =sum(test_bottle_arranged(animal,day,16:30));
        test_bottle_split_sum(animal,day,3) =sum(test_bottle_arranged(animal,day,31:45));
        test_bottle_split_sum(animal,day,4) =sum(test_bottle_arranged(animal,day,46:60));
        test_bottle_split_sum(animal,day,5) =sum(test_bottle_arranged(animal,day,61:75));
        test_bottle_split_sum(animal,day,6) =sum(test_bottle_arranged(animal,day,76:90));
    end    
end

%Plot 2: Stacked-Grouped Bar by animal (X-axis) and condition (bar: in
%order of days), with each color indicating tastant sums
groupLabels = all_animals; plotBarStackGroups(test_bottle_split_sum, groupLabels); 
ylabel('Lick count'); xlabel('Animal'); title('Effect of Nicotine on Lick Count');
legend(fliplr(data_set.sessions_tastes_decode(1,:)));
