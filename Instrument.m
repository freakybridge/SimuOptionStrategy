classdef Instrument < handle
    properties
        symbol = [];
        under = [];
        call_or_put = [];
        strike = [];
        unit = [];
        md = [];
        move = [];
    end
    
    properties (Hidden)
        expire = [];
        date_start = [];
        map_cp_num;
        map_num_cp;
        excel_file;
    end
    properties (Dependent)
        dlmonth;
    end
    
    methods
        % ��ʼ��
        function obj = Instrument(symb, ud, ep, cp, k, ut, home_path)
            obj.symbol = num2str(symb);
            obj.under = ud;
            obj.expire = datenum(ep);
            
            obj.map_cp_num = containers.Map({'call', 'Call', 'CALL', 'c', 'put', 'Put', 'PUT', 'p'}, ...
                {1, 1, 1, 1, -1, -1, -1, -1});
            obj.map_num_cp = containers.Map({1, -1}, {'c', 'p'});
            
            obj.call_or_put = obj.map_cp_num(cp);
            obj.strike = k;
            obj.unit = ut;
            obj.date_start = '2015-02-09 09:30';
            obj.AddMove(obj.date_start, 0);
            obj.FindExcel(home_path);
            
        end
        
        % ������
        function ret = get.dlmonth(obj)
            ret = str2double(datestr(obj.expire, 'yymm'));
        end
        
        % ���붯���嵥
        function AddMove(obj, timing, pos)
            dm = datenum(timing);
            tmp =  [dm, Instrument.GetDate(dm), Instrument.GetTime(dm), pos];
            obj.move = [obj.move; tmp];
        end
        
        % ��ȡ����
        function LoadMarketData(obj)
            [~, ~, dat] = xlsread(obj.excel_file);
            dat(1, :) = [];
            dat(:, 1 : 2) = [];
            time_axis = datenum(dat(:, 1));
            time_vec = datevec(time_axis);
            time_axis = [time_axis, time_vec(:, 1) * 10000 + time_vec(:, 2) * 100 + time_vec(:, 3), time_vec(:, 4) * 100 + time_vec(:, 5)];
            obj.md = [time_axis, cell2mat(dat(:, 2 : end))];
        end
                
        % �޲�����
        function RepairData(obj, tm_ax_std)
            % �������
            [~, loc] = intersect(tm_ax_std(:, 1), obj.md(:, 1));
            md_new = tm_ax_std;
            md_new(loc, 4 : 9) = obj.md(:, 4 : 9);
            
            % ��������
            loc_start = find(md_new(:, 7) ~= 0, 1, 'first');
            loc_end = find(md_new(:, 1) <= obj.expire, 1, 'last');
            for i = loc_start + 1 : loc_end
                if (md_new(i, 7) == 0)
                    md_new(i, 4 : 7) = md_new(i - 1, 7);
                end
            end
            obj.md = md_new;        
        end
        
        % ģ�⽻��
        function Simulation(obj)
            % ���ͷ��
            for i = 2 : size(obj.move, 1)
                if (i ~= size(obj.move, 1))
                    tm_s = obj.move(i - 1, 1);
                    tm_e = obj.move(i, 1);
                    pos = obj.move(i - 1, 4);   
                else
                    tm_s = obj.move(i, 1);
                    tm_e = obj.expire;
                    pos = obj.move(i, 4);   
                end
                loc = obj.md(:, 1) >= tm_s & obj.md(:, 1) < tm_e;
                obj.md(loc, 10) = pos;
            end
            
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
                    pnl_yd = 0;
                    pnl_td = (price_td - price_yd) * obj.unit * pos_td;
                end
                pnl_acc = pnl_yd + pnl_td;               
                obj.md(i, 11 : 13) = [pnl_yd, pnl_td, pnl_acc];
            end
            
            
        end
    end
    
    methods (Access = private)
        % ����excel�ļ���
        function FindExcel(obj, hm_path)
            loc = strfind(hm_path, '\');
            obj.excel_file = [hm_path(1 : loc(end)), ...
                obj.under, '-5m\', ...                
                obj.symbol, '-',  num2str(obj.dlmonth), '-', obj.map_num_cp(obj.call_or_put), '-', num2str(obj.strike, '%.03f'), ...
                '.xlsx'];
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
    end
end