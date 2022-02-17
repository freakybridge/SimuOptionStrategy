# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.
from JoinQuant import *

def print_hi(name):
    # Use a breakpoint in the code line below to debug your script.
    print(f'Hi, {name}')  # Press Ctrl+F8 to toggle the breakpoint.


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    jq = JoinQuant('18162753893', '1101BXue')
    [a, b, c] = jq.FetchCalendar()
    print_hi(b)

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
