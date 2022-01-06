#ifndef POSTGRESQL_H
#define POSTGRESQL_H

#ifdef DATABASE_EXPORTS
#define DATABASE_API __declspec(dllexport)
#else
#define DATABASE_API __declspec(dllimport)
#endif

#ifdef NDEBUG
#undef NDEBUG
#include <assert.h>
#define NDEBUG
#else
#include <assert.h>
#endif

#include <atomic>
#include <cstdlib>
#include "../postgresql/libpq-fe.h"
#include "../../event/include/event.h"
#include "../../trader/include/trader.h"
#include "../../utility/include/timestamp.h"


namespace database::postgresql
{
	using std::any;
	using std::any_cast;
	using std::atomic;
	using std::atof;
	using std::atoi;
	using std::bind;
	using std::make_shared;
	using std::recursive_mutex;
	using std::set;
	using std::to_string;
	using View      = ::utility::object::BarOverview;
	using Contracts = ::utility::object::ContractList;
	using Contract  = ::utility::object::ContractData;
	using ReqView   = ::utility::object::BarOverviewRequest;
	using ReqHis    = ::utility::object::HistoryRequest;
	using ::trader::Bar;
	using ::trader::Bars;
	using ::trader::BaseConfig;
	using ::trader::BaseDatabase;
	using ::trader::Config;
	using ::trader::Contract;
	using ::trader::Exchange;
	using ::trader::Event;
	using ::trader::EventEngine;
	using ::trader::EventPtr;
	using ::trader::EventType;
	using ::trader::Interval;
	using ::trader::Log;
	using ::trader::BaseTrader;
	using ::trader::map;
	using ::trader::string;
	using ::trader::TimeStamp;
	using ::trader::Tick;
	using ::trader::Ticks;
	using ::trader::vector;
	using ::trader::Product;
	using ::utility::Calendar;
	using ::utility::object::EtfData;
	using ::utility::object::FutureData;
	using ::utility::object::OptionData;
	using Switch        = std::pair<std::atomic_bool, PGconn*>;

	using EtfDailyMd    = vector<EtfData*>;
	using FutureDailyMd = vector<FutureData*>;
	using OptionDailyMd = vector<OptionData*>;


	class DbBarData
	{

	};


	class DbTickData 
	{

	};


	class DATABASE_API ConfigPg : public BaseConfig
	{
	public:
		ConfigPg();
		ConfigPg(string _usr, string _pwd, string _ul, string _pt);
		ConfigPg(ConfigPg&& in)                 noexcept;
		ConfigPg(const ConfigPg& in)            noexcept;
		ConfigPg& operator=(const ConfigPg& in) noexcept;
		ConfigPg& operator=(ConfigPg&& in)      noexcept;
		~ConfigPg();

	public:
		inline string GetUser()
		{
			return *user;
		}
		inline string GetPassword()
		{
			return *password;
		};
		inline string GetUrl()
		{
			return *url;
		}
		inline string GetPort()
		{
			return *port;
		}
	private:
		string* user;
		string* password;
		string* url;
		string* port;
	};


	//extern char* PQerrorMessage(PGconn* conn);
	class DATABASE_API PostgreSql : public BaseDatabase
	{
	public:	
		PostgreSql() = delete;
		PostgreSql(BaseTrader* _td, BaseConfig* _cfg_in = nullptr);
		~PostgreSql();

		void Close                 ()                                     override;
		bool SaveFutureChain       (const Contracts&)                     override;
		bool SaveOptionChain       (const Contracts&)                     override;
		bool SaveTick              (const ReqHis* _req, const Ticks&)     override;  // Save tick data into database.
		bool SaveCalendar          (const Calendar&)                      override;  // Save calendar into database.
		bool LoadFutureChain       (const ReqHis* _req, Contracts& _out)  override;
		bool LoadOptionChain       (const ReqHis* _req, Contracts& _out)  override;
		bool LoadTick              (const ReqHis* _req, Ticks&	   _out)  override;  // Load tick data from database.
		int  DeleteBar             (const ReqHis* _req)                   override;  // Del bar data with symbol + exchange + product.
		int  DeleteTick            (const ReqHis* _req)                   override;  // Del tick data with symbol + exchange + product
		vector<View> GetBarOverview(ReqHis* _req = nullptr)               override;
		bool PurgeDatabase         (string _pwd)                          override;
		bool PreUpdateCheck        (const Contract& _contract)            override;  // check before update operation

