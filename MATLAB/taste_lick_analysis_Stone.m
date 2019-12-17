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
days = fieldnames(analyze_struct); trials =48; 
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
cumsum_licks_session = zeros(size(days,1),num_animals,48);
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
            bottle_1_logic_set(day,animal,:) = find(data_set.trial_data(1:trials,2)==1);
            bottle_2_logic_set(day,animal,:) = find(data_set.trial_data(1:trials,2)==2);

        elseif day_read(end-3:end-1)=='DAY'
            day_num = str2num(day_read(end:end));
            dose(day_num+hab_days,animal) = str2num(regexprep(data_set.dose,'(\(|\))','')); %extracts only the numeric values; the added two is to account for habdays
            
            if str2num(regexprep(data_set.dose,'(\(|\))','')) >0
                drug_day=2;
            else
                drug_day=1;
            end
            
            %Store data with saline data in first stored day
            test_bottle_1_logic_set(drug_day,animal,:) = find(data_set.trial_data(1:trials,3)==1);
            test_bottle_2_logic_set(drug_day,animal,:) = find(data_set.trial_data(1:trials,3)==2);
            test_bottle_3_logic_set(drug_day,animal,:) = find(data_set.trial_data(1:trials,3)==3);
            test_bottle_4_logic_set(drug_day,animal,:) = find(data_set.trial_data(1:trials,3)==4);
            test_bottle_5_logic_set(drug_day,animal,:) = find(data_set.trial_data(1:trials,3)==5);
            test_bottle_6_logic_set(drug_day,animal,:) = find(data_set.trial_data(1:trials,3)==6);
        end
               
        %Build tastant, lick count, and latency matrices
        tastants(day,animal,:) = data_set.trial_data(1:trials,3);
        full_data_set(day,animal,:) = data_set.trial_data(1:trials,6);
        full_data_set_latency(day,animal,:) = data_set.trial_data(1:trials,7);
        
        %Build licks per session total matrix
        full_licks_session(day,animal,:) = size(data_set.licks_per_trial(:,:),1);
        
        %Build cumsum licks per session matrix
        cumsum_licks_session(day,animal,:) = cumsum(data_set.licks_session(1:trials,1));
        
    end    
end    

%%%HABITUATION CALCULATION STUFF%%%

%Concatenate bottle logics and grab lick data by bottle
comb_bottle_logic = cat(3,bottle_1_logic_set,bottle_2_logic_set); %stacks 2nd half of trials below first

%Loop through structure to perform logic indexing for HAB days
bottle_set = zeros(hab_days,num_animals,trials); %habdays, animals, trials
for day=1:2
    for animal=1:size(all_animals,1)
        bottle_set(day,animal,:) = full_data_set(day,animal,comb_bottle_logic(day,animal,:));
    end    
end  

%Loop through bottle_data and grab First/Second 1/2 sums
bottle_split_sum = zeros(2,num_animals,2); split_session_sum = zeros(2,num_animals,2);
for day=1:2
    for animal=1:size(all_animals,1)
        bottle_split_sum(day,animal,1) =sum(bottle_set(day,animal,1:24));
        bottle_split_sum(day,animal,2) =sum(bottle_set(day,animal,25:48));
        split_session_sum(day,animal,1) =sum(full_data_set(day,animal,1:24));
        split_session_sum(day,animal,2) =sum(full_data_set(day,animal,25:48));
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
ylabel('Lick count'); xlabel('Animal'); title('Assessment of Bottle Bias based on Lick Count');
legend('Bottle 1', 'Bottle 2');

%Plot 1.5: Stacked-Grouped Bar by animal (X-axis) and condition (bar: in
%order of days), with each line indicating licks within trial
groupLabels = all_animals; [xvals yvals] =plotBarStackGroups_stone(full_data_set_arranged, groupLabels);
ylabel('Lick count'); xlabel('Animal'); title('Licks across days');

%%%TESTING CALCULATION STUFF%%%

