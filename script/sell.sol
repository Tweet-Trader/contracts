// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {TwitterBot} from "../src/TwitterBot.sol";

interface ITwitterBot {
    function sellTokens_v2Router(address tokenAddress, uint256 amountIn, uint256 amountOutMin) external payable;
}

contract Sell is Script {
    ITwitterBot public tb;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        tb = ITwitterBot(0x38628490c3043E5D0bbB26d5a0a62fC77342e9d5);
        tb.sellTokens_v2Router(0x43D7E65B8fF49698D9550a7F315c87E67344FB59, 3 ether, 640437202468886);
        console.log("tokens sold");

        vm.stopBroadcast();
    }
}
