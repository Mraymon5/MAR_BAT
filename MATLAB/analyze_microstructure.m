function [out_microstructure_test, IBP] = analyze_microstructure(input_struct);

%Establish number of days to analyze for loops
test_days = fieldnames(input_struct); trials =48; 
num_animals = size(fieldnames(input_struct.(cell2mat(test_days(1)))),1); %establish number of animals (assuming at least one day)

%Create matrix for doses
dose =zeros(size(test_days,1),num_animals,1);

%Variable for animals
all_animals = fieldnames(input_struct.(cell2mat(test_days(1))));

%{We want to pull out: 1) bouts (based on user input criteria); 2) bout length; 3) ILI within bouts%}
prompt_1 = {'Interbout Pause (IBP) in ms: '}; dlg_title_1 = 'Bout Criteria:'; num_lines_1 = 1;
defaultans_1 = {'500'}; labels_1 = inputdlg(prompt_1,dlg_title_1,num_lines_1,defaultans_1);

IBP = str2num(labels_1{1});

%Create structure for concatenating
microstructure_test = struct;

%Initiate loop and store data by (day,animal,data)
for day=1:size(test_days,1)
    animals = fieldnames(input_struct.(cell2mat(test_days(day))));
    for animal=1:size(animals,1)
        %Dataset Variable
        data_set = input_struct.(cell2mat(test_days(day))).(cell2mat(animals(animal)));
        day_read = cell2mat(test_days(day));
        
        %Lick_logic
        lick_log = data_set.licks_session;
        
        %Extract bottle info
        bottle_info = data_set.trial_data(:,3);
        
        %Obtain latency info
        %Cummulative sum lat_data, but exclude first column
        
        trial_bout_totals =NaN(trials,200); %licks in each bout (I put 200 arbitrarily because I have not seen more than this in my sessions)
        trial_pause_totals =NaN(trials,200); %where pauses are in each trial
        trial_pause_time_totals = NaN(trials,200); %how long each pause was in each trial
        
        %Flip through each row of data and perform logics to build arrays
        for row=1:length(data_set.latency_whole(:,1))
            %Enter dummie column to create sandwich block (grouping between
            %licks and intial pause) -REMOVE THIS IF DOESNT WORK
            dummie_column = ones(length(data_set.latency_whole(:,1)),1)*90000;
            cum_sum_lat_whole_new = horzcat(data_set.latency_whole(:,1),dummie_column,data_set.latency_whole(:,2:end));
            
            %cum_sum_lat_whole = cumsum(data_set.latency_whole(row,1:end)); %must perform this to account for absolute differences later
            cum_sum_lat_whole= cumsum(cum_sum_lat_whole_new(row,1:end));
                       
            %Find where licks do not exist
            check_unique = unique(cum_sum_lat_whole(:))';
            ILI_values =diff(check_unique(1,:));
            
            %Establish counts greater than bout paramter
            pause_location = diff(check_unique(1,:))>=IBP;
            pause_location_ext = pause_location; 
            pause_location_ext(end+1) =1; %places 1 at the end of pause_location to end trial
            pause_count = sum(diff(check_unique(1,:))>=IBP);
           
            %Microstructure variables
            pause_times = ILI_values(pause_location==1);
            pause_col = find(pause_location==1);
            pause_col_ext = find(pause_location_ext==1);
            
            bout_count = diff([pause_col])-1;
            bout_count_ext = diff([pause_col_ext])-1;
            
           % lick_bout_location= find(pause_location<1);
           % ILIs = ILI_values(lick_bout_location); %only for bout licks   
            lick_bout_location= find(pause_location_ext<1); 
            ILIs = ILI_values(lick_bout_location);
           
            trial_bout_totals(row,1:length(bout_count_ext)) = bout_count_ext;              
            trial_pause_totals(row,1:length(pause_col_ext)) = pause_col_ext;
            trial_pause_time_totals(row,1:length(pause_times)) = pause_times;
            
        end
        
        %store in structure
        microstructure_test.([day_read]).(cell2mat([all_animals(animal)])).('dose') = data_set.dose;
        microstructure_test.([day_read]).(cell2mat([all_animals(animal)])).('bottle_info') = bottle_info;
        microstructure_test.([day_read]).(cell2mat([all_animals(animal)])).('full_latency_matrix') = data_set.latency_whole;
        microstructure_test.([day_read]).(cell2mat([all_animals(animal)])).('cummulative_sum_latency_matrix') = data_set.cummulative_latency_trial;
        microstructure_test.([day_read]).(cell2mat([all_animals(animal)])).(['licks_bw_' num2str(IBP) 'ms_pause']) = trial_bout_totals;
        microstructure_test.([day_read]).(cell2mat([all_animals(animal)])).(['trial_' num2str(IBP) 'ms_pause']) = trial_pause_totals;
        microstructure_test.([day_read]).(cell2mat([all_animals(animal)])).(['pauses_exceeding_' num2str(IBP) 'ms_pause']) = trial_pause_time_totals;
        microstructure_test.([day_read]).(cell2mat([all_animals(animal)])).(['lick_trials_licks_bw_' num2str(IBP) 'ms_pause']) = trial_bout_totals(lick_log,:);
        microstructure_test.([day_read]).(cell2mat([all_animals(animal)])).(['lick_trials_trial_' num2str(IBP) 'ms_pause']) = trial_pause_totals(lick_log,:);
        microstructure_test.([day_read]).(cell2mat([all_animals(animal)])).(['lick_trials_pauses_exceeding' num2str(IBP) 'ms_pause']) = trial_pause_time_totals(lick_log,:);
        microstructure_test.([day_read]).(cell2mat([all_animals(animal)])).(['session_taste_decode']) = data_set.sessions_tastes_decode;
        microstructure_test.([day_read]).(cell2mat([all_animals(animal)])).(['lick_logic']) =lick_log;
    end
end    

out_microstructure_test =microstructure_test;