%Concatenate bottle logics and grab lick data by bottle
test_comb_bottle_logic = cat(3,test_bottle_1_logic_set,test_bottle_2_logic_set,test_bottle_3_logic_set,test_bottle_4_logic_set,test_bottle_5_logic_set,test_bottle_6_logic_set); %stacks bottles on top of eachother (e.g. 15trials after 15 trials of each bottle)

%Loop through structure to perform logic indexing for TEST days
test_bottle_set = zeros(test_days,num_animals,trials); %testdays, animals, trials
for day=3:4
    animals = fieldnames(analyze_struct.(cell2mat(days(day))));
    for animal=1:size(animals,1)
        %Dataset Variable
        data_set = analyze_struct.(cell2mat(days(day))).(cell2mat(animals(animal)));
        
        %Get hab (this will only occur on Test days)
        day_read = cell2mat(days(day));
        
        %Organize dataset so that Saline is always in first row
        if day_read(end-3:end-1)=='DAY'
            if str2num(regexprep(data_set.dose,'(\(|\))','')) >0
                drug_day=2;
            else
                drug_day=1;
            end
        end
        
        %Creates matrix organized as (Day_Condition,animal,licks) where
        %day_condition will have first row = saline, second = nicotine
        current_set_logic = test_comb_bottle_logic(day-hab_days,animal,:);
        if max(current_set_logic) ~= 0   
            test_bottle_set(drug_day,animal,:) = full_data_set(day,animal,test_comb_bottle_logic(day-hab_days,animal,:)); %hab_days+day because you need to skip the hab day data
        else
            %test_bottle_set(drug_day,animal,:) = full_data_set(day,animal,:); %Set it up so that the animal's data is appropriately addded (padded as zeros)
            test_bottle_set(drug_day,animal,:) = full_data_set(day,animal,test_comb_bottle_logic(day-1,animal,:));
            disp([animals(animal) 'has not done this test condition yet.']);
        end
    end    
end  

%Rearrange array to (animal,day,data)
test_bottle_arranged = permute(test_bottle_set, [2 1 3]);

%Plot 1: Stacked-Grouped Bar by animal (X-axis) and condition (bar: in
%order of days), with each line indicating licks within trial
groupLabels = all_animals; [xvals yvals] =plotBarStackGroups_stone(test_bottle_arranged, groupLabels); 
ylabel('Lick count'); xlabel('Animal'); title('Nicotine and Lick Count - Ordered by Day');

%Loop through bottle_data and grab by tastant
%1 = sucrose, 2= water, 3=Nacl, 4=QHCl, 5=Sacharine, 6=citricacid
test_bottle_split_sum = zeros(num_animals,2,6); 
for animal=1:size(all_animals,1)
    for day=1:2
        test_bottle_split_sum(animal,day,1) =sum(test_bottle_arranged(animal,day,1:8));
        test_bottle_split_sum(animal,day,2) =sum(test_bottle_arranged(animal,day,9:16));
        test_bottle_split_sum(animal,day,3) =sum(test_bottle_arranged(animal,day,17:24));
        test_bottle_split_sum(animal,day,4) =sum(test_bottle_arranged(animal,day,25:32));
        test_bottle_split_sum(animal,day,5) =sum(test_bottle_arranged(animal,day,33:40));
        test_bottle_split_sum(animal,day,6) =sum(test_bottle_arranged(animal,day,41:48));
    end    
end

%Plot 2: Stacked-Grouped Bar by animal (X-axis) and condition (bar: in
%order of days), with each color indicating tastant sums
groupLabels = all_animals; plotBarStackGroups(test_bottle_split_sum, groupLabels); 
ylabel('Lick count'); xlabel('Animal'); title('Effect of Nicotine on Lick Count by Taste');
hold on;legend(regexprep(data_set.sessions_tastes_decode(1,:),',','')); %Grabs decode and removes comma

%BOXandWHISKER PLOTTING
%Create grouping sets
%Loop through bottle_data and grab by tastant
saline_data = zeros(num_animals,trials/taste_bottles,taste_bottles);
nicotine_data = zeros(num_animals,trials/taste_bottles,taste_bottles);
saline_water_mean =[];nicotine_water_mean=[];
filt_saline_water_mean=[]; filt_nicotine_water_mean =[];

