% Tushare 获取期权行情数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMdOption(obj, symb, exc, inv, ts_s, ts_e)

exc = obj.exchanges(Utility.ToString(exc));
switch inv
    case EnumType.Interval.min1
        [is_err, md] = obj.FetchMinMd(symb, exc, 1, ts_s, ts_e,  'Fetching option [%s.%s] minitue market data');
        
    case EnumType.Interval.min5
        [is_err, md] = obj.FetchMinMd(symb, exc, 5, ts_s, ts_e, 'Fetching option [%s.%s] minitue market data');
        
    case EnumType.Interval.day
        % 下载行情
        [is_err, md] = obj.FetchDailyMd(symb, exc, ts_s, ts_e, 'opt_daily', {'trade_date', 'open', 'high', 'low', 'close', 'vol', 'amount', 'oi', 'pre_settle', 'settle'}, 'Fetching option [%s%s] daily market data');
        
        % 补全到期日信息
        if (~isempty(md))
            last_td_dt = obj.api.query('opt_basic', 'ts_code', [symb, exc]);
            last_td_dt = str2double(last_td_dt.delist_date);
            
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
            
            % 修正成交额
            md(:, 7) = md(:, 7) * 10000;
        end
        
    otherwise
        error('Unexpected "interval" for [%] market data fetching, please check.', symb);
end
end