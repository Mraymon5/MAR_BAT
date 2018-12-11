%Go to appropriate directory and create test struct
test_folder_name = uigetdir('','Choose folder where the TESTING .txt files are'); 
[analyze_struct] = nico_testing_decode_Stone(test_folder_name);

%Create microstruct
[analyze_microstruct, pause_criteria] = analyze_microstructure(analyze_struct);

%Establish number of days to analyze for loops
test_days = fieldnames(analyze_microstruct); trials =48; num_tastes = 6;
num_animals = size(fieldnames(analyze_microstruct.(cell2mat(test_days(1)))),1); %establish number of animals (assuming at least one day)
all_animals = fieldnames(analyze_microstruct.(cell2mat(test_days(1))));
dose =zeros(size(test_days,1),num_animals,1); %4 = 2Test days CHANGE THIS NUMBER IF YOU ONLY WANT HAB5
lat_out=cell(size(test_days,1),num_animals);
first_bout_out=cell(size(test_days,1),num_animals);
bout_out=cell(size(test_days,1),num_animals);
bout_data_stacked = cell(size(test_days,1),num_tastes);

%Create structure for concatenating
microstructure_test = struct;

%Initiate loop and store data by (day,animal,data)
for day=1:size(test_days,1)
    animals = fieldnames(analyze_microstruct.(cell2mat(test_days(day))));
    for animal=1:size(animals,1)
        %animal_lick_bout = zeros(size(test_days,1),;
        bout_array = zeros(size(test_days,1),num_animals,trials/num_tastes,100);
        
        %Dataset Variable
        data_set = analyze_microstruct.(cell2mat(test_days(day))).(cell2mat(animals(animal)));
        cumsum_lick_data = data_set.cummulative_sum_latency_matrix(:,:);
        conv_cumsum_data = diff(cumsum_lick_data,1,2); %performs column-wise subractions
        dynamic_name = (['lick_trials_licks_bw_' num2str(pause_criteria) 'ms_pause']);
        bout_count = data_set.(dynamic_name)(:,:);
        IBP = pause_criteria; %interbout pause

        %establish drug day
        day_read = cell2mat(test_days(day));
        day_num = str2num(day_read(end:end));
        dose(day_num,animal) = str2num(regexprep(data_set.dose,'(\(|\))','')); %extracts only the numeric values; the added two is to account for habdays
            
        if str2num(regexprep(data_set.dose,'(\(|\))','')) >0
            drug_day=2;
        else
            drug_day=1;
        end
        
        %perform bottle logic on lick data
        tastant_logic = data_set.bottle_info(data_set.lick_logic);
        
        %flip through bottle logic and ILI data to build arrays
        taste_log_1 = find(tastant_logic==1); taste_log_2 = find(tastant_logic==2);
        taste_log_3 = find(tastant_logic==3); taste_log_4 = find(tastant_logic==4);
        taste_log_5 = find(tastant_logic==5); taste_log_6 = find(tastant_logic==6);
        
        %extract latency data based on taste logic
        taste_data_1 = conv_cumsum_data(taste_log_1,:);taste_data_2 = conv_cumsum_data(taste_log_2,:);
        taste_data_3 = conv_cumsum_data(taste_log_3,:);taste_data_4 = conv_cumsum_data(taste_log_4,:);
        taste_data_5 = conv_cumsum_data(taste_log_5,:);taste_data_6 = conv_cumsum_data(taste_log_6,:);
        
        %extract bout data based on taste logic
        taste_bout_data_1 = bout_count(taste_log_1,:);taste_bout_data_2 = bout_count(taste_log_2,:);
        taste_bout_data_3 = bout_count(taste_log_3,:);taste_bout_data_4 = bout_count(taste_log_4,:);
        taste_bout_data_5 = bout_count(taste_log_5,:);taste_bout_data_6 = bout_count(taste_log_6,:);
        
        %use IBP criteria to store only latencies < user input
        taste_1_IBP = taste_data_1(taste_data_1<IBP);taste_2_IBP = taste_data_2(taste_data_2<IBP);
        taste_3_IBP = taste_data_3(taste_data_3<IBP);taste_4_IBP = taste_data_4(taste_data_4<IBP);
        taste_5_IBP = taste_data_5(taste_data_5<IBP);taste_6_IBP = taste_data_6(taste_data_6<IBP);
        
        %convert mistakenly made (if vector only has 2 variables) row
        %vectors to column vector for padcat -- later
        taste_1_IBP = taste_1_IBP(:);taste_2_IBP = taste_2_IBP(:);
        taste_3_IBP = taste_3_IBP(:);taste_4_IBP = taste_4_IBP(:);
        taste_5_IBP = taste_5_IBP(:);taste_6_IBP = taste_6_IBP(:);
        
        %Place fake value in array for animals who only licked 1 trial, 1
        %time (I use 900 because it is an impossible amount of licks)
        size_check = [size(taste_bout_data_1,1);size(taste_bout_data_2,1);size(taste_bout_data_3,1);size(taste_bout_data_4,1);size(taste_bout_data_5,1);size(taste_bout_data_6,1);];
        for val=1:length(size_check)
            if size_check(val,1) ==1
               switch val
                    case 1
                        taste_bout_data_1(end+1,1:end) = 900;
                    case 2
                        taste_bout_data_2(end+1,1:end) = 900;
                    case 3
                        taste_bout_data_3(end+1,1:end) = 900;
                    case 4
                        taste_bout_data_4(end+1,1:end) = 900;
                    case 5
                        taste_bout_data_5(end+1,1:end) = 900;
                    case 6
                        taste_bout_data_6(end+1,1:end) = 900;
                end
            end
        end
        
        %store taste data (stacked) for all animals in one matrix (by
        %condition and taste)
        bout_data_stacked{drug_day,1} = vertcat(bout_data_stacked{drug_day,1},taste_bout_data_1);
        bout_data_stacked{drug_day,2} = vertcat(bout_data_stacked{drug_day,2},taste_bout_data_2);
        bout_data_stacked{drug_day,3} = vertcat(bout_data_stacked{drug_day,3},taste_bout_data_3);
        bout_data_stacked{drug_day,4} = vertcat(bout_data_stacked{drug_day,4},taste_bout_data_4);
        bout_data_stacked{drug_day,5} = vertcat(bout_data_stacked{drug_day,5},taste_bout_data_5);
        bout_data_stacked{drug_day,6} = vertcat(bout_data_stacked{drug_day,6},taste_bout_data_6);
        
        
        %store mean licks in bouts into variables (without including 0s and
        %Nan values
        [ii,~,v] = find(taste_bout_data_1); mean_bout_taste_1 = accumarray(ii,v,[],@nanmean);
        [ii,~,v] = find(taste_bout_data_2); mean_bout_taste_2 = accumarray(ii,v,[],@nanmean);
        [ii,~,v] = find(taste_bout_data_3); mean_bout_taste_3 = accumarray(ii,v,[],@nanmean);
        [ii,~,v] = find(taste_bout_data_4); mean_bout_taste_4 = accumarray(ii,v,[],@nanmean);
        [ii,~,v] = find(taste_bout_data_5); mean_bout_taste_5 = accumarray(ii,v,[],@nanmean);
        [ii,~,v] = find(taste_bout_data_6); mean_bout_taste_6 = accumarray(ii,v,[],@nanmean);
        
        %place dummie data in matrix if empty (chose 15ms as value bc
        %impossible lick latency)
        empty_check = [isempty(taste_1_IBP); isempty(taste_2_IBP);isempty(taste_3_IBP); isempty(taste_4_IBP);isempty(taste_5_IBP); isempty(taste_6_IBP)];
        for val=1:length(empty_check)
            if empty_check(val,1) >0
                switch val
                    case 1
                        taste_1_IBP = [15];
                    case 2
                        taste_2_IBP = [15];
                    case 3
                        taste_3_IBP = [15];
                    case 4
                        taste_4_IBP = [15];
                    case 5
                        taste_5_IBP = [15];
                    case 6
                        taste_6_IBP = [15];
                end
            end
        end
        
        %store in cell matrix (row 1 = saline, row 2= nicotine; column =
        %animal)
        lat_out{drug_day,animal}=padcat(taste_1_IBP,taste_2_IBP,taste_3_IBP,taste_4_IBP,taste_5_IBP,taste_6_IBP);
        bout_out{drug_day,animal}=padcat(mean_bout_taste_1,mean_bout_taste_2,mean_bout_taste_3,mean_bout_taste_4,mean_bout_taste_5,mean_bout_taste_6);   
        first_bout_out{drug_day,animal}=padcat(taste_bout_data_1(:,1),taste_bout_data_2(:,1),taste_bout_data_3(:,1),taste_bout_data_4(:,1),taste_bout_data_5(:,1),taste_bout_data_6(:,1));
    end
end    

%create taste decode array
tastes = regexprep(data_set.session_taste_decode(1,:),',','');

%output tables for easy analyses (using function written 'cell2array.m')
lat_table = cell2array(lat_out,animals,tastes);
bout_table = cell2array(bout_out,animals,tastes);
first_bout_table = cell2array(first_bout_out,animals,tastes);

%Histogram ILI plotting by animal for a "sanity check" that the rig is working
for animal=1:num_animals
    for taste=1:num_tastes
        legend_mean = [];
        for day=1:size(test_days,1);
            data_array = cell2mat(lat_out(day,animal));
            figure(animal); subplot(2,3,taste);histogram(data_array(:,taste));hold on;
            title([tastes(taste)]);ylim([0 700]);%vline(mean(data_array(:,taste)),'k');
            legend_mean(end+1)= nanmean(data_array(:,taste));
        end
        %legend shows mean ILIs by taste: Blue = Saline; Pink = Nicotine
        legend(num2str(legend_mean(1)),num2str(legend_mean(2)));
    end
    suptitle(['ILIs - ' all_animals(animal)]);
end
           
%Histogram bout plotting by animal
for animal=1:num_animals
    for taste=1:num_tastes
        legend_mean = [];
        for day=1:size(test_days,1);
            data_array = cell2mat(bout_out(day,animal));
            figure(animal); subplot(2,3,taste);histogram(data_array(:,taste));hold on;
            title([tastes(taste)]);%ylim([0 700]);%vline(mean(data_array(:,taste)),'k');
            legend_mean(end+1)= nanmean(data_array(:,taste));
        end
        %legend shows mean ILIs by taste: Blue = Saline; Pink = Nicotine
        legend(num2str(legend_mean(1)),num2str(legend_mean(2)));
    end
    suptitle([all_animals(animal)]);
end          

%Grabbing bout means (store by day, by animal, by tastes (6))
mean_out = cell(size(test_days,1),1);std_out = cell(size(test_days,1),1);SEM_out= cell(size(test_days,1),1);
for day=1:size(test_days,1)
    mean_vals = [];std_vals =[];SEM_vals =[];
    for animal=1:num_animals
        data_array = cell2mat(bout_out(day,animal));
        %Fix fake value (900) and store means
        dummie_logic = data_array==900; data_array(dummie_logic)=NaN;
        mean_vals(end+1,:)  =  nanmean(data_array); %Stores means
        std_vals(end+1,:)  =  nanstd(data_array) ; %stores STD
        SEM_vals(end+1,:)  =  nanstd(data_array)./sqrt(size(data_array,1)); %stores SEM 
    end
    %Fix fake value (900) and store means
    %dummie_logic = mean_vals==900; mean_vals(dummie_logic)=NaN;
    mean_out{day} = mean_vals; std_out{day} = std_vals; SEM_out{day} = SEM_vals;
end 

%Plot it
sal_means = [nanmean(mean_out{1,1}(:,1)); nanmean(mean_out{1,1}(:,2)); nanmean(mean_out{1,1}(:,3)); nanmean(mean_out{1,1}(:,4)); nanmean(mean_out{1,1}(:,5)); nanmean(mean_out{1,1}(:,6))];
nico_means = [nanmean(mean_out{2,1}(:,1)); nanmean(mean_out{2,1}(:,2)); nanmean(mean_out{2,1}(:,3)); nanmean(mean_out{2,1}(:,4)); nanmean(mean_out{2,1}(:,5)); nanmean(mean_out{2,1}(:,6))];
%sal_std = [nanstd(std_out{1,1}(:,1)); nanstd(std_out{1,1}(:,2)); nanstd(std_out{1,1}(:,3)); nanstd(std_out{1,1}(:,4)); nanstd(std_out{1,1}(:,5)); nanstd(std_out{1,1}(:,6))];
%nico_std = [nanstd(std_out{2,1}(:,1)); nanstd(std_out{2,1}(:,2)); nanstd(std_out{2,1}(:,3)); nanstd(std_out{2,1}(:,4)); nanstd(std_out{2,1}(:,5)); nanstd(std_out{2,1}(:,6))];
sal_SEM = [nanstd(SEM_out{1,1}(:,1))./size(SEM_out{1,1}(:,1),1); nanstd(SEM_out{1,1}(:,2))./size(SEM_out{1,1}(:,2),1); nanstd(SEM_out{1,1}(:,3))./size(SEM_out{1,1}(:,3),1); nanstd(SEM_out{1,1}(:,4))./size(SEM_out{1,1}(:,4),1); nanstd(SEM_out{1,1}(:,5))./size(SEM_out{1,1}(:,5),1); nanstd(SEM_out{1,1}(:,6))./size(SEM_out{1,1}(:,6),1)];
nico_SEM = [nanstd(SEM_out{2,1}(:,1))./size(SEM_out{2,1}(:,1),1); nanstd(SEM_out{2,1}(:,2))./size(SEM_out{2,1}(:,2),1); nanstd(SEM_out{2,1}(:,3))./size(SEM_out{2,1}(:,3),1); nanstd(SEM_out{2,1}(:,4))./size(SEM_out{2,1}(:,4),1); nanstd(SEM_out{2,1}(:,5))./size(SEM_out{2,1}(:,5),1); nanstd(SEM_out{2,1}(:,6))./size(SEM_out{2,1}(:,6),1)];

h= barwitherr([sal_SEM nico_SEM],[sal_means nico_means]); %Special function I NEED TO FIX THESE ERROR BARS
ylabel('Mean Licks in Bout'); set(gca,'xticklabel',tastes.'); 
set(h(1),'FaceColor',[0 0 1],'FaceAlpha',[0.5]);set(h(2),'FaceColor',[0 1 1],'FaceAlpha',[0.5]);
title({'Nicotine Effect on Licks in Bout';['(Bout = licks preceeeding ' num2str(pause_criteria) 'ms pause)']});
legend('Control','Nicotine');


%Grabbing latency means (store by day, by animal, by tastes (6))
mean_lat_out = cell(size(test_days,1),1);std_lat_out = cell(size(test_days,1),1);SEM_lat_out= cell(size(test_days,1),1);
for day=1:size(test_days,1)
    mean_lat_vals = [];std_lat_vals =[];SEM_lat_vals =[];
    for animal=1:num_animals
        data_array = cell2mat(lat_out(day,animal));
        mean_lat_vals(end+1,:)  =  nanmean(data_array); %Stores means
        std_lat_vals(end+1,:)  =  nanstd(data_array) ; %stores STD
        SEM_lat_vals(end+1,:)  =  nanstd(data_array)./sqrt(size(data_array,1)); %stores SEM 
    end
    %Fix fake value (15) and store means
    dummie_lat_logic = mean_lat_vals==15; mean_lat_vals(dummie_lat_logic)=NaN;
    mean_lat_out{day} = mean_lat_vals; std_lat_out{day} = std_lat_vals; SEM_lat_out{day} = SEM_lat_vals;
end 

%Plot it
sal_lat_means = [nanmean(mean_lat_out{1,1}(:,1)); nanmean(mean_lat_out{1,1}(:,2)); nanmean(mean_lat_out{1,1}(:,3)); nanmean(mean_lat_out{1,1}(:,4)); nanmean(mean_lat_out{1,1}(:,5)); nanmean(mean_lat_out{1,1}(:,6))];
nico_lat_means = [nanmean(mean_lat_out{2,1}(:,1)); nanmean(mean_lat_out{2,1}(:,2)); nanmean(mean_lat_out{2,1}(:,3)); nanmean(mean_lat_out{2,1}(:,4)); nanmean(mean_lat_out{2,1}(:,5)); nanmean(mean_lat_out{2,1}(:,6))];
sal_lat_SEM = [nanstd(SEM_lat_out{1,1}(:,1))./size(SEM_lat_out{1,1}(:,1),1); nanstd(SEM_lat_out{1,1}(:,2))./size(SEM_lat_out{1,1}(:,2),1); nanstd(SEM_lat_out{1,1}(:,3))./size(SEM_lat_out{1,1}(:,3),1); nanstd(SEM_lat_out{1,1}(:,4))./size(SEM_lat_out{1,1}(:,4),1); nanstd(SEM_lat_out{1,1}(:,5))./size(SEM_lat_out{1,1}(:,5),1); nanstd(SEM_lat_out{1,1}(:,6))./size(SEM_lat_out{1,1}(:,6),1)];
nico_lat_SEM = [nanstd(SEM_lat_out{2,1}(:,1))./size(SEM_lat_out{2,1}(:,1),1); nanstd(SEM_lat_out{2,1}(:,2))./size(SEM_lat_out{2,1}(:,2),1); nanstd(SEM_lat_out{2,1}(:,3))./size(SEM_lat_out{2,1}(:,3),1); nanstd(SEM_lat_out{2,1}(:,4))./size(SEM_lat_out{2,1}(:,4),1); nanstd(SEM_lat_out{2,1}(:,5))./size(SEM_lat_out{2,1}(:,5),1); nanstd(SEM_lat_out{2,1}(:,6))./size(SEM_lat_out{2,1}(:,6),1)];


b= barwitherr([sal_lat_SEM nico_lat_SEM],[sal_lat_means nico_lat_means]); %Special function FIX THESE ERROR BARS
ylabel('Mean Latencies in Bout'); set(gca,'xticklabel',tastes.'); 
set(b(1),'FaceColor',[0 0 1],'FaceAlpha',[0.5]);set(b(2),'FaceColor',[0 1 1],'FaceAlpha',[0.5]);
title({'Nicotine Effect on ILIs w/in Bout';['(Bout = licks preceeeding ' num2str(pause_criteria) 'ms pause)']});
legend('Control','Nicotine');

%Grabbing latency means (store by day, by animal, by tastes (6))
mean_first_bout_out = cell(size(test_days,1),1);SEM_first_bout_out= cell(size(test_days,1),1);
%mean_first_bout_out_all = [];
for day=1:size(test_days,1)
    mean_first_bout_vals = [];SEM_first_bout_vals =[];
    for animal=1:num_animals
        data_array = cell2mat(first_bout_out(day,animal));
        %Fix fake value (900) and store means
        dummie_logic = data_array==900; data_array(dummie_logic)=NaN;
        %filter out zeros
        data_array(data_array==0)=NaN;
        mean_first_bout_vals(end+1,:)  =  nanmean(data_array); %Stores means
        SEM_first_bout_vals(end+1,:)  =  nanstd(data_array)./sqrt(size(data_array,1)); %stores SEM 
    end
    %Fix fake value (15) and store means
   % dummie_logic = mean_first_bout_vals==900; mean_first_bout_vals(dummie_logic)=NaN;
    mean_first_bout_out{day} = mean_first_bout_vals; SEM_first_bout_out{day} = SEM_first_bout_vals;
    %mean_first_bout_out_all = vertcat(mean_first_bout_out_all,mean_first_bout_vals);
end 

%combine for stats
anovas_output = zeros(num_tastes,1); first_bout_sal = [];first_bout_nico = []; anovas_output_nozeros = zeros(num_tastes,1);
wilcox_output = zeros(num_tastes,1); wilcox_output_nozeros = zeros(num_tastes,1);
pttest_output = zeros(num_tastes,1); pttest_output_nozeros = zeros(num_tastes,1);
first_bout_array = cellfun(@(x)x(:,1),bout_data_stacked,'UniformOutput',false);
first_bout_comb_sal = [];first_bout_comb_nico = []; 
mean_first_nico_nz = []; mean_first_sal_nz = []; sem_first_nico_nz = [];sem_first_sal_nz = [];
mean_first_nico = []; mean_first_sal = []; sem_first_nico = [];sem_first_sal = [];

for taste=1:num_tastes

   %combine all animal data for given taste
    first_bout_comb_sal=[first_bout_comb_sal;first_bout_array{1,taste}(:)];
    first_bout_comb_nico =[first_bout_comb_nico;first_bout_array{2,taste}(:)];
    
    %remove 900s
    first_bout_comb_sal =first_bout_comb_sal'; first_bout_comb_sal(first_bout_comb_sal==900)=[]; first_bout_comb_sal = first_bout_comb_sal';
    first_bout_comb_nico =first_bout_comb_nico'; first_bout_comb_nico(first_bout_comb_nico==900)=[]; first_bout_comb_nico = first_bout_comb_nico';
    
    % %remove zeros (trials where licking did not occur)
    first_bout_sal_nz =first_bout_comb_sal'; first_bout_sal_nz(first_bout_sal_nz==0)=[]; first_bout_sal_nz = first_bout_sal_nz';
    first_bout_nico_nz =first_bout_comb_nico'; first_bout_nico_nz(first_bout_nico_nz==0)=[]; first_bout_nico_nz = first_bout_nico_nz';
        
    %pad vectors based on length no zeros
    max_len=max(numel(first_bout_sal_nz),numel(first_bout_nico_nz));
    first_bout_sal_nz(end+1:max_len)=nan; first_bout_nico_nz(end+1:max_len)=nan;
    mean_first_sal_nz = horzcat(mean_first_sal_nz,nanmean(first_bout_sal_nz)); mean_first_nico_nz = horzcat(mean_first_nico_nz,nanmean(first_bout_nico_nz));
    sem_first_sal_nz = horzcat(sem_first_sal_nz,nanstd((first_bout_sal_nz)/sqrt(size(first_bout_sal_nz,1)))); sem_first_nico_nz = horzcat(sem_first_nico_nz,nanstd((first_bout_nico_nz)/sqrt(size(first_bout_nico_nz,1))));
    
    %pad vectors based on length
    max_len=max(numel(first_bout_comb_sal),numel(first_bout_comb_nico));
    first_bout_comb_sal(end+1:max_len)=nan; first_bout_comb_nico(end+1:max_len)=nan;
    mean_first_sal = horzcat(mean_first_sal,nanmean(first_bout_comb_sal)); mean_first_nico = horzcat(mean_first_nico,nanmean(first_bout_comb_nico));
    sem_first_sal = horzcat(sem_first_sal,nanstd((first_bout_comb_sal)/sqrt(size(first_bout_comb_sal,1)))); sem_first_nico = horzcat(sem_first_nico,nanstd((first_bout_comb_nico)/sqrt(size(first_bout_comb_nico,1))));
    
    %combine taste on condition and perform ANOVAs
    comb_condition = horzcat(first_bout_comb_sal,first_bout_comb_nico);
    %anovas_output(taste) = anova1(comb_condition,[],'off');
    [h,p] = kstest2(first_bout_comb_sal,first_bout_comb_nico);
    wilcox_output(taste) = ranksum(first_bout_comb_sal,first_bout_comb_nico);
    pttest_output(taste) = ttest(first_bout_comb_sal,first_bout_comb_nico);
    
    comb_condition_nz = horzcat(first_bout_sal_nz,first_bout_nico_nz);
    %anovas_output_nozeros(taste) = anova1(comb_condition_nz,[],'off');
    [h1,p1] = kstest2(first_bout_sal_nz,first_bout_nico_nz);
    wilcox_output_nozeros(taste) = ranksum(first_bout_sal_nz,first_bout_nico_nz);
    pttest_output_nozeros(taste) = ttest(first_bout_comb_sal,first_bout_comb_nico);
    
    %reset variables
    first_bout_comb_sal = [];first_bout_comb_nico = [];
    first_bout_sal_nz = [];first_bout_nico_nz = [];
end

% %one-way ANOVA
% anovas_output(1) = anova1(data,groups,'off'); anovas_output(2) = anova1(nacl_pal,[],'off');anovas_output(3) = anova1(QHCl_pal,[],'off');anovas_output(4) = anova1(sach_pal,[],'off');anovas_output(5) = anova1(citric_pal,[],'off');
c= barwitherr([sem_first_sal' sem_first_nico'],[mean_first_sal' mean_first_nico']); %Special function
ylabel('Mean Lick in First Bout'); set(gca,'xticklabel',tastes.'); 
set(c(1),'FaceColor',[0 0 1],'FaceAlpha',[0.5]);set(c(2),'FaceColor',[0 1 1],'FaceAlpha',[0.5]);
title({'Nicotine Effect on First Lick Bout';['(Bout = licks preceeeding ' num2str(pause_criteria) 'ms pause)']});
legend('Control','Nicotine');

figure(2); c= barwitherr([sem_first_sal' sem_first_nico'],[mean_first_sal_nz' mean_first_nico_nz']); %Special function
ylabel('Mean Lick in First Bout'); set(gca,'xticklabel',tastes.'); 
set(c(1),'FaceColor',[0 0 1],'FaceAlpha',[0.5]);set(c(2),'FaceColor',[0 1 1],'FaceAlpha',[0.5]);
title({'Nicotine Effect on First Lick Bout - Filtered';['(Bout = licks preceeeding ' num2str(pause_criteria) 'ms pause)']});
legend('Control','Nicotine');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%OLD%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%Plot it
sal_first_bout_means = [nanmean(mean_first_bout_out{1,1}(:,1)); nanmean(mean_first_bout_out{1,1}(:,2)); nanmean(mean_first_bout_out{1,1}(:,3)); nanmean(mean_first_bout_out{1,1}(:,4)); nanmean(mean_first_bout_out{1,1}(:,5)); nanmean(mean_first_bout_out{1,1}(:,6))];
nico_first_bout_means = [nanmean(mean_first_bout_out{2,1}(:,1)); nanmean(mean_first_bout_out{2,1}(:,2)); nanmean(mean_first_bout_out{2,1}(:,3)); nanmean(mean_first_bout_out{2,1}(:,4)); nanmean(mean_first_bout_out{2,1}(:,5)); nanmean(mean_first_bout_out{2,1}(:,6))];
sal_first_bout_SEM = [nanstd(SEM_first_bout_out{1,1}(:,1))./size(SEM_first_bout_out{1,1}(:,1),1); nanstd(SEM_first_bout_out{1,1}(:,2))./size(SEM_first_bout_out{1,1}(:,2),1); nanstd(SEM_first_bout_out{1,1}(:,3))./size(SEM_first_bout_out{1,1}(:,3),1); nanstd(SEM_first_bout_out{1,1}(:,4))./size(SEM_first_bout_out{1,1}(:,4),1); nanstd(SEM_first_bout_out{1,1}(:,5))./size(SEM_first_bout_out{1,1}(:,5),1); nanstd(SEM_first_bout_out{1,1}(:,6))./size(SEM_first_bout_out{1,1}(:,6),1)];
nico_first_bout_SEM = [nanstd(SEM_first_bout_out{2,1}(:,1))./size(SEM_first_bout_out{2,1}(:,1),1); nanstd(SEM_first_bout_out{2,1}(:,2))./size(SEM_first_bout_out{2,1}(:,2),1); nanstd(SEM_first_bout_out{2,1}(:,3))./size(SEM_first_bout_out{2,1}(:,3),1); nanstd(SEM_first_bout_out{2,1}(:,4))./size(SEM_first_bout_out{2,1}(:,4),1); nanstd(SEM_first_bout_out{2,1}(:,5))./size(SEM_first_bout_out{2,1}(:,5),1); nanstd(SEM_first_bout_out{2,1}(:,6))./size(SEM_first_bout_out{2,1}(:,6),1)];

c= barwitherr([sal_first_bout_SEM nico_first_bout_SEM],[sal_first_bout_means nico_first_bout_means]); %Special function
ylabel('Mean Lick in First Bout'); set(gca,'xticklabel',tastes.'); 
set(c(1),'FaceColor',[0 0 1],'FaceAlpha',[0.5]);set(c(2),'FaceColor',[0 1 1],'FaceAlpha',[0.5]);
title({'Nicotine Effect on First Lick Bout';['(Bout = licks preceeeding ' num2str(pause_criteria) 'ms pause)']});
legend('Control','Nicotine');