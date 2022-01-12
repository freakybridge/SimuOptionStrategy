% ����Դ�˿� iFinDApi
% v1.2.0.20220105.beta
%       �״����
classdef iFinD < BaseClass.DataSource.DataSource
    properties (Access = private)
        user;
        password;
        api;
    end
    properties (Hidden)        
        exchanges;
    end
    
    methods
        % ���캯��
        function obj = iFinD(ur, pwd)
            % iFinD ��������ʵ��
            %   �˴���ʾ��ϸ˵��
            obj = obj@BaseClass.DataSource.DataSource();
            obj.user = ur;
            obj.password = pwd;
            THS_iFinDLogin(ur, pwd);
            
            obj.exchanges = containers.Map;
            obj.exchanges(EnumType.Exchange.ToString(EnumType.Exchange.SSE)) = 'SH';
            obj.exchanges(EnumType.Exchange.ToString(EnumType.Exchange.SZSE)) = 'SZ';         
            disp('DataSource iFinD Ready.');
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
            [md, errorid, dt, ~,~, ~, ~, ~] = THS_HF([opt.symbol, '.', exc],'open;high;low;close;amount;volume;openInterest',...
                sprintf('Fill:Previous,Interval:%i',  inv), ...
                datestr(ts_s, 'yyyy-mm-dd HH:MM:SS'), ...
                datestr(ts_e, 'yyyy-mm-dd HH:MM:SS'), ...
                'format:matrix');
            
            if (errorid ~= 0)
                warning('Fetching option %s market data error, id %i, please check.', symb, errorid);
                md = [];
                return;
            end
            md = [datenum(dt), md];
            
        end
                
        % ��ȡ��Ȩ��Լ�б�
        function instrus = FetchOptionChain(obj, opt_s, instru_local)
            % ��ȡ��������յ�
            [date_s, date_e] = obj.GetChainUpdateSE(opt_s, instru_local);
            
            % ��ȡ����
            if (isa(opt_s, 'BaseClass.Asset.Option.Instance.SSE_510050'))
                param = '171002001';
            elseif (isa(opt_s, 'BaseClass.Asset.Option.Instance.SSE_510300'))
                param = '171002002';
            elseif (isa(opt_s, 'BaseClass.Asset.Option.Instance.SZSE_159919'))
                param = '171003006';
            else
                error("Unexpected option class type, please check!");
            end
            
            % ���غ�Լ����
            symbols = [];
            for i = datenum(date_s) : 15 : datenum(date_e)
                str = sprintf('%s;%s', datestr(i, 'yyyy-mm-dd'), param);
                [data, errorcode, errmsg, ~, ~, ~]=THS_DP('block', str,'thscode:Y','format:array');
                if (errorcode)
                    error("Fetching option chain error, please check. Code:%d, MSG: %s", errorcode, errmsg{:});
                end
                symbols = union(symbols, data);                
            end
            
            [data,errorcode,indicators,thscode,errmsg,dataVol,datatype,perf]=THS_BD('10003533.SH,10003534.SH',...
                'ths_option_short_name_option;ths_contract_type_option;ths_strike_price_option;ths_contract_multiplier_option;ths_listed_date_option;ths_maturity_date_option;', ';;2022-01-12;;;;','format:array');
            exc_ud = obj.exchanges(EnumType.Exchange.ToString(opt_s.ud_exchange));
            exc_opt = lower(EnumType.Exchange.ToString(opt_s.exchange));
            str = sprintf('startdate=%s;enddate=%s;exchange=%s;windcode=%s.%s;status=all;field=wind_code,sec_name,call_or_put,exercise_price,contract_unit,listed_date,expire_date', ...
                date_s, date_e, exc_opt, opt_s.variety, exc_ud);
            [instrus, ~, ~, ~, errid, ~] = obj.api.wset('optioncontractbasicinfo', str);

            % ��������쳣
            if isa(instrus, 'cell')
                % �����º�Լ���ϲ����غ�Լ
                % ��������Ϣ
                instrus(strcmpi(instrus(:, 3), '�Ϲ�'), 3) = deal({'Call'});
                instrus(strcmpi(instrus(:, 3), '�Ϲ�'), 3) = deal({'Put'});
                instrus(:, 6) = arrayfun(@(x) {datestr(x, 'yyyy-mm-dd HH:MM')}, Utility.DatetimeOffset(instrus(:, 6), opt_s.tradetimetable(1)));
                instrus(:, 7) = arrayfun(@(x) {datestr(x, 'yyyy-mm-dd HH:MM')}, Utility.DatetimeOffset(instrus(:, 7), opt_s.tradetimetable(end)));
                instrus(:, 8) = num2cell(cellfun(@(x) str2double(datestr(x, 'yyyymm')), instrus(:, 7)));
                
                % ��ȫ��Ϣ
                exc = upper(char(EnumType.Exchange.ToString(opt_s.exchange)));
                var = char(opt_s.variety);
                ud_symb = char(opt_s.ud_symbol);
                ud_product = upper(char(EnumType.Product.ToString(opt_s.ud_product)));
                ud_exc = upper(char(EnumType.Exchange.ToString(opt_s.ud_exchange)));
                striketype = Utility.InitCapital(EnumType.OptionStrikeType.ToString(opt_s.strike_type));
                ticksz = opt_s.tick_size;
                sttmode = Utility.InitCapital(EnumType.OptionSettleMode.ToString(opt_s.settle_mode));
                upd_time = datestr(now(), 'yyyy-mm-dd HH:MM');
                info = {exc, var, ud_symb, ud_product, ud_exc,  striketype, ticksz, sttmode, upd_time};
                info = repmat(info, size(instrus, 1), 1);
                
                instrus = [instrus(:, 1 : 2), info(:, 1 : 5), instrus(:, 3), info(:, 6), instrus(:, 4 : 5), info(:, 7), instrus(:, [8, 6, 7]), info(:, 8 : 9)];
                instrus = cell2table(instrus, 'VariableNames', {'SYMBOL','SEC_NAME','EXCHANGE','VARIETY','UD_SYMBOL','UD_PRODUCT','UD_EXCHANGE','CALL_OR_PUT','STRIKE_TYPE','STRIKE','SIZE','TICK_SIZE','DLMONTH','START_TRADE_DATE','END_TRADE_DATE','SETTLE_MODE','LAST_UPDATE_DATE'});

                % �ϲ�
                if (~isempty(instru_local))
                    [~, loc] = intersect(instru_local(:, 1), instrus(:, 1));
                    instru_local(loc, :) = [];
                    instrus = [instru_local; instrus];
                end
                instrus = sortrows(instrus, 1);
                
            elseif isnan(instrus) && ~isempty(instru_local)
                % ���º�Լ������
                instrus = instru_local;
                return;
            elseif (errid)
                error("DataSource Wind fetching option chain failure, please check. ERRORID:%i", errid);
            end
        end
    end
    
    methods (Static)        
        % ��ȡapi����ʱ��
        function ret = FetchApiDateLimit()
            ret = 1 * 365;
        end
    end
end

