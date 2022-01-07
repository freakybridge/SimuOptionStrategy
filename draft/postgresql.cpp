�?#include "pch.h"
#include "framework.h"
#include "../include/postgresql.h"

using namespace database::postgresql;
using ::utility::constant::OptionDeliverType;
using ::utility::constant::OptionStrikeType;
using ::utility::constant::OptionType;
using Lock = std::unique_lock<recursive_mutex>;




map<string, Interval> trans_pg_string_interval           = {
	{"1MIN", Interval::Minute},	
	{"1H",   Interval::Hour},
	{"1D",   Interval::Daily},
	{"1W",   Interval::Weekly},
	{"TICK", Interval::Tick}
};
map<string, Exchange> trans_pg_string_exchange           = {
	{"CFFEX", Exchange::CFFEX},
	{"CZCE",  Exchange::CZCE},
	{"DCE",   Exchange::DCE},
	{"INE",   Exchange::INE},
	{"SHFE",  Exchange::SHFE},
	{"SSE",   Exchange::SSE},
	{"SZSE",  Exchange::SZSE},
};
map<string, Product>  trans_pg_string_product            = {
	{"ETF",		  Product::Etf},
	{"FUND",	  Product::Fund},
	{"FUTURE",	  Product::Future},
	{"INDEX",	  Product::Index},
	{"INTEREST",  Product::Interest},
	{"STOCK",	  Product::Stock},
	{"OPTION",	  Product::Option},
};
map<string, OptionType> trans_pg_string_optiontype       = {
	{"Call",	OptionType::Call},
	{"Put",		OptionType::Put},
};
map<string, OptionStrikeType> trans_pg_string_striketype = {
	{"American",	OptionStrikeType::American},
	{"Asian",		OptionStrikeType::Asian},
	{"European",	OptionStrikeType::European},
}; 
map<string, OptionDeliverType> trans_pg_string_delitype  = {
	{"Cash",		OptionDeliverType::Cash},
	{"Physical",	OptionDeliverType::Physical},
};



PostgreSql::PostgreSql(BaseTrader* _td, BaseConfig* _cfg_in)
	: BaseDatabase(_td, "PostgreSql")
	, _user        (new string)
	, _password    (new string)
	, _url         (new string)
	, _port        (new string)
	, _db_default  (new string("postgres"))
	, _db_instru   (new string("INSTRUMENTS"))
	, _config_file (new string("database_postgresql_config.json"))
	, _conns       (new map<string, Switch>)
	, _tables      (new map<string, set<string>>)
	, _tb_oview    (new string("BarOverviews"))
	, _mtx_conn	   (new recursive_mutex)
	, _mtx_table   (new recursive_mutex)
	, _mtx_file    (new recursive_mutex)
{
	if (_cfg_in)
	{
		ConfigPg* tmp = (ConfigPg*)(_cfg_in);
		*_user        = tmp->GetUser();
		*_password    = tmp->GetPassword();
		*_url         = tmp->GetUrl();
		*_port        = tmp->GetPort();
	}
	else
		LoadConfig();
	SaveConfig();

	InitDatabaseTables();
	WriteLog("Initialized.");
}
PostgreSql::~PostgreSql()
{
	Close();
	delete _user;
	delete _password;
	delete _url;
	delete _port;
	delete _db_default;
	delete _db_instru;
	delete _config_file;
	delete _conns;
	delete _tables;
	delete _tb_oview;
	delete _mtx_conn;
	delete _mtx_table;
	delete _mtx_file;
}
void PostgreSql::Close()
{
	Disconnect();
	SaveConfig();
}


void PostgreSql::LoadConfig()
{
	Lock lck(*_mtx_file);
	Config cfg = ::utility::LoadJson(*_config_file);
	if (cfg.size())
	{
		*_user     = any_cast<string>(cfg["user"].second);
		*_password = any_cast<string>(cfg["password"].second);
		*_url      = any_cast<string>(cfg["url"].second);
		*_port     = any_cast<string>(cfg["port"].second);
	}
}
void PostgreSql::SaveConfig()
{
	Lock lck(*_mtx_file);
	Config cfg;
	cfg["user"]     = make_pair("string", *_user);
	cfg["password"] = make_pair("string", *_password);
	cfg["url"]      = make_pair("string", *_url);
	cfg["port"]     = make_pair("string", *_port);
	::utility::SaveJson(cfg, *_config_file);
}


void PostgreSql::InitDatabaseTables()
{
	Connect(*_db_default);

	auto dbs = FetchDatabases();
	if (dbs.find(*_db_instru) == dbs.end())
		CreateDatabase(SelectConn(), *_db_instru);
	else
	{
		Connect(*_db_instru);
		dbs.erase(*_db_instru);
	}


	vector<std::thread> threads;
	for (auto& i : dbs)
		threads.push_back(std::thread(&PostgreSql::FetchTables, this, i));
	for (auto& i : threads)
		i.join();
}
void PostgreSql::Connect(const string& _db, bool _gui_show)
{

	Lock lck_conn(*_mtx_conn);
	if (_conns->count(_db))
		return;
	lck_conn.unlock();

	// connect
	PGconn* conn;
	conn = PQsetdbLogin(_url->c_str(), _port->c_str(), NULL, NULL, _db.c_str(), _user->c_str(), _password->c_str());
	if (PQstatus(conn) != CONNECTION_OK)
		return WriteError("Missing Database " + _db + ".", "FATAL", PQerrorMessage(conn));

	// save conn
	lck_conn.lock();
	(*_conns)[_db] = std::make_pair(false, conn);
	lck_conn.unlock();

	// fetch tables buffer
	if (_db == *_db_default)
		return;
	PGresult* res = Execute((*_conns)[_db], "SELECT tablename FROM pg_tables WHERE tablename NOT LIKE 'pg%%' AND tablename NOT LIKE 'sql_%%' ORDER BY tablename;");
	Lock lck_table(*_mtx_table);
	for (int i = 0; i < PQntuples(res); ++i)
		(*_tables)[_db].insert(PQgetvalue(res, i, 0));
	PQclear(res);
	return WriteLog("Connected [" + _db + "].", ::trader::Log::Level::Info, _gui_show);

}
void PostgreSql::Disconnect(const string* _db)
{
	if (!_db)
	{
		for (auto& i : *_conns)
			PQfinish(i.second.second);
		_conns->clear();
		return;
	}
	else
	{
		PQfinish((*_conns)[*_db].second);
		_conns->erase(*_db);
	}
}

set<string> PostgreSql::FetchDatabases()
{
	set<string> ret;
	const char* sql = "SELECT u.datname FROM pg_catalog.pg_database u WHERE u.datname LIKE '1MIN-%' OR u.datname LIKE '1H-%' OR u.datname LIKE '1D-%' OR u.datname LIKE '1W-%' OR u.datname LIKE 'TICK-%' OR u.datname LIKE 'INSTRUMENTS' ORDER BY u.datname;";
	PGresult* res = Execute(SelectConn(), sql);
	for (int i = 0; i < PQntuples(res); ++i)
		ret.insert(PQgetvalue(res, i, 0));
	PQclear(res);
	return ret;
}
set<string> PostgreSql::FetchTables(const string& _db)
{
	Connect(_db);
	Lock lck(*_mtx_table);
	return (*_tables)[_db];
}


