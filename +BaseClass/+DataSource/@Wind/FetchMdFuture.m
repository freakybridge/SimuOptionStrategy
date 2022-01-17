% Wind 获取期货分钟数据
% v1.3.0.20220113.beta
%       1.首次加入
function [is_err, md] = FetchMinMdFuture(obj, fut, ts_s, ts_e)
[is_err, md] = obj.FetchMinMd(fut, ts_s, ts_e, 'Fetching future [%s.%s] minitue market data');
end