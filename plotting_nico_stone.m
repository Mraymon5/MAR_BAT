%hab_day4 logic
OR1_hday1_sum_t2 = find(hab_out.HAB4.OR1.trial_data(:,3)==2);
OR2_hday1_sum_t2 = find(hab_out.HAB4.OR2.trial_data(:,3)==2);
 
OR1_lick_data_hday1 = hab_out.HAB4.OR1.trial_data(:,6);
OR2_lick_data_hday1 = hab_out.HAB4.OR2.trial_data(:,6);

OR3_hday4_sum_t2 = find(hab_out.HAB4.OR3.trial_data(:,3)==2);
OR4_hday4_sum_t2 = find(hab_out.HAB4.OR4.trial_data(:,3)==2);
 
OR3_lick_data_hday4 = hab_out.HAB4.OR3.trial_data(:,6);
OR4_lick_data_hday4 = hab_out.HAB4.OR4.trial_data(:,6);

%hab_day5 logic
OR3_hday5_sum_t2 = find(hab_out.HAB5.OR3.trial_data(:,3)==2);
OR4_hday5_sum_t2 = find(hab_out.HAB5.OR4.trial_data(:,3)==2);
 
OR3_lick_data_hday5 = hab_out.HAB5.OR3.trial_data(:,6);
OR4_lick_data_hday5 = hab_out.HAB5.OR4.trial_data(:,6);

%index logic vectors to lick arrays
OR1_t2_hday1 = OR1_lick_data_hday1(OR1_hday1_sum_t2);
OR2_t2_hday1 = OR2_lick_data_hday1(OR2_hday1_sum_t2); 

%day1 tastant logic
OR1_day1_sum_t2 = find(test_out.DAY1.OR1.trial_data(:,3)==2);
OR2_day1_sum_t2 = find(test_out.DAY1.OR2.trial_data(:,3)==2);
 
OR1_lick_data_day1 = test_out.DAY1.OR1.trial_data(:,6);
OR2_lick_data_day1 = test_out.DAY1.OR2.trial_data(:,6);

OR3_day1_sum_t2 = find(nico_out.DAY1.OR3.trial_data(:,3)==2);
OR4_day1_sum_t2 = find(nico_out.DAY1.OR4.trial_data(:,3)==2);
 
OR3_lick_data_day1 = nico_out.DAY1.OR3.trial_data(:,6);
OR4_lick_data_day1 = nico_out.DAY1.OR4.trial_data(:,6);
 
%index logic vectors to lick arrays
OR1_t2_day1 = OR1_lick_data_day1(OR1_day1_sum_t2);
OR2_t2_day1 = OR2_lick_data_day1(OR2_day1_sum_t2); 

%day2 tastant logic
OR1_day2_sum_t2 = find(test_out.DAY2.OR1.trial_data(:,3)==2);
OR2_day2_sum_t2 = find(test_out.DAY2.OR2.trial_data(:,3)==2);
 
OR1_lick_data_day2 = test_out.DAY2.OR1.trial_data(:,6);
OR2_lick_data_day2 = test_out.DAY2.OR2.trial_data(:,6);
 
%index logic vectors to lick arrays
OR1_t2_day2 = OR1_lick_data_day2(OR1_day2_sum_t2);
OR2_t2_day2 = OR2_lick_data_day2(OR2_day2_sum_t2); 

%day3 tastant logic
OR1_day3_sum_t2 = find(test_out.DAY3.OR1.trial_data(:,3)==2);
OR2_day3_sum_t2 = find(test_out.DAY3.OR2.trial_data(:,3)==2);
 
OR1_lick_data_day3 = test_out.DAY3.OR1.trial_data(:,6);
OR2_lick_data_day3 = test_out.DAY3.OR2.trial_data(:,6);
 
%index logic vectors to lick arrays
OR1_t2_day3 = OR1_lick_data_day3(OR1_day3_sum_t2);
OR2_t2_day3 = OR2_lick_data_day3(OR2_day3_sum_t2);

%create time vector for time course plotting (in seconds)
cum_sess_time(1:90,1)=40; cum_sess_time = cumsum(cum_sess_time);

