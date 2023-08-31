// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {TwitterBot} from "../src/TwitterBot.sol";

contract Deploy is Script {
    TwitterBot public tb;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        tb = new TwitterBot();
        console.log("twitter bot deployed: ", address(tb));

        vm.stopBroadcast();
    }
}