bool PostgreSql::SaveFutureChain(const Contracts& _in)
{
	// 预处�?
	if (_in.size() == 0)
		return false;
	for (auto& i : _in)
		if (i->product != Product::Future)
		{
			WriteError("Future chain saving error, please check!", "", i->symbol->c_str());
			return false;
		}

	// 获得conn
	string db = *_db_instru;
	Switch& conn = SelectConn(db);

	// �?查表
	string table = TableName(_in);
	if (!CheckTable(db, table))
		CreateTable(conn, db, table, _in);

	// 插入
	for (auto curr = _in.begin(); curr != _in.end();)
	{
		auto start = curr;
		auto end = distance(_in.end(), curr) < 4096 ? _in.end() : curr + 4096;
		if (!ExecUpdateSQL(conn, table, Contracts(start, end)))
			return false;
		else
			curr = end;
	}
	return true;
}
bool PostgreSql::SaveOptionChain(const Contracts& _in)
{
	// 预处�?
	if (_in.size() == 0)
		return false;
	for (auto& i : _in)
		if (i->product != Product::Option)
		{
			WriteError("Option chain saving error, please check!", "", i->symbol->c_str());
			return false;
		}

	// 获得conn
	string db = *_db_instru;
	Switch& conn = SelectConn(db);

	// �?查表
	string table = TableName(_in);
	if (!CheckTable(db, table))
		CreateTable(conn, db, table, _in);

	// 插入
	for (auto curr = _in.begin(); curr != _in.end();)
	{
		auto start = curr;
		auto end   = distance(_in.end(), curr) < 4096 ? _in.end() : curr + 4096;
		if (!ExecUpdateSQL(conn, table, Contracts(start, end)))
			return false;
		else
			curr   = end;
	}
	return true;
}
bool PostgreSql::SaveTick(const ReqHis* _req, const Ticks& _in)
{
	// 获得conn / �?查表
	string db    = DatabaseName(_req);
	Switch& conn = SelectConn(db);
	string table = TableName(_req);
	if (!CheckTable(db, table))
		CreateTable(conn, db, table, _in);


	// 插入
	for (auto curr = _in.begin(); curr != _in.end();)
	{
		auto start = curr;
		auto end = distance(_in.end(), curr) < 4096 ? _in.end() : curr + 4096;
		if (!ExecUpdateSQL(conn, table, Ticks(start, end)))
			return false;
		else
			curr = end;
	}
	return true;
}
bool PostgreSql::SaveCalendar(const Calendar& _in)
{
	// 获得conn / �?查表
	string db    = "CALENDAR";
	Switch& conn = SelectConn(db);
	string table = "CALENDAR";
	if (!CheckTable(db, table))
		CreateTable(conn, db, table, _in);

	// 插入
	for (auto curr = _in.begin(); curr != _in.end();)
	{
		auto start = curr;
		auto end = distance(_in.end(), curr) < 4096 ? _in.end() : curr + 4096;
		if (!ExecUpdateSQL(conn, table, Calendar(start, end)))
			return false;
		else
			curr = end;
	}
	return true;
}
bool PostgreSql::SaveMinute(const ReqHis* _req, const Bars& _dat)
{
	// 获得conn / �?查表
	string db    = DatabaseName(_req);
	Switch& conn = SelectConn(db);
	string table = TableName(_req);
	if (!CheckTable(db, table))
		CreateTable(conn, db, table, _dat);


	// 插入
	for (auto curr = _dat.begin(); curr != _dat.end();)
	{
		auto start = curr;
		auto end   = distance(_dat.end(), curr) < 4096 ? _dat.end() : curr + 4096;
		if (!ExecUpdateSQL(conn, table, Bars(start, end)))
			return false;
		else
			curr   = end;
	}
	return true;
}
bool PostgreSql::SaveEtf(const ReqHis* _req, const Bars& _dat)
{
	// 类型转换
	EtfDailyMd buffer;
	for (auto i : _dat)
		buffer.push_back((EtfData*)i);


	// 获得conn / �?查表
	string db    = DatabaseName(_req);
	Switch& conn = SelectConn(db);
	string table = TableName(_req);
	if (!CheckTable(db, table))
		CreateTable(conn, db, table, buffer);


	// 插入
	for (auto curr = buffer.begin(); curr != buffer.end();)
	{
		auto start = curr;
		auto end = distance(buffer.end(), curr) < 4096 ? buffer.end() : curr + 4096;
		if (!ExecUpdateSQL(conn, table, EtfDailyMd(start, end)))
			return false;
		else
			curr = end;
	}
	return true;
}
bool PostgreSql::SaveFuture(const ReqHis* _req, const Bars& _dat)
{	
	// 类型转换
	FutureDailyMd buffer;
	for (auto i : _dat)
		buffer.push_back((FutureData*)i);


	// 获得conn / �?查表
	string db = DatabaseName(_req);
	Switch& conn = SelectConn(db);
	string table = TableName(_req);
	if (!CheckTable(db, table))
		CreateTable(conn, db, table, buffer);


	// 插入
	for (auto curr = buffer.begin(); curr != buffer.end();)
	{
		auto start = curr;
		auto end = distance(buffer.end(), curr) < 4096 ? buffer.end() : curr + 4096;
		if (!ExecUpdateSQL(conn, table, FutureDailyMd(start, end)))
			return false;
		else
			curr = end;
	}
	return true;
}
bool PostgreSql::SaveIndex(const ReqHis* _req, const Bars& _dat)
{
	return SaveMinute(_req, _dat);
}
bool PostgreSql::SaveInterest(const ReqHis* _req, const Bars& _dat)
{	
	return SaveMinute(_req, _dat);
}
bool PostgreSql::SaveOption(const ReqHis* _req, const Bars& _dat)
{	
	// 类型转换
	OptionDailyMd buffer;
	for (auto i : _dat)
		buffer.push_back((::utility::object::OptionData*)i);


	// 获得conn / �?查表
	string db    = DatabaseName(_req);
	Switch& conn = SelectConn(db);
	string table = TableName(_req);
	if (!CheckTable(db, table))
		CreateTable(conn, db, table, buffer);


	// 插入
	for (auto curr = buffer.begin(); curr != buffer.end();)
	{
		auto start = curr;
		auto end = distance(buffer.end(), curr) < 4096 ? buffer.end() : curr + 4096;
		if (!ExecUpdateSQL(conn, table, OptionDailyMd(start, end)))
			return false;
		else
			curr = end;
	}
	return true;
}


