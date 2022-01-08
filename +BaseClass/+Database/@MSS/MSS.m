classdef MSS < BaseClass.Database.Database
    % MSS �˴���ʾ�йش����ժҪ
    % Microsoft Sql Server
    methods
        % ���캯��
        function obj = MSS(user, pwd)
            obj = obj@BaseClass.Database.Database(user, pwd, 'master');
            obj.driver = 'com.microsoft.sqlserver.jdbc.SQLServerDriver';
            obj.url = obj.ConfirmUrl();
            obj.Connect(obj.db_default);            
        end
        
        % ������Ȩ��
        function ret = SaveOptionChain(obj, instru)
            ret = 1;
%             % ����option chain���˲������޸�
%             sql_string = ['SELECT * FROM ', db_nm, '.[dbo].[CodeList] ORDER BY wind_code'];
%             setdbprefs('DataReturnFormat', 'CellArray');
%             api = BaseClass.DatabaseApi(db_nm, user, pwd);
%             chain = table2cell(fetch(api.conn, sql_string));
%             chain(:, end) = [];
%             api.Off();
%             
%             % ���ֻ���������
%             switch lower(db_nm)
%                 case {'option_510050_sh', ...
%                         'option_510300_sh', ...
%                         'option_159919_sz', ...
%                         'option_io_cfe'}
%                     chain(:, 1) = chain(:, 15);
%                     chain(:, [9, 15]) = [];
%                 otherwise
%             end
%             col = [9, 10, 11, 12];
%             for i = 1 : length(col)
%                 chain(:, col(i)) = num2cell(str2double(cellstr(datestr(chain(:, col(i)), 'yyyymmdd'))));
%             end
%             
%             % struct��
%             fields = lower({ ...
%                 'wind_code', ...
%                 'sec_name', ...
%                 'option_mark_code', ...
%                 'option_type', ...
%                 'call_or_put', ...
%                 'exercise_mode', ...
%                 'exercise_price', ...
%                 'contract_unit_ini', ...
%                 'listed_date', ...
%                 'expire_date', ...
%                 'exercise_date', ...
%                 'settle_date', ...
%                 'settle_mode', ...
%                 'db', ...
%                 });
%             chain = cell2struct(chain, fields, 2);
%             
%             % д���ֶ� limit_month
%             temp = num2cell(floor([chain.expire_date] / 100));
%             [chain.limit_month] = temp{:};
%             
%             % ���ֻ���Ȩ�����ֶ�
%             loc_call = strcmpi({chain.call_or_put}, '�Ϲ�');
%             loc_put = strcmpi({chain.call_or_put}, '�Ϲ�');
%             [chain(loc_call).call_or_put] = deal(1);
%             [chain(loc_put).call_or_put] = deal(-1);
%             
%             % ɾ���������ֶ�(db) / �޸��ֶ�(wind_code, sec_name, option_mark_code)
%             chain = rmfield(chain, 'db');
%             [chain.code] = chain.wind_code;
%             chain = rmfield(chain, 'wind_code');
%             [chain.comment] = chain.sec_name;
%             chain = rmfield(chain, 'sec_name');
%             [chain.underlying] = chain.option_mark_code;
%             instru = rmfield(chain, 'option_mark_code');
        end
        
        % ��ȡ��Ȩ��
        function instru = LoadOptionChain(obj, opt)
            instru = 1;
