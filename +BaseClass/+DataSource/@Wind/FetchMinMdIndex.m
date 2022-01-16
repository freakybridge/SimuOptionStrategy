% Wind 获取指数分钟数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMinMdIndex(obj, idx, ts_s, ts_e)
[is_err, md] = obj.FetchMinMd(idx, ts_s, ts_e, 'Fetching index [%s.%s] minitue market data');
end