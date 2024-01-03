import json
from web3 import Web3, HTTPProvider
from config import config
from tools.txs import sign_tx, get_address_from_key
import time

HTTPProvider = HTTPProvider(config['PROVIDER'])
w3 = Web3(HTTPProvider)
# contract
opbs_json = open(file='opbs-contracts/opbs-metaverse.json')
# abi = json.loads(airdropper_json.read())['abi']
abi = json.loads(opbs_json.read())

contract_opbs = w3.eth.contract(address=config['CONTRACT_ADDRESS'], abi=abi)
# keys
pk = config['PRIVATE_KEY']
address = get_address_from_key(pk)

while True:
    nonce = w3.eth.get_transaction_count(address)

    active_orders = contract_opbs.functions.getActiveOrders().call()
    if len(active_orders) >= 1:
        print(active_orders[0])
        for i in range(0, len(active_orders)):
            order_info = contract_opbs.functions.getOrder(active_orders[i]).call()
            print(order_info[0], order_info[1], order_info[2], order_info[3])
            # excute orders.
            excute_orders = contract_opbs.functions.executeOrder(active_orders[i]).build_transaction(
                {
                    'type': '0x2',
                    'gas': config['GAS'],
                    'chainId': config['CHAIN_ID'],                            
                    'maxFeePerGas': w3.to_wei(0.00000001, 'gwei'),  # required for dynamic fee transactions
                    'maxPriorityFeePerGas': w3.to_wei(0.000000001, 'gwei'),  # required for dynamic fee transactions
                    'nonce': nonce,
                    'value': order_info[2],
                }
            )

            signed_tx = sign_tx(excute_orders, pk)
            try:
                tx_hash = w3.eth.send_raw_transaction(signed_tx.rawTransaction)
                print(f'tx hash for batch: https://opbnbscan.com/tx/{tx_hash.hex()}')
            except Exception as e:
                print(e)

            # Wait for the transaction to be mined
            transaction_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
            print("status", transaction_receipt.status)
    else:
        print("No orders.............................................")
    time.sleep(3)
