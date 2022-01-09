% 根据给定资产建表
function ret = CreateTable(~, conn, db_, tb_, ast)

% 分情况建表
switch ast.product
    case EnumType.Product.Etf
        error("Unexpected ""product"" for create table, please check.");
        
        
    case EnumType.Product.Future
        error("Unexpected ""product"" for create table, please check.");
        
        
    case EnumType.Product.Index
        error("Unexpected ""product"" for create table, please check.");
        
        
    case EnumType.Product.Option
        switch ast.interval
            case {EnumType.Interval.min1, EnumType.Interval.min5}
                ret = CreateTableBar(conn, db_, tb_);
                
            otherwise
                error("Unexpected ""interval"" for create table, please check.");
        end
        
        
    case EnumType.Product.Stock
        error("Unexpected ""product"" for create table, please check.");
        
        
    otherwise
        error("Unexpected ""product"" for create table, please check.");
end

end

% 表索引
function ret = TableIndex(db_, tb_)
ret = sprintf("id_%s_%s", db_, tb_);
end

% 结果输出
function ResultDisp(ret, db_, tb_, msg)
if (ret)
    fprintf("Table ""%s""/""%s"" created success.\r", db_, tb_);
else
    error("Table ""%s""/""%s"" created failure. Msg: %s\r", db_, tb_, msg);
end
end

% 建表K线数据
function ret = CreateTableBar(conn, db_, tb_)
sql = sprintf("CREATE TABLE [%s](" ...
    + "[DATETIME] [datetime] NOT NULL PRIMARY KEY, " ...
    + "[OPEN] [numeric](18, 4) NULL, " ...
    + "[HIGH] [numeric](18, 4) NULL, " ...
    + "[LOW] [numeric](18, 4) NULL, " ...
    + "[LAST] [numeric](18, 4) NULL, " ...
    + "[TURNOVER] [numeric](18, 4) NULL, " ...
    + "[VOLUME] [numeric](18, 4) NULL, " ...
    + "[OI] [numeric](18, 4) NULL " ...
    + ")ON [PRIMARY];" ...
    + "CREATE INDEX [%s] ON [%s] ([DATETIME] ASC);" ...
    , tb_, TableIndex(db_, tb_), tb_);
res = exec(conn, sql);

if (~isempty(res.Cursor))
    ret = true;
else
    ret = false;
end
ResultDisp(ret, db_, tb_, res.Message);
end







