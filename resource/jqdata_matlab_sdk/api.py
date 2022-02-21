# This is api for join quant financial DataSource
from jqdatasdk import *
import numpy as np
import pandas as pd
import re


# 获取日历
def fetch_all_trade_day(usr, pwd):
    try:
        auth(usr, pwd)
        res = get_all_trade_days()
        logout()
        return False, "", [__trans_datatime_2_string(res, '%Y-%m-%d')]

    except Exception as err:
        return True, err.args[0], None


# 获取期权列表
def fetch_option_chain(usr, pwd, ud_symb):
    try:
        # 读取
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

        # 输出
        if res.iloc[:, 0].size:
            symbols = tuple(res.code)
            sec_name = tuple(res.name)
            call_or_put = tuple(res.contract_type)
            strike = tuple(res.exercise_price)
            unit = tuple(res.contract_unit)
            start_trade_date = tuple(
                __trans_datatime_2_string(
                    res.list_date, '%Y-%m-%d'))
            end_trade_date = tuple(
                __trans_datatime_2_string(
                    res.last_trade_date, '%Y-%m-%d'))

        else:
            symbols = tuple()
            sec_name = tuple()
            call_or_put = tuple()
            strike = tuple()
            unit = tuple()
            start_trade_date = tuple()
            end_trade_date = tuple()
        return False, '', [symbols, sec_name, call_or_put,
                           strike, unit, start_trade_date, end_trade_date]

    except Exception as err:
        return True, err.args[0], None


# 获取单个期权最后交易日
def fetch_option_last_tradedate(usr, pwd, symb, exc):
    try:
        auth(usr, pwd)
        res = opt.run_query(query(opt.OPT_CONTRACT_INFO.last_trade_date).filter(opt.OPT_CONTRACT_INFO.code == ('%s.%s') % (symb, exc)))
        logout()
        return False, "", [[res.last_trade_date[0].strftime('%Y-%m-%d')]]

    except Exception as err:
        return True, err.args[0], None

# 获取分钟行情
def fetch_min_bar(usr, pwd, symb, exc, fds, freq, enddt, cnt):
    try:
        # 读取
        auth(usr, pwd)
        res = get_bars(
            ('%s.%s') % (symb, exc),
            cnt,
            unit=freq,
            fields=fds,
            include_now=False,
            end_dt=enddt,
            fq_ref_date=None,
            df=True)
        logout()

        # 输出
        if res.iloc[:, 0].size:
            dt = tuple(__trans_datatime_2_string(res.date, '%Y-%m-%d %H:%M'))
            po = tuple(res.open)
            ph = tuple(res.high)
            pl = tuple(res.low)
            pc = tuple(res.close)
            vol = tuple(res.volume)
            amt = tuple(res.money)
            if fds.count('open_interest'):
                oi = tuple(res.open_interest)
            else:
                oi = tuple(np.zeros(np.size(dt)))

        else:
            dt = tuple()
            po = tuple()
            ph = tuple()
            pl = tuple()
            pc = tuple()
            vol = tuple()
            amt = tuple()
            oi = tuple()
        return False, '', [dt, po, ph, pl, pc, vol, amt, oi]

    except Exception as err:
        return True, err.args[0], None


# 获取每日指数行情
def fetch_day_index_bar(usr, pwd, symb, exc, dt_s, dt_e):
    try:
        auth(usr, pwd)
        res = get_price(
            ('%s.%s') % (symb, exc),
            start_date=dt_s,
            end_date=dt_e,
            frequency='daily',
            fields=None,
            skip_paused=True,
            fq='pre',
            count=None,
            panel=False,
            fill_paused=True)
        logout()

        # 输出
        if res.iloc[:, 0].size:
            dt = tuple(res.index.strftime('%Y-%m-%d'))
            po = tuple(res.open)
            ph = tuple(res.high)
            pl = tuple(res.low)
            pc = tuple(res.close)
            vol = tuple(res.volume)
            amt = tuple(res.money)
        else:
            dt = tuple()
            po = tuple()
            ph = tuple()
            pl = tuple()
            pc = tuple()
            vol = tuple()
            amt = tuple()

        return False, '', [dt, po, ph, pl, pc, vol, amt]

    except Exception as err:
        return True, err.args[0], None