%PLOT THE DATA
%Ordered by increasing dose
figure(1); plot(cum_sess_time,[OR1_lick_data_hday1 OR1_t2_day2 OR1_t2_day3 OR1_t2_day1 OR2_lick_data_hday1 OR2_t2_day3 OR2_t2_day2 OR2_t2_day1 ]); hold on;  
legend('OR1 - 0.0mg/kg', 'OR1 - 0.1mg/kg', 'OR1 - 0.2mg/kg','OR1 - 0.4mg/kg','OR2 - 0.0mg/kg','OR2 - 0.1mg/kg','OR2 - 0.2mg/kg','OR2 - 0.4mg/kg');
xlim([0 3600]); xticks(0:200:3600);xticklabels({'0','5','10','15','20','25','30','35','40','45','50','55','60','65','70','75','80','85','90'});
ylabel('Lick count'); xlabel('Trials Post-Injection'); title('Effect of Nicotine on Lick Count');

%Ordered by increasing dose
figure(2); bar([sum(OR1_t2_hday1); sum(OR1_t2_day2); sum(OR1_t2_day3); sum(OR1_t2_day1); sum(OR2_t2_hday1); sum(OR2_t2_day3); sum(OR2_t2_day2); sum(OR2_t2_day1)]); 
xticklabels({'OR1 - 0.0mg/kg', 'OR1 - 0.1mg/kg', 'OR1 - 0.2mg/kg','OR1 - 0.4mg/kg','OR2 - 0.0mg/kg','OR2 - 0.1mg/kg','OR2 - 0.2mg/kg','OR2 - 0.4mg/kg'});
ylabel('Lick count'); xlabel('Animal'); title('Effect of Nicotine on Lick Count');

%Does not take into account the fact that DAY3 (for OR1 and OR2) had 90
%trials, while the preceeding days capped sessions at 1Hr. 
figure(3); bar([sum(OR1_t2_hday1); sum(OR1_t2_day1); sum(OR1_t2_day2); sum(OR1_t2_day3); sum(OR2_t2_hday1); sum(OR2_t2_day1); sum(OR2_t2_day2); sum(OR2_t2_day3)]); 
xticklabels({'OR1 - 0.0mg/kg', 'OR1 - 0.4mg/kg', 'OR1 - 0.1mg/kg','OR1 - 0.2mg/kg','OR2 - 0.0mg/kg','OR2 - 0.4mg/kg','OR2 - 0.2mg/kg','OR2 - 0.1mg/kg'});
ylabel('Lick count'); xlabel('Animal'); title('Effect of Nicotine on Lick Count');