for animal=1:num_animals
    for day=1:2
        if day ==1
            saline_data(animal,:,1) =test_bottle_arranged(animal,day,1:8);
            saline_data(animal,:,2) =test_bottle_arranged(animal,day,9:16);
            saline_data(animal,:,3) =test_bottle_arranged(animal,day,17:24);
            saline_data(animal,:,4) =test_bottle_arranged(animal,day,25:32);
            saline_data(animal,:,5) =test_bottle_arranged(animal,day,33:40);
            saline_data(animal,:,6) =test_bottle_arranged(animal,day,41:48);
        elseif day ==2
            nicotine_data(animal,:,1) =test_bottle_arranged(animal,day,1:8);
            nicotine_data(animal,:,2) =test_bottle_arranged(animal,day,9:16);
            nicotine_data(animal,:,3) =test_bottle_arranged(animal,day,17:24);
            nicotine_data(animal,:,4) =test_bottle_arranged(animal,day,25:32);
            nicotine_data(animal,:,5) =test_bottle_arranged(animal,day,33:40);
            nicotine_data(animal,:,6) =test_bottle_arranged(animal,day,41:48);
        end    
    end
    
    %calculate mean water lick counts
    saline_water_mean(end+1) = mean(saline_data(animal,:,2));
    nicotine_water_mean(end+1) = mean(nicotine_data(animal,:,2));
    
    %remove zeros
    filt_combined_saline_mean=saline_data; filt_combined_nicotine_mean =nicotine_data;
    %filt_combined_saline_mean(combined_saline==0) = NaN; filt_combined_nicotine_mean(combined_nicotine==0) = NaN; 
    filt_saline_water_mean(end+1) = nanmean(filt_combined_saline_mean(animal,:,2));
    filt_nicotine_water_mean(end+1) = nanmean(filt_combined_nicotine_mean(animal,:,2));
end

%Create pal matrices
saline_pal_index = zeros(num_animals,trials/taste_bottles,taste_bottles);
nicotine_pal_index = zeros(num_animals,trials/taste_bottles,taste_bottles);
filt_saline_pal_index = zeros(num_animals,trials/taste_bottles,taste_bottles);
filt_nicotine_pal_index = zeros(num_animals,trials/taste_bottles,taste_bottles);

for animal=1:num_animals
    for day=1:2
        if day ==1
            saline_pal_index(animal,:,:) =(saline_data(animal,:,:)-saline_water_mean(animal))/saline_water_mean(animal);
            filt_saline_pal_index(animal,:,:) =(filt_combined_saline_mean(animal,:,:)-filt_saline_water_mean(animal))/filt_saline_water_mean(animal);
        elseif day ==2
            nicotine_pal_index(animal,:,:) =(nicotine_data(animal,:,:)-nicotine_water_mean(animal))/nicotine_water_mean(animal);
            filt_nicotine_pal_index(animal,:,:) =(filt_combined_nicotine_mean(animal,:,:)-filt_nicotine_water_mean(animal))/filt_nicotine_water_mean(animal);
        end    
    end
end