# 获取每日ETF行情
def fetch_day_etf_bar(usr, pwd, symb, exc, dt_s, dt_e):
    try:
        # 读取
        auth(usr, pwd)
        md = get_price(
            ('%s.%s') % (symb, exc),
            start_date=dt_s,
            end_date=dt_e,
            frequency='daily',
            fields=None,
            skip_paused=True,
            fq='pre',
            count=None,
            panel=False,
            fill_paused=True)

        if md.iloc[:, 0].size == 0:
            return False, '', [[], [], [], [], [], [], [], [], []]

        nv = finance.run_query(
            query(
                finance.FUND_NET_VALUE.day,
                finance.FUND_NET_VALUE.net_value,
                finance.FUND_NET_VALUE.refactor_net_value).filter(
                finance.FUND_NET_VALUE.code == symb,
                finance.FUND_NET_VALUE.day >= md[:1].index[0].strftime('%Y-%m-%d'),
                finance.FUND_NET_VALUE.day <= md[-1:].index[0].strftime('%Y-%m-%d')
            ).order_by(finance.FUND_NET_VALUE.day.asc()).limit(50000))
        logout()

        # 合并
        md['day'] = md.index.date
        md['datetime'] = md.index.strftime('%Y-%m-%d')
        md = md.merge(nv, on='day')

        # 输出
        dt = tuple(md['datetime'])
        nv = tuple(md.net_value)
        nv_adj = tuple(md.refactor_net_value)
        po = tuple(md.open)
        ph = tuple(md.high)
        pl = tuple(md.low)
        pc = tuple(md.close)
        vol = tuple(md.volume)
        amt = tuple(md.money)

        return False, '', [dt, nv, nv_adj, po, ph, pl, pc, vol, amt]

    except Exception as err:
        return True, err.args[0], None


# 获取每日期货行情
def fetch_day_future_bar(usr, pwd, symb, exc, dt_s, dt_e):
    try:
        # 读取
        auth(usr, pwd)
        md = get_price(
            ('%s.%s') % (symb, exc),
            start_date=dt_s,
            end_date=dt_e,
            frequency='daily',
            fields=[
                'open',
                'high',
                'low',
                'close',
                'volume',
                'money',
                'open_interest',
                'pre_close'],
            skip_paused=True,
            fq='pre',
            count=None,
            panel=False,
            fill_paused=True)

        if md.iloc[:, 0].size == 0:
            return False, '', [[], [], [], [], [], [], [], [], [], [], []]

        var = symb[0 : re.search("\d", symb).start()]
        if var.upper() == 'IF' or var.upper() == 'IH' or var.upper() == 'IC' or var.upper() == 'T' or var.upper() == 'TF':
            st_stock = pd.DataFrame({'day': md.index.date, 'warehouse_receipt_number': np.zeros(md.iloc[:, 0].size)})
        else :
            st_stock = finance.run_query(
                query(finance.FUT_WAREHOUSE_RECEIPT.day,
                      finance.FUT_WAREHOUSE_RECEIPT.warehouse_receipt_number).filter(
                    finance.FUT_WAREHOUSE_RECEIPT.underlying_code == var,
                    finance.FUT_WAREHOUSE_RECEIPT.day >= md[:1].index[0].strftime('%Y-%m-%d'),
                    finance.FUT_WAREHOUSE_RECEIPT.day <= md[-1:].index[0].strftime('%Y-%m-%d'))
                .order_by(finance.FUT_WAREHOUSE_RECEIPT.day.asc()))
            st_stock = st_stock.groupby('day').sum()

        settle = get_extras(
            'futures_sett_price',
            ('%s.%s') % (symb, exc),
            start_date=dt_s,
            end_date=dt_e,
            df=True,
            count=None)
        settle.columns = ['settle']
        logout()

        # 合并
        md = md.join(settle)
        md['day'] = md.index.date
        md['datetime'] = md.index.strftime('%Y-%m-%d')
        md = md.merge(st_stock, on='day')

        # 输出
        dt = tuple(md.datetime)
        po = tuple(md.open)
        ph = tuple(md.high)
        pl = tuple(md.low)
        pc = tuple(md.close)
        vol = tuple(md.volume)
        amt = tuple(md.money)
        oi = tuple(md.open_interest)
        pre_settle = tuple(md.pre_close)
        settle = tuple(md.settle)
        st_stock = tuple(md.warehouse_receipt_number)

        return False, '', [dt, po, ph, pl, pc, vol,
                           amt, oi, pre_settle, settle, st_stock]

    except Exception as err:
        return True, err.args[0], None


