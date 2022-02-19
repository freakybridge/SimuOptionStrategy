# This is api for join quant financial DataSource
from jqdatasdk import *
from datetime import datetime
import numpy as np


# 获取日历
def fetch_all_trade_day(usr, pwd):
    try:
        auth(usr, pwd)
        res = get_all_trade_days()
        logout()
        return False, "", [__trans_datetime_2_string(res, '%Y-%m-%d')]

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
        start_trade_date = tuple(
            __trans_datetime_2_string(
                res.list_date, '%Y-%m-%d'))
        end_trade_date = tuple(
            __trans_datetime_2_string(
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

        dt = tuple(__trans_datetime_2_string(res.date, '%Y-%m-%d %H:%M'))
        open = tuple(res.open)
        high = tuple(res.high)
        low = tuple(res.low)
        close = tuple(res.close)
        vol = tuple(res.volume)
        amt = tuple(res.money)
        if fds.count('open_interest'):
            oi = tuple(res.open_interest)
        else:
            oi = tuple(np.zeros(np.size(dt)))

        return False, '', [dt, open, high, low, close, vol, amt, oi]

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
            panel=False,
            fill_paused=True)
        logout()

        dt = tuple(__trans_datetime_2_string(res.index, '%Y-%m-%d'))
        open = tuple(res.open)
        high = tuple(res.high)
        low = tuple(res.low)
        close = tuple(res.close)
        vol = tuple(res.volume)
        amt = tuple(res.money)

        return False, '', [dt, open, high, low, close, vol, amt]

    except Exception as err:
        return True, err.args[0], None


# 获取每日ETF行情
def fetch_day_etf_bar(usr, pwd, symb, dt_s, dt_e):
    try:
        auth(usr, pwd)
        md = get_price(
            symb,
            start_date=dt_s,
            end_date=dt_e,
            frequency='daily',
            fields=None,
            skip_paused=True,
            fq='pre',
            count=None,
            panel=False,
            fill_paused=True)
        nv = get_extras(
            'unit_net_value',
            symb,
            start_date=dt_s,
            end_date=dt_e,
            df=True,
            count=None)
        nv_adj = get_extras(
            'acc_net_value',
            symb,
            start_date=dt_s,
            end_date=dt_e,
            df=True,
            count=None)
        logout()

        nv.columns = ['nv']
        nv_adj.columns = ['nv_adj']
        md = md.join(nv)
        md = md.join(nv_adj)

        dt = tuple(__trans_datetime_2_string(md.index, '%Y-%m-%d'))
        nv = tuple(md.nv)
        nv_adj = tuple(md.nv_adj)
        open = tuple(md.open)
        high = tuple(md.high)
        low = tuple(md.low)
        close = tuple(md.close)
        vol = tuple(md.volume)
        amt = tuple(md.money)

        return False, '', [
            dt, nv, nv_adj, open, high, low, close, vol, amt]

    except Exception as err:
        return True, err.args[0], None


# 获取每日期货行情
def fetch_day_future_bar(usr, pwd, symb, var, dt_s, dt_e):
    try:
        auth(usr, pwd)
        md = get_price(
            symb,
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
        md['st_stock'] = 0
        for i in range(md.iloc[:, 0].size):
            q = query(
                finance.FUT_WAREHOUSE_RECEIPT.warehouse_receipt_number).filter(
                finance.FUT_WAREHOUSE_RECEIPT.underlying_code == var,
                finance.FUT_WAREHOUSE_RECEIPT.day == datetime.strftime(
                    md.index[i],
                    '%Y-%m-%d')).order_by(
                finance.FUT_WAREHOUSE_RECEIPT.warehouse_receipt_number.desc())
            md.iloc[i, 8] = finance.run_query(
                q).sum()['warehouse_receipt_number']
        settle = get_extras(
            'futures_sett_price',
            symb,
            start_date=dt_s,
            end_date=dt_e,
            df=True,
            count=None)
        logout()

        settle.columns = ['settle']
        md = md.join(settle)
        dt = tuple(__trans_datetime_2_string(md.index, '%Y-%m-%d'))
        open = tuple(md.open)
        high = tuple(md.high)
        low = tuple(md.low)
        close = tuple(md.close)
        vol = tuple(md.volume)
        amt = tuple(md.money)
        oi = tuple(md.open_interest)
        pre_settle = tuple(md.pre_close)
        settle = tuple(settle.settle)
        st_stock = tuple(md.st_stock)

        return False, '', [dt, open, high, low, close,
                           vol, amt, oi, pre_settle, settle, st_stock]

    except Exception as err:
        return True, err.args[0], None


# 获取每日期权行情
def fetch_day_option_bar(usr, pwd, symb, dt_s, dt_e):
    try:
        auth(usr, pwd)
        md = get_price(
            symb,
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
        md['pre_settle'] = 0
        md['settle'] = 0
        for i in range(md.iloc[:, 0].size):
            price = opt.run_query(
                query(
                    opt.OPT_DAILY_PRICE.pre_settle,
                    opt.OPT_DAILY_PRICE.settle_price).filter(
                    opt.OPT_DAILY_PRICE.code == symb,
                    opt.OPT_DAILY_PRICE.date == datetime.strftime(
                        md.index[i],
                        '%Y-%m-%d')).order_by(
                    opt.OPT_DAILY_PRICE.date.desc()).limit(10))
            md.iloc[i, 7] = price.pre_settle[0]
            md.iloc[i, 8] = price.settle_price[0]
        logout()

        dt = tuple(__trans_datetime_2_string(md.index, '%Y-%m-%d'))
        open = tuple(md.open)
        high = tuple(md.high)
        low = tuple(md.low)
        close = tuple(md.close)
        vol = tuple(md.volume)
        amt = tuple(md.money)
        oi = tuple(md.open_interest)
        pre_settle = tuple(md.pre_settle)
        settle = tuple(md.settle)

        return False, '', [dt, open, high, low, close,
                           vol, amt, oi, pre_settle, settle]

    except Exception as err:
        return True, err.args[0], None


# 日期转换
def __trans_datetime_2_string(in_, fmt):
    return [datetime.strftime(in_[i], fmt) for i in range(np.size(in_))]