%% bool PostgreSql::CreateTable(Switch& _conn, const string& _db, const string& _tb, const EtfDailyMd& _bars)
% {
% 	char sql[512];
% 	sprintf_s(sql, sizeof(sql),
% 		"CREATE TABLE \"%s\" ("
% 		"datetime_action TIMESTAMP(3) WITHOUT TIME ZONE NOT NULL,"
% 		"nav float8, "
% 		"nav_adj float8, "
% 		"open float8, "
% 		"high float8, "
% 		"low float8, "
% 		"last float8, "
% 		"volume float8, "
% 		"oi float8, "
% 		"turnover float8, "
% 		"PRIMARY KEY(datetime_action));"
% 		"CREATE INDEX %s ON \"%s\" (datetime_action ASC);",
% 		_tb.c_str(),
% 		TableIndex(_tb).c_str(),
% 		_tb.c_str()
% 	);
% 
% 	if (!ExecCreateSQL(_conn, "[" + _tb + "]@[" + _db + "] create error.", sql))
% 		return false;
% 	else
% 	{
% 		WriteLog("Created [" + _tb + "]@[" + _db + "].");
% 		Lock lck(*_mtx_table);
% 		(*_tables)[_db].insert(_tb);
% 
% 	}
% 	CreateTriggerOverview(_conn, _db, _tb);
% 	return true;
% }
%% bool PostgreSql::CreateTable(Switch& _conn, const string& _db, const string& _tb, const FutureDailyMd& _bars)
% {
% 	char sql[512];
% 	sprintf_s(sql, sizeof(sql),
% 		"CREATE TABLE \"%s\" ("
% 		"datetime_action TIMESTAMP(3) WITHOUT TIME ZONE NOT NULL,"
% 		"open float8, "
% 		"high float8, "
% 		"low float8, "
% 		"last float8, "
% 		"volume float8, "
% 		"oi float8, "
% 		"turnover float8, "
% 		"settle float8, "
% 		"presettle float8, "
% 		"st_stock int, "
% 		"rem_nday smallint, "
% 		"PRIMARY KEY(datetime_action));"
% 		"CREATE INDEX %s ON \"%s\" (datetime_action ASC);",
% 		_tb.c_str(),
% 		TableIndex(_tb).c_str(),
% 		_tb.c_str()
% 	);
% 
% 	if (!ExecCreateSQL(_conn, "[" + _tb + "]@[" + _db + "] create error.", sql))
% 		return false;
% 	else
% 	{
% 		WriteLog("Created [" + _tb + "]@[" + _db + "].");
% 		Lock lck(*_mtx_table);
% 		(*_tables)[_db].insert(_tb);
% 
% 	}
% 	CreateTriggerOverview(_conn, _db, _tb);
% 	return true;
% }
%% bool PostgreSql::CreateTable(Switch& _conn, const string& _db, const string& _tb, const OptionDailyMd& _bars)
% {
% 	char sql[512];
% 	sprintf_s(sql, sizeof(sql),
% 		"CREATE TABLE \"%s\" ("
% 		"datetime_action TIMESTAMP(3) WITHOUT TIME ZONE NOT NULL,"
% 		"open float8, "
% 		"high float8, "
% 		"low float8, "
% 		"last float8, "
% 		"volume float8, "
% 		"oi float8, "
% 		"turnover float8, "
% 		"settle float8, "
% 		"presettle float8, "
% 		"rem_nday smallint, "
% 		"rem_tday smallint, "
% 		"PRIMARY KEY(datetime_action));"
% 		"CREATE INDEX %s ON \"%s\" (datetime_action ASC);",
% 		_tb.c_str(),
% 		TableIndex(_tb).c_str(),
% 		_tb.c_str()
% 	);
% 
% 	if (!ExecCreateSQL(_conn, "[" + _tb + "]@[" + _db + "] create error.", sql))
% 		return false;
% 	else
% 	{
% 		WriteLog("Created [" + _tb + "]@[" + _db + "].");
% 		Lock lck(*_mtx_table);
% 		(*_tables)[_db].insert(_tb);
% 
% 	}
% 	CreateTriggerOverview(_conn, _db, _tb);
% 	return true;
% }
%% bool PostgreSql::CreateTable(Switch& _conn, const string& _db, const string& _tb, const Ticks& _ticks)
% {
% 	char sql[2048];
% 	sprintf_s(sql, sizeof(sql),
% 		"CREATE TABLE \"%s\" ("
% 		"datetime_action TIMESTAMP(3) WITHOUT TIME ZONE NOT NULL,"
% 		"open float8, "
% 		"high float8, "
% 		"low float8, "
% 		"last float8, "
% 		"volume float8, "
% 		"oi float8, "
% 		"turnover float8, "
% 		"b1p float8, b2p float8, b3p float8, b4p float8, b5p float8, "
% 		"b1v float8, b2v float8, b3v float8, b4v float8, b5v float8, "
% 		"a1p float8, a2p float8, a3p float8, a4p float8, a5p float8, "
% 		"a1v float8, a2v float8, a3v float8, a4v float8, a5v float8, "
% 		"high_lmt float8, "
% 		"low_lmt float8, "
% 		"ave_price float8, "
% 		"preclose float8, "
% 		"presettle float8, "
% 		"preoi float8, "
% 		"PRIMARY KEY(datetime_action)); "
% 		"CREATE INDEX %s ON \"%s\" (datetime_action ASC);",
% 		_tb.c_str(),
% 		TableIndex(_tb).c_str(),
% 		_tb.c_str()
% 		);
% 	if (!ExecCreateSQL(_conn, "[" + _tb + "]@[" + _db + "] create error.", sql))
% 		return false;
% 	else
% 	{
% 		WriteLog("Created [" + _tb + "]@[" + _db + "].");
% 		Lock lck(*_mtx_table);
% 		(*_tables)[_db].insert(_tb);
% 
% 	}
% 	CreateTriggerOverview(_conn, _db, _tb);
% 	return true;
% 
% 
% 	// sprintf_s(sql, sizeof(sql), "SELECT create_hypertable('%s', 'datetime_action', 1, create_default_indexes=>FALSE);", _name.c_str());
% 	//if (!ExecCreateSQL("table_bar", "Create tick hypertable error.", sql))
% 	//	return;
% }
%% bool PostgreSql::CreateTable(Switch& _conn, const string& _db, const string& _tb, const Calendar& _calendar)
% {
% 	char sql[2048];
% 	sprintf_s(sql, sizeof(sql),
% 		"CREATE TABLE \"%s\" ("
% 		"datetime TIMESTAMP(3) WITHOUT TIME ZONE NOT NULL,"
% 		"isTrading bool, "
% 		"isWorking bool, "
% 		"Weekday int, "
% 		"datenum int, "
% 		"PRIMARY KEY(datetime)); "
% 		"CREATE INDEX %s ON \"%s\" (datetime ASC);",
% 		_tb.c_str(),
% 		TableIndex(_tb).c_str(),
% 		_tb.c_str()
% 	);
% 	if (!ExecCreateSQL(_conn, "[" + _tb + "]@[" + _db + "] create error.", sql))
% 		return false;
% 	else
% 	{
% 		WriteLog("Created [" + _tb + "]@[" + _db + "].");
% 		Lock lck(*_mtx_table);
% 		(*_tables)[_db].insert(_tb);
% 
% 	}
% 	return true;
% }
%% bool PostgreSql::CreateTable(Switch& _conn, const string& _db, const string& _tb, const Contracts& _infos)
% {
% 	Product product = _infos.at(0)->product;
% 	switch (product)
% 	{
% 	case Product::Future:
% 	{
% 		"symbol = excluded.symbol, "
% 			"exchange = excluded.exchange, "
% 			"start_trade_date = excluded.start_trade_date, "
% 			"end_trade_date = excluded.end_trade_date, "
% 			"dlmonth = excluded.dlmonth, "
% 			"margin_ratio = excluded.margin_ratio, "
% 			"size = excluded.size, "
% 			"price_tick = excluded.price_tick;";
% 		char sql[2048];
% 		sprintf_s(sql, sizeof(sql),
% 			"CREATE TABLE \"%s\" ("
% 			"symbol text NOT NULL,"
% 			"exchange text, "
% 			"start_trade_date TIMESTAMP(3) WITHOUT TIME ZONE,"
% 			"end_trade_date TIMESTAMP(3) WITHOUT TIME ZONE,"
% 			"dlmonth int, "
% 			"margin_ratio float8, "
% 			"size float8, "
% 			"price_tick float8, "
% 			"PRIMARY KEY(symbol)); "
% 			"CREATE INDEX %s ON \"%s\" (symbol ASC);",
% 			_tb.c_str(),
% 			TableIndex(_tb).c_str(),
% 			_tb.c_str()
% 		);
% 		if (!ExecCreateSQL(_conn, "[" + _tb + "]@[" + _db + "] create error.", sql))
% 			return false;
% 		else
% 		{
% 			WriteLog("Created [" + _tb + "]@[" + _db + "].");
% 			Lock lck(*_mtx_table);
% 			(*_tables)[_db].insert(_tb);
% 
% 		}
% 		return true;
% 	}
% 
% 	case Product::Option:
% 	{	
% 		char sql[2048];
% 		sprintf_s(sql, sizeof(sql),
% 			"CREATE TABLE \"%s\" ("
% 			"symbol text NOT NULL,"
% 			"exchange text, "
% 			"vareity text, "
% 			"ud_symbol text, "
% 			"ud_product text, "
% 			"ud_exchange text, "
% 			"call_or_put text, "
% 			"strike_type text, "
% 			"strike float8, "
% 			"size float8, "
% 			"price_tick float8, "
% 			"dlmonth int, "
% 			"start_trade_date TIMESTAMP(3) WITHOUT TIME ZONE,"
% 			"end_trade_date TIMESTAMP(3) WITHOUT TIME ZONE,"
% 			"settle_mode text, "
% 			"PRIMARY KEY(symbol)); "
% 			"CREATE INDEX %s ON \"%s\" (symbol ASC);",
% 			_tb.c_str(),
% 			TableIndex(_tb).c_str(),
% 			_tb.c_str()
% 		);
% 		if (!ExecCreateSQL(_conn, "[" + _tb + "]@[" + _db + "] create error.", sql))
% 			return false;
% 		else
% 		{
% 			WriteLog("Created [" + _tb + "]@[" + _db + "].");
% 			Lock lck(*_mtx_table);
% 			(*_tables)[_db].insert(_tb);
% 
% 		}
% 		return true;
% 	}
% 
% 	default:
% 		WriteError("Unsupported contract type: " + ::utility::constant::Enum2String(product) + ", please check !", "", "");
% 		return false;
% 	}
% 
% 
% }