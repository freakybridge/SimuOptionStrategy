% iFinD 获取交易日历
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, cal] = FetchCalendar(obj)
try
    % 获取起点终点
    date.start = datestr(datenum('1988-09-10') - 365, 'yyyy-mm-dd');
    date.end = datestr(now + 365, 'yyyy-mm-dd');
    
    % 获取日历日 / 交易日
    [~, obj.err.code, dt_natural, obj.err.msg] = THS_Date_Query('212001', 'mode:1,dateType:1,period:D,dateFormat:0', date.start, date.end);
    if (obj.err.code)
        obj.err.msg = obj.err.msg{:};
        fprintf('%s ERROR: Fetching calendar natural day error, [code: %d] [msg: %s], please check. \r', obj.name, usr_ht, obj.err.code, obj.err.msg);
    else
        dt_natural = datenum(dt_natural);
    end
    [~, obj.err.code, dt_trading, obj.err.msg] = THS_Date_Query('212001', 'mode:1,dateType:0,period:D,dateFormat:0', date.start, date.end);
    if (obj.err.code)
        obj.err.msg = obj.err.msg{:};
        fprintf('%s ERROR: Fetching calendar trading day error, [code: %d] [msg: %s], please check. \r', obj.name, usr_ht, obj.err.code, obj.err.msg);
    else
        dt_trading = datenum(dt_trading);
    end
    
    % 合并
    cal = arrayfun(@(x) str2double(datestr(x, 'yyyymmdd')), dt_natural);
    cal(:, 5) = dt_natural;
    [~, loc] = ismember(dt_trading, dt_natural);
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