% Microsoft Sql Server��
% v1.2.0.20220105.beta
%       �״����
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
        function ret = SaveOptionChain(obj, var, exc, instrus)
            % ���ݿ�׼��
            if (isempty(instrus))
                ret = false;
                return;
            end
            db = obj.db_instru;
            conn = obj.SelectConn(db);
            
            % ��׼��
            tb = BaseClass.Database.Database.GetTableName(EnumType.Product.Option, var, EnumType.Exchange.ToEnum(exc));
            if (~obj.CheckTable(db, tb))
                obj.CreateTable(conn, db, tb, instrus);
            end           
            
            % ����sql
            fprintf("Inserting option chain ""%s"", please wait ...\r", tb);
            sql = string();
            for i = 1 : size(instrus, 1)
                this = instrus(i, :);                    
                head = sprintf("IF EXISTS (SELECT * FROM [%s] WHERE [SYMBOL] = '%s') UPDATE [%s] SET [SEC_NAME] = '%s', [EXCHANGE] = '%s', [VARIETY] = '%s', [UD_SYMBOL] = '%s', [UD_PRODUCT] = '%s', [UD_EXCHANGE] = '%s', [CALL_OR_PUT] = '%s', [STRIKE_TYPE] = '%s', [STRIKE] = %f, [SIZE] = %f, [TICK_SIZE] = %f, [DLMONTH] = %i, [START_TRADE_DATE] = '%s', [END_TRADE_DATE] = '%s', [SETTLE_MODE] = '%s', [LAST_UPDATE_DATE] = '%s' WHERE [SYMBOL] = '%s'", ...
                    tb, ...
                    this.SYMBOL{:}, ...
                    tb, ...
                    this.SEC_NAME{:}, ...
                    this.EXCHANGE{:}, ...
                    this.VARIETY{:}, ...
                    this.UD_SYMBOL{:}, ...
                    this.UD_PRODUCT{:}, ...
                    this.UD_EXCHANGE{:}, ...
                    this.CALL_OR_PUT{:}, ...
                    this.STRIKE_TYPE{:}, ...
                    this.STRIKE, ...
                    this.SIZE, ...
                    this.TICK_SIZE, ...
                    this.DLMONTH, ...
                    this.START_TRADE_DATE{:}, ...
                    this.END_TRADE_DATE{:}, ...
                    this.SETTLE_MODE{:}, ...
                    this.LAST_UPDATE_DATE{:}, ...
                    this.SYMBOL{:} ...
                    );
                
                tail = sprintf(" ELSE INSERT [%s]([SYMBOL], [SEC_NAME], [EXCHANGE], [VARIETY], [UD_SYMBOL], [UD_PRODUCT], [UD_EXCHANGE], [CALL_OR_PUT], [STRIKE_TYPE], [STRIKE], [SIZE], [TICK_SIZE], [DLMONTH], [START_TRADE_DATE], [END_TRADE_DATE], [SETTLE_MODE], [LAST_UPDATE_DATE]) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', %f, %f, %f, %i, '%s', '%s', '%s', '%s')", ...
                    tb, ...
                    this.SYMBOL{:}, ...
                    this.SEC_NAME{:}, ...
                    this.EXCHANGE{:}, ...
                    this.VARIETY{:}, ...
                    this.UD_SYMBOL{:}, ...
                    this.UD_PRODUCT{:}, ...
                    this.UD_EXCHANGE{:}, ...
                    this.CALL_OR_PUT{:}, ...
                    this.STRIKE_TYPE{:}, ...
                    this.STRIKE, ...
                    this.SIZE, ...
                    this.TICK_SIZE, ...
                    this.DLMONTH, ...
                    this.START_TRADE_DATE{:}, ...
                    this.END_TRADE_DATE{:}, ...
                    this.SETTLE_MODE{:}, ...
                    this.LAST_UPDATE_DATE{:} ...
                    );
                
                sql = sql + head + tail;
            end

            % ���
            exec(conn, sql);
            ret = true;
        end
        
        % ��ȡ��Ȩ��
        function instru = LoadOptionChain(obj, var, exc)
            try           
                % ���ݿ� / ��׼��
                db = obj.db_instru;
                tb = BaseClass.Database.Database.GetTableName(EnumType.Product.Option, var, EnumType.Exchange.ToEnum(exc));
                
                % ��ȡ
                sql = sprintf("SELECT [SYMBOL], [SEC_NAME], [EXCHANGE], [VARIETY], [UD_SYMBOL], [UD_PRODUCT], [UD_EXCHANGE], [CALL_OR_PUT], [STRIKE_TYPE], [STRIKE], [SIZE], [TICK_SIZE], [DLMONTH], [START_TRADE_DATE], [END_TRADE_DATE], [SETTLE_MODE], [LAST_UPDATE_DATE] FROM [%s].[dbo].[%s]  ORDER BY [SYMBOL]", ...
                    db, tb);
                conn = obj.SelectConn(db);
                value = fetch(conn, sql);
                
            catch
                warning("Fetching option chain ""%s"" failure, please check ...\r", tb);                
                value = [];
            end
            instru = value;
                
        end
        
    end
        
    
    methods (Hidden)
        % �����������
        function ret = SaveBar(obj, ast)
            % ��ȡ���ݿ� / �˿� / ���� / ���
            db = BaseClass.Database.Database.GetDbName(ast);
            conn = SelectConn(obj, db);
            tb = BaseClass.Database.Database.GetTableName(ast);
            if (~CheckTable(obj, db, tb))
                ret = CreateTable(obj, conn, db, tb, ast);
            end
            
            % ����sql
            sql = string();
            for i = 1 : size(ast.md, 1)
                this = ast.md(i, :);
                head = sprintf("IF EXISTS (SELECT * FROM [%s] WHERE [DATETIME] = '%s') UPDATE [%s] SET [OPEN] = %f, [HIGH] = %f, [LOW] = %f, [LAST] = %f, [TURNOVER] = %f, [VOLUME] = %f, [OI] = %f WHERE [DATETIME] = '%s'", ...
                    tb, datestr(this(1), 'yyyy-mm-dd HH:MM'), tb, this(4), this(5), this(6), this(7), this(8), this(9), this(10), datestr(this(1), 'yyyy-mm-dd HH:MM'));
                tail = sprintf(" ELSE INSERT [%s]([DATETIME], [OPEN], [HIGH], [LOW], [LAST], [TURNOVER], [VOLUME], [OI]) VALUES ('%s', %f, %f, %f, %f, %f, %f, %f)", ...
                    tb, datestr(this(1), 'yyyy-mm-dd HH:MM'), this(4), this(5), this(6), this(7), this(8), this(9), this(10));
                sql = sql + head + tail;
            end
            
            % ���
            exec(conn, sql);
            ret = true;
        end
        
        % ��ȡ��Ȩ��������
        function LoadBar(obj, ast)
            % Ԥ����
            db = BaseClass.Database.Database.GetDbName(ast);
            tb = BaseClass.Database.Database.GetTableName(ast);
            conn = SelectConn(obj, db);
            
            % ��ȡ
            try
                sql = sprintf("SELECT [DATETIME], [OPEN], [HIGH], [LOW], [LAST], [TURNOVER], [VOLUME], [OI] FROM [%s].[dbo].[%s] ORDER BY [DATETIME]", db, tb);
                setdbprefs('DataReturnFormat', 'numeric');
                md = fetch(conn, sql);
                md = [datenum(md.DATETIME), table2array(md(:, 2 : end))];
                ast.MergeMarketData(md);
            catch
                ast.md = [];
            end
        end        
    end
    
    
    % �ڲ�����
    methods (Access = private, Hidden)
        % ȷ��url
        function ret = ConfirmUrl(~)
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
        function ret = CheckTable(obj, db, tb)
            if (obj.tables.isKey(db))
                tmp = obj.tables.at(db);
                for i = 1 : length(tmp)
                    if (tmp{i} == tb)
                        ret = true;
                        return;
                    end
                end
                ret = false;
            else
                ret = false;
            end
        end
        ret = CreateTable(obj, conn, db, tb,  varargin);
        

    end
end

