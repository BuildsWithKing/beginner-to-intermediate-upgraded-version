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

    event NewUser(
        address indexed userAddress,
        string name,
        uint8 indexed age,
        string gender,
        string skill
    );

    event UpdatedData(
        address indexed userAddress,
        string newName,
        uint8 indexed newAge,
        string newGender,
        string newSkill
    );

    event UserDataDeleted(address indexed userAddress);

    event EthReceived(address indexed senderAddress, uint256 ethAmount);

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

    // Test to check if constructor sets owner.
    function testConstructorSetsOwner() public {
        assertEq(userStorage.getOwner(), owner);
    }

    // Test reverts if zero address tries to register.
    function testZeroAddressCannotReegister() public {
        vm.expectRevert();
        vm.prank(zero);
        userStorage.store("hacker", 29, "Male", "hacker@gmail.com", "fraud");
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

    // Test for empty name field.
    function testEmptyNameReverts() public {
        vm.expectRevert();
        vm.prank(user1);
        userStorage.store("", 23, "Male", "buildswithking@gmail.com", "Solidity");
    }

    // Test for zero Age.
    function testZeroAgeReverts() public {
        vm.expectRevert();
        vm.prank(user1);
        userStorage.store("Michealking", 0, "Male", "buildswithking@gmail.com", "Solidity");
    }

    // Test for empty gender field.
    function testEmptyGenderReverts() public {
        vm.expectRevert();
        vm.prank(user1);
        userStorage.store("Michealking", 23, "", "buildswithking@gmail.com", "Solidity");
    }

    // Test for empty email field.
    function testEmptyEmailReverts() public {
        vm.expectRevert();
        vm.prank(user1);
        userStorage.store("Michealking", 23, "Male", "", "Solidity");
    }

    // Test for empty skill field.
    function testEmptySkillReverts() public {
        vm.expectRevert();
        vm.prank(user1);
        userStorage.store("Michealking", 23, "Male", "buildswithking@gmail.com", "");
    }

    // Test for new user event.
    function testStoreEmitsNewUserEvent() public {
        vm.startPrank(user1);
        vm.expectEmit(); //indexed field true.
        emit NewUser(user1, "Michealking", 23, "Male", "Solidity");
        userStorage.store("Michealking", 23, "Male", "buildswithking@gmail.com", "Solidity");
        vm.stopPrank();
    }

    // Test for existing user can't register.
    function testExistingUserCannotRegister() public {
        vm.prank(user1);
        userStorage.store("Michealking", 23, "Male", "buildswithking@gmail.com", "Solidity");

        vm.expectRevert();
        vm.prank(user1);
        userStorage.store("Michealking", 23, "Male", "buildswithking@gmail.com", "Solidity");
    }

    // Test for users can't store with data.
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
    // Test for zero address can't access user data.
    function testZeroAddressCannotGetUserData() public {
        vm.expectRevert();
        vm.prank(zero);
        userStorage.getUserData(user1);
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

    // Test for empty name field.
    function testEmptyUserNewNameReverts() public {
        vm.expectRevert();
        vm.prank(user1);
        userStorage.updateMyData("", 25, "Male", "buildswithking@gmail.com", "Advanced Solidity");
    }

    // Test for zero Age.
    function testZeroUserNewAgeReverts() public {
        vm.expectRevert();
        vm.prank(user1);
        userStorage.updateMyData("Solidityking", 0, "Male", "buildswithking@gmail.com", "Advanced Solidity");
    }

    // Test for empty gender field.
    function testEmptyUserNewGenderReverts() public {
        vm.expectRevert();
        vm.prank(user1);
        userStorage.updateMyData("Solidityking", 25, "", "buildswithking@gmail.com", "Advanced Solidity");
    }

    // Test for empty email field.
    function testEmptyUserNewEmailReverts() public {
        vm.expectRevert();
        vm.prank(user1);
        userStorage.updateMyData("Solidityking", 25, "Male", "", "Advanced Solidity");
    }

    // Test for empty skill field.
    function testEmptyUserNewSkillReverts() public {
        vm.expectRevert();
        vm.prank(user1);
        userStorage.updateMyData("Solidityking", 25, "Male", "buildswithking@gmail.com", "");
    }

    // Test for event: Updated Data
    function testUpdateEmitsUpdateData() public {
        vm.startPrank(user1);
        vm.expectEmit();
        emit UpdatedData(user1, "Solidityking", 25, "Male", "Advanced Solidity");
        userStorage.updateMyData("Solidityking", 25, "Male", "buildswithking@gmail.com", "Advanced Solidity");
        vm.stopPrank();
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

    // Test for event: UserDataDeleted.
    function testDeleteMyDataEmitsEvent() public {
        vm.startPrank(user1);
        vm.expectEmit();
        emit UserDataDeleted(user1);
        userStorage.deleteMyData();
        vm.stopPrank();
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

    // This test ensures only owner can get users data.
    function testOwnerCanGetUserData() public {
        vm.prank(user1);
        userStorage.store("Michealking", 23, "Male", "buildswithking@gmail.com", "Solidity");

        vm.prank(owner);
        userStorage.getUserData(user1);
    }

    // Test reverts if owner tries to get the data of a zero address user.
    function testGetUserDataWithZeroAddressReverts() public {
        vm.expectRevert();
        vm.prank(owner);
        userStorage.getUserData(address(0));
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

    // Test reverts if zero address tries to delete user data.
    function testDeleteUserDataWithZeroAddressReverts() public {
        vm.expectRevert();
        vm.prank(owner);
        userStorage.deleteUserData(address(0));
    }

     // Test for event: UserDataDeleted.
    function testOwnerDeletesUserDataEmitsEvent() public {
        vm.startPrank(owner);
        vm.expectEmit();
        emit UserDataDeleted(user1);
        userStorage.deleteUserData(user1);
        vm.stopPrank();
    }
    
    // Test to ensure only only can call restricted functions.
    function testOnlyOwnerCanCallRestrictedFunction() public {
        // Fails when non-owner tries
        vm.expectRevert();
        vm.prank(user2);
        userStorage.withdrawETH();

        vm.prank(owner);
        (bool success,) = address(userStorage).call{value: ETH_AMOUNT}(hex"abcd");
        assertTrue(success);

        //permits only owner.
        vm.prank(owner);
        userStorage.withdrawETH();
    }

    // Test for withdrawETH function.
    function testonlyOwnerCanWithdrawETH() public {
        vm.expectRevert(); // This expects the next line to revert.
        vm.prank(user2);
        userStorage.withdrawETH();
    }

    function testfailedOwnerETHWithdrawal() public {
        vm.expectRevert(); // Reverts due to insufficient balance.
        vm.prank(owner);
        userStorage.withdrawETH();
    }

    // Test for succesful ETH withdrawal by owner.
    function testOnlyOwnerCanSuccessfullyWithdrawETH() public {
        vm.prank(user2);
        (bool success,) = address(userStorage).call{value: ETH_AMOUNT}("");
        assertTrue(success);
        assertEq(address(userStorage).balance, ETH_AMOUNT);

        uint256 ownerBalanceBefore = address(this).balance;

        vm.prank(owner);
        userStorage.withdrawETH();

        assertEq(address(userStorage).balance, 0);
        assertGt(address(this).balance, ownerBalanceBefore);
    }

    // Test for increment in owner's balance after withdrawal.
    function testOwnerBalanceIncreasesAfterWithdrawal() public {
        vm.prank(user2);
        (bool success,) = address(userStorage).call{value:ETH_AMOUNT}("");
        assertTrue(success);

        vm.prank(owner);
        userStorage.withdrawETH();

        assertGt(address(this).balance, address(userStorage).balance);
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

    // Test for event: EthReceived(receive).
    function testETHReceivedEventEmits() public {
        vm.startPrank(user2);
        vm.expectEmit();
        emit EthReceived(user2, ETH_AMOUNT);
        (bool success,) = address(userStorage).call{value: ETH_AMOUNT}("");
        assertTrue(success);
        vm.stopPrank();
    }

    // Test for event: EthReceived(fallback).
    function testFallBackEmitsETHReceivedEvent() public {
        vm.startPrank(user2);
        vm.expectEmit();
        emit EthReceived(user2, ETH_AMOUNT);
        (bool success,) = address(userStorage).call{value: ETH_AMOUNT}(hex"abcd");
        assertTrue(success);
        vm.stopPrank();
    }
    // Test to ensure fallback triggers.
    function testFallBakisTriggered() public {
        vm.prank(user2);
        (bool success,) = address (userStorage).call(abi.encodePacked("invalidData"));
        assertTrue(success);
    }

    // Handles Eth deposits without calldata.
    receive() external payable {}
}