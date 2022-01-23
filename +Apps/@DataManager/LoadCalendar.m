% DataManager / LoadCalendar 多种方式获取交易日历
% v1.3.0.20220113.beta
%      1.首次加入
function cal = LoadCalendar(obj)

% 读取数据库 / csv
cal = obj.db.LoadCalendar();
if (isempty(cal))
    cal = obj.dr.LoadCalendar(obj.dir_csv);
    if (~NeedUpdate(cal))
        obj.db.SaveCalendar(cal);
        return;
    end
elseif (~NeedUpdate(cal))
    return;
end
    
% 更新
cal = obj.LoadCalViaDataSource();
obj.db.SaveCalendar(cal);
obj.dr.SaveCalendar(cal, obj.dir_csv);

end


% 判定是否需要更新
function ret = NeedUpdate(cal)
% 若当前无日历信息，必须更新
if (isempty(cal))
    ret = true;
    return;
end

% 若为距离已有日历不足365天，则必须更新
if (cal(end, 5) - now() <= 365)
    ret = true;
else
    ret = false;
end
end