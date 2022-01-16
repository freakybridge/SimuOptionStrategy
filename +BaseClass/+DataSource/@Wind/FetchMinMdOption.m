% Wind 获取期权分钟数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMinMdOption(obj, opt, ts_s, ts_e)
[is_err, md] = obj.FetchMinMd(opt, ts_s, ts_e, 'Fetching option [%s.%s] minitue market data');
end