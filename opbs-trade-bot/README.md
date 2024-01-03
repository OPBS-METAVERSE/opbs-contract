# opbs-metaverse-python3-trader
open source trader bot for opbs-metavers use Python3

# How to use 
1. install python3.8
    - download miniconda:
    ```
    https://docs.conda.io/projects/miniconda/en/latest/miniconda-install.html
    ```
    - install miniconda 
    - open a terminal in this folder
    - run this commands
    ```
    conda create -n opbs-bot python=3.8
    ```
2. install web3.py
    ```
    pip install web3
    ```
3. set private key in the config.py
    get private key from metamask && paste to config.py
4. run script with
```
python3 check_and_excute_orders.py
```
Or
```
python3 place_orders.py
```

5. Place order
    - amt = w3.to_wei(10000, 'wei') : this line in place_order.py replace 10000 to the amount you want to sell.
    - price = w3.to_wei(0.001, 'ether'): price is the total BNB of this order. price = amt * per_opbs

##
opbs metaverse's data open and store on chain. every market or builder can use this data and contract build market or dapp or anything. 

LET'S BUILD && MAKE OPBS TO THE MOON.
