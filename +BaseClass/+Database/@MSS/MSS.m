% Microsoft Sql Server类
% v1.2.0.20220105.beta
%       首次添加
classdef MSS < BaseClass.Database.Database
    % MSS 此处显示有关此类的摘要
    % Microsoft Sql Server
    methods
        % 构造函数
        function obj = MSS(user, pwd)
            obj = obj@BaseClass.Database.Database(user, pwd, 'master');
            obj.driver = 'com.microsoft.sqlserver.jdbc.SQLServerDriver';
            obj.url = obj.ConfirmUrl();
            obj.Connect(obj.db_default);   
        end
        
        % 保存期权链
        function ret = SaveOptionChain(obj, var, exc, instrus)
            % 数据库准备
            if (isempty(instrus))
                ret = false;
                return;
            end
            db = obj.db_instru;
            conn = obj.SelectConn(db);
            
            % 表准备
            tb = BaseClass.Database.Database.GetTableName(EnumType.Product.Option, var, EnumType.Exchange.ToEnum(exc));
            if (~obj.CheckTable(db, tb))
                obj.CreateTable(conn, db, tb, instrus);
            end
            
            % 生成sql
            sql = string();
            for i = 1 : size(instrus, 1)
                this = instrus(i, :);
                head = sprintf("IF EXISTS (SELECT * FROM [%s] WHERE [SYMBOL] = '%s') UPDATE [%s] SET [SEC_NAME] = '%s', [EXCHANGE] = '%s', [VARIETY] = '%s', [UD_SYMBOL] = '%s', [UD_PRODUCT] = '%s', [UD_EXCHANGE] = '%s', [CALL_OR_PUT] = '%s', [STRIKE_TYPE] = '%s', [STRIKE] = %f, [SIZE] = %f, [TICK_SIZE] = %f, [DLMONTH] = %i, [START_TRADE_DATE] = '%s', [END_TRADE_DATE] = '%s', [SETTLE_MODE] = '%s', [LAST_UPDATE_DATE] = '%s' ", ...
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
                    datestr(this.START_TRADE_DATE{:}, 'yyyy-mm-dd HH:MM'), ...
                    datestr(this.END_TRADE_DATE{:}, 'yyyy-mm-dd HH:MM'), ...
                    this.SETTLE_MODE{:}, ...
                    datestr(this.LAST_UPDATE_DATE{:}, 'yyyy-mm-dd HH:MM'));
                
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
                    datestr(this.START_TRADE_DATE{:}, 'yyyy-mm-dd HH:MM'), ...
                    datestr(this.END_TRADE_DATE{:}, 'yyyy-mm-dd HH:MM'), ...
                    this.SETTLE_MODE{:}, ...
                    datestr(this.LAST_UPDATE_DATE{:}, 'yyyy-mm-dd HH:MM'));
                
                sql = sql + head + tail;
            end

            % 入库
            fprintf("Inserting option chain ""%s"", please wait ...\r", tb);
            exec(conn, sql);
            ret = true;
        end
        
        % 获取期权链
        function instru = LoadOptionChain(obj, opt)
            instru = 1;
%             % 下载option chain，此部分无修改
%             sql_string = ['SELECT * FROM ', db_nm, '.[dbo].[CodeList] ORDER BY wind_code'];
%             setdbprefs('DataReturnFormat', 'CellArray');
%             api = BaseClass.DatabaseApi(db_nm, user, pwd);
%             chain = table2cell(fetch(api.conn, sql_string));
%             chain(:, end) = [];
%             api.Off();
%             
%             % 数字化所有日期
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
%             % struct化
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
%             % 写入字段 limit_month
%             temp = num2cell(floor([chain.expire_date] / 100));
%             [chain.limit_month] = temp{:};
%             
%             % 数字化期权类型字段
%             loc_call = strcmpi({chain.call_or_put}, '认购');
%             loc_put = strcmpi({chain.call_or_put}, '认沽');
%             [chain(loc_call).call_or_put] = deal(1);
%             [chain(loc_put).call_or_put] = deal(-1);
%             
%             % 删除无意义字段(db) / 修改字段(wind_code, sec_name, option_mark_code)
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
        % 保存分钟行情
        function ret = SaveBar(obj, ast)
            % 获取数据库 / 端口 / 表名 / 检查
            db = BaseClass.Database.Database.GetDbName(ast);
            conn = SelectConn(obj, db);
            tb = BaseClass.Database.Database.GetTableName(ast);
            if (~CheckTable(obj, db, tb))
                ret = CreateTable(obj, conn, db, tb, ast);
            end
            
            % 生成sql
            sql = string();
            for i = 1 : size(ast.md, 1)
                this = ast.md(i, :);
                head = sprintf("IF EXISTS (SELECT * FROM [%s] WHERE [DATETIME] = '%s') UPDATE [%s] SET [OPEN] = %f, [HIGH] = %f, [LOW] = %f, [LAST] = %f, [TURNOVER] = %f, [VOLUME] = %f, [OI] = %f", ...
                    tb, datestr(this(1), 'yyyy-mm-dd HH:MM'), tb, this(4), this(5), this(6), this(7), this(8), this(9), this(10));
                tail = sprintf(" ELSE INSERT [%s]([DATETIME], [OPEN], [HIGH], [LOW], [LAST], [TURNOVER], [VOLUME], [OI]) VALUES ('%s', %f, %f, %f, %f, %f, %f, %f)", ...
                    tb, datestr(this(1), 'yyyy-mm-dd HH:MM'), this(4), this(5), this(6), this(7), this(8), this(9), this(10));
                sql = sql + head + tail;
            end
            
            % 入库
            exec(conn, sql);
            ret = true;
        end
        
        % 读取期权分钟行情
        function LoadBar(obj, ast)
            % 预处理
            db = BaseClass.Database.Database.GetDbName(ast);
            tb = BaseClass.Database.Database.GetTableName(ast);
            conn = SelectConn(obj, db);
            
            % 读取
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
    
    
    % 内部方法
    methods (Access = private, Hidden)
        % 确定url
        function ret = ConfirmUrl(~)
            [~, result] = dos('ipconfig');
            [~, loc(1)] = regexp(result, 'IPv4 地址 . . . . . . . . . . . . : ');
            loc(2) = regexp(result, '子网掩码  . . . . . . . . . . . . : ');
            ip = result(loc(1) + 1 : loc(2) - 1);
            ip(isspace(ip)) = [];
            ret = sprintf("jdbc:sqlserver://%s:1433;;databaseName=", ip);
        end
        
        % 关闭
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
               

        
        % 连接数据库 / 获取端口 / 检查数据库 / 创建数据库
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
        
        % 检查表 / 创建表        
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

