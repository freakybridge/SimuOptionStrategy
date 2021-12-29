% ���ݶ˿�API
classdef DatabaseApi < handle    
    properties (Hidden)
        user;
        password;
        driver; 
        url;
        name;
        conn;
    end
        
    methods
        % �˿ڳ�ʼ��
        function obj = DatabaseApi(name, user, pwd)
            obj.name = name;
            obj.user = user;
            obj.password = pwd;
            obj.driver = 'com.microsoft.sqlserver.jdbc.SQLServerDriver';
            obj.url = obj.ConfirmUrl();
            
            obj.On();
        end
        
        % ��
        function obj = On(obj)
            cConn = database(obj.name, obj.user, obj.password, obj.driver, [obj.url, obj.name]);
            if isopen(cConn)
                disp(['Database ', obj.name, ' log on success. ']);
                obj.conn = cConn;
            else
                disp(['Database ', obj.name, ' log on failure. ']);
                error(cConn.Message);
            end
        end
        
        % �ر�
        function obj = Off(obj)
            close(obj.conn);
            if ~isopen(obj.conn)
                disp(['Database ', obj.name, ' log off success. ']);
            else
                disp(['Database ', obj.name, ' log off failure. ']);
                error(cThis.Conn.Message);
            end
        end
    end
    
    
    methods (Static)
        % ��ȡ��Ȩ��
        function instru = FetchOptionChain(db_nm, user, pwd)
            % ����option chain���˲������޸�
            sql_string = ['SELECT * FROM ', db_nm, '.[dbo].[CodeList] ORDER BY wind_code'];
            setdbprefs('DataReturnFormat', 'CellArray');
            api = BaseClass.DatabaseApi(db_nm, user, pwd);
            chain = table2cell(fetch(api.conn, sql_string));
            chain(:, end) = [];
            api.Off();
            
            % ���ֻ���������
            switch lower(db_nm)
                case {'option_510050_sh', ...
                        'option_510300_sh', ...
                        'option_159919_sz', ...
                        'option_io_cfe'}
                    chain(:, 1) = chain(:, 15);
                    chain(:, [9, 15]) = [];
                otherwise
            end
            col = [9, 10, 11, 12];
            for i = 1 : length(col)
                chain(:, col(i)) = num2cell(str2double(cellstr(datestr(chain(:, col(i)), 'yyyymmdd'))));
            end
            
            % struct��
            fields = lower({ ...
                'wind_code', ...
                'sec_name', ...
                'option_mark_code', ...
                'option_type', ...
                'call_or_put', ...
                'exercise_mode', ...
                'exercise_price', ...
                'contract_unit_ini', ...
                'listed_date', ...
                'expire_date', ...
                'exercise_date', ...
                'settle_date', ...
                'settle_mode', ...
                'db', ...
                });
            chain = cell2struct(chain, fields, 2);
            
            % д���ֶ� limit_month
            temp = num2cell(floor([chain.expire_date] / 100));
            [chain.limit_month] = temp{:};
            
            % ���ֻ���Ȩ�����ֶ�
            loc_call = strcmpi({chain.call_or_put}, '�Ϲ�');
            loc_put = strcmpi({chain.call_or_put}, '�Ϲ�');
            [chain(loc_call).call_or_put] = deal(1);
            [chain(loc_put).call_or_put] = deal(-1);
            
            % ɾ���������ֶ�(db) / �޸��ֶ�(wind_code, sec_name, option_mark_code)
            chain = rmfield(chain, 'db');
            [chain.code] = chain.wind_code;
            chain = rmfield(chain, 'wind_code');
            [chain.comment] = chain.sec_name;
            chain = rmfield(chain, 'sec_name');
            [chain.underlying] = chain.option_mark_code;
            instru = rmfield(chain, 'option_mark_code');
        end
    end
    
    
    methods (Access = private, Hidden, Static)
        % ȷ��url
        function ret = ConfirmUrl()
            [~, result] = dos('ipconfig');
            [~, loc(1)] = regexp(result, 'IPv4 ��ַ . . . . . . . . . . . . : ');
            loc(2) = regexp(result, '��������  . . . . . . . . . . . . : ');
            ip = result(loc(1) + 1 : loc(2) - 1);
            ip(isspace(ip)) = [];
            ret = ['jdbc:sqlserver://', ip, ':1433;;databaseName='];
        end
    end
end