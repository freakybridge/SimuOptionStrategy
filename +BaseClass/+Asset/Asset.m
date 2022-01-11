% Asset����
% v1.2.0.20220105.beta
%       �״����
classdef Asset < handle & matlab.mixin.Heterogeneous

    properties
        symbol;
        exchange;
        variety;
        unit;
        interval;
        md;
        move;
        sec_name;
    end
    properties (Abstract, Constant)
        product;
        tradetimetable;
        tick_size;
    end
    
    %% ��������
    methods
        % ���캯��
        function obj = Asset(symb, exc, var, sz, inv, snm)
            % ASSET ��������ʵ��
            % �˴���ʾ��ϸ˵��
            obj.symbol = symb;
            obj.exchange = EnumType.Exchange.ToEnum(exc);
            obj.variety = var;
            obj.unit = sz;
            obj.interval = EnumType.Interval.ToEnum(inv);
            obj.sec_name = snm;
            obj.md = [];
            obj.move = [];
        end
        
        % �ϲ�����
        function MergeMarketData(obj, md_new)
            % ɾ���ظ�����
            if (~isempty(obj.md))                
                [~, loc_old, ~] = intersect(obj.md(:, 1), md_new(:, 1));
                if (~isempty(loc_old))
                    obj.md(loc_old, :) = [];
                end
            end
            
            % �ϲ� / ��ʱ������
            tmp = datevec(md_new(:, 1));
            date_lst = tmp(:, 1) * 10000 + tmp(:, 2) * 100 + tmp(:, 3);
            time_lst = tmp(:, 4) * 100 + tmp(:, 5);
            md_new = [md_new(:, 1), date_lst, time_lst, md_new(:, 2 : end)];
            if (~isempty(obj.md))
                obj.md = [obj.md; md_new];
            else
                obj.md = md_new;
            end
            
            % �޲�����
            obj.md = sortrows(obj.md, 1);
            obj.RepairData(obj.md(:, 1));
        end
        
        % �޲�����
        function RepairData(obj, tm_ax_std)
            % �������
            [~, loc] = intersect(tm_ax_std(:, 1), obj.md(:, 1));
            md_new = tm_ax_std;
            md_new(loc, 2 : size(obj.md, 2)) = obj.md(:, 2 : end);
            
            % ����nan
            md_new(isnan(md_new)) = 0;
            
            % ��������
            % ����ǰ������
            loc_start = find(md_new(:, 7) ~= 0, 1, 'first');
            md_new(1 : loc_start, 7) = md_new(loc_start, 4);
            
            % ����������
            loc_end = find(md_new(:, 1) <= obj.expire, 1, 'last');
            for i = loc_start + 1 : loc_end
                if (md_new(i, 7) == 0)
                    md_new(i, 4 : 7) = md_new(i - 1, 7);
                end
            end
            obj.md = md_new;
        end
        
        % ����������K��
        function NewBarMarketData(obj, inv)
            % ����ʱ����
            datelst = unique(obj.md(:, 2));
            [tm_axis, bp] = Utility.GenStandardTimeAxis(obj.timetable, datelst, inv);
            
            % ������K��
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
        
        % ���붯���嵥
        function AddMove(obj, timing, pos)
            dm = datenum(timing);
            tmp =  [dm, BaseClass.Instrument.GetDate(dm), BaseClass.Instrument.GetTime(dm), pos];
            obj.move = [obj.move; tmp];
        end
                
        % ģ�⽻��
        function Simulation(obj)
            % ���ͷ��
            obj.move = sortrows(obj.move, 1);
            tm_e = obj.expire;
            for i = 1 : size(obj.move, 1)
                tm_s = obj.move(i, 1);
                pos = obj.move(i, 4);
                loc = obj.md(:, 1) >= tm_s & obj.md(:, 1) < tm_e;
                obj.md(loc, 10) = pos;
            end
            obj.md(i, 13) = 0;
            
            % ����ӯ��
            loc_s = find(obj.md(:, 10) ~= 0, 1, 'first');
            loc_e = size(obj.md, 1);
            for i = loc_s : loc_e
                pos_yd = obj.md(i - 1, 10);
                pos_td = obj.md(i, 10);
                
                % ͷ��仯 ���̼۽���
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
    end
    
    %% ��̬����
    methods (Static)
        % ��ȡ��׼ʱ����
        function tm_axis_std = UnionTimeAxis(portfolio)
            tm_axis_std = [];
            keys = portfolio.keys;
            for i = 1 : length(keys)
                tm_axis_std = union(tm_axis_std, portfolio(keys{i}).md(:, 1));
            end
            time_vec = datevec(tm_axis_std);
            tm_axis_std = [tm_axis_std, time_vec(:, 1) * 10000 + time_vec(:, 2) * 100 + time_vec(:, 3), time_vec(:, 4) * 100 + time_vec(:, 5)];
        end
        
        % ��ȡ���pnl
        function [pnl, legends, tm_ax] = GetPnL(portfolio)
            % ͳ��
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
            
            % ���ͼʾ
            legends = cell(length(keys) + 1, 1);
            legends{1} = 'portfolio';
            for i = 1 : length(keys)
                legends{i + 1} = portfolio(keys{i}).GetFullSymbol();
            end
            
        end
    end
    
    
        
    %% ���÷���
    methods (Hidden, Static)
        % ��ȡ���� / ʱ��
        function ret = GetDate(input)
            ret = str2double(datestr(input, 'yyyymmdd'));
        end
        function ret = GetTime(input)
            ret = str2double(datestr(input, 'HHMM'));
        end
    end
end

