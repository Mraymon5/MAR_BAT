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
%Table will have 8 columns (2nd column = condition; 0 = saline/ 1 = Nico)
lat_table = cell2array(lat_out,0,animals,tastes);
bout_table = cell2array(bout_out,1,animals,tastes);
first_bout_table = cell2array(first_bout_out,2,animals,tastes);

% %plotting
% tf = (lat_table.condition == 0);
% h1 = histogram(lat_table.SUCROSE(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
% hold on
% tf2 = (lat_table.condition == 1);
% h2 = histogram(lat_table.SUCROSE(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
% legend('Saline','Nicotine'); xlabel('Interlick Interval (ILI)'); ylabel('Number of licks');
% hold off; title('Sucrose');

%all tastes plots
%ILIs
figure(); 
subplot(3,2,1); tf = (lat_table.condition == 0); h1 = histogram(lat_table.SUCROSE(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (lat_table.condition == 1); h2 = histogram(lat_table.SUCROSE(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Interlick Interval (ILI)'); ylabel('Number of licks'); title('Sucrose');
hold off
subplot(3,2,2); tf = (lat_table.condition == 0); h1 = histogram(lat_table.WATER(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (lat_table.condition == 1); h2 = histogram(lat_table.WATER(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Interlick Interval (ILI)'); ylabel('Number of licks'); title('Water');
hold off
subplot(3,2,3); tf = (lat_table.condition == 0); h1 = histogram(lat_table.NaCl(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (lat_table.condition == 1); h2 = histogram(lat_table.NaCl(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Interlick Interval (ILI)'); ylabel('Number of licks'); title('NaCl');
hold off
subplot(3,2,4); tf = (lat_table.condition == 0); h1 = histogram(lat_table.QHC(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (lat_table.condition == 1); h2 = histogram(lat_table.QHC(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Interlick Interval (ILI)'); ylabel('Number of licks'); title('QHCl');
hold off
subplot(3,2,5); tf = (lat_table.condition == 0); h1 = histogram(lat_table.SACCHARINE(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (lat_table.condition == 1); h2 = histogram(lat_table.SACCHARINE(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Interlick Interval (ILI)'); ylabel('Number of licks'); title('Saccharine');
hold off
subplot(3,2,6); tf = (lat_table.condition == 0); h1 = histogram(lat_table.CITRICACID(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (lat_table.condition == 1); h2 = histogram(lat_table.CITRICACID(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Interlick Interval (ILI)'); ylabel('Number of licks'); title('Citric Acid');
suptitle({'Nicotine Effect on ILIs w/in Bout';['(Bout = licks preceeeding ' num2str(pause_criteria) 'ms pause)']});
hold off
% [h,p] = ttest2(lat_table.SUCROSE(tf),lat_table.SUCROSE(tf2))

%group stats
dsa = lat_table(:,{'condition','SUCROSE','WATER','NaCl','QHC','SACCHARINE','CITRICACID'});
statarraygroup = grpstats(dsa,'condition'); statarray_sem_group = grpstats(dsa,'condition',{'sem'}); %by animal/condition
dsa = lat_table(:,{'animal','condition','SUCROSE','WATER','NaCl','QHC','SACCHARINE','CITRICACID'});
statarray = grpstats(dsa,{'animal','condition'}); statarray_sem = grpstats(dsa,{'animal','condition'},{'sem'}); %by animal/condition
t1 = statarraygroup(1,3:end); t2 = statarraygroup(2,3:end); t3 = statarray_sem_group(1,3:end); t4 = statarray_sem_group(2,3:end); 

%barplot
%bar([t1.Variables' t2.Variables'],'grouped') 
figure();
c= barwitherr([t3.Variables' t4.Variables'],[t1.Variables' t2.Variables']); ax = gca; ax.XTickLabel = tastes; legend('Saline','Nicotine'); 
ylabel('Interlick Interval (ILI; ms)');title({'Nicotine Effect on ILIs w/in Bout';['(Bout = licks preceeeding ' num2str(pause_criteria) 'ms pause)']});
ylim=get(gca,'ylim');xlim=get(gca,'xlim');%text(xlim(1)+0.2,ylim(2)-5,['N = ' num2str(size(statarray.animal,1)/2)]);
hf = gcf;dim = [0.15 0.4 0.5 0.5];han = annotation(hf, 'textbox', dim, 'String', ['N = ' num2str(size(statarray.animal,1)/2)],'FitBoxToText', 'on');

%Licks in bout (all)
figure(); 
subplot(3,2,1); tf = (bout_table.condition == 0); h1 = histogram(bout_table.SUCROSE(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (bout_table.condition == 1); h2 = histogram(bout_table.SUCROSE(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Bout Length'); ylabel('Number of Bouts'); title('Sucrose');
hold off
subplot(3,2,2); tf = (bout_table.condition == 0); h1 = histogram(bout_table.WATER(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (bout_table.condition == 1); h2 = histogram(bout_table.WATER(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Bout Length'); ylabel('Number of Bouts'); title('Water');
hold off
subplot(3,2,3); tf = (bout_table.condition == 0); h1 = histogram(bout_table.NaCl(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (bout_table.condition == 1); h2 = histogram(bout_table.NaCl(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Bout Length'); ylabel('Number of Bouts'); title('NaCl');
hold off
subplot(3,2,4); tf = (bout_table.condition == 0); h1 = histogram(bout_table.QHC(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (bout_table.condition == 1); h2 = histogram(bout_table.QHC(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Bout Length'); ylabel('Number of Bouts'); title('QHCl');
hold off
subplot(3,2,5); tf = (bout_table.condition == 0); h1 = histogram(bout_table.SACCHARINE(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (bout_table.condition == 1); h2 = histogram(bout_table.SACCHARINE(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Bout Length'); ylabel('Number of Bouts'); title('Saccharine');
hold off
subplot(3,2,6); tf = (bout_table.condition == 0); h1 = histogram(bout_table.CITRICACID(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (bout_table.condition == 1); h2 = histogram(bout_table.CITRICACID(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Bout Length (licks)'); ylabel('Number of Bouts'); title('Citric Acid');
suptitle({'Nicotine Effect on licks w/in Bout';['(Bout = licks preceeeding ' num2str(pause_criteria) 'ms pause)']});
hold off

%group stats
dsa = bout_table(:,{'condition','SUCROSE','WATER','NaCl','QHC','SACCHARINE','CITRICACID'});
statarraygroup = grpstats(dsa,'condition'); statarray_sem_group = grpstats(dsa,'condition',{'sem'}); %by animal/condition
dsa = bout_table(:,{'animal','condition','SUCROSE','WATER','NaCl','QHC','SACCHARINE','CITRICACID'});
statarray = grpstats(dsa,{'animal','condition'}); statarray_sem = grpstats(dsa,{'animal','condition'},{'sem'}); %by animal/condition
t1 = statarraygroup(1,3:end); t2 = statarraygroup(2,3:end); t3 = statarray_sem_group(1,3:end); t4 = statarray_sem_group(2,3:end); 

%barplot
%bar([t1.Variables' t2.Variables'],'grouped');
figure();
c= barwitherr([t3.Variables' t4.Variables'],[t1.Variables' t2.Variables']); ax = gca; ax.XTickLabel = tastes; legend('Saline','Nicotine'); 
ylabel('Bout length (licks)');title({'Nicotine Effect on Licks w/in Bout';['(Bout = licks preceeeding ' num2str(pause_criteria) 'ms pause)']});
ylim=get(gca,'ylim');xlim=get(gca,'xlim');%text(xlim(1)+0.2,ylim(2)-5,['N = ' num2str(size(statarray.animal,1)/2)]);
hf = gcf;dim = [0.15 0.4 0.5 0.5];han = annotation(hf, 'textbox', dim, 'String', ['N = ' num2str(size(statarray.animal,1)/2)],'FitBoxToText', 'on');

% [h,p] = ttest2(bout_table.SUCROSE(tf),bout_table.SUCROSE(tf2)) 
% [h,p] = ttest2(bout_table.WATER(tf),bout_table.WATER(tf2))
% [h,p] = ttest2(bout_table.NaCl(tf),bout_table.NaCl(tf2))
% [h,p] = ttest2(bout_table.QHC(tf),bout_table.QHC(tf2))
% [h,p] = ttest2(bout_table.SACCHARINE(tf),bout_table.SACCHARINE(tf2))
% [h,p] = ttest2(bout_table.CITRICACID(tf),bout_table.CITRICACID(tf2))

%Licks in bout (first)
figure(); 
subplot(3,2,1); tf = (first_bout_table.condition == 0); h1 = histogram(first_bout_table.SUCROSE(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (first_bout_table.condition == 1); h2 = histogram(first_bout_table.SUCROSE(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Bout Length'); ylabel('Number of Bouts'); title('Sucrose');
hold off
subplot(3,2,2); tf = (first_bout_table.condition == 0); h1 = histogram(first_bout_table.WATER(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (first_bout_table.condition == 1); h2 = histogram(first_bout_table.WATER(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Bout Length'); ylabel('Number of Bouts'); title('Water');
hold off
subplot(3,2,3); tf = (first_bout_table.condition == 0); h1 = histogram(first_bout_table.NaCl(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (first_bout_table.condition == 1); h2 = histogram(first_bout_table.NaCl(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Bout Length'); ylabel('Number of Bouts'); title('NaCl');
hold off
subplot(3,2,4); tf = (first_bout_table.condition == 0); h1 = histogram(first_bout_table.QHC(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (first_bout_table.condition == 1); h2 = histogram(first_bout_table.QHC(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Bout Length'); ylabel('Number of Bouts'); title('QHCl');
hold off
subplot(3,2,5); tf = (first_bout_table.condition == 0); h1 = histogram(first_bout_table.SACCHARINE(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (first_bout_table.condition == 1); h2 = histogram(first_bout_table.SACCHARINE(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Bout Length'); ylabel('Number of Bouts'); title('Saccharine');
hold off
subplot(3,2,6); tf = (first_bout_table.condition == 0); h1 = histogram(first_bout_table.CITRICACID(tf),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
hold on; tf2 = (first_bout_table.condition == 1); h2 = histogram(first_bout_table.CITRICACID(tf2),'BinMethod','integers','DisplayStyle','stairs','LineWidth',2);
legend('Saline','Nicotine'); xlabel('Bout Length (licks)'); ylabel('Number of Bouts'); title('Citric Acid');
suptitle({'Nicotine Effect on licks w/in First Bout';['(Bout = licks preceeeding ' num2str(pause_criteria) 'ms pause)']});
hold off

%group stats
dsa = first_bout_table(:,{'condition','SUCROSE','WATER','NaCl','QHC','SACCHARINE','CITRICACID'});
statarraygroup = grpstats(dsa,'condition'); statarray_sem_group = grpstats(dsa,'condition',{'sem'}); %by animal/condition
dsa = first_bout_table(:,{'animal','condition','SUCROSE','WATER','NaCl','QHC','SACCHARINE','CITRICACID'});
statarray = grpstats(dsa,{'animal','condition'}); statarray_sem = grpstats(dsa,{'animal','condition'},{'sem'}); %by animal/condition
t1 = statarraygroup(1,3:end); t2 = statarraygroup(2,3:end); t3 = statarray_sem_group(1,3:end); t4 = statarray_sem_group(2,3:end); 

%barplot
%bar([t1.Variables' t2.Variables'],'grouped'); 
figure();
c= barwitherr([t3.Variables' t4.Variables'],[t1.Variables' t2.Variables']); ax = gca; ax.XTickLabel = tastes; legend('Saline','Nicotine'); 
ylabel('Bout length (licks)');title({'Nicotine Effect on Licks w/in First Bout';['(Bout = licks preceeeding ' num2str(pause_criteria) 'ms pause)']});
ylim=get(gca,'ylim');xlim=get(gca,'xlim');%text(xlim(1)+0.2,ylim(2)-5,['N = ' num2str(size(statarray.animal,1)/2)]);
hf = gcf;dim = [0.15 0.4 0.5 0.5];han = annotation(hf, 'textbox', dim, 'String', ['N = ' num2str(size(statarray.animal,1)/2)],'FitBoxToText', 'on');

%barplot
%bar([t1.Variables' t2.Variables'],'grouped'); 
figure();
c= barwitherr([t3.Variables' t4.Variables'],[t1.Variables' t2.Variables']); ax = gca; ax.XTickLabel = tastes; legend({'Saline','Nicotine'},'FontSize', 14); 
yL = ylabel('Bout length (licks)');title({'Nicotine Effect on Licks w/in First Bout';['(Bout = licks preceeeding ' num2str(pause_criteria) 'ms pause)']});
ylim=get(gca,'ylim');xlim=get(gca,'xlim');%text(xlim(1)+0.2,ylim(2)-5,['N = ' num2str(size(statarray.animal,1)/2)]);
%hf = gcf;dim = [0.15 0.4 0.5 0.5];han = annotation(hf, 'textbox', dim, 'String', ['N = ' num2str(size(statarray.animal,1)/2)],'FitBoxToText', 'on','FontSize', 24);
ax = ancestor(ax, 'axes'); yL.FontSize = 16; yrule = ax.YAxis; yrule.FontSize = 14; xrule = ax.XAxis;  xrule.FontSize = 16; 