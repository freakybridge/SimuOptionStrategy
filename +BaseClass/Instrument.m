classdef Instrument < handle
    properties
        symbol = [];
        exchange = [];
        under = [];
        call_or_put = [];
        strike = [];
        unit = [];
        md = [];
        move = [];
    end
    
    properties (Hidden)
        expire = [];
        listed_date = [];
        map_cp_num;
        map_num_cp;
    end
    properties (Dependent)
        dlmonth;
    end
    
    methods
        % 初始化
        function obj = Instrument(symb, exc, ud, ep, cp, k, ut, ldt)
            obj.symbol = symb;
            obj.exchange = exc;
            obj.under = ud;
            obj.expire = datenum(ep);
            
            obj.map_cp_num = containers.Map({'call', 'Call', 'CALL', 'c', 'put', 'Put', 'PUT', 'p'}, ...
                {1, 1, 1, 1, -1, -1, -1, -1});
            obj.map_num_cp = containers.Map({1, -1}, {'c', 'p'});
            
            obj.call_or_put = obj.map_cp_num(cp);
            obj.strike = k;
            obj.unit = ut;
            obj.listed_date = datenum(ldt);
            
        end
        
        % 交割月
        function ret = get.dlmonth(obj)
            ret = str2double(datestr(obj.expire, 'yymm'));
        end
        
        % 加入动作清单
        function AddMove(obj, timing, pos)
            dm = datenum(timing);
            tmp =  [dm, BaseClass.Instrument.GetDate(dm), BaseClass.Instrument.GetTime(dm), pos];
            obj.move = [obj.move; tmp];
        end
        
        % 读取行情
        function LoadMarketData(obj)
