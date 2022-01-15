% 从数据接口获取交易日历
% v1.3.0.20220113.beta
%      1.首次加入
function cal = LoadCalViaDs(obj)
cal = obj.ds.FetchCalendar();
end