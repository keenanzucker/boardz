% filename = 'Raw-25-15-1.csv';

% FiberBend/Raw25-15-1.csv

function res = CSVProcessing(extension, load)
    
%     data = csvread(filename,0,1);
% 
%     extension = data(:,2);
%     load = data(:,3);
    plot(extension, load)
end

