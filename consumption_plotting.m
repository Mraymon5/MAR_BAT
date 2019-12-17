%Bring in data and establish what data to analyze
[num,txt,raw] = xlsread('Bottle Data.xlsx','Totals_Hab5');
NaN_logic = isnan(num(:,2)); NaN_list = find(NaN_logic(:,1)==1);
if isempty(NaN_logic)~=0
    NaN_start_row = NaN_list(1,1); analyze_data_row = NaN_start_row-1;
else
    NaN_start_row = length(num(:,2));
end
animal_names = unique(raw(2:NaN_start_row,1)); 

%user input prompt
[indx,tf] = listdlg('ListString',animal_names);

%Flip through data and plot dose-response info
figure; hold on;
for animal=1:size(indx,2)
    animal_lookup=cell2mat(animal_names(indx(1,animal))); %Inidicate which animal loop is working on
    plot_log = find(strcmp((raw(2:NaN_start_row,1)),animal_lookup)==1); %Indicate rows that hold this animal's data
    scatter(num(plot_log,1),num(plot_log,4)); %Use plot logic to pull dose (column 1) & consumption (column 4) values from 
end   
legend(animal_names(indx)); hold on; title('Effect of Nicotine on Water Consumption');
ylabel('Water Consumed (mL)'); xlabel('Dose of Nicotine (mg/kg)');ylim([0 20]);

%Box and whisker plots
animal_start=cell2mat(animal_names(indx(1,1)));row_log = find(strcmp((raw(2:NaN_start_row,1)),animal_start)==1);
doses_box = unique(num(row_log:end,1)); NaN_logic_2 = isnan(doses_box); 
doses_rows = find(NaN_logic_2(:,1)==0); dose_analyze = doses_box(doses_rows);
consumption_change=num(row_log:end,4);

box_build = NaN(size(dose_analyze,1),8);
for dose=1:size(dose_analyze,1);
    dose_logic = find(num(row_log:end,1)==dose_analyze(dose));
    box_build(dose,1:length(consumption_change(dose_logic))) = consumption_change(dose_logic)';
end    
figure; boxplot(box_build'); hold on; xticklabels([dose_analyze]); xlabel('Nicotine Dose (mg/kg)'); ylabel('Water Consumption (g)');
title('Nicotine Dose response effect on Water Consumption');

