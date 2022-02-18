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

        calendar = []
        for i in range(np.size(res)):
            calendar.append(datetime.strftime(res[i], '%Y-%m-%d'))

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
        end_trade_date = tuple(TransDatetime2Str(res.last_trade_date, '%Y-%m-%d'))
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


def test_print(in_):
    print(in_)


# 日期转换
def TransDatetime2Str(in_, fmt):
    ret = []
    for i in range(np.size(in_)):
        ret.append(datetime.strftime(in_[i], fmt))
    return ret


if __name__ == '__main__':
    fetch_option_chain('18162753893', '1101BXue', '510050.XSHG')
