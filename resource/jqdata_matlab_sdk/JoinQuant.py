# -*- coding: UTF-8 -*-
from jqdatasdk import *


class JoinQuant:

    def __init__(self, ur: str, pwd: str):
        self.__user = ur
        self.__password = pwd

    def __del__(self):
        self.logout()

    def logout(self):
        logout()

    def fetch_calendar(self):
        try:
            auth(self.__user, self.__password)
            calendar = get_all_trade_days()
            logout()
            return False, "", calendar

        except Exception as err:
            return True, err.args[0], None

    def __is_connect(self):
        return is_auth()