bool PostgreSql::LoadFutureChain(const ReqHis* _req, Contracts& _out)
{
	string table = TableName(_out, _req);
	string db    = *_db_instru;

	char sql[1024];
	sprintf_s(sql, sizeof(sql),
		"SELECT symbol, exchange, "
		"TO_CHAR(start_trade_date, 'YYYY-MM-DD HH24:MI:SS.MS'), "
		"TO_CHAR(end_trade_date, 'YYYY-MM-DD HH24:MI:SS.MS'), "
		"dlmonth, "
		"margin_ratio, "
		"size, "
		"price_tick "
		"from public.\"%s\" "
		"ORDER BY \"symbol\" ASC;",
		table.c_str()
	);

	Switch& conn  = SelectConn(db);
	PGresult* res = Execute(conn, sql);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		WriteError("Table bar fetch error.", std::move(table), PQerrorMessage(conn.second));
		PQclear(res);
		return false;
	}

	for (int i = 0; i < PQntuples(res); i++)
	{
		Contract* contract     = new Contract();
		contract->product      = Product::Future;
		*contract->symbol      = PQgetvalue(res, i, 0);
		contract->exchange     = trans_pg_string_exchange[PQgetvalue(res, i, 1)];
		*contract->variety     = ::utility::RegSymbolLetter(*contract->symbol);
		contract->trade_start  = TimeStamp(PQgetvalue(res, i, 2), "%04d-%02d-%02d %02d:%02d:%02d.%03d");
		contract->trade_end    = TimeStamp(PQgetvalue(res, i, 3), "%04d-%02d-%02d %02d:%02d:%02d.%03d");
		contract->dlmonth      = atoi((PQgetvalue(res, i, 4)));
		contract->margin_ratio = atof((PQgetvalue(res, i, 5)));
		contract->size         = atof((PQgetvalue(res, i, 6)));
		contract->price_tick   = atof((PQgetvalue(res, i, 7)));
		_out.emplace_back(contract);
	}
	PQclear(res);
	return true;
}
bool PostgreSql::LoadOptionChain(const ReqHis* _req, Contracts& _out)
{
	string table = TableName(_out, _req);
	string db    = *_db_instru;

	char sql[1024];
	sprintf_s(sql, sizeof(sql),
		"SELECT symbol, exchange, vareity, ud_symbol, ud_product, ud_exchange, call_or_put, strike_type, strike, size, price_tick, dlmonth, "
		"TO_CHAR(start_trade_date, 'YYYY-MM-DD HH24:MI:SS.MS'), "
		"TO_CHAR(end_trade_date, 'YYYY-MM-DD HH24:MI:SS.MS'), "
		"settle_mode "
		"from public.\"%s\" "
		"ORDER BY \"symbol\" ASC; ",
		table.c_str()
		);

	Switch& conn  = SelectConn(db);;
	PGresult* res = Execute(conn, sql);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		WriteError("Table bar fetch error.", std::move(table), PQerrorMessage(conn.second));
		PQclear(res);
		return false;
	}

	for (int i = 0; i < PQntuples(res); i++)
	{
		Contract* contract        = new Contract();
		contract->product         = Product::Option;
		*contract->symbol         = PQgetvalue(res, i, 0);
		contract->exchange        = trans_pg_string_exchange[PQgetvalue(res, i, 1)];
		*contract->variety        = PQgetvalue(res, i, 2);

		*contract->ud_symbol      = PQgetvalue(res, i, 3);
		contract->ud_product      = trans_pg_string_product[PQgetvalue(res, i, 4)];
		contract->ud_exchange     = trans_pg_string_exchange[PQgetvalue(res, i, 5)];
		*contract->ud_variety     = ::utility::RegSymbolLetter(*contract->ud_symbol);

		contract->opt_direct      = trans_pg_string_optiontype[PQgetvalue(res, i, 6)];
		contract->opt_strike_type = trans_pg_string_striketype[PQgetvalue(res, i, 7)];
		contract->opt_strike      = atof((PQgetvalue(res, i, 8)));
		contract->size            = atof((PQgetvalue(res, i, 9)));
		contract->price_tick      = atof((PQgetvalue(res, i, 10)));
		contract->dlmonth         = atoi((PQgetvalue(res, i, 11)));
		contract->trade_start     = TimeStamp(PQgetvalue(res, i, 12), "%04d-%02d-%02d %02d:%02d:%02d.%03d");
		contract->trade_end       = TimeStamp(PQgetvalue(res, i, 13), "%04d-%02d-%02d %02d:%02d:%02d.%03d");
		contract->opt_deliver     = trans_pg_string_delitype[PQgetvalue(res, i, 14)];
		_out.emplace_back(contract);
	}
	PQclear(res);
	return true;
}
bool PostgreSql::LoadTick(const ReqHis* _req, Ticks& _out)
{
	string start = _req->GetStart().ToString();
	string end   = _req->GetEnd().ToString();
	string table = TableName(_req);
	string db    = DatabaseName(_req);


	char sql[1024];
	sprintf_s(sql, sizeof(sql),
		"SELECT TO_CHAR(datetime_action, 'YYYY-MM-DD HH24:MI:SS.MS'), open, high, low, last, volume, oi, turnover, "
		"b1p, b2p, b3p, b4p, b5p, b1v, b2v, b3v, b4v, b5v, "
		"a1p, a2p, a3p, a4p, a5p, a1v, a2v, a3v, a4v, a5v, "
		"high_lmt, low_lmt, ave_price, preclose, presettle, preoi "
		"FROM public.\"%s\" "
		"WHERE(\"datetime_action\" >= '%s' AND \"datetime_action\" <= '%s') "
		"ORDER BY \"datetime_action\";",
		table.c_str(),
		start.c_str(),
		end.c_str());

	Switch& conn  = SelectConn(db);;
	PGresult* res = Execute(conn, sql);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		WriteError("Table tick fetch error.", std::move(table), PQerrorMessage(conn.second));
		PQclear(res);
		return false;
	}


	for (int i = 0; i < PQntuples(res); i++)
	{
		Tick* curr      = new Tick(*_unit_name);
		*curr->symbol   = _req->GetSymbol();
		curr->exchange  = _req->GetExchange();
		curr->product   = _req->GetProduct();
		curr->ts        = TimeStamp(PQgetvalue(res, i, 0), "%04d-%02d-%02d %02d:%02d:%02d.%03d");
		curr->open      = atof((PQgetvalue(res, i, 1)));
		curr->high      = atof((PQgetvalue(res, i, 2)));
		curr->low       = atof((PQgetvalue(res, i, 3)));
		curr->last      = atof((PQgetvalue(res, i, 4)));
		curr->volume    = atoi((PQgetvalue(res, i, 5)));
		curr->oi        = atof((PQgetvalue(res, i, 6)));
		curr->turnover  = atof((PQgetvalue(res, i, 7)));

		curr->bp1       = atof((PQgetvalue(res, i, 8)));
		curr->bp2       = atof((PQgetvalue(res, i, 9)));
		curr->bp3       = atof((PQgetvalue(res, i, 10)));
		curr->bp4       = atof((PQgetvalue(res, i, 11)));
		curr->bp5       = atof((PQgetvalue(res, i, 12)));
		curr->bv1       = atoi((PQgetvalue(res, i, 13)));
		curr->bv2       = atoi((PQgetvalue(res, i, 14)));
		curr->bv3       = atoi((PQgetvalue(res, i, 15)));
		curr->bv4       = atoi((PQgetvalue(res, i, 16)));
		curr->bv5       = atoi((PQgetvalue(res, i, 17)));

		curr->ap1       = atof((PQgetvalue(res, i, 18)));
		curr->ap2       = atof((PQgetvalue(res, i, 19)));
		curr->ap3       = atof((PQgetvalue(res, i, 20)));
		curr->ap4       = atof((PQgetvalue(res, i, 21)));
		curr->ap5       = atof((PQgetvalue(res, i, 22)));
		curr->av1       = atoi((PQgetvalue(res, i, 23)));
		curr->av2       = atoi((PQgetvalue(res, i, 24)));
		curr->av3       = atoi((PQgetvalue(res, i, 25)));
		curr->av4       = atoi((PQgetvalue(res, i, 26)));
		curr->av5       = atoi((PQgetvalue(res, i, 27)));

		curr->high_lmt  = atof((PQgetvalue(res, i, 28)));
		curr->low_lmt   = atof((PQgetvalue(res, i, 29)));
		curr->ave_price = atof((PQgetvalue(res, i, 30)));
		curr->preclose  = atof((PQgetvalue(res, i, 31)));
		curr->presettle = atof((PQgetvalue(res, i, 32)));
		curr->preoi     = atof((PQgetvalue(res, i, 33)));
		_out.push_back(curr);
	}
	PQclear(res);
	return true;
}
bool PostgreSql::LoadMinute(const ReqHis* _req, Bars& _out)
{
	string start = _req->GetStart().ToString();
	string end   = _req->GetEnd().ToString();
	string table = TableName(_req);
	string db    = DatabaseName(_req);


	char sql[1024];
	sprintf_s(sql, sizeof(sql),
		"SELECT TO_CHAR(datetime_action, 'YYYY-MM-DD HH24:MI:SS.MS'), open, high, low, last, volume, oi, turnover FROM public.\"%s\" "
		"WHERE(\"datetime_action\" >= '%s' AND \"datetime_action\" <= '%s') "
		"ORDER BY \"datetime_action\";",
		table.c_str(),
		start.c_str(),
		end.c_str());

	Switch& conn  = SelectConn(db);;
	PGresult* res = Execute(conn, sql);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		WriteError("Table bar fetch error.", std::move(table), PQerrorMessage(conn.second));
		PQclear(res);
		return false;
	}


	for (int i = 0; i < PQntuples(res); i++)
	{
		Bar* curr      = new Bar(*_unit_name);
		*curr->symbol  = _req->GetSymbol();
		curr->exchange = _req->GetExchange();
		curr->product  = _req->GetProduct();
		curr->interval = _req->GetInterval();
		curr->ts       = TimeStamp(PQgetvalue(res, i, 0), "%04d-%02d-%02d %02d:%02d:%02d.%03d");
		curr->open     = atof((PQgetvalue(res, i, 1)));
		curr->high     = atof((PQgetvalue(res, i, 2)));
		curr->low      = atof((PQgetvalue(res, i, 3)));
		curr->last     = atof((PQgetvalue(res, i, 4)));
		curr->volume   = atoi((PQgetvalue(res, i, 5)));
		curr->oi       = atof((PQgetvalue(res, i, 6)));
		curr->turnover = atof((PQgetvalue(res, i, 7)));
		_out.emplace_back(curr);
	}
	PQclear(res);
	return true;
}
bool PostgreSql::LoadEtf(const ReqHis* _req, Bars& _out)
{
	string start = _req->GetStart().ToString();
	string end   = _req->GetEnd().ToString();
	string table = TableName(_req);
	string db    = DatabaseName(_req);


	char sql[1024];
	sprintf_s(sql, sizeof(sql),
		"SELECT TO_CHAR(datetime_action, 'YYYY-MM-DD HH24:MI:SS.MS'), nav, nav_adj, open, high, low, last, volume, oi, turnover FROM public.\"%s\" "
		"WHERE(\"datetime_action\" >= '%s' AND \"datetime_action\" <= '%s') "
		"ORDER BY \"datetime_action\";",
		table.c_str(),
		start.c_str(),
		end.c_str());

	Switch& conn = SelectConn(db);;
	PGresult* res = Execute(conn, sql);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		WriteError("Option market data fetch error.", std::move(table), PQerrorMessage(conn.second));
		PQclear(res);
		return false;
	}


	for (int i = 0; i < PQntuples(res); i++)
	{
		EtfData* curr  = new EtfData(*_unit_name);
		*curr->symbol  = _req->GetSymbol();
		curr->exchange = _req->GetExchange();
		curr->product  = _req->GetProduct();
		curr->interval = _req->GetInterval();
		curr->ts       = TimeStamp(PQgetvalue(res, i, 0), "%04d-%02d-%02d %02d:%02d:%02d.%03d");
		curr->nav      = atof((PQgetvalue(res, i, 1)));
		curr->nav_adj  = atof((PQgetvalue(res, i, 2)));
		curr->open     = atof((PQgetvalue(res, i, 3)));
		curr->high     = atof((PQgetvalue(res, i, 4)));
		curr->low      = atof((PQgetvalue(res, i, 5)));
		curr->last     = atof((PQgetvalue(res, i, 6)));
		curr->volume   = atoi((PQgetvalue(res, i, 7)));
		curr->oi       = atof((PQgetvalue(res, i, 8)));
		curr->turnover = atof((PQgetvalue(res, i, 9)));
		_out.emplace_back(curr);
	}
	PQclear(res);
	return true;
}
bool PostgreSql::LoadFuture(const ReqHis* _req, Bars& _out)
{
	string start = _req->GetStart().ToString();
	string end   = _req->GetEnd().ToString();
	string table = TableName(_req);
	string db    = DatabaseName(_req);


	char sql[1024];
	sprintf_s(sql, sizeof(sql),
		"SELECT TO_CHAR(datetime_action, 'YYYY-MM-DD HH24:MI:SS.MS'), open, high, low, last, volume, oi, turnover, settle, presettle, st_stock, rem_nday FROM public.\"%s\" "
		"WHERE(\"datetime_action\" >= '%s' AND \"datetime_action\" <= '%s') "
		"ORDER BY \"datetime_action\";",
		table.c_str(),
		start.c_str(),
		end.c_str());

	Switch& conn  = SelectConn(db);;
	PGresult* res = Execute(conn, sql);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		WriteError("Option market data fetch error.", std::move(table), PQerrorMessage(conn.second));
		PQclear(res);
		return false;
	}


	for (int i = 0; i < PQntuples(res); i++)
	{
		FutureData* curr = new FutureData(*_unit_name);
		*curr->symbol    = _req->GetSymbol();
		curr->exchange   = _req->GetExchange();
		curr->product    = _req->GetProduct();
		curr->interval   = _req->GetInterval();
		curr->ts         = TimeStamp(PQgetvalue(res, i, 0), "%04d-%02d-%02d %02d:%02d:%02d.%03d");
		curr->open       = atof((PQgetvalue(res, i, 1)));
		curr->high       = atof((PQgetvalue(res, i, 2)));
		curr->low        = atof((PQgetvalue(res, i, 3)));
		curr->last       = atof((PQgetvalue(res, i, 4)));
		curr->volume     = atoi((PQgetvalue(res, i, 5)));
		curr->oi         = atof((PQgetvalue(res, i, 6)));
		curr->turnover   = atof((PQgetvalue(res, i, 7)));
		curr->settle     = atof((PQgetvalue(res, i, 8)));
		curr->pre_settle = atof((PQgetvalue(res, i, 9)));
		curr->st_stock   = atoi((PQgetvalue(res, i, 10)));
		curr->rem_nday   = atoi((PQgetvalue(res, i, 11)));
		_out.emplace_back(curr);
	}
	PQclear(res);
	return true;
}
bool PostgreSql::LoadIndex(const ReqHis* _req, Bars& _out)
{
	return LoadMinute(_req, _out);
}
bool PostgreSql::LoadInterest(const ReqHis* _req, Bars& _out)
{
	return LoadMinute(_req, _out);
}
bool PostgreSql::LoadOption(const ReqHis* _req, Bars& _out)
{
	string start = _req->GetStart().ToString();
	string end   = _req->GetEnd().ToString();
	string table = TableName(_req);
	string db    = DatabaseName(_req);


	char sql[1024];
	sprintf_s(sql, sizeof(sql),
		"SELECT TO_CHAR(datetime_action, 'YYYY-MM-DD HH24:MI:SS.MS'), open, high, low, last, volume, oi, turnover, settle, presettle, rem_nday, rem_tday FROM public.\"%s\" "
		"WHERE(\"datetime_action\" >= '%s' AND \"datetime_action\" <= '%s') "
		"ORDER BY \"datetime_action\";",
		table.c_str(),
		start.c_str(),
		end.c_str());

	Switch& conn  = SelectConn(db);
	PGresult* res = Execute(conn, sql);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		WriteError("Option market data fetch error.", std::move(table), PQerrorMessage(conn.second));
		PQclear(res);
		return false;
	}


	for (int i = 0; i < PQntuples(res); i++)
	{
		OptionData* curr = new OptionData(*_unit_name);
		*curr->symbol    = _req->GetSymbol();
		curr->exchange   = _req->GetExchange();
		curr->product    = _req->GetProduct();
		curr->interval   = _req->GetInterval();
		curr->ts         = TimeStamp(PQgetvalue(res, i, 0), "%04d-%02d-%02d %02d:%02d:%02d.%03d");
		curr->open       = atof((PQgetvalue(res, i, 1)));
		curr->high       = atof((PQgetvalue(res, i, 2)));
		curr->low        = atof((PQgetvalue(res, i, 3)));
		curr->last       = atof((PQgetvalue(res, i, 4)));
		curr->volume     = atoi((PQgetvalue(res, i, 5)));
		curr->oi         = atof((PQgetvalue(res, i, 6)));
		curr->turnover   = atof((PQgetvalue(res, i, 7)));
		curr->settle     = atof((PQgetvalue(res, i, 8)));
		curr->pre_settle = atof((PQgetvalue(res, i, 9)));
		curr->rem_nday   = atoi((PQgetvalue(res, i, 10)));
		curr->rem_tday   = atoi((PQgetvalue(res, i, 11)));
		_out.emplace_back(curr);
	}
	PQclear(res);
	return true;
}


