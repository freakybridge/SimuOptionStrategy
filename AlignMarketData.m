function port = AlignMarketData(path, port, exit_timing)

time_axis = [];

% 读取行情
for i = 1 : length(port)
    file = [path, port(i).file, '.xlsx'];
    [~, ~, data] = xlsread(file);
    data = data(2 : end, :);
    data = data(:, 3 : end);
    
    data = [datenum(data(:, 1)), cell2mat(data(:, 2 : end))];
    data = data(data(:, 1) >= datenum(port(i). entry_timing) & data(:, 1) <= datenum(exit_timing), :);
    time_axis = union(time_axis, datenum(data(:, 1)));
    
    port(i).md = data;
end


% 对齐行情
for i = 1 : length(port)
    md = port(i).md;
    data = zeros(length(time_axis), 9);
    data(:, 3) = time_axis;
    [~, loc] = ismember(md(:, 1), time_axis);
    data(loc, 4 : end) = md(:, 2 : end);
    
    data(:, 1) = arrayfun(@(x) str2double(datestr(x, 'yyyymmdd')), data(:, 3));
    data(:, 2) = arrayfun(@(x) str2double(datestr(x, 'HHMM')), data(:, 3));
    
    for j = 2 : size(data, 1)
        if data(j, 7) == 0
            data(j, 4 : 7) = data(j - 1, 7);
        end
    end
     port(i).md = data;
end



end
% 
%     for j = 1 : size(data, 1)
%         str = datestr(data{j, 2}, 'yyyymmddHHMM');
%         data{j, 1} =  str2double(str(1 : 8));
%         data{j, 2} =  str2double(str(9 : end));
%     end
%     md = cell2mat(data);    
%     
%     tmp = md(:, 1) * 1000 + md(:, 2);
%     
%     
%     markdata{i} = md;