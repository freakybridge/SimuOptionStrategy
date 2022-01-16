% Wind 获取ETF分钟数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMinMdEtf(obj, etf, ts_s, ts_e)
[is_err, md] = obj.FetchMinMd(etf, ts_s, ts_e, 'Fetching etf [%s.%s] minitue market data');
end