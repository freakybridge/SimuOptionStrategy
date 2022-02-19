% JoinQuant 获取交易日历
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, cal] = FetchCalendar(obj)
try
%     % 获取起点终点
%     date.start = datestr(datenum('1988-09-10') - 365, 'yyyy-mm-dd');
%     date.end = datestr(now + 365, 'yyyy-mm-dd');

    % fetch trade days
    [is_err, obj.err.code, obj.err.msg, dt_trade] = obj.AnalysisApiResult(py.api.fetch_all_trade_day(obj.user, obj.password));
    if (is_err)
        fprintf('%s ERROR: Fetching calendar trade day error, [code: %d] [msg: %s], please check. \r', obj.name, obj.err.code, obj.err.msg);
    end
    dt_trade = datenum(dt_trade);

    % fetch natural day
    dt_natural = (dt_trade(1) : dt_trade(end))';
        
    % 合并
    cal = str2double(cellstr(datestr(dt_natural, 'yyyymmdd')));
    cal(:, 5) = dt_natural;
    [~, loc] = ismember(dt_trade, dt_natural);
    cal(loc, 2) = 1;
    cal(:, 4) = weekday(cal(:, 5));
    loc = cal(:, 4) ~= 7 & cal(:, 4) ~= 1;
    cal(loc, 3) = 1;
    
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