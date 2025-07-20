//SPDX-License-Identifier: MIT

/// @title Advanced UserStorage.
/// @author MichealKing (@BuildsWithKing).
/// @date created 17th of july, 2025.

/// @notice Basic smart contract that store, update, retrieve and delete user's name, age, gender, email address, and skill.
/// @dev Owned by the contract deployer.

pragma solidity ^0.8.18;

/// @dev Thrown when a user tries to perform only owner operation.
error __USERSTORAGE_UNAUTHORIZED_ACCESS();

/// @dev Thrown when owner/user inputs/use the zero address.
error __USERSTORAGE_INVALID_ADDRESS();

/// @dev Thrown when an existing user tries to register.
error __USERSTORAGE_EXISTING_USER();

/// @dev Thrown for blank name field.
error __USERSTORAGE_NAME_CANNOT_BE_EMPTY();

/// @dev Thrown for blank age.
error __USERSTORAGE_AGE_CANNOT_BE_ZERO();

/// @dev Thrown for blank gender field.
error __USERSTORAGE_GENDER_CANNOT_BE_EMPTY();

/// @dev Thrown for blank email address field.
error __USERSTORAGE_EMAIL_ADDRESS_CANNOT_BE_EMPTY();

/// @dev Thrown for blank skill field.
error __USERSTORAGE_SKILL_CANNOT_BE_EMPTY();

/// @dev Thrown when owner tries to withdraw ETH when balance is zero.
error __USERSTORAGE_INSUFFICIENT_BALANCE();

/// @dev Thrown when owner's withdrawal fails.
error __USERSTORAGE_ETH_WITHDRAWAL_FAILED();