%             [~, ~, dat] = xlsread(fullfile(obj.excel_dir, obj.excel_file), 'dat');
%             dat(1, :) = [];
%             time_axis = datenum(dat(:, 1));
%             time_vec = datevec(time_axis);
%             time_axis = [time_axis, time_vec(:, 1) * 10000 + time_vec(:, 2) * 100 + time_vec(:, 3), time_vec(:, 4) * 100 + time_vec(:, 5)];
%             obj.md = [time_axis, cell2mat(dat(:, 2 : end))];
        end
                
        % 修补行情
        function RepairData(obj, tm_ax_std)
            % 行情对齐
            [~, loc] = intersect(tm_ax_std(:, 1), obj.md(:, 1));
            md_new = tm_ax_std;
            md_new(loc, 2 : 13) = obj.md(:, 2 : 13);
            
            % 消除nan
            md_new(isnan(md_new)) = 0;            
            
            % 补足行情
            % 补足前端行情
            loc_start = find(md_new(:, 7) ~= 0, 1, 'first');
            md_new(1 : loc_start, 7) = md_new(loc_start, 4);
            
            % 补足后端行情
            loc_end = find(md_new(:, 1) <= obj.expire, 1, 'last');
            for i = loc_start + 1 : loc_end
                if (md_new(i, 7) == 0)
                    md_new(i, 4 : 7) = md_new(i - 1, 7);
                end
            end
            obj.md = md_new;        
        end
        
        % 模拟交易
        function Simulation(obj)
            % 标记头寸
            obj.move = sortrows(obj.move, 1);
            tm_e = obj.expire;
            for i = 1 : size(obj.move, 1)
                tm_s = obj.move(i, 1);
                pos = obj.move(i, 4);
                loc = obj.md(:, 1) >= tm_s & obj.md(:, 1) < tm_e;
                obj.md(loc, 10) = pos;
            end
            obj.md(i, 13) = 0;
            
            % 计算盈亏
            loc_s = find(obj.md(:, 10) ~= 0, 1, 'first');
            loc_e = size(obj.md, 1);
            for i = loc_s : loc_e
                pos_yd = obj.md(i - 1, 10);
                pos_td = obj.md(i, 10);
                
                % 头寸变化 开盘价交易
                price_yd = obj.md(i - 1, 7);
                price_td = obj.md(i, 7);
                if (pos_yd ~= pos_td)
                    price_trade = obj.md(i, 4);
                    pnl_yd = (price_trade - price_yd) * obj.unit * pos_yd;
                    pnl_td = (price_td - price_trade) * obj.unit * pos_td;
                else
                    pnl_yd = (price_td - price_yd) * obj.unit * pos_td;
                    pnl_td = 0;
                end
                pnl_acc = pnl_yd + pnl_td + obj.md(i - 1, 13);               
                obj.md(i, 11 : 13) = [pnl_yd, pnl_td, pnl_acc];
            end
        end
        
        % 合约全名
        function ret = GetFullSymbol(obj)
            ret = [obj.symbol, '-',  num2str(obj.dlmonth), '-', obj.map_num_cp(obj.call_or_put), '-', num2str(obj.strike, '%.03f')];
        end
                
        % 获取挂牌时点
        function ret = GetDateListed(obj)
            ret = datestr(obj.listed_date);
        end
        
        % 获取到期时点
        function ret = GetDateExpire(obj)
            ret = datestr(obj.expire);
        end
        
        % 合并行情
        function MergeMarketData(obj, md_new)
            % 删除重复数据
            if (~isempty(obj.md))                
                [~, loc_old, ~] = intersect(obj.md(:, 1), md_new(:, 1));
                if (~isempty(loc_old))
                    obj.md(loc_old, :) = [];
                end
            end
            
            % 合并 / 按时间排序
            tmp = datevec(md_new(:, 1));
            date_lst = tmp(:, 1) * 10000 + tmp(:, 2) * 100 + tmp(:, 3);
            time_lst = tmp(:, 4) * 100 + tmp(:, 5);
            md_new = [md_new(:, 1), date_lst, time_lst, md_new(:, 2 : end)];
            if (~isempty(obj.md))
                obj.md = [obj.md; md_new];
            else
                obj.md = md_new;
            end
            
            % 修补数据
            obj.md = sortrows(obj.md, 1);
            obj.RepairData(obj.md(:, 1));
        end
                
        % 生成新K线
        function NewBarMarketData(obj, inv)
            % 生成时间轴
            timetable = [[930, 1130]; [1300, 1500]];
            datelst = unique(obj.md(:, 2));
            [tm_axis, bp] = Utility.GenStandardTimeAxis(timetable, datelst, inv);
            
            % 生成新K线
            md_new = tm_axis;
            tmp = datevec(tm_axis);
            md_new(:, 2) = tmp(:, 1) * 10000 + tmp(:, 2) * 100 + tmp(:, 3);
            md_new(:, 3) = tmp(:, 4) * 100 + tmp(:, 5);
            for i = 1 : size(md_new, 1)
                if (i ~= 1)
                    start_ = md_new(i - 1, 1);
                else
                    start_ = bp;
                end
                end_ = md_new(i, 1);
                    
                tmp = obj.md(obj.md(:, 1) > start_ & obj.md(:, 1) <= end_, :);
                if (~isempty(tmp))
                    p_open = tmp(1, 4);
                    p_high = max(tmp(:, 5));
                    p_low = min(tmp(:, 6));
                    p_last = tmp(end, 7);
                    turnover = sum(tmp(:, 8));
                    volume = sum(tmp(:, 9));
                    oi = tmp(end, 10);
                else
                    p_open = 0;
                    p_high = 0;
                    p_low = 0;
                    p_last = md_new(i - 1, 7);
                    turnover = 0;
                    volume = 0;
                    oi = md_new(i - 1, 10);
                end
                md_new(i, 4 : 10) = [p_open, p_high, p_low, p_last, turnover, volume, oi];
            end
            obj.md = md_new;
            
        end
    end
    
        
    methods (Hidden, Static)
        function ret = GetDate(input)
            ret = str2double(datestr(input, 'yyyymmdd'));
        end
        function ret = GetTime(input)
            ret = str2double(datestr(input, 'HHMM'));
        end
    end
    
    methods (Static)
        % 获取标准时间轴
        function tm_axis_std = UnionTimeAxis(portfolio)
            tm_axis_std = [];
            keys = portfolio.keys;
            for i = 1 : length(keys)
                tm_axis_std = union(tm_axis_std, portfolio(keys{i}).md(:, 1));
            end
            time_vec = datevec(tm_axis_std);
            tm_axis_std = [tm_axis_std, time_vec(:, 1) * 10000 + time_vec(:, 2) * 100 + time_vec(:, 3), time_vec(:, 4) * 100 + time_vec(:, 5)];
        end
        
        % 获取组合pnl
        function [pnl, legends, tm_ax] = GetPnL(portfolio)
            % 统计
            keys = portfolio.keys;
            pnl = zeros(size(portfolio(keys{1}).md, 1), length(keys));
            tm_ax = portfolio(keys{1}).md(:, 1 : 3);
            for i = 1 : length(keys)
                pnl(:, i) = portfolio(keys{i}).md(:, 13);
            end
            pnl = [sum(pnl, 2), pnl];
            loc = find(pnl(:, 1) ~= 0, 1, 'first') : size(pnl, 1);
            pnl = pnl(loc, :);
            tm_ax = tm_ax(loc, :);
            
            % 输出图示
            legends = cell(length(keys) + 1, 1);
            legends{1} = 'portfolio';
            for i = 1 : length(keys)
                legends{i + 1} = portfolio(keys{i}).GetFullSymbol();
            end
            
        end
    end
end