%Takes the mean number of licks per trials licked across session (allows
%comparison accross protocol change
figure(4); bar([mean(hab_out.HAB4.OR1.licks_per_trial); mean(test_out.DAY1.OR1.licks_per_trial); mean(test_out.DAY2.OR1.licks_per_trial); mean(test_out.DAY3.OR1.licks_per_trial); mean(hab_out.HAB4.OR2.licks_per_trial); mean(test_out.DAY1.OR2.licks_per_trial); mean(test_out.DAY2.OR2.licks_per_trial); mean(test_out.DAY3.OR2.licks_per_trial)]); 
xticklabels({'OR1 - 0.0mg/kg', 'OR1 - 0.4mg/kg', 'OR1 - 0.1mg/kg','OR1 - 0.2mg/kg','OR2 - 0.0mg/kg','OR2 - 0.4mg/kg','OR2 - 0.2mg/kg','OR2 - 0.1mg/kg'});
ylabel('Mean Lick per Trial'); xlabel('Animal'); title('Effect of Nicotine on Lick Count');

figure(5); bar([size(hab_out.HAB4.OR1.licks_per_trial,1); size(test_out.DAY1.OR1.licks_per_trial,1); size(test_out.DAY2.OR1.licks_per_trial,1); size(test_out.DAY3.OR1.licks_per_trial,1); size(hab_out.HAB4.OR2.licks_per_trial,1); size(test_out.DAY1.OR2.licks_per_trial,1); size(test_out.DAY2.OR2.licks_per_trial,1); size(test_out.DAY3.OR2.licks_per_trial,1)]); 
xticklabels({'OR1 - 0.0mg/kg', 'OR1 - 0.4mg/kg', 'OR1 - 0.1mg/kg','OR1 - 0.2mg/kg','OR2 - 0.0mg/kg','OR2 - 0.4mg/kg','OR2 - 0.2mg/kg','OR2 - 0.1mg/kg'});
ylabel('Trials licked'); xlabel('Animal'); title('Effect of Nicotine on Number of Trials Licked');

figure(6); plot(cum_sess_time,[OR1_t2_day1 OR2_t2_day1 OR1_t2_day2 OR2_t2_day2]); hold on;  
legend('OR1 - 0.4mg/kg','OR2 - 0.4mg/kg','OR1 - 0.1mg/kg','OR2 - 0.2mg/kg');
xlim([0 3600]); xticks(0:200:3600);xticklabels({'0','5','10','15','20','25','30','35','40','45','50','55','60','65','70','75','80','85','90'});
ylabel('Lick count'); xlabel('Trials Post-Injection'); title('Effect of Nicotine on Lick Count');

%plot the data
%2 animals y-axis with 5 tastes
%figure(1); bar([sum(data1) sum(data2) sum(data3) sum(data4) sum(data5); sum(data11) sum(data12) sum(data13) sum(data14) sum(data15)]);
% %hold on; legend('Sucrose','H2O','Nacl','QHCl','Saccharin'); xticklabels({'OR2 - Control', 'SS10 - Obese'});
% figure(1);subplot(1,3,1); bar([sum(OR2_t1_day1) sum(SS10_t1_day1); sum(OR2_t2_day1) sum(SS10_t2_day1); sum(OR2_t3_day1) sum(SS10_t3_day1); sum(OR2_t4_day1) sum(SS10_t4_day1); sum(OR2_t5_day1) sum(SS10_t_day1)]);
% hold on; legend('OR2 - Control','SS10 - Obese'); xticklabels({'Sucrose','H2O','Nacl','QHCl','Saccharin'}); title('Test Day -1');
% 
% figure(1);subplot(1,3,2); bar([sum(OR2_t1_day2) sum(SS10_t1_day2); sum(data2_day2) sum(data12_day2); sum(OR2_t3_day2) sum(SS10_t3_day2); sum(data4_day2) sum(SS10_t4_day2); sum(OR2_t5_day2) sum(SS10_t5_day2)]);
% hold on; legend('OR2 - Control','SS10 - Obese'); xticklabels({'Sucrose','H2O','Nacl','QHCl','Saccharin'}); title('Test Day -2');
% 
% figure(1); subplot(1,3,3); bar([sum(data1) sum(data11); sum(data2) sum(data12); sum(data3) sum(data13); sum(data4) sum(data14); sum(data5) sum(data15)]);
% hold on; legend('OR2 - Control','SS10 - Obese'); xticklabels({'Sucrose','H2O','Nacl','QHCl','Saccharin'}); title('Test Day -3');

%all averaged by group
%Controls
taste1_day1_con = mean([sum(OR2_t1_day1)]); taste1_day2_con = mean([sum(SS4_t1_day2),sum(OR2_t1_day2)]); taste1_day3_con = mean([sum(SS4_t1_day3),sum(OR2_t1_day3)]);
taste2_day1_con = mean([sum(OR2_t2_day1)]); taste2_day2_con = mean([sum(SS4_t2_day2),sum(OR2_t2_day2)]); taste2_day3_con = mean([sum(SS4_t2_day3),sum(OR2_t2_day3)]);
taste3_day1_con = mean([sum(OR2_t3_day1)]); taste3_day2_con = mean([sum(SS4_t3_day2),sum(OR2_t3_day2)]); taste3_day3_con = mean([sum(SS4_t3_day3),sum(OR2_t3_day3)]);
taste4_day1_con = mean([sum(OR2_t4_day1)]); taste4_day2_con = mean([sum(SS4_t4_day2),sum(OR2_t4_day2)]); taste4_day3_con = mean([sum(SS4_t4_day3),sum(OR2_t4_day3)]);
taste5_day1_con = mean([sum(OR2_t5_day1)]); taste5_day2_con = mean([sum(SS4_t5_day2),sum(OR2_t5_day2)]); taste5_day3_con = mean([sum(SS4_t5_day3),sum(OR2_t5_day3)]);

%obese
taste1_day1_ob = mean([sum(OR1t1_day1),sum(SS10_t1_day1)]); taste1_day2_ob = mean([sum(OR1t1_day2),sum(SS10_t1_day2)]); taste1_day3_ob = mean([sum(OR1t1_day3),sum(SS10_t1_day3)]);
taste2_day1_ob = mean([sum(OR1t2_day1),sum(SS10_t2_day1)]); taste2_day2_ob = mean([sum(OR1t2_day2),sum(SS10_t2_day2)]); taste2_day3_ob = mean([sum(OR1t2_day3),sum(SS10_t2_day3)]);
taste3_day1_ob = mean([sum(OR1t3_day1),sum(SS10_t3_day1)]); taste3_day2_ob = mean([sum(OR1t3_day2),sum(SS10_t3_day2)]); taste3_day3_ob = mean([sum(OR1t3_day3),sum(SS10_t3_day3)]);
taste4_day1_ob = mean([sum(OR1t4_day1),sum(SS10_t4_day1)]); taste4_day2_ob = mean([sum(OR1t4_day2),sum(SS10_t4_day2)]); taste4_day3_ob = mean([sum(OR1t4_day3),sum(SS10_t4_day3)]);
taste5_day1_ob = mean([sum(OR1t5_day1),sum(SS10_t5_day1)]); taste5_day2_ob = mean([sum(OR1t5_day2),sum(SS10_t5_day2)]); taste5_day3_ob = mean([sum(OR1t5_day3),sum(SS10_t5_day3)]);

%plot
figure(1);subplot(1,3,1); bar([taste1_day1_ob taste1_day1_con; taste2_day1_ob taste2_day1_con; taste3_day1_ob taste3_day1_con; taste4_day1_ob taste4_day1_con; taste5_day1_ob taste5_day1_con]);
hold on; legend('Obese','Control (N =1 )','location','northwest'); xticklabels({'Sucrose','H2O','Nacl','QHCl','Saccharin'}); title('Test Day -1'); ylim([0 1200]);
figure(1);subplot(1,3,2); bar([taste1_day2_ob taste1_day2_con; taste2_day2_ob taste2_day2_con; taste3_day2_ob taste3_day2_con; taste4_day2_ob taste4_day2_con; taste5_day2_ob taste5_day2_con]);
hold on; legend('Obese','Control'); xticklabels({'Sucrose','H2O','Nacl','QHCl','Saccharin'}); title('Test Day -2');
figure(1); subplot(1,3,3);  bar([taste1_day3_ob taste1_day3_con; taste2_day3_ob taste2_day3_con; taste3_day3_ob taste3_day3_con; taste4_day3_ob taste4_day3_con; taste5_day3_ob taste5_day3_con]);
hold on; legend('Obese','Control'); xticklabels({'Sucrose','H2O','Nacl','QHCl','Saccharin'}); title('Test Day -3'); suptitle('All Trials');

%first half averaged by group
%control
taste1_day1_con_first = mean([sum(OR2_t1_day1(1:5))]); taste1_day2_con_first  = mean([sum(SS4_t1_day2(1:5)),sum(OR2_t1_day2(1:5))]); taste1_day3_con_first = mean([sum(SS4_t1_day3(1:5)),sum(OR2_t1_day3(1:5))]);
taste2_day1_con_first  = mean([sum(OR2_t2_day1(1:5))]); taste2_day2_con_first = mean([sum(SS4_t2_day2(1:5)),sum(OR2_t2_day2(1:5))]); taste2_day3_con_first = mean([sum(SS4_t2_day3(1:5)),sum(OR2_t2_day3(1:5))]);
taste3_day1_con_first  = mean([sum(OR2_t3_day1(1:5))]); taste3_day2_con_first = mean([sum(SS4_t3_day2(1:5)),sum(OR2_t3_day2(1:5))]); taste3_day3_con_first = mean([sum(SS4_t3_day3(1:5)),sum(OR2_t3_day3(1:5))]);
taste4_day1_con_first  = mean([sum(OR2_t4_day1(1:5))]); taste4_day2_con_first = mean([sum(SS4_t4_day2(1:5)),sum(OR2_t4_day2(1:5))]); taste4_day3_con_first = mean([sum(SS4_t4_day3(1:5)),sum(OR2_t4_day3(1:5))]);
taste5_day1_con_first  = mean([sum(OR2_t5_day1(1:5))]); taste5_day2_con_first = mean([sum(SS4_t5_day2(1:5)),sum(OR2_t5_day2(1:5))]); taste5_day3_con_first = mean([sum(SS4_t5_day3(1:5)),sum(OR2_t5_day3(1:5))]);
 
%obese
taste1_day1_ob_first  = mean([sum(OR1t1_day1(1:5)),sum(SS10_t1_day1(1:5))]); taste1_day2_ob_first = mean([sum(OR1t1_day2(1:5)),sum(SS10_t1_day2(1:5))]); taste1_day3_ob_first = mean([sum(OR1t1_day3(1:5)),sum(SS10_t1_day3(1:5))]);
taste2_day1_ob_first  = mean([sum(OR1t2_day1(1:5)),sum(SS10_t2_day1(1:5))]); taste2_day2_ob_first = mean([sum(OR1t2_day2(1:5)),sum(SS10_t2_day2(1:5))]); taste2_day3_ob_first = mean([sum(OR1t2_day3(1:5)),sum(SS10_t2_day3(1:5))]);
taste3_day1_ob_first  = mean([sum(OR1t3_day1(1:5)),sum(SS10_t3_day1(1:5))]); taste3_day2_ob_first = mean([sum(OR1t3_day2(1:5)),sum(SS10_t3_day2(1:5))]); taste3_day3_ob_first = mean([sum(OR1t3_day3(1:5)),sum(SS10_t3_day3(1:5))]);
taste4_day1_ob_first  = mean([sum(OR1t4_day1(1:5)),sum(SS10_t4_day1(1:5))]); taste4_day2_ob_first = mean([sum(OR1t4_day2(1:5)),sum(SS10_t4_day2(1:5))]); taste4_day3_ob_first = mean([sum(OR1t4_day3(1:5)),sum(SS10_t4_day3(1:5))]);
taste5_day1_ob_first  = mean([sum(OR1t5_day1(1:5)),sum(SS10_t5_day1(1:5))]); taste5_day2_ob_first = mean([sum(OR1t5_day2(1:5)),sum(SS10_t5_day2(1:5))]); taste5_day3_ob_first = mean([sum(OR1t5_day3(1:5)),sum(SS10_t5_day3(1:5))]);

%plot
figure(2);subplot(1,3,1); bar([taste1_day1_ob_first taste1_day1_con_first; taste2_day1_ob_first taste2_day1_con_first; taste3_day1_ob_first taste3_day1_con_first; taste4_day1_ob_first taste4_day1_con_first; taste5_day1_ob_first taste5_day1_con_first]);
hold on; legend('Obese','Control (N =1 )','location','northwest'); xticklabels({'Sucrose','H2O','Nacl','QHCl','Saccharin'}); title('Test Day -1'); ylim([0 600]);
figure(2);subplot(1,3,2); bar([taste1_day2_ob_first taste1_day2_con_first; taste2_day2_ob_first taste2_day2_con_first; taste3_day2_ob_first taste3_day2_con_first; taste4_day2_ob_first taste4_day2_con_first; taste5_day2_ob_first taste5_day2_con_first]);
hold on; legend('Obese','Control'); xticklabels({'Sucrose','H2O','Nacl','QHCl','Saccharin'}); title('Test Day -2');
figure(2); subplot(1,3,3);  bar([taste1_day3_ob_first taste1_day3_con_first; taste2_day3_ob_first taste2_day3_con_first; taste3_day3_ob_first taste3_day3_con_first; taste4_day3_ob_first taste4_day3_con_first; taste5_day3_ob_first taste5_day3_con_first]);
hold on; legend('Obese','Control'); xticklabels({'Sucrose','H2O','Nacl','QHCl','Saccharin'}); title('Test Day -3'); suptitle('First 1/2 Trials');

%second half averaged by group
%control
taste1_day1_con_sec  = mean([sum(OR2_t1_day1(6:10))]); taste1_day2_con_sec = mean([sum(SS4_t1_day2(6:10)),sum(OR2_t1_day2(6:10))]); taste1_day3_con_sec = mean([sum(SS4_t1_day3(6:10)),sum(OR2_t1_day3(6:10))]);
taste2_day1_con_sec  = mean([sum(OR2_t2_day1(6:10))]); taste2_day2_con_sec = mean([sum(SS4_t2_day2(6:10)),sum(OR2_t2_day2(6:10))]); taste2_day3_con_sec = mean([sum(SS4_t2_day3(6:10)),sum(OR2_t2_day3(6:10))]);
taste3_day1_con_sec  = mean([sum(OR2_t3_day1(6:10))]); taste3_day2_con_sec = mean([sum(SS4_t3_day2(6:10)),sum(OR2_t3_day2(6:10))]); taste3_day3_con_sec = mean([sum(SS4_t3_day3(6:10)),sum(OR2_t3_day3(6:10))]);
taste4_day1_con_sec  = mean([sum(OR2_t4_day1(6:10))]); taste4_day2_con_sec = mean([sum(SS4_t4_day2(6:10)),sum(OR2_t4_day2(6:10))]); taste4_day3_con_sec = mean([sum(SS4_t4_day3(6:10)),sum(OR2_t4_day3(6:10))]);
taste5_day1_con_sec  = mean([sum(OR2_t5_day1(6:10))]); taste5_day2_con_sec = mean([sum(SS4_t5_day2(6:10)),sum(OR2_t5_day2(6:10))]); taste5_day3_con_sec = mean([sum(SS4_t5_day3(6:10)),sum(OR2_t5_day3(6:10))]);
 
%obese
taste1_day1_ob_sec  = mean([sum(OR1t1_day1(6:10)),sum(SS10_t1_day1(6:10))]); taste1_day2_ob_sec = mean([sum(OR1t1_day2(6:10)),sum(SS10_t1_day2(6:10))]); taste1_day3_ob_sec = mean([sum(OR1t1_day3(6:10)),sum(SS10_t1_day3(6:10))]);
taste2_day1_ob_sec  = mean([sum(OR1t2_day1(6:10)),sum(SS10_t2_day1(6:10))]); taste2_day2_ob_sec = mean([sum(OR1t2_day2(6:10)),sum(SS10_t2_day2(6:10))]); taste2_day3_ob_sec = mean([sum(OR1t2_day3(6:10)),sum(SS10_t2_day3(6:10))]);
taste3_day1_ob_sec  = mean([sum(OR1t3_day1(6:10)),sum(SS10_t3_day1(6:10))]); taste3_day2_ob_sec = mean([sum(OR1t3_day2(6:10)),sum(SS10_t3_day2(6:10))]); taste3_day3_ob_sec = mean([sum(OR1t3_day3(6:10)),sum(SS10_t3_day3(6:10))]);
taste4_day1_ob_sec  = mean([sum(OR1t4_day1(6:10)),sum(SS10_t4_day1(6:10))]); taste4_day2_ob_sec = mean([sum(OR1t4_day2(6:10)),sum(SS10_t4_day2(6:10))]); taste4_day3_ob_sec = mean([sum(OR1t4_day3(6:10)),sum(SS10_t4_day3(6:10))]);
taste5_day1_ob_sec  = mean([sum(OR1t5_day1(6:10)),sum(SS10_t5_day1(6:10))]); taste5_day2_ob_sec = mean([sum(OR1t5_day2(6:10)),sum(SS10_t5_day2(6:10))]); taste5_day3_ob_sec = mean([sum(OR1t5_day3(6:10)),sum(SS10_t5_day3(6:10))]);

%plot
figure(3);subplot(1,3,1); bar([taste1_day1_ob_sec taste1_day1_con_sec; taste2_day1_ob_sec taste2_day1_con_sec; taste3_day1_ob_sec taste3_day1_con_sec; taste4_day1_ob_sec taste4_day1_con_sec; taste5_day1_ob_sec taste5_day1_con_sec]);
hold on; legend('Obese','Control (N =1 )','location','northwest'); xticklabels({'Sucrose','H2O','Nacl','QHCl','Saccharin'}); title('Test Day -1'); ylim([0 600]);
figure(3);subplot(1,3,2); bar([taste1_day2_ob_sec taste1_day2_con_sec; taste2_day2_ob_sec taste2_day2_con_sec; taste3_day2_ob_sec taste3_day2_con_sec; taste4_day2_ob_sec taste4_day2_con_sec; taste5_day2_ob_sec taste5_day2_con_sec]);
hold on; legend('Obese','Control'); xticklabels({'Sucrose','H2O','Nacl','QHCl','Saccharin'}); title('Test Day -2');
figure(3); subplot(1,3,3);  bar([taste1_day3_ob_sec taste1_day3_con_sec; taste2_day3_ob_sec taste2_day3_con_sec; taste3_day3_ob_sec taste3_day3_con_sec; taste4_day3_ob_sec taste4_day3_con_sec; taste5_day3_ob_sec taste5_day3_con_sec]);
hold on; legend('Obese','Control'); xticklabels({'Sucrose','H2O','Nacl','QHCl','Saccharin'}); title('Test Day -3'); suptitle('Second 1/2 Trials');

%plot by water exposure
figure(4); subplot(1,3,1); bar([

%stack plot
figure(4); subplot(1,3,1); bar([taste1_day1_ob_first taste1_day1_ob_sec; taste2_day1_ob_first taste2_day1_ob_sec; taste3_day1_ob_first taste3_day1_ob_sec; taste4_day1_ob_first taste4_day1_ob_sec; taste5_day1_ob_first taste5_day1_ob_sec],'stacked');