%Combine animal's data (This method creates a concatenate matrix with the
%elements in concatenated matrix preserving their columnwise ordering from
%A. e.g. Trial 1 from animal 2, with be the second row in matrix (meaning
%first trial of this animal follows first trial of animal 1
combined_saline = reshape(saline_data(:,:,:),size(saline_data,2)*num_animals,size(saline_data,3)); 
combined_nicotine = reshape(nicotine_data(:,:,:),size(nicotine_data,2)*num_animals,size(nicotine_data,3)); 
combined_saline_pal_index = reshape(saline_pal_index(:,:,:),size(saline_pal_index,2)*num_animals,size(saline_pal_index,3)); 
combined_nicotine_pal_index = reshape(nicotine_pal_index(:,:,:),size(nicotine_pal_index,2)*num_animals,size(nicotine_pal_index,3)); 
filt_combined_saline_pal_index =reshape(filt_saline_pal_index(:,:,:),size(filt_saline_pal_index,2)*num_animals,size(filt_saline_pal_index,3)); 
filt_combined_nicotine_pal_index = reshape(filt_nicotine_pal_index(:,:,:),size(filt_nicotine_pal_index,2)*num_animals,size(filt_nicotine_pal_index,3)); 

%Plots grouped boxplots with dose as grouping variable w/zeros in
testg1=[combined_saline(:,1)', combined_nicotine(:,1)'];
testv1=[repmat('A',1,numel(combined_saline(:,1))'),repmat('B',1,numel(combined_nicotine(:,1)))];

testg2=[combined_saline(:,2)', combined_nicotine(:,2)'];
testv2=[repmat('A',1,numel(combined_saline(:,2))'),repmat('B',1,numel(combined_nicotine(:,2)))];

testg3=[combined_saline(:,3)', combined_nicotine(:,3)'];
testv3=[repmat('A',1,numel(combined_saline(:,3))'),repmat('B',1,numel(combined_nicotine(:,3)))];

testg4=[combined_saline(:,4)', combined_nicotine(:,4)'];
testv4=[repmat('A',1,numel(combined_saline(:,4))'),repmat('B',1,numel(combined_nicotine(:,4)))];

testg5=[combined_saline(:,5)', combined_nicotine(:,5)'];
testv5=[repmat('A',1,numel(combined_saline(:,5))'),repmat('B',1,numel(combined_nicotine(:,5)))];

testg6=[combined_saline(:,6)', combined_nicotine(:,6)'];
testv6=[repmat('A',1,numel(combined_saline(:,6))'),repmat('B',1,numel(combined_nicotine(:,6)))];

testG=[testg1,testg2,testg3,testg4,testg5,testg6];
testvg1 = [repmat('1',1,numel(testv1)),repmat('2',1,numel(testv2)),repmat('3',1,numel(testv3)),repmat('4',1,numel(testv4)),repmat('5',1,numel(testv5)),repmat('6',1,numel(testv6))];
testvg2=[testv1,testv2,testv3,testv4,testv5,testv6];

figure(109); hold on; boxplot(testG', {testvg1';testvg2'}, 'factorseparator',1 , 'factorgap',30,...
    'colorgroup',testvg2','labelverbosity','majorminor'); title('Nicotine Effect on Lick Count');
ylabel('Lick Count');xlabel('Tastants by Dose Condition');

%%Palatabilty index plotting (taste_trial-water_mean/water_mean)
%Plots grouped boxplots with dose as grouping variable w/zeros in

PItestg1=[combined_saline_pal_index(:,1)', combined_nicotine_pal_index(:,1)'];
PItestv1=[repmat('A',1,numel(combined_saline_pal_index(:,1))'),repmat('B',1,numel(combined_nicotine_pal_index(:,1)))];

PItestg2=[combined_saline_pal_index(:,2)', combined_nicotine_pal_index(:,2)'];
PItestv2=[repmat('A',1,numel(combined_saline_pal_index(:,2))'),repmat('B',1,numel(combined_nicotine_pal_index(:,2)))];

PItestg3=[combined_saline_pal_index(:,3)', combined_nicotine_pal_index(:,3)'];
PItestv3=[repmat('A',1,numel(combined_saline_pal_index(:,3))'),repmat('B',1,numel(combined_nicotine_pal_index(:,3)))];

PItestg4=[combined_saline_pal_index(:,4)', combined_nicotine_pal_index(:,4)'];
PItestv4=[repmat('A',1,numel(combined_saline_pal_index(:,4))'),repmat('B',1,numel(combined_nicotine_pal_index(:,4)))];

PItestg5=[combined_saline_pal_index(:,5)', combined_nicotine_pal_index(:,5)'];
PItestv5=[repmat('A',1,numel(combined_saline_pal_index(:,5))'),repmat('B',1,numel(combined_nicotine_pal_index(:,5)))];

PItestg6=[combined_saline_pal_index(:,6)', combined_nicotine_pal_index(:,6)'];
PItestv6=[repmat('A',1,numel(combined_saline_pal_index(:,6))'),repmat('B',1,numel(combined_nicotine_pal_index(:,6)))];

PItestG=[PItestg1,PItestg2,PItestg3,PItestg4,PItestg5,PItestg6];
PItestvg1 = [repmat('1',1,numel(PItestv1)),repmat('2',1,numel(PItestv2)),repmat('3',1,numel(PItestv3)),repmat('4',1,numel(PItestv4)),repmat('5',1,numel(PItestv5)),repmat('6',1,numel(PItestv6))];
PItestvg2=[PItestv1,PItestv2,PItestv3,PItestv4,PItestv5,PItestv6];

figure(119); hold on; boxplot(PItestG', {PItestvg1';PItestvg2'}, 'factorseparator',1 , 'factorgap',30,...
    'colorgroup',PItestvg2','labelverbosity','majorminor'); title('Nicotine Effect on Lick Count');
ylabel('Platabililty Index');xlabel('Tastants by Dose Condition');

%ylabel({'Platabililty Index';'(Licks to Taste- $\bar{x}$ Licks to Water/$\bar{x}$ Licks to Water'}, 'interpreter','latex');

%Plots grouped boxplots with dose as grouping variable w/0 zeros in
%remove zeros
filt_combined_saline=combined_saline; filt_combined_nicotine =combined_nicotine;
filt_combined_saline(combined_saline==0) = NaN; filt_combined_nicotine(combined_nicotine==0) = NaN; 

%Create plotting variables
filt_testg1=[filt_combined_saline(:,1)', filt_combined_nicotine(:,1)'];
filt_testv1=[repmat('A',1,numel(filt_combined_saline(:,1))'),repmat('B',1,numel(filt_combined_nicotine(:,1)))];

filt_testg2=[filt_combined_saline(:,2)', filt_combined_nicotine(:,2)'];
filt_testv2=[repmat('A',1,numel(filt_combined_saline(:,2))'),repmat('B',1,numel(filt_combined_nicotine(:,2)))];

filt_testg3=[filt_combined_saline(:,3)', filt_combined_nicotine(:,3)'];
filt_testv3=[repmat('A',1,numel(filt_combined_saline(:,3))'),repmat('B',1,numel(filt_combined_nicotine(:,3)))];

filt_testg4=[filt_combined_saline(:,4)', filt_combined_nicotine(:,4)'];
filt_testv4=[repmat('A',1,numel(filt_combined_saline(:,4))'),repmat('B',1,numel(filt_combined_nicotine(:,4)))];

filt_testg5=[filt_combined_saline(:,5)', filt_combined_nicotine(:,5)'];
filt_testv5=[repmat('A',1,numel(filt_combined_saline(:,5))'),repmat('B',1,numel(filt_combined_nicotine(:,5)))];

filt_testg6=[filt_combined_saline(:,6)', filt_combined_nicotine(:,6)'];
filt_testv6=[repmat('A',1,numel(filt_combined_saline(:,6))'),repmat('B',1,numel(filt_combined_nicotine(:,6)))];

filt_testG=[filt_testg1,filt_testg2,filt_testg3,filt_testg4,filt_testg5,filt_testg6];
filt_testvg1 = [repmat('1',1,numel(filt_testv1)),repmat('2',1,numel(filt_testv2)),repmat('3',1,numel(filt_testv3)),repmat('4',1,numel(filt_testv4)),repmat('5',1,numel(filt_testv5)),repmat('6',1,numel(filt_testv6))];
filt_testvg2=[filt_testv1,filt_testv2,filt_testv3,filt_testv4,filt_testv5,filt_testv6];

figure(110); hold on; boxplot(filt_testG', {filt_testvg1';filt_testvg2'}, 'factorseparator',1 , 'factorgap',30,...
    'colorgroup',filt_testvg2','labelverbosity','majorminor'); title('Nicotine Effect on Lick Count - Filtered');
ylabel('Lick Count');xlabel('Tastants by Dose Condition');

%%Palatabilty index plotting (taste_trial-water_mean/water_mean)
%Plots grouped boxplots with dose as grouping variable w/0 zeros in

filt_PItestg1=[filt_combined_saline_pal_index(:,1)', filt_combined_nicotine_pal_index(:,1)'];
filt_PItestv1=[repmat('S',1,numel(filt_combined_saline_pal_index(:,1))'),repmat('N',1,numel(filt_combined_nicotine_pal_index(:,1)))];

filt_PItestg2=[filt_combined_saline_pal_index(:,2)', filt_combined_nicotine_pal_index(:,2)'];
filt_PItestv2=[repmat('S',1,numel(filt_combined_saline_pal_index(:,2))'),repmat('N',1,numel(filt_combined_nicotine_pal_index(:,2)))];

filt_PItestg3=[filt_combined_saline_pal_index(:,3)', filt_combined_nicotine_pal_index(:,3)'];
filt_PItestv3=[repmat('S',1,numel(filt_combined_saline_pal_index(:,3))'),repmat('N',1,numel(filt_combined_nicotine_pal_index(:,3)))];

filt_PItestg4=[filt_combined_saline_pal_index(:,4)', filt_combined_nicotine_pal_index(:,4)'];
filt_PItestv4=[repmat('S',1,numel(filt_combined_saline_pal_index(:,4))'),repmat('N',1,numel(filt_combined_nicotine_pal_index(:,4)))];

filt_PItestg5=[filt_combined_saline_pal_index(:,5)', filt_combined_nicotine_pal_index(:,5)'];
filt_PItestv5=[repmat('S',1,numel(filt_combined_saline_pal_index(:,5))'),repmat('N',1,numel(filt_combined_nicotine_pal_index(:,5)))];

filt_PItestg6=[filt_combined_saline_pal_index(:,6)', filt_combined_nicotine_pal_index(:,6)'];
filt_PItestv6=[repmat('S',1,numel(filt_combined_saline_pal_index(:,6))'),repmat('N',1,numel(filt_combined_nicotine_pal_index(:,6)))];

filt_PItestG=[filt_PItestg1,filt_PItestg2,filt_PItestg3,filt_PItestg4,filt_PItestg5,filt_PItestg6];
filt_PItestvg1 = [repmat('1',1,numel(filt_PItestv1)),repmat('2',1,numel(filt_PItestv2)),repmat('3',1,numel(filt_PItestv3)),repmat('4',1,numel(filt_PItestv4)),repmat('5',1,numel(filt_PItestv5)),repmat('6',1,numel(filt_PItestv6))];
filt_PItestvg2=[filt_PItestv1,filt_PItestv2,filt_PItestv3,filt_PItestv4,filt_PItestv5,filt_PItestv6];

figure(120); hold on; boxplot(filt_PItestG', {filt_PItestvg1';filt_PItestvg2'}, 'factorseparator',1 , 'factorgap',30,...
    'colorgroup',filt_PItestvg2','labelverbosity','majorminor'); title('Nicotine Effect on Lick Count - Filtered');
ylabel({'Platabililty Index Referenced to Water'});xlabel('Tastants by Injection Condition'); hLine= refline(0,0); hLine.Color = 'k';

%Plots grouped boxplots with dose as grouping variable w/0 zeros in
%remove water tastant from figure

noWater_filt_PItestg1=[filt_combined_saline_pal_index(:,1)', filt_combined_nicotine_pal_index(:,1)'];
noWater_filt_PItestv1=[repmat('S',1,numel(filt_combined_saline_pal_index(:,1))'),repmat('N',1,numel(filt_combined_nicotine_pal_index(:,1)))];

noWater_filt_PItestg2=[filt_combined_saline_pal_index(:,3)', filt_combined_nicotine_pal_index(:,3)'];
noWater_filt_PItestv2=[repmat('S',1,numel(filt_combined_saline_pal_index(:,3))'),repmat('N',1,numel(filt_combined_nicotine_pal_index(:,3)))];

noWater_filt_PItestg3=[filt_combined_saline_pal_index(:,4)', filt_combined_nicotine_pal_index(:,4)'];
noWater_filt_PItestv3=[repmat('S',1,numel(filt_combined_saline_pal_index(:,4))'),repmat('N',1,numel(filt_combined_nicotine_pal_index(:,4)))];

noWater_filt_PItestg4=[filt_combined_saline_pal_index(:,5)', filt_combined_nicotine_pal_index(:,5)'];
noWater_filt_PItestv4=[repmat('S',1,numel(filt_combined_saline_pal_index(:,5))'),repmat('N',1,numel(filt_combined_nicotine_pal_index(:,5)))];

noWater_filt_PItestg5=[filt_combined_saline_pal_index(:,6)', filt_combined_nicotine_pal_index(:,6)'];
noWater_filt_PItestv5=[repmat('S',1,numel(filt_combined_saline_pal_index(:,6))'),repmat('N',1,numel(filt_combined_nicotine_pal_index(:,6)))];

noWater_filt_PItestG=[noWater_filt_PItestg1,noWater_filt_PItestg2,noWater_filt_PItestg3,noWater_filt_PItestg4,noWater_filt_PItestg5];
noWater_filt_PItestvg1 = [repmat('1',1,numel(noWater_filt_PItestv1)),repmat('2',1,numel(noWater_filt_PItestv2)),repmat('3',1,numel(noWater_filt_PItestv3)),repmat('4',1,numel(noWater_filt_PItestv4)),repmat('5',1,numel(noWater_filt_PItestv5))];
noWater_filt_PItestvg2=[noWater_filt_PItestv1,noWater_filt_PItestv2,noWater_filt_PItestv3,noWater_filt_PItestv4,noWater_filt_PItestv5];

figure(121); hold on; boxplot(noWater_filt_PItestG', {noWater_filt_PItestvg1';noWater_filt_PItestvg2'}, 'factorseparator',1 , 'factorgap',30,...
    'colorgroup',noWater_filt_PItestvg2','labelverbosity','majorminor'); title('Nicotine Effect on Lick Count - Filtered');
ylabel({'Platabililty Index Referenced to Water'},'fontweight','bold');xlabel('Tastants by Injection Condition','fontweight','bold'); hLine= refline(0,0); hLine.Color = 'k';
ylim([-2 20]);
color = ['c', 'y', 'c', 'y','c', 'y', 'c', 'y', 'c', 'y'];
h = findobj(gca,'Tag','Box');
for j=1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),color(j),'FaceAlpha',.5);
end
legend([color(2) color(6) color(3)],{'Water','Nicotine','Saline'});

%Remove all xtick labels
figure(121); set(gca,'xticklabel',{'a','b','c','d','e'});

%Add labels of tastants
tastants =regexprep(data_set.sessions_tastes_decode(1,:),',','');
text(0.5,-2.5,{tastants(1,1)});text(5.5,-2.5,{tastants(1,3)});text(10,-2.5,{tastants(1,4)});text(13.5,-2.5,{tastants(1,5)});text(18,-2.5,{tastants(1,6)});

%Run one-way ANOVAs
sucrose_pal = [filt_combined_saline_pal_index(:,1)';filt_combined_nicotine_pal_index(:,1)']';
nacl_pal = [filt_combined_saline_pal_index(:,3)';filt_combined_nicotine_pal_index(:,3)']';
QHCl_pal = [filt_combined_saline_pal_index(:,4)';filt_combined_nicotine_pal_index(:,4)']';
sach_pal = [filt_combined_saline_pal_index(:,5)';filt_combined_nicotine_pal_index(:,5)']';
citric_pal = [filt_combined_saline_pal_index(:,6)';filt_combined_nicotine_pal_index(:,6)']';

anovas_output = zeros(size(tastants,2)-1,1);
anovas_output(1) = anova1(sucrose_pal,[],'off'); anovas_output(2) = anova1(nacl_pal,[],'off');anovas_output(3) = anova1(QHCl_pal,[],'off');anovas_output(4) = anova1(sach_pal,[],'off');anovas_output(5) = anova1(citric_pal,[],'off');