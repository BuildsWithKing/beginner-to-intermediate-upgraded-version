//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {UserStorage} from "../src/UserStorage.sol";

contract DeployUserStorage is Script {
    function run() external {
        vm.startBroadcast();
        new UserStorage();
        vm.stopBroadcast();
    }
}
