% 数据端口API
classdef DatabaseApi < handle    
    properties (Access = private)
        user;
        password;
        driver; 
        url;
        conns;
        tables;
        db_default;
    end
        
    methods
        % 端口初始化
        function obj = DatabaseApi(user, pwd)
            obj.user = user;
            obj.password = pwd;
            obj.driver = 'com.microsoft.sqlserver.jdbc.SQLServerDriver';
            obj.url = obj.ConfirmUrl();
            obj.conns = containers.Map();
            obj.tables = containers.Map();
            obj.db_default = 'master';
            obj.Connect(obj.db_default);
        end
    end
    
    % 接口
    methods (Static, Access = public)
        % 获取期权链
        function instru = FetchOptionChain(db_nm, user, pwd)
            % 下载option chain，此部分无修改
            sql_string = ['SELECT * FROM ', db_nm, '.[dbo].[CodeList] ORDER BY wind_code'];
            setdbprefs('DataReturnFormat', 'CellArray');
            api = BaseClass.DatabaseApi(db_nm, user, pwd);
            chain = table2cell(fetch(api.conn, sql_string));
            chain(:, end) = [];
            api.Off();
            
            % 数字化所有日期
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
            
            % struct化
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
            
            % 写入字段 limit_month
            temp = num2cell(floor([chain.expire_date] / 100));
            [chain.limit_month] = temp{:};
            
            % 数字化期权类型字段
            loc_call = strcmpi({chain.call_or_put}, '认购');
            loc_put = strcmpi({chain.call_or_put}, '认沽');
            [chain(loc_call).call_or_put] = deal(1);
            [chain(loc_put).call_or_put] = deal(-1);
            
            % 删除无意义字段(db) / 修改字段(wind_code, sec_name, option_mark_code)
            chain = rmfield(chain, 'db');
            [chain.code] = chain.wind_code;
            chain = rmfield(chain, 'wind_code');
            [chain.comment] = chain.sec_name;
            chain = rmfield(chain, 'sec_name');
            [chain.underlying] = chain.option_mark_code;
            instru = rmfield(chain, 'option_mark_code');
        end
    end
    methods (Access = public)
        % 保存期权分钟行情
        function ret = SaveOptionMin(obj)
            %             	// 鑾峰緱conn / 妫?鏌ヨ〃
            % 	string db    = DatabaseName(_req);
            % 	Switch& conn = SelectConn(db);
            % 	string table = TableName(_req);
            % 	if (!CheckTable(db, table))
            % 		CreateTable(conn, db, table, buffer);
            % 
            % 
            % 	// 鎻掑叆
            % 	for (auto curr = buffer.begin(); curr != buffer.end();)
            % 	{
            % 		auto start = curr;
            % 		auto end = distance(buffer.end(), curr) < 4096 ? buffer.end() : curr + 4096;
            % 		if (!ExecUpdateSQL(conn, table, OptionDailyMd(start, end)))
            % 			return false;
            % 		else
            % 			curr = end;
            % 	}
            % 	return true;
        end
        
        % 读取期权分钟行情
        function md = LoadOptionMin(obj)
        end
    end
    
    
    % 内部方法
    methods (Access = private, Hidden, Static)
        % 确定url
        function ret = ConfirmUrl()
            [~, result] = dos('ipconfig');
            [~, loc(1)] = regexp(result, 'IPv4 地址 . . . . . . . . . . . . : ');
            loc(2) = regexp(result, '子网掩码  . . . . . . . . . . . . : ');
            ip = result(loc(1) + 1 : loc(2) - 1);
            ip(isspace(ip)) = [];
            ret = ['jdbc:sqlserver://', ip, ':1433;;databaseName='];
        end
    end
    methods (Access = private)        
        
        
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
        
        
        
        % 连接数据库
        function Connect(obj, db_name)
            %  connect
            conn = database(db_name, obj.user, obj.password, obj.driver, [obj.url, db_name]);
            if isopen(conn)
                disp(['Database ', db_name, ' log on success. ']);
            else
                disp(['Database ', db_name, ' log on failure. ']);
                error(con.Message);
            end
            obj.conns(db_name) = conn;
            
            % tables buffer
            sql = 'SELECT NAME FROM SYSOBJECTS WHERE XTYPE=''U'' ORDER BY NAME';
            obj.tables(db_name) = table2cell(fetch(conn, sql));
        end
        
        % 检查数据库是否
        function ret = CheckDatabase()
        end
        function ret = CreateDatabase()
        end
        function ret = CheckTable()
        end
        function ret = CreateTable()
        end
        function ret = ExecUpdateSQL()
        end
        function ret = ExecDeleteSQL()
        end
        function ret = SaveOption()
        end
        function ret = LoadOption()
        end
        
        function ret = DbName()
        end
        function ret = TableName()
        end
    end
end