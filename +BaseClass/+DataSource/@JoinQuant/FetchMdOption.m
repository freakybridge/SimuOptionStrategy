% JoinQuant 获取期权行情数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMdOption(obj, symb, exc, inv, ts_s, ts_e)

% 预处理
ts_s = datestr(ts_s, 'yyyy-mm-dd HH:MM:SS');
ts_e = datestr(ts_e, 'yyyy-mm-dd HH:MM:SS');
cnt = obj.CalcFetchingRows(ts_s, ts_e, inv, exc);
exc = obj.exchanges(Utility.ToString(exc));

% 下载
switch inv
    case EnumType.Interval.min1
        [is_err, md] = FetchMin(obj, symb, exc, '1m', ts_s, ts_e, cnt, {'date', 'open', 'high', 'low', 'close', 'volume', 'money', 'open_interest'},  'Fetching option [%s.%s] minitue market data');
        
    case EnumType.Interval.min5
        [is_err, md] = FetchMin(obj, symb, exc, '5m', ts_s, ts_e, cnt, {'date', 'open', 'high', 'low', 'close', 'volume', 'money', 'open_interest'},  'Fetching option [%s.%s] minitue market data');
        
    case EnumType.Interval.day
        [is_err, obj.err.code, obj.err.msg, data] = obj.AnalysisApiResult(py.api.fetch_day_option_bar(obj.user, obj.password, symb, exc, ts_s, ts_e));
        if (~is_err)
            % 整理
            md = [datenum(data(:, 1)), cell2mat(data(:, 2 : end))];
            
            % 获取最后交易日 / 补全到期日信息
            [is_err, obj.err.code, obj.err.msg, last_td_dt] = obj.AnalysisApiResult(py.api.fetch_option_last_tradedate(obj.user, obj.password, symb, exc));
            last_td_dt = str2double(datestr(last_td_dt, 'yyyymmdd'));
            
            if (isempty(obj.calendar))
                [~, obj.calendar] = obj.FetchCalendar();
            end
            for i = 1 : size(md, 1)
                s = find(obj.calendar(:, 5) == md(i, 1), 1, 'first');
                e = find(obj.calendar(:, 1) == last_td_dt, 1, 'first');
                rem_n = e - s + 1;
                rem_t = sum(obj.calendar(s : e, 2));
                md(i, 11 : 12) = [rem_n, rem_t];
            end
            
        else
            md = [];
            obj.DispErr(sprintf('Fetching option [%s.%s] daily market data', symb, exc));
        end
        
    otherwise
        error('Unexpected "interval" for [%s] market data fetching, please check.', symb);
end
end