# 获取每日期权行情
def fetch_day_option_bar(usr, pwd, symb, exc, dt_s, dt_e):
    try:
        # 获取
        auth(usr, pwd)
        md = get_price(
            ('%s.%s') % (symb, exc),
            start_date=dt_s,
            end_date=dt_e,
            frequency='daily',
            fields=[
                'open',
                'high',
                'low',
                'close',
                'volume',
                'money',
                'open_interest'],
            skip_paused=True,
            fq='pre',
            count=None,
            panel=False,
            fill_paused=True)

        if md.iloc[:, 0].size == 0:
            return False, '', [[], [], [], [], [], [], [], [], [], []]

        price = opt.run_query(
            query(
                opt.OPT_DAILY_PRICE.date,
                opt.OPT_DAILY_PRICE.pre_settle,
                opt.OPT_DAILY_PRICE.settle_price).filter(
                opt.OPT_DAILY_PRICE.code == ('%s.%s') % (symb, exc),
                opt.OPT_DAILY_PRICE.date >= md[:1].index[0].strftime('%Y-%m-%d'),
                opt.OPT_DAILY_PRICE.date <= md[-1:].index[0].strftime('%Y-%m-%d')
            ).order_by(
                opt.OPT_DAILY_PRICE.date.asc()).limit(5000))
        logout()

        # 合并
        md['date'] = md.index.date
        md['datetime'] = md.index.strftime('%Y-%m-%d')
        md = md.merge(price, on='date')

        # 输出
        dt = tuple(md.datetime)
        po = tuple(md.open)
        ph = tuple(md.high)
        pl = tuple(md.low)
        pc = tuple(md.close)
        vol = tuple(md.volume)
        amt = tuple(md.money)
        oi = tuple(md.open_interest)
        pre_settle = tuple(md.pre_settle)
        settle = tuple(md.settle_price)

        return False, '', [dt, po, ph, pl, pc, vol, amt, oi, pre_settle, settle]

    except Exception as err:
        return True, err.args[0], None


# 转换格式
def __trans_datatime_2_string(in_, fmt):
    return [in_[i].strftime(fmt) for i in range(np.size(in_))]


# debug
if __name__ == '__main__':

    a1, b1, c1 = fetch_all_trade_day('18162753893', '1101BXue')

    a2, b2, c2 = fetch_day_index_bar(
        '18162753893', '1101BXue', '000300', 'XSHG', '2021-01-01 09:30:00', '2021-02-15 09:30:00')

    a3, b3, c3 = fetch_day_etf_bar(
        '18162753893', '1101BXue', '510050', 'XSHG', '2021-01-01 09:30:00', '2021-02-15 09:30:00')

    a4, b4, c4 = fetch_day_future_bar(
        '18162753893', '1101BXue', 'CU2206', 'XSGE', '2022-01-01 09:30:00', '2022-02-15 09:30:00')

    a5, b5, c5 = fetch_day_option_bar(
        '18162753893', '1101BXue', '10003852', 'XSHG', '2022-01-01 09:30:00', '2022-02-15 09:30:00')

    a6, b6, c6 = fetch_min_bar(
        '18162753893', '1101BXue', '10003852', 'XSHG',
        ['date', 'open', 'high', 'low', 'close', 'volume', 'money', 'open_interest'],
        '5m', '2022-02-15 09:30:00', 50)

    a7, b7, c7 = fetch_option_chain('18162753893', '1101BXue', '510050.XSHG')

    a8, b8, c8 = fetch_option_last_tradedate('18162753893', '1101BXue', '10003852', 'XSHG')
    pass
