% JoinQuant 获取指数行情数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMdIndex(obj, symb, exc, inv, ts_s, ts_e)
switch inv
    case EnumType.Interval.min1
        [is_err, md] = obj.FetchMinMd(symb, exc, 1, ts_s, ts_e,  'Fetching index [%s.%s] minitue market data');
        
    case EnumType.Interval.min5
        [is_err, md] = obj.FetchMinMd(symb, exc, 5, ts_s, ts_e, 'Fetching index [%s.%s] minitue market data');
        
    case EnumType.Interval.day
        symb = sprintf('%s.%s', symb, obj.exchanges(Utility.ToString(exc)));
        ts_s = datestr(ts_s, 'yyyy-mm-dd HH:MM:SS');
        ts_e = datestr(ts_e, 'yyyy-mm-dd HH:MM:SS');
        [is_err, obj.err.code, obj.err.msg, data] = obj.AnalysisApiResult(py.api.fetch_day_index_bar(obj.user, obj.password, symb, ts_s, ts_e));
        if (~is_err)
            md = [datenum(data(:, 1)), cell2mat(data(:, 2 : end))];
        else
            md = [];
             obj.DispErr(sprintf('Fetching index [%s] daily market data', symb));
        end
        
    otherwise
        error('Unexpected "interval" for [%] market data fetching, please check.', symb);
end
end