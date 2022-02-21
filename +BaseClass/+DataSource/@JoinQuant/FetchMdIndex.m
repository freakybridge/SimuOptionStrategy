% JoinQuant ��ȡָ����������
% v1.3.0.20220113.beta
%       1.�״μ���
function [is_err, md] = FetchMdIndex(obj, symb, exc, inv, ts_s, ts_e)

% Ԥ����
ts_s = datestr(ts_s, 'yyyy-mm-dd HH:MM:SS');
ts_e = datestr(ts_e, 'yyyy-mm-dd HH:MM:SS');
cnt = obj.CalcFetchingRows(ts_s, ts_e, inv, exc);
exc = obj.exchanges(Utility.ToString(exc));

% ����
switch inv
    case EnumType.Interval.min1
        [is_err, md] = FetchMin(obj, symb, exc, '1m', ts_s, ts_e, cnt);
        
    case EnumType.Interval.min5
        [is_err, md] = FetchMin(obj, symb, exc, '5m', ts_s, ts_e, cnt);
        
    case EnumType.Interval.day
        [is_err, md] = FetchDay(obj, symb, exc, inv, ts_s, ts_e);
        
    otherwise
        error('Unexpected "interval" for [%] market data fetching, please check.', symb);
end
end

 % ��ȡ��������
function [is_err, md] = FetchMin(obj, symb, exc, inv, ts_s, ts_e, cnt)
        
[is_err, obj.err.code, obj.err.msg, data] = obj.AnalysisApiResult(py.api.fetch_min_bar(obj.user, obj.password, symb, exc, ...
    {'date', 'open', 'high', 'low', 'close', 'volume', 'money'}, ...
    inv, ts_e, int64(cnt)));

if (~is_err)
    md = [datenum(data(:, 1)), cell2mat(data(:, 2 : end))];
    md = md(md(:, 1) >= datenum(ts_s) & md(:, 1) <= datenum(ts_e), :);    
else
    md = [];
    obj.DispErr(sprintf('Fetching index [%s] minitue market data', symb));
end
end

% ��ȡ������
function [is_err, md] = FetchDay(obj, symb, exc, ~, ts_s, ts_e)
[is_err, obj.err.code, obj.err.msg, data] = obj.AnalysisApiResult(py.api.fetch_day_index_bar(obj.user, obj.password, symb, exc, ts_s, ts_e));
if (~is_err)
    md = [datenum(data(:, 1)), cell2mat(data(:, 2 : end))];
else
    md = [];
    obj.DispErr(sprintf('Fetching index [%s] daily market data', symb));
end
end

