% ����Դ�˿� WindApi
% v1.2.0.20220105.beta
%       �״����
classdef Wind < BaseClass.DataSource.DataSource
    properties (Access = private)
        api;
    end
    properties (Hidden)        
        exchanges;
    end
    
    methods
        % ���캯��
        function obj = Wind()
            %WIND ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj = obj@BaseClass.DataSource.DataSource();
            obj.api = windmatlab;
            obj.exchanges = containers.Map;
            obj.exchanges(EnumType.Exchange.ToString(EnumType.Exchange.SSE)) = 'SH';
            obj.exchanges(EnumType.Exchange.ToString(EnumType.Exchange.SZSE)) = 'SZ';       
            disp('DataSource Wind Ready.');
        end
        
        % ��ȡ��Ȩ��������
        function md = FetchOptionMinData(obj, opt, ts_s, ts_e, inv)
            % ȷ���Ƿ����ݳ���
            if (datenum(opt.GetDateListed()) < now - obj.FetchApiDateLimit())
                md = [];
                return;
            end
            
            % ����
            exc = obj.exchanges(EnumType.Exchange.ToString(opt.exchange));
            [md, code, ~, dt, errorid, ~] = obj.api.wsi([opt.symbol, '.', exc], 'open,high,low,close,amt,volume,oi', ...
                datestr(ts_s, 'yyyy-mm-dd HH:MM:SS'), datestr(ts_e, 'yyyy-mm-dd HH:MM:SS'), sprintf('BarSize=%i',  inv));
            
            if (errorid ~= 0)
                warning('Fetching option %s market data error, id %i, msg %s, please check.', code{:}, errorid, md{:});
                md = [];
                return;
            end
            md = [dt, md];
        end
        
        % ��ȡ��Ȩ��Լ�б�
        function instrus = FetchOptionChain(obj, sample_opt, instru_local, date_s, date_e)
            exc_ud = obj.exchanges(EnumType.Exchange.ToString(sample_opt.ud_exchange));
            exc_opt = lower(EnumType.Exchange.ToString(sample_opt.exchange));
            str = sprintf('startdate=%s;enddate=%s;exchange=%s;windcode=%s.%s;status=all;field=wind_code,sec_name,call_or_put,exercise_price,contract_unit,listed_date,expire_date', ...
                date_s, date_e, exc_opt, sample_opt.variety, exc_ud);
            [instrus, ~, ~, ~, errid, ~] = obj.api.wset('optioncontractbasicinfo', str);

            % ��������쳣
            if isa(instrus, 'cell')
                % �����º�Լ���ϲ����غ�Լ
                % ��ȫ��Ϣ
                exc = repmat({upper(char(EnumType.Exchange.ToString(sample_opt.exchange)))}, size(instrus, 1), 1);
                var = repmat({char(sample_opt.variety)}, size(instrus, 1), 1);
                ud_symb = repmat({char(sample_opt.ud_symbol)}, size(instrus, 1), 1);
                ud_product = repmat({upper(char(EnumType.Product.ToString(sample_opt.ud_product)))}, size(instrus, 1), 1);
                ud_exc = repmat({upper(char(EnumType.Exchange.ToString(sample_opt.ud_exchange)))}, size(instrus, 1), 1);
                instrus(strcmpi(instrus(:, 3), '�Ϲ�'), 3) = deal({'Call'});
                instrus(strcmpi(instrus(:, 3), '�Ϲ�'), 3) = deal({'Put'});
                striketype = char(EnumType.OptionStrikeType.ToString(sample_opt.strike_type));
                striketype = [striketype(1), lower(striketype(2 : end))];
                striketype = repmat({striketype}, size(instrus, 1), 1);
                ticksz = repmat({sample_opt.tick_size}, size(instrus, 1), 1);
                dlmonth = num2cell(cellfun(@(x) str2double(datestr(x, 'yyyymm')), instrus(:, 7)));
                trade_start = arrayfun(@(x) {datestr(x, 'yyyy-mm-dd HH:MM')}, Utility.DatetimeOffset(instrus(:, 6), sample_opt.tradetimetable(1)));
                trade_end = arrayfun(@(x) {datestr(x, 'yyyy-mm-dd HH:MM')}, Utility.DatetimeOffset(instrus(:, 7), sample_opt.tradetimetable(end)));
                sttmode = char(EnumType.OptionStrikeType.ToString(sample_opt.settle_mode));
                sttmode = [sttmode(1), lower(sttmode(2 : end))];
                sttmode = repmat({sttmode}, size(instrus, 1), 1);
                upd_time = repmat({datestr(now(), 'yyyy-mm-dd HH:MM')}, size(instrus, 1), 1);
                
                instrus = [instrus(:, 1 : 2), exc, var, ud_symb, ud_product, ud_exc, instrus(:, 3), striketype, instrus(:, 4 : 5), ticksz, dlmonth, trade_start, trade_end, sttmode, upd_time];
                instrus = cell2table(instrus, 'VariableNames', instru_local.Properties.VariableNames);
                
                % �ϲ�
                [~, loc] = intersect(instru_local(:, 1), instrus(:, 1));
                instru_local(loc, :) = [];
                instrus = [instru_local; instrus];
                instrus = sortrows(instrus, 1);
                
                
            elseif isnan(instrus) && ~isempty(instru_local)
                % ���º�Լ������
                instrus = instru_local;
                return;
            elseif (errid)
                error("DataSource Wind fetching option chain failure, please check. ERRORID:%i", errid);
            end
            
            % ��ΪETF��Ȩ����е���
            if (ismember('BaseClass.Asset.Option.ETF', superclasses(sample_opt)))
            end
        end
    end
    
    methods (Static)        
        % ��ȡapi����ʱ��
        function ret = FetchApiDateLimit()
            ret = 3 * 365;
        end
    end
end