Contracts PostgreSql::FetchChains()
{
	auto tables = FetchTables(*_db_instru);
	Contracts ret;
	for (auto& i : tables)
	{
		auto strs         = ::utility::Split(i, "_");
		Product product   = trans_pg_string_product[strs.at(0)];
		string variety    = strs.at(1);
		Exchange exchange = trans_pg_string_exchange[strs.at(2)];

		Contract contr(product, "", exchange, variety);
		ReqHis req(&contr, TimeStamp(), TimeStamp(), Interval::Daily);
		switch (product)
		{
		case Product::Future:	LoadFutureChain(&req, ret);		break;
		case Product::Option:	LoadOptionChain(&req, ret);		break;
		default:
			continue;
		}
	}
	return ret;
}
vector<View> PostgreSql::FetchAllIntervalProduct()
{
	return GetBarOverview();
}


int PostgreSql::DeleteBar(const ReqHis* _req)
{
	// 预处�?
	auto view    = GetBarOverview(const_cast<ReqHis*>(_req));
	int ret      = view.at(0).GetCounts();
	string db    = DatabaseName(_req);
	string tb    = TableName(_req);
	Switch& conn = SelectConn(db);

	// 删除�?
	ExecDeleteSQL(conn, TableName(_req));

	// 删除缓存
	Lock lck(*_mtx_table);
	(*_tables)[DatabaseName(_req)].erase(tb);
	return ret;
}
int PostgreSql::DeleteTick(const ReqHis* _req)
{
	// 预处�?
	auto view    = GetBarOverview(const_cast<ReqHis*>(_req));
	int ret      = view.at(0).GetCounts();
	string db    = DatabaseName(_req);
	string tb    = TableName(_req);
	Switch& conn = SelectConn(db);

	// 删除�?
	ExecDeleteSQL(conn, TableName(_req));

	// 删除缓存
	Lock lck(*_mtx_table);
	(*_tables)[DatabaseName(_req)].erase(tb);
	return ret;
}
vector<View> PostgreSql::GetBarOverview(ReqHis* _req)
{
	// 获取�?有可用数据库
	vector<View> ret;
	if (!_req)
	{
		vector<std::thread> threads;
		for (auto& i : *_conns)
		{
			if (i.first != *_db_default && i.first != *_db_instru)
				threads.push_back(std::thread(&PostgreSql::SingleOverview, this, i.first, &ret));
		}
		for (auto& i : threads)
			i.join();
		std::sort(ret.begin(), ret.end(), View::Compare);
	}
	else
	{
		SingleOverview(DatabaseName(_req), &ret);
		if (ret.size() == 0)
			ret = { View(*_req) };
	}

	return ret;
}
void PostgreSql::SingleOverview(const string& db, vector<View>* _ret)
{
	// 预处�?
	auto     strs     = ::utility::Split(db, "-");
	Product  product  = trans_pg_string_product[strs.at(1)];
	string   variety;
	Interval interval = trans_pg_string_interval[strs.at(0)];


	// 读取overviews
	auto& conn    = SelectConn(db);
	string sql    = "SELECT tablename, start_timestamp, end_timestamp, counts FROM public.\"" + *_tb_oview + "\" ORDER BY tablename";
	PGresult* res = Execute(conn, sql.c_str());
	vector<View> tmp_res;
	for (auto i = 0; i < PQntuples(res); ++i)
	{
		string tb       = PQgetvalue(res, i, 0);
		TimeStamp start = TimeStamp(PQgetvalue(res, i, 1), "%04d-%02d-%02d %02d:%02d:%02d.%03d");
		TimeStamp end   = TimeStamp(PQgetvalue(res, i, 2), "%04d-%02d-%02d %02d:%02d:%02d.%03d");
		int count       = atoi((PQgetvalue(res, i, 3)));

		Contract* contract = new Contract();
		switch (product)
		{
		case utility::constant::Product::Future:
		{
			contract->product = product;
			*contract->symbol = tb;
			contract->exchange = trans_pg_string_exchange[*strs.rbegin()];
			*contract->variety = strs.at(2);
			break;
		}

		case utility::constant::Product::Option:
		{
			contract->product     = product;
			*contract->symbol     = tb;
			contract->exchange    = trans_pg_string_exchange[*strs.rbegin()];
			*contract->variety    = strs.at(2);
			*contract->ud_variety = strs.at(2);
			break;
		}

		case utility::constant::Product::Etf:
		case utility::constant::Product::Fund:
		case utility::constant::Product::Index:
		{
			auto strs          = ::utility::Split(tb, "_");
			contract->product  = product;
			*contract->symbol  = strs.at(0);
			contract->exchange = trans_pg_string_exchange[strs.at(1)];
			*contract->variety = strs.at(0);
			break;
		}

		case utility::constant::Product::Interest:
		{
			*contract->symbol = tb;
			break;
		}

		default:
			delete contract;
			continue;
		}

		tmp_res.push_back({ contract, interval, count, start, end });
		delete contract;
	}
	PQclear(res);

	Lock lck(*_mtx_file);
	_ret->insert(_ret->end(), tmp_res.begin(), tmp_res.end());
}



