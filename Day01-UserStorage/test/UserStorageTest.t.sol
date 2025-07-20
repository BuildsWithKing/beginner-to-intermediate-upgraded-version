// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {UserStorage} from "../src/UserStorage.sol";

contract UserStorageTest is Test {
    UserStorage userStorage;

    address owner = address(this);
    address zero = address(0);
    address user1 = address(0x1);
    address user2 = address(0x2);
    uint256 constant ETH_AMOUNT = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    // This is the setup function that runs before every other test.
    function setUp() public {
        userStorage = new UserStorage();
        vm.label(owner, "Owner");
        vm.label(user1, "USER1");
        vm.label(user2, "USER2");
        // Labels Owner, user1 and user2.
        vm.deal(user2, STARTING_BALANCE);
        // This gives user 2 starting balance of 10 ETH.
    }

    // Test for Store and GetMyData function.
    function testStoreAndGetMyData() public {
        vm.prank(user1); // User1 stores data
        userStorage.store("Michealking", 23, "Male", "buildswithking@gmail.com", "Solidity");
        // User1 stores data

        vm.prank(user1);
        (string memory name, uint8 age, string memory gender, string memory emailAddress, string memory skill) =
            userStorage.getMyData();
        // User1 gets Data

        assertEq(name, "Michealking");
        assertEq(age, 23);
        assertEq(gender, "Male");
        assertEq(emailAddress, "buildswithking@gmail.com");
        assertEq(skill, "Solidity");
        // AssertEq Ensure each input is equal to the other, fails if not.
    }

    // Test for existing user can't register.
    function testExistingUserCannotRegister() public {
        vm.prank(user1);
        userStorage.store("Michealking", 23, "Male", "buildswithking@gmail.com", "Solidity");

        vm.expectRevert();
        vm.prank(user1);
        userStorage.store("Michealking", 23, "Male", "buildswithking@gmail.com", "Solidity");
    }

    function testCannotStoreWithoutData() public {
        vm.expectRevert();
        vm.prank(user2);
        userStorage.store("", 0, "", "", "");
    }

    // Test for getMySkill function.
    function testGetMySkill() public {
        vm.prank(user1);
        userStorage.store("Michealking", 23, "Male", "buildswithking@gmail.com", "Solidity");

        vm.prank(user1);
        (string memory skill) = userStorage.getMySkill();

        assertEq(skill, "Solidity");
    }

    // Test for updateMyData Function.
    function testUpdateMyData() public {
        vm.prank(user1);
        userStorage.store("Michealking", 23, "Male", "buildswithking@gmail.com", "solidity");

        vm.prank(user1);
        userStorage.updateMyData("Solidityking", 25, "Male", "buildswithking@gmail.com", "Advanced Solidity");

        vm.prank(user1);
        (string memory name, uint8 age, string memory gender, string memory emailAddress, string memory skill) =
            userStorage.getMyData();

        assertEq(name, "Solidityking");
        assertEq(age, 25);
        assertEq(gender, "Male");
        assertEq(emailAddress, "buildswithking@gmail.com");
        assertEq(skill, "Advanced Solidity");
    }

    // Test for deleteMyData function.
    function testDeleteMyData() public {
        vm.prank(user1);
        userStorage.store("Michealking", 23, "Male", "buildswithking@gmail.com", "solidity");

        vm.prank(user1);
        userStorage.deleteMyData();

        vm.prank(user1);
        (string memory name, uint8 age, string memory gender, string memory emailAddress, string memory skill) =
            userStorage.getMyData();

        assertEq(bytes(name).length, 0);
        assertEq(age, 0);
        assertEq(bytes(gender).length, 0);
        assertEq(bytes(emailAddress).length, 0);
        assertEq(bytes(skill).length, 0);
    }

    // Test for getOwner function.
    function testGetOwner() public {
        address contractOwner = userStorage.getOwner();
        assertEq(contractOwner, owner);
    }

    // Test for custom error: __USERSTORAGE_UNAUTHORIZED_ACCESS.
    function testUnauthorizedAccess() public {
        vm.prank(user1);
        userStorage.store("Michealking", 23, "Male", "buildswithking@gmail.com", "solidity");

        vm.expectRevert();
        vm.prank(user1);
        userStorage.deleteUserData(user1);
    }

    // Test for custom error: __USERSTORAGE_INVALID_ADDRESS.
    function testInvalidAddress() public {
        vm.expectRevert();
        vm.prank(zero);
        userStorage.store("hacker", 29, "Male", "hacker@gmail.com", "fraud");
    }

    // Test for custom error: __USERSTORAGE_INSUFFICIENT_BALANCE.
    function testInsufficientBalance() public {
        vm.expectRevert();
        vm.prank(owner);
        userStorage.withdrawETH();
    }

    // Test for getUserData function.
    function testOnlyOwnerCanGetUserData() public {
        vm.prank(user1);
        userStorage.store("Michealking", 23, "Male", "buildswithking@gmail.com", "Solidity");

        vm.expectRevert();
        vm.prank(user1);
        userStorage.getUserData(user1);
    }

    // Test for deleteUserData function.
    function testOnlyOwnerCanDeleteUserData() public {
        vm.prank(user1);
        userStorage.store("Michealking", 23, "Male", "buildswithking@gmail.com", "solidity");

        vm.expectRevert();
        vm.prank(user1);
        userStorage.deleteUserData(user1);

        vm.prank(owner);
        userStorage.deleteUserData(user1);

        vm.prank(user1);
        (string memory name, uint8 age, string memory gender, string memory emailAddress, string memory skill) =
            userStorage.getMyData();

        assertEq(bytes(name).length, 0);
        assertEq(age, 0);
        assertEq(bytes(gender).length, 0);
        assertEq(bytes(emailAddress).length, 0);
        assertEq(bytes(skill).length, 0);
    }

    // Test for withdrawETH function.
    function testonlyOwnerCanWithdrawETH() public {
        vm.expectRevert(); // This expects the next line to revert.
        vm.prank(user2);
        userStorage.withdrawETH();
    }

    // Test for succesful ETH withdrawal by owner.
    function testOnlyOwnerCanSuccessfullyWithdrawETH() public {
        vm.prank(owner);
        (bool success,) = address(userStorage).call{value: ETH_AMOUNT}("");
        assertTrue(success);
        assertEq(address(userStorage).balance, ETH_AMOUNT);

        uint256 ownerBalanceBefore = address(this).balance;

        vm.prank(owner);
        userStorage.withdrawETH();

        assertEq(address(userStorage).balance, 0);
        assertGt(address(this).balance, ownerBalanceBefore);
    }

    // Test for receive function.
    function testReceiveETH() public {
        vm.prank(user2);
        (bool success,) = address(userStorage).call{value: ETH_AMOUNT}("");
        assertTrue(success);
        assertEq(address(userStorage).balance, ETH_AMOUNT);
    }

    // Test for fallback function.
    function testFallbackETH() public {
        vm.prank(user2);
        (bool success,) = address(userStorage).call{value: ETH_AMOUNT}(hex"abcd");
        assertTrue(success);
        assertEq(address(userStorage).balance, ETH_AMOUNT);
    }

    // Handles Eth deposits without calldata.
    receive() external payable {}
}
