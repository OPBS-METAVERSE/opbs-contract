import csv

with open('opbs-snapshot/balance.csv', 'r') as f:
    reader = csv.reader(f)
    balances = 0
    addr = 0
    for i , row in enumerate(reader):
        target_address = row[0]
        balance = row[1]
        if int(balance) > 1000000000000:
            balances += int(balance)
            addr += 1
            print("Addresses:", target_address , "Balances: ", balance )
print("total:", i, "total balances:", balances, "addr of 1", addr)
