import json
from web3 import Web3, HTTPProvider
from config import config
from tools.txs import sign_tx, get_address_from_key

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
# starting nonce
nonce = w3.eth.get_transaction_count(address)
amt = w3.to_wei(10000, 'wei')
price = w3.to_wei(0.001, 'ether')

place_orders_tx = contract_opbs.functions.placeOrder(amt, price).build_transaction(
    {
        'type': '0x2',
        'gas': config['GAS'],
        'chainId': config['CHAIN_ID'],                            
        'maxFeePerGas': w3.to_wei(0.00000001, 'gwei'),  # required for dynamic fee transactions
        'maxPriorityFeePerGas': w3.to_wei(0.000000001, 'gwei'),  # required for dynamic fee transactions
        'nonce': nonce,
    }
)

signed_tx = sign_tx(place_orders_tx, pk)
tx_hash = w3.eth.send_raw_transaction(signed_tx.rawTransaction)
# tx_hash = w3.to_hex(w3.sha3(signed_tx.rawTransaction))
print(f'tx hash for batch: https://opbnbscan.com/tx/{tx_hash.hex()}')
# Wait for the transaction to be mined
transaction_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
print("status", transaction_receipt.status)