contract UserStorage {
    /// @notice Contract deployer's address.
    address immutable i_Owner;

    /// @notice Groups user's data.
    struct Data {
        string name;
        uint8 age;
        string gender;
        string emailAddress;
        string skill;
        uint256 timestamp;
    }

    /// @dev Maps user's address to their data.
    mapping(address => Data) internal userData;

    /// @notice Emits NewUser.
    /// @param userAddress New user address.
    /// @param name New user name.
    /// @param age New user age.
    /// @param gender New user gender.
    /// @param skill New user skill.
    event NewUser(
        address indexed userAddress,
        string name,
        uint8 indexed age,
        string gender,
        string skill
    );

    /// @notice Emits UpdatedData.
    /// @param userAddress The user's address.
    /// @param newName The user's new name.
    /// @param newAge The user's new age.
    /// @param newGender The user's new gender.
    /// @param newSkill The user's new skill.
    event UpdatedData(
        address indexed userAddress,
        string newName,
        uint8 indexed newAge,
        string newGender,
        string newSkill
    );

    /// @notice Emits UserDataDeleted.
    /// @param userAddress The user's address.
    event UserDataDeleted(address indexed userAddress);

    /// @notice Emits EthReceived.
    /// @param senderAddress The sender's address.
    /// @param ethAmount The amount of ETH received.
    event EthReceived(address indexed senderAddress, uint256 ethAmount);

    /// @notice Sets contract deployer as owner.
    constructor() {
        i_Owner = msg.sender;
    }

    /// @dev Restricts access to only contract deployer.
    modifier onlyOwner() {
        if (msg.sender != i_Owner) revert __USERSTORAGE_UNAUTHORIZED_ACCESS();
        _;
    }

    /// @notice Stores users data.
    /// @param _name The user's name.
    /// @param _age The user's age.
    /// @param _gender The user's gender.
    /// @param _emailAddress The user's email address.
    /// @param _skill The user's skill.
    function store(
        string memory _name,
        uint8 _age,
        string memory _gender,
        string memory _emailAddress,
        string memory _skill
    ) public {
        if (msg.sender == address(0)) revert __USERSTORAGE_INVALID_ADDRESS();
        if (bytes(userData[msg.sender].name).length > 0)
            revert __USERSTORAGE_EXISTING_USER();
        if (bytes(_name).length <= 0)
            revert __USERSTORAGE_NAME_CANNOT_BE_EMPTY();
        if (_age <= 0) revert __USERSTORAGE_AGE_CANNOT_BE_ZERO();
        if (bytes(_gender).length <= 0)
            revert __USERSTORAGE_GENDER_CANNOT_BE_EMPTY();
        if (bytes(_emailAddress).length <= 0)
            revert __USERSTORAGE_EMAIL_ADDRESS_CANNOT_BE_EMPTY();
        if (bytes(_skill).length <= 0)
            revert __USERSTORAGE_SKILL_CANNOT_BE_EMPTY();
        userData[msg.sender] = Data(
            _name,
            _age,
            _gender,
            _emailAddress,
            _skill,
            block.timestamp
        );
        emit NewUser(msg.sender, _name, _age, _gender, _skill);
    }

    /// @notice Returns user's data.
    /// @return user's name, age, gender, email address, and skill.
    function getMyData()
        public
        view
        returns (
            string memory,
            uint8,
            string memory,
            string memory,
            string memory
        )
    {
        Data memory data = userData[msg.sender];
        return (
            data.name,
            data.age,
            data.gender,
            data.emailAddress,
            data.skill
        );
    }

    /// @notice Returns user's skill.
    /// @return user's skill.
    function getMySkill() public view returns (string memory) {
        Data memory data = userData[msg.sender];
        return (data.skill);
    }

    /// @notice Updates user's data.
    /// @param _newName The user's new name.
    /// @param _newAge The user's new age.
    /// @param _newGender The user's new gender.
    /// @param _newEmailAddress The user's new email address.
    /// @param _newSkill The user's new skill.
    function updateMyData(
        string memory _newName,
        uint8 _newAge,
        string memory _newGender,
        string memory _newEmailAddress,
        string memory _newSkill
    ) public {
        if (bytes(_newName).length <= 0)
            revert __USERSTORAGE_NAME_CANNOT_BE_EMPTY();
        if (_newAge <= 0) revert __USERSTORAGE_AGE_CANNOT_BE_ZERO();
        if (bytes(_newGender).length <= 0)
            revert __USERSTORAGE_GENDER_CANNOT_BE_EMPTY();
        if (bytes(_newEmailAddress).length <= 0)
            revert __USERSTORAGE_EMAIL_ADDRESS_CANNOT_BE_EMPTY();
        if (bytes(_newSkill).length <= 0)
            revert __USERSTORAGE_SKILL_CANNOT_BE_EMPTY();
        userData[msg.sender] = Data(
            _newName,
            _newAge,
            _newGender,
            _newEmailAddress,
            _newSkill,
            block.timestamp
        );
        emit UpdatedData(msg.sender, _newName, _newAge, _newGender, _newSkill);
    }

    /// @notice Deletes user's data.
    function deleteMyData() public {
        delete userData[msg.sender];
        emit UserDataDeleted(msg.sender);
    }

    /// @notice Returns owner's address.
    /// @return The owner's address.
    function getOwner() public view returns (address) {
        return i_Owner;
    }

    /// @notice Only owner can returns users data.
    /// @param _userAddress The user's address.
    /// @return User's name, age, gender, email address, skill.
    function getUserData(
        address _userAddress
    )
        external
        view
        onlyOwner
        returns (
            string memory,
            uint8,
            string memory,
            string memory,
            string memory
        )
    {
        if (_userAddress == address(0)) revert __USERSTORAGE_INVALID_ADDRESS();
        Data memory data = userData[_userAddress];
        return (
            data.name,
            data.age,
            data.gender,
            data.emailAddress,
            data.skill
        );
    }

    /// @notice Only owner can delete users data.
    /// @param _userAddress The user's address.
    function deleteUserData(address _userAddress) external onlyOwner {
        if (_userAddress == address(0)) revert __USERSTORAGE_INVALID_ADDRESS();
        delete userData[_userAddress];
        emit UserDataDeleted(_userAddress);
    }

    /// @notice Only owner can withdraw ETH.
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) revert __USERSTORAGE_INSUFFICIENT_BALANCE();
        (bool success, ) = payable(i_Owner).call{value: balance}("");
        if (!success) revert __USERSTORAGE_ETH_WITHDRAWAL_FAILED();
    }

    /// @notice Handles ETH transfer with no calldata.
    receive() external payable {
        emit EthReceived(msg.sender, msg.value);
    }

    /// @notice Handles ETH transfer with calldata.
    fallback() external payable {
        emit EthReceived(msg.sender, msg.value);
    }
}
