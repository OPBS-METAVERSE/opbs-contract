// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "node_modules/openzeppelin-contracts/utils/EnumerableSet.sol";

contract OPBS_METAVERSE {
    string tick = 'OPBS METAVERSE';
    mapping(address => uint256) private balances;
    using EnumerableSet for EnumerableSet.UintSet;

    EnumerableSet.UintSet private activeOrdersSet;
    EnumerableSet.UintSet private allOrdersSet;

    address admin = address(0x2aF8A5cF409C338f01A79758211646727692135E);
    address market_fee_address = address(0x2aF8A5cF409C338f01A79758211646727692135E);

    struct Order {
        address trader;
        uint256 amount;
        uint256 price;
        bool active;
    }

    mapping(uint256 => Order) public orders;

    event OrderPlaced(uint256 orderId, address trader, uint256 amount, string tick, uint256 price);
    event OrderCancelled(uint256 orderId);
    event OrderExecuted(uint256 orderId);
    event Transferd(address from, address to,uint256 amt, string tick);


    function setBalance(address _address, uint256 _balance) private {
        balances[_address] = _balance;
    }

    function setAdmin() public {
        admin = address(0x2024);
    }

    function getAdmin() public view returns (address){
        return admin;
    }

    function batchMappingBalances(address[] calldata _addresses, uint256[] calldata _balances) public returns (bool) {
        require(msg.sender == address(admin),"You need use the admin address.");
        require(_addresses.length > 0, '.');
        require(_balances.length > 0, 'x');
        require(_addresses.length == _balances.length, "x");
        for (uint256 i = 0; i <= _addresses.length - 1; i++) {
            setBalance(address(_addresses[i]), _balances[i]);
        }
        return true;
    }
    function getBalance(address _address) public view returns (uint256) {
        return balances[_address];
    }

    function burnBalance(uint256 _amt) public returns (bool){
        require(_amt >= 0, "you are sweet babay");
        address burn_from = msg.sender;
        uint256 balance = getBalance(burn_from);
        require(balance - _amt >= 0, "x");
        setBalance(burn_from, balance - _amt);
        return true;
    }

    function transferBalance(address _to, uint256 _amt) public returns (bool) {
        require(_amt >= 0, "F");
        address from = msg.sender;
        uint256 balance_from = getBalance(from);
        uint256 balance_to = getBalance(_to);
        require(balance_from > 0, "U");
        require(balance_from - _amt >=0, "C");
        setBalance(from, balance_from -= _amt);
        setBalance(_to, balance_to += _amt);

        emit Transferd(from, _to, _amt, tick);
        return true;
    }


    function placeOrder(uint256 _amount, uint256 _price) public {
        // 获取 msg.sender 的opbs 数量
        address trader = msg.sender;
        uint256 trader_amt = getBalance(trader);
        require(_amount > 0,"K");
        require(trader_amt >= _amount,"U");
        Order memory newOrder = Order(msg.sender, _amount, _price, true);
        uint256 orderId = uint256(keccak256(abi.encodePacked(msg.sender, _amount, _price, block.timestamp))); // Generate a unique order ID
        orders[orderId] = newOrder;
        // 将订单添加到活动订单activeOrdersSet中
        activeOrdersSet.add(orderId);
        allOrdersSet.add(orderId);
        // 提交订单时减少 opbs数量
        setBalance(trader, trader_amt -= _amount);

        emit OrderPlaced(orderId, msg.sender, _amount, tick, _price);
    }

    function cancelOrder(uint256 _orderId) public {
        // 获取 msg.sender 的opbs 数量
        address trader = msg.sender;
        uint256 trader_amt = getBalance(trader);

        require(orders[_orderId].trader == msg.sender, "You can only cancel your own order");
        require(orders[_orderId].active, "Order is already cancelled or executed");
        uint256 amt = orders[_orderId].amount;
        // 将订单移除活动订单activeOrdersSet
        activeOrdersSet.remove(_orderId);
        orders[_orderId].active = false;
        // 取消订单时 增加数量

        setBalance(trader, trader_amt += amt);

        emit OrderCancelled(_orderId);
    }

    function getAllOrder() public view returns (uint256[] memory) {
        uint256[] memory elements = new uint256[](allOrdersSet.length());
        for (uint256 i = 0; i < allOrdersSet.length(); i++) {
            elements[i] = allOrdersSet.at(i);
        }
        return elements;
    }

    function _transferFees(uint256 _orderId) internal {
        uint256 order_value = orders[_orderId].price;
        address trader = orders[_orderId].trader;
        // uint256 market_fee =  317888800000000;
        uint256 market_fee =  order_value * 200 / 100000;

        (bool market_fee_transfer_success,) = market_fee_address.call{value: market_fee}("11111111");
        if (!market_fee_transfer_success) {
            revert("transfer fee failed");
        }
        uint256 seller_value = order_value - market_fee;

        (bool trade_transfer_success,) = trader.call{value: seller_value}("");
        if (!trade_transfer_success) {
            revert("transfer value failed");
        }
    }

    function executeOrder(uint256 _orderId) public payable {
        require(orders[_orderId].active, "Order is cancelled or executed");
        // msg.value == order.price
        require(msg.value >= 0, "c n m");
        require(msg.value == orders[_orderId].price, "value not match");
        uint256 amt = orders[_orderId].amount;
        uint256 sender_pre_amt = getBalance(msg.sender);

        _transferFees(_orderId);
        // 将订单移除到活动订单activeOrdersSet中
        activeOrdersSet.remove(_orderId);
        orders[_orderId].active = false;

        // 订单成交时 增加数量

        setBalance(msg.sender, sender_pre_amt += amt);


        emit OrderExecuted(_orderId);
    }

    function getOrder(uint256 _orderId) public view returns (address, uint256, uint256, bool) {
        Order memory order = orders[_orderId];
        return (order.trader, order.amount, order.price, order.active);
    }


    function getActiveOrders() public view returns (uint256[] memory) {
        uint256[] memory elements = new uint256[](activeOrdersSet.length());
        for (uint256 i = 0; i < activeOrdersSet.length(); i++) {
            elements[i] = activeOrdersSet.at(i);
        }
        return elements;
    }

    function getUserActiveOrders(address _address) public view returns (uint256[] memory) {
        uint256[] memory userActiveOrders = new uint256[](activeOrdersSet.length()); 
        uint256 k = 0;
        for (uint256 i = 0; i < activeOrdersSet.length(); i++) {
            uint256 orderId = activeOrdersSet.at(i);
            (address trader, uint256 amt, uint256 price, bool active) = getOrder(orderId);
            if (trader == _address){
                userActiveOrders[k] = orderId;
                k += 1;
            }
        }
        return userActiveOrders;
    }

    function getUserAllOrders(address _address) public view returns (uint256[] memory) {
        uint256[] memory userAllOrders = new uint256[](allOrdersSet.length()); 
        uint256 k = 0;
        for (uint256 i = 0; i < allOrdersSet.length(); i++) {
            uint256 orderId = allOrdersSet.at(i);
            (address trader, uint256 amt, uint256 price, bool active) = getOrder(orderId);
            if (trader == _address){
                userAllOrders[k] = orderId;
                k += 1;
            }
        }
        return userAllOrders;
    }

}