bool PostgreSql::PurgeDatabase(string _pwd)
{
	// 验证密码
	if (_pwd != "123456654321")
	{
		WriteLog("Purge password error, operation cancel.");
		return false;
	}

	// 获取�?有数据库
	Switch& conn  = SelectConn(*_db_default);
	PGresult* res = Execute(conn, "SELECT datname FROM pg_database;");
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		WriteError("Fetch all databases error.", "", PQerrorMessage(conn.second));
		PQclear(res);
		res = Execute(conn, "ROLLBACK;");
		PQclear(res);
		return false;
	}

	// 逐一删除
	for (int i = 0; i < PQntuples(res); i++)
	{
		string db = PQgetvalue(res, i, 0);
		if (db == *_db_default || db == "template1" || db == "template0")
			continue;

		Disconnect(&db);
		string sql = "DROP DATABASE \"" + db + "\";";
		PGresult* res_curr = PQexec(conn.second, sql.c_str());
		if (PQresultStatus(res_curr) != PGRES_COMMAND_OK)
			WriteError("Database [" + db + "] purge error.", "", PQerrorMessage(conn.second));
		else
			WriteLog("Database [" + db + "] purged.");
		PQclear(res_curr);
	}

	PQclear(res);

	// 清除缓存
	_tables->clear();
	WriteLog("Purge operation finished.");
	return true;
}
bool PostgreSql::PreUpdateCheck(const Contract& _contract)
{
	// 预处�?
	Switch& conn = SelectConn(*_db_default);
	bool ret = true;

	string db;
	Ticks tmp_ticks;
	Bars tmp_bars;
	for (auto i = 0; i != 2; i++)
	{
		if (i == 0)
			WriteLog("Checking [" + *_contract.symbol + "] database & table ...", ::trader::Log::Level::Info, true, false);


		// 数据库检�? TICK + BAR
		ReqHis req(&_contract, TimeStamp(), TimeStamp(), i == 0 ? Interval::Tick : Interval::Minute);
		db = DatabaseName(&req);


		if (!(*_conns)[db].second && !CheckDatabase(db) && !CreateDatabase(conn, db))
		{
			ret = false;
			continue;
		}

		// �?查表是否建立
		Connect(db);
		Switch& conn = SelectConn(db);
		string table = TableName(&req);
		if (CheckTable(db, table))
			continue;

		if (i == 0 && !CreateTable(conn, db, table, tmp_ticks))
		{
			ret = false;
			continue;
		}
		else if (i == 1 && !CreateTable(conn, db, table, tmp_bars))
		{
			ret = false;
			continue;
		}
	}
	return ret;
}






