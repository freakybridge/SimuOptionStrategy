% Wind 获取交易日历
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, cal] = FetchCalendar(obj)
try    
    date.start = datestr(datenum('1988-09-10') - 365, 'yyyy-mm-dd');
    date.end = datestr(now + 365, 'yyyy-mm-dd');
    
    % 获取数据
    [~, ~, ~, date_natural, ~, ~] = obj.api.tdays(date.start, date.end, 'Days=Alldays');
    [~, ~, ~, date_working, ~, ~] = obj.api.tdays(date.start, date.end, 'Days=Weekdays');
    [~, ~, ~, date_trading, ~, ~] = obj.api.tdays(date.start, date.end);
    
    % 合并交易日历
    cal = date_natural;
    [~, loc] = ismember(date_trading, date_natural);
    cal(loc, 2) = 1;
    [~, loc] = ismember(date_working, date_natural);
    cal(loc, 3) = 1;
    
    % 标记工作日
    cal(:, 4) = weekday(cal(:, 1));
    cal(:, 5) = cal(:, 1);
    cal(:, 1) = str2double(cellstr(datestr(cal(:, 1), 'yyyymmdd')));
    
    % 标记更新时间
    cal(:, 6) = now();
    is_err = false;
    fprintf(2, 'Loading [Calendar] from [%s], please wait ...\r', obj.name);
catch 
    cal = zeros(0, 6);
    is_err = true;
    fprintf(2, 'Loading [Calendar] from [%s] occurs error, please check ...\r', obj.name);
end
end