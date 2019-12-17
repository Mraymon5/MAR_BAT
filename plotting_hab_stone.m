%hab_day4 logic
OR3_hday4_sum_t2 = find(hab_out.HAB4.OR3.trial_data(:,3)==2);
OR4_hday4_sum_t2 = find(hab_out.HAB4.OR4.trial_data(:,3)==2);
 
OR3_lick_data_hday4 = hab_out.HAB4.OR3.trial_data(:,6);
OR4_lick_data_hday4 = hab_out.HAB4.OR4.trial_data(:,6);

%hab_day4 bottle analysis
OR3_bot_1_log_hday4 = find(hab_out.HAB4.OR3.trial_data(:,2)==1);
OR3_bot_2_log_hday4 = find(hab_out.HAB4.OR3.trial_data(:,2)==2);
OR4_bot_1_log_hday4 = find(hab_out.HAB4.OR4.trial_data(:,2)==1);
OR4_bot_2_log_hday4 = find(hab_out.HAB4.OR4.trial_data(:,2)==2);

OR3_hday4_bot_1 = OR3_lick_data_hday4(OR3_bot_1_log_hday4);
OR3_hday4_bot_2 = OR3_lick_data_hday4(OR3_bot_2_log_hday4);
OR4_hday4_bot_1 = OR4_lick_data_hday4(OR4_bot_1_log_hday4);
OR4_hday4_bot_2 = OR4_lick_data_hday4(OR4_bot_2_log_hday4);

%hab_day5 logic
OR3_hday5_sum_t2 = find(hab_out.HAB5.OR3.trial_data(:,3)==2);
OR4_hday5_sum_t2 = find(hab_out.HAB5.OR4.trial_data(:,3)==2);
 
OR3_lick_data_hday5 = hab_out.HAB5.OR3.trial_data(:,6);
OR4_lick_data_hday5 = hab_out.HAB5.OR4.trial_data(:,6);

%hab_day5 bottle analysis
OR3_bot_1_log_hday5 = find(hab_out.HAB5.OR3.trial_data(:,2)==1);
OR3_bot_2_log_hday5 = find(hab_out.HAB5.OR3.trial_data(:,2)==2);
OR4_bot_1_log_hday5 = find(hab_out.HAB5.OR4.trial_data(:,2)==1);
OR4_bot_2_log_hday5 = find(hab_out.HAB5.OR4.trial_data(:,2)==2);

OR3_hday5_bot_1 = OR3_lick_data_hday5(OR3_bot_1_log_hday5);
OR3_hday5_bot_2 = OR3_lick_data_hday5(OR3_bot_2_log_hday5);
OR4_hday5_bot_1 = OR4_lick_data_hday5(OR4_bot_1_log_hday5);
OR4_hday5_bot_2 = OR4_lick_data_hday5(OR4_bot_2_log_hday5);

%create time vector for time course plotting (in seconds)
cum_sess_time(1:90,1)=40; cum_sess_time = cumsum(cum_sess_time);

%PLOT THE DATA
%Ordered by increasing dose
figure(1); plot(cum_sess_time,[OR3_lick_data_hday4 OR4_lick_data_hday4 OR3_lick_data_hday5 OR4_lick_data_hday5]); hold on;  
legend('OR3 - 0.0mg/kg - Hab4', 'OR4 - 0.0mg/kg - Hab4', 'OR3 - 0.0mg/kg - Hab5','OR4 - 0.0mg/kg - Hab5');
xlim([0 3600]); xticks(0:200:3600);xticklabels({'0','5','10','15','20','25','30','35','40','45','50','55','60','65','70','75','80','85','90'});
ylabel('Lick count'); xlabel('Trials Post-Injection'); title('Habituation and Lick Count');

%Ordered by increasing dose
figure(2); bar([sum(OR3_lick_data_hday4) sum(OR3_lick_data_hday5); sum(OR4_lick_data_hday4) sum(OR4_lick_data_hday5)]); 
xticklabels({'OR3', 'OR4'}); legend('Hab - 4', 'Hab - 5');
ylabel('Lick count'); xlabel('Animal'); title('Habituation and Lick Count');

%First/Second stacked
figure(3); bar([sum(OR3_lick_data_hday4(1:45)), sum(OR3_lick_data_hday4(46:90)); sum(OR3_lick_data_hday5(1:45)), sum(OR3_lick_data_hday5(46:90)); sum(OR4_lick_data_hday4(1:45)) sum(OR4_lick_data_hday4(46:90)); sum(OR4_lick_data_hday5(1:45)) sum(OR4_lick_data_hday5(46:90))],'stacked');

%First/Second stacked/groups
A = zeros(2,2,2); %Animals,Days,Split (1st/2nd) 
A(1,1,1) = sum(OR3_lick_data_hday4(1:45)); A(1,1,2) = sum(OR3_lick_data_hday4(46:90));
A(1,2,1) = sum(OR3_lick_data_hday5(1:45)); A(1,2,2) = sum(OR3_lick_data_hday5(46:90));
A(2,1,1) = sum(OR4_lick_data_hday4(1:45)); A(2,1,2) = sum(OR4_lick_data_hday4(46:90));
A(2,2,1) = sum(OR4_lick_data_hday5(1:45)); A(2,2,2) = sum(OR4_lick_data_hday5(46:90));
groupLabels = {'OR3','OR4'}; plotBarStackGroups(A, groupLabels); legend('First 1/2', 'Second 1/2');
ylabel('Lick count'); xlabel('Animal'); title('Habituation and Lick Count');

%Bottle analysis
figure(5); subplot(2,2,1); pie([sum(OR3_hday4_bot_1) sum(OR3_hday4_bot_2)],{'Bottle 1','Bottle 2'}); title('OR3 - Hab4');
figure(5); subplot(2,2,2); pie([sum(OR4_hday4_bot_1) sum(OR4_hday4_bot_2)],{'Bottle 1','Bottle 2'}); title('OR4 - Hab4');
figure(5); subplot(2,2,3); pie([sum(OR3_hday5_bot_1) sum(OR3_hday5_bot_2)],{'Bottle 1','Bottle 2'}); title('OR3 - Hab5');
figure(5); subplot(2,2,4); pie([sum(OR4_hday5_bot_1) sum(OR4_hday5_bot_2)],{'Bottle 1','Bottle 2'}); title('OR4 - Hab5');

