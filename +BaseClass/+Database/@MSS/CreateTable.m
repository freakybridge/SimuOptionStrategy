% Microsoft Sql Server / CreateTable
% v1.2.0.20220105.beta
%       首次添加
function ret = CreateTable(obj, conn, db, tb,  varargin)

% 多态处理
if (nargin() == 5)
    if (isa(varargin{1}, 'table') && db == obj.db_instru)
        % 建立合约表
        ret = CreateTableInstru(conn, db, tb);
        
        
    elseif (ismember('BaseClass.Asset.Asset', superclasses(varargin{1})))
        % 按照资产建立行情表
        asset = varargin{1};
        switch asset.interval
            case {EnumType.Interval.min1, EnumType.Interval.min5}
                ret = CreateTableBarMin(conn, db, tb);

            case EnumType.Interval.day
                switch asset.product
                    case EnumType.Product.Etf

                    case EnumType.Product.Future

                    case EnumType.Product.Index

                    case EnumType.Product.Option

                    otherwise
                        error("Unexpected ""product"" for create table, please check.");
                end


            otherwise
                error("Unexpected ""interval"" for create table, please check.");
        end
        
    else
        error("Unexpected argument input, please check !");
    end
    
else
    error("Unexpected argument input number, please check !");
end

% 写入缓存
if (ret)
    obj.tables(db) = [obj.tables(db); {tb}];
end
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