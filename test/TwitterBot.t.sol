// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {TwitterBot} from "../src/TwitterBot.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

contract Initial is Test {
    TwitterBot tb;
    IERC20 shia;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), 18033341);
        tb = new TwitterBot();
        shia = IERC20(0x43D7E65B8fF49698D9550a7F315c87E67344FB59);
    }
}

contract Buy is Initial {
    function test_buy() public {
        vm.startPrank(address(2));
        deal(address(2), 1000 ether);

        tb.buyTokens_v2Router{value: 1 ether}(address(shia), 2534471196320);

        console.log("token balance: ", shia.balanceOf(address(2)));

        vm.stopPrank();
    }
}

contract Sell is Initial {
    function test_sell() public {
        vm.startPrank(address(2));
        deal(address(2), 1000 ether);

        tb.buyTokens_v2Router{value: 1 ether}(address(shia), 2534471196320);
        uint256 balance = shia.balanceOf(address(2));
        shia.approve(address(tb), balance);
        tb.sellTokens_v2Router(address(shia), balance, 0);

        vm.stopPrank();
    }
}
