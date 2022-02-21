% JoinQuant 获取ETF数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMdEtf(obj, symb, exc, inv, ts_s, ts_e)
exc = obj.exchanges(Utility.ToString(exc));
switch inv
    case EnumType.Interval.min1
        [is_err, md] = obj.FetchMinMd(symb, exc, 1, ts_s, ts_e,  'Fetching etf [%s.%s] minitue market data');
        
    case EnumType.Interval.min5
        [is_err, md] = obj.FetchMinMd(symb, exc, 5, ts_s, ts_e, 'Fetching etf [%s.%s] minitue market data');
        
    case EnumType.Interval.day
        ts_s = datestr(ts_s, 'yyyy-mm-dd HH:MM:SS');
        ts_e = datestr(ts_e, 'yyyy-mm-dd HH:MM:SS');
        [is_err, obj.err.code, obj.err.msg, data] = obj.AnalysisApiResult(py.api.fetch_day_etf_bar(obj.user, obj.password, symb, exc, ts_s, ts_e));
        if (~is_err)
            md = [datenum(data(:, 1)), cell2mat(data(:, 2 : end))];
            md(logical(sum(isnan(md), 2)), :) = [];
        else
            md = [];
             obj.DispErr(sprintf('Fetching etf [%s] daily market data', symb));
        end
        
    otherwise
        error('Unexpected "interval" for [%] market data fetching, please check.', symb);
end
end