// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe{
    using PriceConverter for uint256;
    mapping (address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public i_Owner;
    uint256 public constant MINIMUM_USD = 5*10**18;
    constructor(){
        i_Owner = msg.sender;
    }
    function fund() public payable{
        require(msg.value.getConversionRate() >= MINIMUM_USD, "You need to spent more ETH");
        addressToAmountFunded[msg.sender] +=msg.value;
        funders.push(msg.sender);
    } 
    modifier onlyOwner(){
        if(msg.sender != i_Owner) revert NotOwner();
        _;
    }
    function withdraw() public onlyOwner{
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        (bool callSuccess,)=payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}