bool PostgreSql::CreateTriggerOverview(Switch& _conn, const string& _db, const string& _tb)
{
	string table = _tb;
	transform(table.begin(), table.end(), table.begin(), [](char i) {return i == '-' ? '_' : i; });


	char sql[2048];
	sprintf_s(sql, sizeof(sql),
		"CREATE OR REPLACE FUNCTION \"RefreshOverviews_%s\"() RETURNS TRIGGER AS $example_table$"
		"	DECLARE"
		"		ts_start TIMESTAMP(3) WITHOUT TIME ZONE;"
		"		ts_end   TIMESTAMP(3) WITHOUT TIME ZONE;"
		"		counts   int;"
		"	BEGIN"
		"		DELETE FROM \"BarOverviews\" WHERE tablename = '%s';"
		"		SELECT MIN(datetime_action), MAX(datetime_action), COUNT(*) INTO ts_start, ts_end, counts FROM public.\"%s\";"
		"		INSERT INTO \"BarOverviews\"(tablename, start_timestamp, end_timestamp, counts) VALUES(TG_TABLE_NAME, ts_start, ts_end, counts);"
		"		RETURN NEW;"
		"	END;"
		"$example_table$ LANGUAGE plpgsql;"
		"CREATE TRIGGER trigger_view_%s AFTER INSERT ON \"%s\" FOR EACH ROW EXECUTE PROCEDURE \"RefreshOverviews_%s\"();",
		table.c_str(),
		_tb.c_str(),
		_tb.c_str(),
		table.c_str(),
		_tb.c_str(),
		table.c_str()
	);

	if (!ExecCreateSQL(_conn, "[" + _tb + "]@[" + _db + "] create trigger error.", sql))
		return false;
	WriteLog("Created [" + _tb + "]@[" + _db + "] trigger.");
	return true;
}


