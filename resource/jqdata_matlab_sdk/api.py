# This is api for join quant financial DataSource
from jqdatasdk import *
from datetime import datetime
import numpy as np


# 获取日历
def fetch_calendar(usr, pwd):
    try:
        auth(usr, pwd)
        res = get_all_trade_days()
        logout()
        return False, "", TransDatetime2Str(res, '%Y-%m-%d')

    except Exception as err:
        return True, err.args[0], None


# 获取期权列表
def fetch_option_chain(usr, pwd, ud_symb):
    try:
        auth(usr, pwd)
        res = opt.run_query(
            query(
                opt.OPT_CONTRACT_INFO.code,
                opt.OPT_CONTRACT_INFO.name,
                opt.OPT_CONTRACT_INFO.contract_type,
                opt.OPT_CONTRACT_INFO.exercise_price,
                opt.OPT_CONTRACT_INFO.contract_unit,
                opt.OPT_CONTRACT_INFO.list_date,
                opt.OPT_CONTRACT_INFO.last_trade_date).filter(
                opt.OPT_CONTRACT_INFO.underlying_symbol == ud_symb))
        logout()

        symbols = tuple(res.code)
        sec_name = tuple(res.name)
        call_or_put = tuple(res.contract_type)
        strike = tuple(res.exercise_price)
        unit = tuple(res.contract_unit)
        start_trade_date = tuple(TransDatetime2Str(res.list_date, '%Y-%m-%d'))
        end_trade_date = tuple(
            TransDatetime2Str(
                res.last_trade_date,
                '%Y-%m-%d'))
        ins = [
            symbols,
            sec_name,
            call_or_put,
            strike,
            unit,
            start_trade_date,
            end_trade_date]
        return False, '', ins
    except Exception as err:
        return True, err.args[0], None


# 获取分钟行情
def fetch_min_bar(usr, pwd, symb, fds, freq, enddt, cnt):
    try:
        auth(usr, pwd)
        res = get_bars(
            symb,
            cnt,
            unit=freq,
            fields=fds,
            include_now=False,
            end_dt=enddt,
            fq_ref_date=None,
            df=True)
        logout()

        dt = tuple(TransDatetime2Str(res.date, '%Y-%m-%d %H:%M'))
        open = tuple(res.open)
        high = tuple(res.high)
        low = tuple(res.low)
        close = tuple(res.close)
        vol = tuple(res.volume)
        amt = tuple(res.money)
        if (fds.count('open_interest')):
            oi = tuple(res.open_interest)
        else:
            oi = tuple(np.zeros(np.size(dt)))

        return False, "False", [dt, open, high, low, close, vol, amt, oi]

    except Exception as err:
        return True, err.args[0], None


# 获取每日指数行情
def fetch_day_index_bar(usr, pwd, symb, dt_s, dt_e):
    try:
        auth(usr, pwd)
        res = get_price(
            symb,
            start_date=dt_s,
            end_date=dt_e,
            frequency='daily',
            fields=None,
            skip_paused=True,
            fq='pre',
            count=None,
            panel=True,
            fill_paused=True)
        logout()

        dt = tuple(TransDatetime2Str(res.index, '%Y-%m-%d'))
        open = tuple(res.open)
        high = tuple(res.high)
        low = tuple(res.low)
        close = tuple(res.close)
        vol = tuple(res.volume)
        amt = tuple(res.money)

        return False, "False", [dt, open, high, low, close, vol, amt]

    except Exception as err:
        return True, err.args[0], None

# 获取每日ETF行情
def fetch_day_etf_bar(usr, pwd, symb, dt_s, dt_e):
    try:
        # 行情
        auth(usr, pwd)
        res = get_price(
            symb,
            start_date=dt_s,
            end_date=dt_e,
            frequency='daily',
            fields=None,
            skip_paused=True,
            fq='pre',
            count=None,
            panel=True,
            fill_paused=True)
        dt = tuple(TransDatetime2Str(res.index, '%Y-%m-%d'))
        open = tuple(res.open)
        high = tuple(res.high)
        low = tuple(res.low)
        close = tuple(res.close)
        vol = tuple(res.volume)
        amt = tuple(res.money)

        res = get_extras('unit_net_value', symb, start_date=dt_s, end_date=dt_e, df=True, count=None)
        res = get_extras('unit_net_value', symb, start_date=dt_s, end_date=dt_e, df=True, count=None)
        logout()

        return False, "False", [dt, open, high, low, close, vol, amt]

    except Exception as err:
        return True, err.args[0], None

# 日期转换
def TransDatetime2Str(in_, fmt):
    return [datetime.strftime(in_[i], fmt) for i in range(np.size(in_))]


if __name__ == '__main__':
    a1, b1, c1 = fetch_day_index_bar(
        '18162753893', '1101BXue', '000300.XSHG', '2022-01-02', '2022-01-15')
    a2, b2, c3 = fetch_day_etf_bar(
        '18162753893', '1101BXue', '510050.XSHG', '2022-01-02', '2022-01-15')
    pass
    # fetch_min_bar('18162753893', '1101BXue', '510050.XSHG', ['date', 'open', 'high', 'low', 'close', 'volume', 'money'], '5m', '2022-02-17 15:30:00', 50)
    # fetch_min_bar('18162753893',
    #               '1101BXue',
    #               '10003852.XSHG',
    #               ['date',
    #                'open',
    #                'high',
    #                'low',
    #                'close',
    #                'volume',
    #                'money',
    #                'open_interest'],
    #               '5m',
    #               '2022-02-17 15:30:00',
    #               50)
    # fetch_calendar('18162753893', '1101BXue')
