function [port, time_axis] = AlignMarketData(path, port)

time_axis = [];

% 读取行情
for i = 1 : length(port)
    file = [path, port(i).file, '.xlsx'];
    [~, ~, data] = xlsread(file);
    data = data(2 : end, :);
    data = data(:, 3 : end);
    
    data = [datenum(data(:, 1)), cell2mat(data(:, 2 : end))];
    time_axis = union(time_axis, data(:, 1));
    
    port(i).md = data;
end


% 对齐行情
for i = 1 : length(port)
    md = port(i).md;
    this_axis = time_axis(time_axis >= md(1, 1) & time_axis <= md(end, 1));
    
    curr_md = zeros(length(this_axis), 9);    
    curr_md(:, 3) = this_axis;
    [~, loc] = ismember(md(:, 1), time_axis);
    curr_md(loc, 4 : end) = md(:, 2 : end);
    
    curr_md(:, 1) = arrayfun(@(x) str2double(datestr(x, 'yyyymmdd')), curr_md(:, 3));
    curr_md(:, 2) = arrayfun(@(x) str2double(datestr(x, 'HHMM')), curr_md(:, 3));
    
    for j = 2 : size(curr_md, 1)
        if curr_md(j, 7) == 0
            curr_md(j, 4 : 7) = curr_md(j - 1, 7);
        end
    end
    port(i).md = curr_md;
end


% 截取时间轴
start_point = min(datenum({port.entry_timing}));
end_point = max(datenum({port.exit_timing}));
time_axis = time_axis(time_axis >=  start_point & time_axis <= end_point);


end