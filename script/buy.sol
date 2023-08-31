// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {TwitterBot} from "../src/TwitterBot.sol";

interface ITwitterBot {
    function buyTokens_v2Router(address tokenAddress, uint256 amountOutMin) external payable;
}

contract Buy is Script {
    ITwitterBot public tb;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        tb = ITwitterBot(0x38628490c3043E5D0bbB26d5a0a62fC77342e9d5);
        tb.buyTokens_v2Router{value: 1000000000000000000}(0x43D7E65B8fF49698D9550a7F315c87E67344FB59, 2534471196320);
        console.log("tokens bought");

        vm.stopBroadcast();
    }
}
