function [test_out] = nico_testing_decode_Stone(dirname)

%DIRNAME = directory name that files are located in 
%TEST_OUT = output struct of the combined BAT data from all animals in
%folder

matfile = dir([dirname filesep '*.txt']);

%Create structure for concatenating
combined_OR_test = struct;

%Flip through each matlab output file and contruct merged arrays
for file =1:length(matfile')
    
    %find all lines within text file
    fid = fopen(matfile(file).name); lines = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid); lines = lines{1};

    %find all the blank lines using cellfun and call out (row) of headerlines
    blank_lines = find(cellfun('isempty', lines)); header_start_line = strfind(lines, 'PRESENTATION');
    isOne = cellfun(@(x)isequal(x,1),header_start_line);[row,col] = find(isOne); %row indicates where headers begin
    
    %Open file and scan data using specified layout (%n = number, %c =
    %character, %s = string) starting at headerline
    fid = fopen(matfile(file).name); disp(['Working on file ' matfile(file).name]); %Displays working file
    data = textscan(fid,'%n %c %n %c %c %s %n %c %n %c %n %c %n %c %n %c %n %c %n','HeaderLines',row);
    trials = max(data{1,1}); 
    
    %Grab headers to put into struct later
    fid = fopen(matfile(file).name); header_data = textscan(fid,'%s %s %s %s %s %s %s %s %s %s %s',row,'Delimiter',',');
    headers = [];
    for header=1:size(header_data,2)
        headers{end+1} = header_data{1,header}{row,1};
    end

    %grab the tastant info and convert to numbers
    tastes = ["SUCROSE,","WATER,","NaCl,","QHC,","SACCHARINE,","CITRICACID,"]; num_var = ["1","2","3","4","5","6"];
    conv_text = str2double(replace([data{1,6}(1:trials,:)],tastes,num_var));
     
    %pad data based on length
    maxsize = max(cellfun(@numel,data(1,[1 3 7 9 11 13 15 17 19]))); fcn = @(x) [x; nan(maxsize-numel(x),1)];
    cmat = cellfun(fcn,data(1,[1 3 7 9 11 13 15 17 19]),'UniformOutput',false); cmat = horzcat(cmat{:});full_data = cmat(1:trials,:);
    
    %create matrix of complete data
    %full_data = horzcat(cell2mat(data(1,[1 3 7 9 11 13 15 17 19]))); full_data = full_data(1:trials,:); 
    full_data = horzcat(full_data(:,[1 2]),conv_text,full_data(:,[3 4 5 6 7 8 9]));
    
    %Create storying array and grab animal name, test day, and
    %concentration of nicotine used
    animal = matfile(file).name(strfind((matfile(file).name),'OR'):strfind((matfile(file).name),'OR')+3);    
    if contains(animal,"_")
        animal = animal(1:3);
    end
    
    test_day = matfile(file).name(strfind((matfile(file).name),'DAY'):strfind((matfile(file).name),'DAY')+3);    
    nico_dose = matfile(file).name(strfind((matfile(file).name),'('):strfind((matfile(file).name),'(')+4);    
    
    %Place in structure under animal name
    combined_OR_test.([test_day]).([animal]).('data_headers') = headers(1,[1 2 4 5 6 7 8 9 10 11]);
    combined_OR_test.([test_day]).([animal]).('trial_data') = full_data;
    combined_OR_test.([test_day]).([animal]).('sessions_tastes_decode') = vertcat(tastes,num_var);
    combined_OR_test.([test_day]).([animal]).('dose') = nico_dose;
    
    %create variable for latency data
    lick_data = csvread(matfile(file).name,row,6); lick_data= lick_data(1:trials,1:2); %extract lick data
    working_data = csvread(matfile(file).name,blank_lines);  %extract latency data
    
    %establish trials animal licked in and create matching latency index
    lick_trials = lick_data(:,1)>0; lat_data = working_data;
    
    %cummulative sum up values for trials
    licks = lick_data(lick_trials(:),1);
    lat_start = lick_data(lick_trials(:),2);
    cum_sum_lat = cumsum(lat_data(lick_trials(:),:)');
    
    %clean up the cummulative file to reflect NaNs where latency count is
    %less than needed for given trial    
    for column=1:size(cum_sum_lat,2)
        start_max = cum_sum_lat(cum_sum_lat(:,column)<max(cum_sum_lat(:,column)));
        cum_sum_lat(length(start_max)+2:size(cum_sum_lat,1),column) = NaN;
    end
        
    %Place in structure under animal name
    combined_OR_test.([test_day]).([animal]).('licks_session') = lick_trials;
    combined_OR_test.([test_day]).([animal]).('licks_per_trial') = licks;
    combined_OR_test.([test_day]).([animal]).('lat_first_trial') = lat_start;
    combined_OR_test.([test_day]).([animal]).('cummulative_latency_trial') = cum_sum_lat'; %latenciesXtrials
    combined_OR_test.([test_day]).([animal]).('latency_whole') = working_data; %all latency data
end

test_out = combined_OR_test;