%             % ����option chain���˲������޸�
%             sql_string = ['SELECT * FROM ', db_nm, '.[dbo].[CodeList] ORDER BY wind_code'];
%             setdbprefs('DataReturnFormat', 'CellArray');
%             api = BaseClass.DatabaseApi(db_nm, user, pwd);
%             chain = table2cell(fetch(api.conn, sql_string));
%             chain(:, end) = [];
%             api.Off();
%             
%             % ���ֻ���������
%             switch lower(db_nm)
%                 case {'option_510050_sh', ...
%                         'option_510300_sh', ...
%                         'option_159919_sz', ...
%                         'option_io_cfe'}
%                     chain(:, 1) = chain(:, 15);
%                     chain(:, [9, 15]) = [];
%                 otherwise
%             end
%             col = [9, 10, 11, 12];
%             for i = 1 : length(col)
%                 chain(:, col(i)) = num2cell(str2double(cellstr(datestr(chain(:, col(i)), 'yyyymmdd'))));
%             end
%             
%             % struct��
%             fields = lower({ ...
%                 'wind_code', ...
%                 'sec_name', ...
%                 'option_mark_code', ...
%                 'option_type', ...
%                 'call_or_put', ...
%                 'exercise_mode', ...
%                 'exercise_price', ...
%                 'contract_unit_ini', ...
%                 'listed_date', ...
%                 'expire_date', ...
%                 'exercise_date', ...
%                 'settle_date', ...
%                 'settle_mode', ...
%                 'db', ...
%                 });
%             chain = cell2struct(chain, fields, 2);
%             
%             % д���ֶ� limit_month
%             temp = num2cell(floor([chain.expire_date] / 100));
%             [chain.limit_month] = temp{:};
%             
%             % ���ֻ���Ȩ�����ֶ�
%             loc_call = strcmpi({chain.call_or_put}, '�Ϲ�');
%             loc_put = strcmpi({chain.call_or_put}, '�Ϲ�');
%             [chain(loc_call).call_or_put] = deal(1);
%             [chain(loc_put).call_or_put] = deal(-1);
%             
%             % ɾ���������ֶ�(db) / �޸��ֶ�(wind_code, sec_name, option_mark_code)
%             chain = rmfield(chain, 'db');
%             [chain.code] = chain.wind_code;
%             chain = rmfield(chain, 'wind_code');
%             [chain.comment] = chain.sec_name;
%             chain = rmfield(chain, 'sec_name');
%             [chain.underlying] = chain.option_mark_code;
%             instru = rmfield(chain, 'option_mark_code');
        end
        
    end
        
    
    methods (Hidden)
        % ������Ȩ��������
        function ret = SaveOptionMinMd(obj, opt)
            % ��ȡ���ݿ� / �˿� / ���� / ���
            db = GetDbName(obj, opt);
            conn = SelectConn(obj, db);
            tb = GetTableName(obj, opt);
            if (~CheckTable(obj, db, tb))
                ret = CreateTable(obj, conn, db, tb, opt);
            end
            
            % ����sql
            sql = string();
            for i = 1 : size(opt.md, 1)
                this = opt.md(i, :);
                head = sprintf("IF EXISTS (SELECT * FROM [%s] WHERE [DATETIME] = '%s') UPDATE [%s] SET [OPEN] = %f, [HIGH] = %f, [LOW] = %f, [LAST] = %f, [TURNOVER] = %f, [VOLUME] = %f, [OI] = %f, [STRIKE] = %f, [UNIT] = %f, [SPOT] = %f", ...
                    tb, datestr(this(1), 'yyyy-mm-dd HH:MM'), tb, this(2), this(3), this(4), this(5), this(6), this(7), this(8), this(9), this(10), this(11));
                tail = sprintf(" ELSE INSERT [%s]([DATETIME], [OPEN], [HIGH], [LOW], [LAST], [TURNOVER], [VOLUME], [OI], [STRIKE], [UNIT], [SPOT]) VALUES ('%s', %f, %f, %f, %f, %f, %f, %f, %f, %i, %f)", ...
                    tb, datestr(this(1), 'yyyy-mm-dd HH:MM'), this(2), this(3), this(4), this(5), this(6), this(7), this(8), this(9), this(10), this(11));
                sql = sql + head + tail;
            end
            
            % ���
            exec(conn, sql);
            ret = true;
        end
        
        % ��ȡ��Ȩ��������
        function LoadOptionMinMd(obj, opt)
            opt.md = nan;
        end
        
    end
    
    
    % �ڲ�����
    methods (Access = private, Hidden)
        % ȷ��url
        function ret = ConfirmUrl(obj)
            [~, result] = dos('ipconfig');
            [~, loc(1)] = regexp(result, 'IPv4 ��ַ . . . . . . . . . . . . : ');
            loc(2) = regexp(result, '��������  . . . . . . . . . . . . : ');
            ip = result(loc(1) + 1 : loc(2) - 1);
            ip(isspace(ip)) = [];
            ret = sprintf("jdbc:sqlserver://%s:1433;;databaseName=", ip);
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
        
        
        
        % 
        
        
        function ret = ExecUpdateSQL()
        end
        function ret = ExecDeleteSQL()
        end
        function ret = SaveOption()
        end
        function ret = LoadOption()
        end
        
        
        % ��ȡ���� / ��ȡ
        function ret = GetDbName(~, ast)
            % Ԥ����
            inv = EnumType.Interval.ToString(ast.interval);
            product = EnumType.Product.ToString(ast.product);
            variety = ast.variety;
            exchange = EnumType.Exchange.ToString(ast.exchange);
            
            % ��������
            switch ast.product
                case EnumType.Product.Etf
                    ret = sprintf("%s-%s", inv, product);
                    
                case EnumType.Product.Future
                    ret = sprintf("%s-%s-%s-%s", inv, product, variety, exchange);
                    
                case EnumType.Product.Index
                    ret = sprintf("%s-%s", inv, product);
                    
                case EnumType.Product.Option
                    ret = sprintf("%s-%s-%s-%s", inv, product, variety, exchange);
                    
                otherwise
                    error("Unexpected product for name database, please check !");
            end
            ret = upper(ret);
        end
        function ret = GetTableName(~, ast)
            % Ԥ����
            symbol = ast.symbol;
            exchange = EnumType.Exchange.ToString(ast.exchange);
            
            % ��������
            switch ast.product
                case EnumType.Product.Etf
                    ret = sprintf("%s_%s", symbol, exchange);
                    
                case EnumType.Product.Future
                    ret = symbol;
                    
                case EnumType.Product.Index
                    ret = sprintf("%s_%s", symbol, exchange);
                    
                case EnumType.Product.Option
                    ret = symbol;
                    
                otherwise
                    error("Unexpected product for name table, please check !");
            end
            ret = upper(ret);
        end
        
        % �������ݿ� / ��ȡ�˿� / ������ݿ� / �������ݿ�
        function Connect(obj, db_)
            %  connect
            conn = database(db_, obj.user, obj.password, obj.driver, obj.url + db_);
            if isopen(conn)
                fprintf("Database ""%s"" log on success.\r", db_);
            else
                fprintf("Database ""%s"" log on failure.\r", db_);
                error(conn.Message);
            end
            obj.conns(db_) = conn;
            
            % tables buffer
            sql = 'SELECT NAME FROM SYSOBJECTS WHERE XTYPE=''U'' ORDER BY NAME';
            obj.tables(db_) = table2cell(fetch(conn, sql));
        end
        function conn = SelectConn(obj, db_)
            if (~CheckDatabase(obj, db_))
                CreateDatabase(obj, SelectConn(obj, obj.db_default), db_);
            end
            conn = obj.conns.at(db_);
        end
        function ret = CheckDatabase(obj, db_)
            if (obj.conns.isKey(db_))
                ret = true;
            else
                ret = false;
            end
        end
        function ret = CreateDatabase(obj, conn, db_)
            sql = sprintf("CREATE DATABASE ""%s""", db_);
            res = exec(conn, sql);
            if (~isempty(res.Cursor))
                Connect(obj, db_);
                ret = true;
            else
                ret = false;
                error("Create database %s error, msg: %, please check!", db_, res.Message);
            end
        end
        
        % ���� / ������        
        function ret = CheckTable(obj, db_, tb_)
            if (obj.tables.isKey(db_) && ismember(tb_,  obj.tables.at(db_)))
                ret = true;
            else
                ret = false;
            end
        end
        ret = CreateTable(obj, conn, db_, tb_, ast);
        

    end
end