bool PostgreSql::ExecUpdateSQL(Switch& _conn, const string& _tb, const Bars&& _data)
{
	string head, tail, sql;
	{
		head = "INSERT INTO \"" + _tb + "\"(datetime_action, open, high, low, last, volume, oi, turnover) VALUES ";
		tail = "ON CONFLICT (datetime_action) DO UPDATE SET "
			"open = excluded.open, "
			"high = excluded.high, "
			"low = excluded.low, "
			"last = excluded.last, "
			"volume = excluded.volume, "
			"oi = excluded.oi, "
			"turnover = excluded.turnover;";
		char buffer[1024];
		const char* fmt = "(\'%s\', %f, %f, %f, %f, %f, %f, %f)";
		for (auto& i : _data)
		{
			sprintf_s(buffer, sizeof(buffer), fmt,
				i->ts.ToString().c_str(),
				i->open,
				i->high,
				i->low,
				i->last,
				i->volume,
				i->oi,
				i->turnover
			);
			sql += head + buffer + tail;
		}
	}
	sql = "BEGIN;" + sql + "END;";

	{
		PGresult* res = Execute(_conn, sql.c_str());
		if (PQresultStatus(res) != PGRES_COMMAND_OK)
		{
			WriteError("Bar update error.", string(_tb), PQerrorMessage(_conn.second));
			PQclear(res);
			res = Execute(_conn, "ROLLBACK;");
			PQclear(res);
			return false;
		}
		PQclear(res);
		return true;
	}
}
bool PostgreSql::ExecUpdateSQL(Switch& _conn, const string& _tb, const EtfDailyMd&& _data)
{
	string head, tail, sql;
	{
		head = "INSERT INTO \"" + _tb + "\"(datetime_action, nav, nav_adj, open, high, low, last, volume, oi, turnover) VALUES ";
		tail = "ON CONFLICT (datetime_action) DO UPDATE SET "
			"nav = excluded.nav, "
			"nav_adj = excluded.nav_adj, "
			"open = excluded.open, "
			"high = excluded.high, "
			"low = excluded.low, "
			"last = excluded.last, "
			"volume = excluded.volume, "
			"oi = excluded.oi, "
			"turnover = excluded.turnover;";
		char buffer[1024];
		const char* fmt = "(\'%s\', %f, %f, %f, %f, %f, %f, %f, %f, %f)";
		for (auto& i : _data)
		{
			sprintf_s(buffer, sizeof(buffer), fmt,
				i->ts.ToString().c_str(),
				i->nav,
				i->nav_adj,
				i->open,
				i->high,
				i->low,
				i->last,
				i->volume,
				i->oi,
				i->turnover
			);
			sql += head + buffer + tail;
		}
	}
	sql = "BEGIN;" + sql + "END;";

	{
		PGresult* res = Execute(_conn, sql.c_str());
		if (PQresultStatus(res) != PGRES_COMMAND_OK)
		{
			WriteError("Bar update error.", string(_tb), PQerrorMessage(_conn.second));
			PQclear(res);
			res = Execute(_conn, "ROLLBACK;");
			PQclear(res);
			return false;
		}
		PQclear(res);
		return true;
	}
}
bool PostgreSql::ExecUpdateSQL(Switch& _conn, const string& _tb, const FutureDailyMd&& _data)
{
	string head, tail, sql;
	{
		head = "INSERT INTO \"" + _tb + "\"(datetime_action, open, high, low, last, volume, oi, turnover, settle, presettle, st_stock, rem_nday) VALUES ";
		tail = "ON CONFLICT (datetime_action) DO UPDATE SET "
			"open = excluded.open, "
			"high = excluded.high, "
			"low = excluded.low, "
			"last = excluded.last, "
			"volume = excluded.volume, "
			"oi = excluded.oi, "
			"turnover = excluded.turnover, "
			"settle = excluded.settle, "
			"presettle = excluded.presettle, "
			"st_stock = excluded.st_stock, "
			"rem_nday = excluded.rem_nday;";
		char buffer[1024];
		const char* fmt = "(\'%s\', %f, %f, %f, %f, %f, %f, %f, %f, %f, %d, %d)";
		for (auto& i : _data)
		{
			sprintf_s(buffer, sizeof(buffer), fmt,
				i->ts.ToString().c_str(),
				i->open,
				i->high,
				i->low,
				i->last,
				i->volume,
				i->oi,
				i->turnover,
				i->settle,
				i->pre_settle,
				i->st_stock,
				i->rem_nday
			);
			sql += head + buffer + tail;
		}
	}
	sql = "BEGIN;" + sql + "END;";

	{
		PGresult* res = Execute(_conn, sql.c_str());
		if (PQresultStatus(res) != PGRES_COMMAND_OK)
		{
			WriteError("Bar update error.", string(_tb), PQerrorMessage(_conn.second));
			PQclear(res);
			res = Execute(_conn, "ROLLBACK;");
			PQclear(res);
			return false;
		}
		PQclear(res);
		return true;
	}
}
bool PostgreSql::ExecUpdateSQL(Switch& _conn, const string& _tb, const OptionDailyMd&& _data)
{
	string head, tail, sql;
	{
		head = "INSERT INTO \"" + _tb + "\"(datetime_action, open, high, low, last, volume, oi, turnover, settle, presettle, rem_nday, rem_tday) VALUES ";
		tail = "ON CONFLICT (datetime_action) DO UPDATE SET "
			"open = excluded.open, "
			"high = excluded.high, "
			"low = excluded.low, "
			"last = excluded.last, "
			"volume = excluded.volume, "
			"oi = excluded.oi, "
			"turnover = excluded.turnover, "
			"settle = excluded.settle, "
			"presettle = excluded.presettle, "
			"rem_nday = excluded.rem_nday, "
			"rem_tday = excluded.rem_tday;";
		char buffer[1024];
		const char* fmt = "(\'%s\', %f, %f, %f, %f, %f, %f, %f, %f, %f, %d, %d)";
		for (auto& i : _data)
		{
			sprintf_s(buffer, sizeof(buffer), fmt,
				i->ts.ToString().c_str(),
				i->open,
				i->high,
				i->low,
				i->last,
				i->volume,
				i->oi,
				i->turnover,
				i->settle,
				i->pre_settle,
				i->rem_nday,
				i->rem_tday
			);
			sql += head + buffer + tail;
		}
	}
	sql = "BEGIN;" + sql + "END;";

	{
		PGresult* res = Execute(_conn, sql.c_str());
		if (PQresultStatus(res) != PGRES_COMMAND_OK)
		{
			WriteError("Bar update error.", string(_tb), PQerrorMessage(_conn.second));
			PQclear(res);
			res = Execute(_conn, "ROLLBACK;");
			PQclear(res);
			return false;
		}
		PQclear(res);
		return true;
	}
}
bool PostgreSql::ExecUpdateSQL(Switch& _conn, const string& _tb, const Ticks&& _data)
{
	string head, tail, sql;
	{
		head = "INSERT INTO \"" + _tb + "\"(datetime_action, open, high, low, last, volume, oi, turnover, "
			"b1p, b2p, b3p, b4p, b5p, b1v, b2v, b3v, b4v, b5v, "
			"a1p, a2p, a3p, a4p, a5p, a1v, a2v, a3v, a4v, a5v, "
			"high_lmt, low_lmt, ave_price, preclose, presettle, preoi"
			") VALUES ";
		tail = "ON CONFLICT (datetime_action) DO UPDATE SET "
			"open = excluded.open, "
			"high = excluded.high, "
			"low = excluded.low, "
			"last = excluded.last, "
			"volume = excluded.volume, "
			"oi = excluded.oi, "
			"turnover = excluded.turnover, "
			"b1p = excluded.b1p, "
			"b2p = excluded.b2p, "
			"b3p = excluded.b3p, "
			"b4p = excluded.b4p, "
			"b5p = excluded.b5p, "
			"b1v = excluded.b1v, "
			"b2v = excluded.b2v, "
			"b3v = excluded.b3v, "
			"b4v = excluded.b4v, "
			"b5v = excluded.b5v, "
			"a1p = excluded.a1p, "
			"a2p = excluded.a2p, "
			"a3p = excluded.a3p, "
			"a4p = excluded.a4p, "
			"a5p = excluded.a5p, "
			"a1v = excluded.a1v, "
			"a2v = excluded.a2v, "
			"a3v = excluded.a3v, "
			"a4v = excluded.a4v, "
			"a5v = excluded.a5v, "
			"high_lmt = excluded.high_lmt, "
			"low_lmt = excluded.low_lmt, "
			"ave_price = excluded.ave_price, "
			"preclose = excluded.preclose, "
			"presettle = excluded.presettle, "
			"preoi = excluded.preoi;";

		char buffer[2048];
		const char* fmt = "(\'%s\',  %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f)";
		for (auto& i : _data)
		{
			sprintf_s(buffer, sizeof(buffer), fmt,
				i->ts.ToString().c_str(),
				i->open, i->high, i->low, i->last, i->volume, i->oi, i->turnover,
				i->bp1, i->bp2, i->bp3, i->bp4, i->bp5,
				i->bv1, i->bv2, i->bv3, i->bv4, i->bv5,
				i->ap1, i->ap2, i->ap3, i->ap4, i->ap5,
				i->av1, i->av2, i->av3, i->av4, i->av5,
				i->high_lmt, i->low_lmt, i->ave_price, i->preclose, i->presettle, i->preoi
			);
			sql += head + buffer + tail;
		};
	}
	sql = "BEGIN;" + sql + "END;";

	{
		PGresult* res = Execute(_conn, sql.c_str());
		if (PQresultStatus(res) != PGRES_COMMAND_OK)
		{
			WriteError("Tick update error.", string(_tb), PQerrorMessage(_conn.second));
			PQclear(res);
			res = Execute(_conn, "ROLLBACK;");
			PQclear(res);
			return false;
		}
		PQclear(res);
		return true;
	}
}
bool PostgreSql::ExecUpdateSQL(Switch& _conn, const string& _tb, const Calendar&& _data)
{
	string head, tail, sql;
	{
		head = "INSERT INTO \"" + _tb + "\"(datetime, isTrading, isWorking, Weekday, datenum) VALUES ";
		tail = "ON CONFLICT (datetime) DO UPDATE SET "
			"isTrading = excluded.isTrading, "
			"isWorking = excluded.isWorking, "
			"Weekday = excluded.Weekday, "
			"datenum = excluded.datenum;";
		char buffer[1024];
		const char* fmt = "(\'%s\', %s, %s, %d, %d)";
		for (auto& i : _data)
		{
			sprintf_s(buffer, sizeof(buffer), fmt,
				i.GetTimeStamp().ToString().c_str(),
				i.isTrading() ? "true" : "false",
				i.isWorking() ? "true" : "false",
				int(i.Weekday()),
				i.getDatenum()
			);
			sql += head + buffer + tail;
		}
	}
	sql = "BEGIN;" + sql + "END;";

	{
		PGresult* res = Execute(_conn, sql.c_str());
		if (PQresultStatus(res) != PGRES_COMMAND_OK)
		{
			WriteError("Bar update error.", string(_tb), PQerrorMessage(_conn.second));
			PQclear(res);
			res = Execute(_conn, "ROLLBACK;");
			PQclear(res);
			return false;
		}
		PQclear(res);
		return true;
	}
}
bool PostgreSql::ExecUpdateSQL(Switch& _conn, const string& _tb, const Contracts&& _data)
{
	string head, tail, sql;
	switch (_data.at(0)->product)
	{
	case Product::Option:
	{
		head = "INSERT INTO \"" + _tb + "\"(symbol, exchange, vareity, ud_symbol, ud_product, ud_exchange, call_or_put, strike_type, strike, size, price_tick, dlmonth, start_trade_date, end_trade_date, settle_mode) VALUES ";
		tail = "ON CONFLICT (symbol) DO UPDATE SET "
			"symbol = excluded.symbol, "
			"exchange = excluded.exchange, "
			"vareity = excluded.vareity, "
			"ud_symbol = excluded.ud_symbol, "
			"ud_product = excluded.ud_product, "
			"ud_exchange = excluded.ud_exchange, "
			"call_or_put = excluded.call_or_put, "
			"strike_type = excluded.strike_type, "
			"strike = excluded.strike, "
			"size = excluded.size, "
			"price_tick = excluded.price_tick, "
			"dlmonth = excluded.dlmonth, "
			"start_trade_date = excluded.start_trade_date, "
			"end_trade_date = excluded.end_trade_date, "
			"settle_mode = excluded.settle_mode;";
		char buffer[1024];
		const char* fmt = "(\'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', %f, %f, %f, %d, \'%s\', \'%s\', \'%s\')";
		for (auto& i : _data)
		{
			sprintf_s(buffer, sizeof(buffer), fmt,
				i->symbol->c_str(),
				::utility::constant::Enum2String(i->exchange).c_str(),
				i->variety->c_str(),
				i->ud_symbol->c_str(),
				::utility::constant::Enum2String(i->ud_product).c_str(),
				::utility::constant::Enum2String(i->ud_exchange).c_str(),
				::utility::constant::Enum2String(i->opt_direct).c_str(),
				::utility::constant::Enum2String(i->opt_strike_type).c_str(),
				i->opt_strike, 
				i->size,
				i->price_tick,
				i->dlmonth,
				i->trade_start.ToString().c_str(),
				i->trade_end.ToString().c_str(),
				::utility::constant::Enum2String(i->opt_deliver).c_str()
			);
			sql += head + buffer + tail;
		}
		sql = "BEGIN;" + sql + "END;";


		PGresult* res = Execute(_conn, sql.c_str());
		if (PQresultStatus(res) != PGRES_COMMAND_OK)
		{
			WriteError("Option contracts update error.", string(_tb), PQerrorMessage(_conn.second));
			PQclear(res);
			res = Execute(_conn, "ROLLBACK;");
			PQclear(res);
			return false;
		}
		PQclear(res);
		return true;
	}

	case Product::Future:
	{
		head = "INSERT INTO \"" + _tb + "\"(symbol, exchange, start_trade_date, end_trade_date, dlmonth, margin_ratio, size, price_tick) VALUES ";
		tail = "ON CONFLICT (symbol) DO UPDATE SET "
			"symbol = excluded.symbol, "
			"exchange = excluded.exchange, "
			"start_trade_date = excluded.start_trade_date, "
			"end_trade_date = excluded.end_trade_date, "
			"dlmonth = excluded.dlmonth, "
			"margin_ratio = excluded.margin_ratio, "
			"size = excluded.size, "
			"price_tick = excluded.price_tick;";
		char buffer[1024];
		const char* fmt = "(\'%s\', \'%s\', \'%s\', \'%s\', %d, %f, %f, %f)";
		for (auto& i : _data)
		{
			sprintf_s(buffer, sizeof(buffer), fmt,
				i->symbol->c_str(),
				::utility::constant::Enum2String(i->exchange).c_str(),
				i->trade_start.ToString().c_str(),
				i->trade_end.ToString().c_str(),
				i->dlmonth,
				i->margin_ratio,
				i->size,
				i->price_tick
			);
			sql += head + buffer + tail;
		}
		sql = "BEGIN;" + sql + "END;";


		PGresult* res = Execute(_conn, sql.c_str());
		if (PQresultStatus(res) != PGRES_COMMAND_OK)
		{
			WriteError("Future contracts update error.", string(_tb), PQerrorMessage(_conn.second));
			PQclear(res);
			res = Execute(_conn, "ROLLBACK;");
			PQclear(res);
			return false;
		}
		PQclear(res);
		return true;
	}

	default:
		return false;
	}
}



