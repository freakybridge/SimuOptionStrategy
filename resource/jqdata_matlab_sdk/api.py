# This is api for join quant financial DataSource
from JoinQuant import *

def fetch_calendar(usr:str, pwd:str):
    try:
        auth(usr, pwd)
        calendar = get_all_trade_days()
        logout()
        return False, "", calendar

    except Exception as err:
        return True, err.args[0], None