	private:
		void LoadConfig            ()                                     override;
		void SaveConfig            ()                                     override;
		bool SaveMinute            (const ReqHis* _req, const Bars& _dat) override;
		bool SaveEtf               (const ReqHis* _req, const Bars& _dat) override;
		bool SaveFuture            (const ReqHis* _req, const Bars& _dat) override;
		bool SaveIndex             (const ReqHis* _req, const Bars& _dat) override;
		bool SaveInterest          (const ReqHis* _req, const Bars& _dat) override;
		bool SaveOption            (const ReqHis* _req, const Bars& _dat) override;
		bool LoadMinute            (const ReqHis* _req, Bars& _dat)       override;
		bool LoadEtf               (const ReqHis* _req, Bars& _dat)       override;
		bool LoadFuture            (const ReqHis* _req, Bars& _dat)       override;
		bool LoadIndex             (const ReqHis* _req, Bars& _dat)       override;
		bool LoadInterest          (const ReqHis* _req, Bars& _dat)       override;
		bool LoadOption            (const ReqHis* _req, Bars& _dat)       override;

	public:
		Contracts    FetchChains()                                        override;
		vector<View> FetchAllIntervalProduct()                            override;

	private:
		void InitDatabaseTables();
		void Connect(const string& _db, bool _gui_show = true);
		void Disconnect(const string* _db = nullptr);		

	private:
		Switch& SelectConn(const string& _db);
		Switch& SelectConn();
		set<string> FetchDatabases();
		set<string> FetchTables(const string& _db);

	private:
		bool CheckDatabase(const string& _db);
		bool CheckTable(const string& _db, const string& _tb);

		bool CreateDatabase(Switch& _conn, const string& _db);
		bool CreateTableOverview(Switch& _conn, const string& _db);
		bool CreateTable(Switch& _conn, const string& _db, const string& _tb, const Bars&			_bars);
		bool CreateTable(Switch& _conn, const string& _db, const string& _tb, const EtfDailyMd&		_bars);
		bool CreateTable(Switch& _conn, const string& _db, const string& _tb, const FutureDailyMd&	_bars);
		bool CreateTable(Switch& _conn, const string& _db, const string& _tb, const OptionDailyMd&	_bars);
		bool CreateTable(Switch& _conn, const string& _db, const string& _tb, const Ticks&			_ticks);
		bool CreateTable(Switch& _conn, const string& _db, const string& _tb, const Calendar&		_calendar);
		bool CreateTable(Switch& _conn, const string& _db, const string& _tb, const Contracts&		_infos);
		bool CreateTriggerOverview(Switch& _conn, const string& _db, const string& _tb);


		string DatabaseName(const ReqHis* _req) const;
		string TableName(const ReqHis* _req) const;
		string TableName(const Contracts& _infos, const ReqHis* _req = nullptr) const;
		string TableIndex(const string& _fsymb) const;


	private:
		bool ExecCreateSQL(Switch& _conn, string&& _user_msg, const char* _sql);
		bool ExecUpdateSQL(Switch& _conn, const string& _tb, const Bars&&			_data);
		bool ExecUpdateSQL(Switch& _conn, const string& _tb, const EtfDailyMd&&		_data);
		bool ExecUpdateSQL(Switch& _conn, const string& _tb, const FutureDailyMd&&	_data);
		bool ExecUpdateSQL(Switch& _conn, const string& _tb, const OptionDailyMd&&	_data);
		bool ExecUpdateSQL(Switch& _conn, const string& _tb, const Ticks&&			_data);
		bool ExecUpdateSQL(Switch& _conn, const string& _tb, const Calendar&&		_data);
		bool ExecUpdateSQL(Switch& _conn, const string& _tb, const Contracts&&		_data);
		bool ExecDeleteSQL(Switch& _conn, const string&& _tb);
		PGresult* Execute(Switch& _conn, const char* _sql);

	private:
		void SingleOverview(const string& db, vector<View>* _ret);


	private:
		string*						_user;
		string*						_password;
		string*						_url;
		string*						_port;
		string*						_db_default;
		string*						_db_instru;
		string*						_config_file;
		map<string, set<string>>*	_tables;
		string*						_tb_oview;
		map<string, Switch>*		_conns;
		recursive_mutex*			_mtx_conn;
		recursive_mutex*			_mtx_table;
		recursive_mutex*			_mtx_file;
	};
}


#endif