bool PostgreSql::ExecDeleteSQL(Switch& _conn, const string&& _tb)
{
	bool ret;
	{
		string sql = "BEGIN; DROP TABLE \"" + _tb + "\"; END;";
		PGresult* res = Execute(_conn, sql.c_str());
		if (PQresultStatus(res) != PGRES_COMMAND_OK)
		{
			WriteError("Delete bar table " + _tb + " error.", "", PQerrorMessage(_conn.second));
			ret = false;
		}
		else
			ret = true;
		PQclear(res);
	}
	return ret;
}
PGresult* PostgreSql::Execute(Switch& _conn, const char* _sql)
{
	bool idle = false;
	while (!_conn.first.compare_exchange_weak(idle, true))
	{
		idle = false;
		std::this_thread::sleep_for(std::chrono::microseconds(10));
	}

	PGresult* ret = PQexec(_conn.second, _sql);
	_conn.first.store(false);
	return ret;
}





ConfigPg::ConfigPg()
	: user    (new string())
	, password(new string())
	, url     (new string())
	, port    (new string())
{}
ConfigPg::ConfigPg(string _usr, string _pwd, string _ul, string _pt)
	: user(new string(_usr))
	, password(new string(_pwd))
	, url(new string(_ul))
	, port(new string(_pt))
{}
ConfigPg::ConfigPg(ConfigPg&& in) noexcept
	: ConfigPg()
{
	*user     = *in.user;
	*password = *in.password;
	*url      = *in.url;
	*port     = *in.port;
}
ConfigPg::ConfigPg(const ConfigPg& in) noexcept
	: ConfigPg()
{
	*user     = *in.user;
	*password = *in.password;
	*url      = *in.url;
	*port     = *in.port;
}
ConfigPg& ConfigPg::operator=(const ConfigPg& in) noexcept
{
	*user     = *in.user;
	*password = *in.password;
	*url      = *in.url;
	*port     = *in.port;
	return *this;
}
ConfigPg& ConfigPg::operator=(ConfigPg&& in) noexcept
{
	*user     = *in.user;
	*password = *in.password;
	*url      = *in.url;
	*port     = *in.port;
	return *this;
}
ConfigPg::~ConfigPg()
{
	delete user;
	delete password;
	delete url;
	delete port;
}
