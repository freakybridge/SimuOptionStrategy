% Wind ��ȡ��������
% v1.3.0.20220113.beta
%       1.�״μ���
function [is_err, cal] = FetchCalendar(obj)
try    
    date.start = datestr(datenum('1988-09-10') - 365, 'yyyy-mm-dd');
    date.end = datestr(now + 365, 'yyyy-mm-dd');
    
    % ��ȡ����
    [~, ~, ~, date_natural, ~, ~] = obj.api.tdays(date.start, date.end, 'Days=Alldays');
    [~, ~, ~, date_working, ~, ~] = obj.api.tdays(date.start, date.end, 'Days=Weekdays');
    [~, ~, ~, date_trading, ~, ~] = obj.api.tdays(date.start, date.end);
    
    % �ϲ���������
    cal = date_natural;
    [~, loc] = ismember(date_trading, date_natural);
    cal(loc, 2) = 1;
    [~, loc] = ismember(date_working, date_natural);
    cal(loc, 3) = 1;
    
    % ��ǹ�����
    cal(:, 4) = weekday(cal(:, 1));
    cal(:, 5) = cal(:, 1);
    cal(:, 1) = str2double(cellstr(datestr(cal(:, 1), 'yyyymmdd')));
    
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