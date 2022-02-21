% Tushare ��ȡ��������
% v1.3.0.20220113.beta
%       1.�״μ���
function [is_err, cal] = FetchCalendar(obj)
try
    % ��ȡ����յ�
    date.start = datestr(datenum('1988-09-10') - 365, 'yyyymmdd');
    date.end = datestr(now + 365, 'yyyymmdd');
    
    % ��ȡ������ / ������
    res = obj.api.query('trade_cal', 'start_date', date.start, 'end_date', date.end);
    if (isempty(res))
        obj.err.msg = 'fetch calendar error';
        fprintf('%s ERROR: Fetching calendar natural/trade day error, [code: %d] [msg: %s], please check. \r', obj.name, obj.err.code, obj.err.msg);
    end
    
    % ����
    dt_natural = datenum(res.cal_date, 'yyyymmdd');
    dt_trading = dt_natural(logical(res.is_open));
    
    % �ϲ�
    cal = str2double(cellstr(datestr(dt_natural, 'yyyymmdd')));
    cal(:, 5) = dt_natural;
    [~, loc] = ismember(dt_trading, dt_natural);
    cal(loc, 2) = 1;
    cal(:, 4) = weekday(cal(:, 5));
    loc = cal(:, 4) ~= 7 & cal(:, 4) ~= 1;
    cal(loc, 3) = 1;
    
    % ��Ǹ���ʱ��
    cal(:, 6) = now();
    is_err = false;
    fprintf(2, 'Loading [Calendar] from [%s], please wait ...\r', obj.name);
catch 
    cal = zeros(0, 6);
    is_err = true;
    fprintf(2, 'Loading [Calendar] from [%s] occurs error, please check ...\r', obj.name);
end
end