function [converted_array] = cell2array(cell_input,type,animals,tastes)

%detail row lengths (events in condition) to flip construct array dimension
row_lengths = cellfun('length',cell_input);

%create empty array
grouped_array = []; grouped_array_clean=[];
for i =1:length(cell_input)

    %create/store animal name and condition
    Names = cell(length(cell_input{1,i}),2); Names(:,1)={animals(i)}; Names(:,2)={0}; 
    
    %clean file
    if type == 1 || type ==2    %bout data
        raw_data = cell_input{1,i}; raw_data(raw_data==900)=NaN; cleaned_data = raw_data;
    elseif type == 0            %latency data
        raw_data = cell_input{1,i}; raw_data(raw_data<=15)=NaN; cleaned_data = raw_data;
    end
    group_1 = [Names,num2cell(cell_input{1,i})];group_1_cleaned = [Names,num2cell(cleaned_data)];
    
    Names = cell(length(cell_input{2,i}),2); Names(:,1)={animals(i)}; Names(:,2)={1}; 
   
    %clean file
    if type == 1 || type ==2    %bout data
        raw_data = cell_input{2,i}; raw_data(raw_data==900)=NaN; cleaned_data = raw_data;
    elseif type == 0            %latency data
        raw_data = cell_input{2,i}; raw_data(raw_data<=15)=NaN; cleaned_data = raw_data;
    end
    
    group_2 = [Names,num2cell(cell_input{2,i})];group_2_cleaned = [Names,num2cell(cleaned_data)];
    
    %store together
    grouped_array = vertcat(grouped_array,group_1,group_2);
    grouped_array_clean = vertcat(grouped_array_clean,group_1_cleaned,group_2_cleaned);
   
end

%create header vector
headers = [{'animal'},{'condition'},split(tastes)];

%create table
converted_array = cell2table(grouped_array_clean,...
    'VariableNames',cellstr(headers));
