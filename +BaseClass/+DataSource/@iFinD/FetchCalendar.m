% Wind 获取交易日历
% v1.3.0.20220113.beta
%       1.首次加入
function cal = FetchCalendar(obj)
error('Under construction, please check!');
date.start = datestr(datenum('1988-09-10') - 365, 'yyyy-mm-dd');
date.end = datestr(now + 365, 'yyyy-mm-dd');
% 
% [data,errorcode,time,errmsg]=THS_Date_Query('212001','mode:1,dateType:0,period:D,dateFormat:0','2022-01-06','2022-01-17')
% 
% 
% 
% 
% % 获取日历日 / 交易日
% [date_natural, errorcode, time, errmsg] = THS_Date_Query('212001', 'mode:1,dateType:0,period:D,dateFormat:0', '2022-01-06', '2022-01-13');
% 
% [date_trading, errorcode, time, errmsg] = THS_Date_Query('212001', 'mode:1,dateType:1,period:D,dateFormat:0', '2022-01-06', '2022-01-13');
% [~, ~, ~, date_natural, ~, ~] = obj.api.tdays(date.start, date.end, 'Days=Alldays');
% [~, ~, ~, date_working, ~, ~] = obj.api.tdays(date.start, date.end, 'Days=Weekdays');
% [~, ~, ~, date_trading, ~, ~] = obj.api.tdays(date.start, date.end);
% 
% % 合并交易日历
% cal = date_natural;
% [~, loc] = ismember(date_trading, date_natural);
% cal(loc, 2) = 1;
% [~, loc] = ismember(date_working, date_natural);
% cal(loc, 3) = 1;
% 
% % 标记工作日
% cal(:, 4) = weekday(cal(:, 1));
% cal(:, 5) = cal(:, 1);
% cal(:, 1) = str2double(cellstr(datestr(cal(:, 1), 'yyyymmdd')));
% 

% string start = "1988-09-10";
% 	auto tmp = TimeStamp();
% 	tmp.DeltaDays(365);
% 	string end = tmp.ToString("%04d-%02d-%02d");
% 
% 
% 	// 获取所有日历日
% 	THS_DateQuery("SSE", "dateType:1,period:D,dateFormat:0", start.c_str(), end.c_str(), _data_buffer);
% 	reader.parse(*_data_buffer, root);
% 	StatsDataUsage("THS_DateQuery", root["dataVol"].asInt());
% 
% 	if (IsError("Calendar", _out))
% 		return 0;
% 
% 	_out.reserve(root["tables"]["time"].size());
% 	for (auto i = 0; i != root["tables"]["time"].size(); ++i)
% 	{
% 		Day curr(TimeStamp(root["tables"]["time"][i].asString().c_str(), "%04d-%02d-%02d %02d:%02d:%02d"));
% 		_out.push_back(curr);
% 	}
% 	
% 
% 	// 获取所有交易日
% 	THS_DateQuery("SSE", "dateType:0,period:D,dateFormat:0", start.c_str(), end.c_str(), _data_buffer);
% 	reader.parse(*_data_buffer, root);
% 	StatsDataUsage("THS_DateQuery", root["dataVol"].asInt());
% 
% 	if (IsError("Calendar-TradingDay", _out))
% 		return 0;
% 
% 	for (auto i = 0; i != root["tables"]["time"].size(); ++i)
% 	{
% 		Day curr(TimeStamp(root["tables"]["time"][i].asString().c_str(), "%04d-%02d-%02d %02d:%02d:%02d"));
% 		auto loc = find(_out.begin(), _out.end(), curr);
% 		loc->setTrading(true);
% 	}		
% 
% 
% 	// 设置工作日
% 	for (auto& i : _out)
% 	{
% 		bool value;
% 		if (i.Weekday() == TimeStamp::Weekday::Saturday || i.Weekday() == TimeStamp::Weekday::Sunday)
% 			value = false;
% 		else
% 			value = true;
% 		i.setWorking(value);
% 	}
end