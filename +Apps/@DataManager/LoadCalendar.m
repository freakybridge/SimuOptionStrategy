% DataManager / LoadCalendar
% v1.3.0.20220113.beta
%      1.First Commit
function cal = LoadCalendar(obj)

% local fetching
cal = obj.db.LoadCalendar();
if (isempty(cal))
    cal = obj.dr.LoadCalendar(obj.dir_root);
    if (~NeedUpdate(cal))
        obj.db.SaveCalendar(cal);
        return;
    end
elseif (~NeedUpdate(cal))
    return;
end
    
% fetch from ds / saving
cal = LoadViaDs(obj);
obj.db.SaveCalendar(cal);
obj.dr.SaveCalendar(cal, obj.dir_root);

end


% determine whether need update
function ret = NeedUpdate(cal)
% if isempty -> need update
if (isempty(cal))
    ret = true;
    return;
end

% 20 days since last update -> need update
if (now() - cal(end, 6) >= 20)
    ret = true;
else
    ret = false;
end
end

% 从数据接口获取合约列表
function cal = LoadViaDs(obj)
while (true)
    [is_err, cal] = obj.ds.FetchCalendar();    
    if (is_err)
        obj.SetDsFailure();
        obj.ds = obj.AutoSwitchDataSource();
        continue;    
    end
    return;
end
end