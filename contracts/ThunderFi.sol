// Author : br0wnD3v
// ThunderFi : Invoicing protocol built for the Arbitrum ecosystem.

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

struct Agreement {
    bool active;
    bool accepted;
    bool settled;
    string agreementURL; //  ipfs://QmXeDSDdqSgxKZx6g62vJ4pD6AmbWWbzFNpdG9KdJXJggj
    address paymentToken;
    uint amount; // 500, 50,1000 etc
    uint creationTimestamp;
    uint expiryTimestamp;
    address seller; // The one issuing the invoice.
    address purchaser; // The one receiving the invoice.
}

error ThunderFi_UserInvalid();
error ThunderFi_AgreementIdInvalid();

contract ThunderFi is Context, Ownable {
    uint private idCounter = 1;
    string public baseURI = "https://gateway.lighthouse.storage/ipfs/";

    mapping(uint => Agreement) public agreements;
    mapping(address => uint[]) private addressToContracts;
    mapping(address => bool) public whitelisted;

    /// @dev STATUS -
    //  0 : Inactive
    //  1 : Active
    //  2 : Accepted
    //  3 : Settled
    event AgreementStatusUpdate(
        address indexed seller,
        address indexed purchaser,
        uint timestamp,
        uint expiry,
        uint status
    );

    constructor() Ownable(_msgSender()) {}

    modifier isWhitelisted(address _user) {
        if (whitelisted[_user]) revert ThunderFi_UserInvalid();
        _;
    }
    modifier validAgreement(uint _id) {
        if (_id >= idCounter) revert ThunderFi_AgreementIdInvalid();
        _;
    }

    function init() public {
        whitelisted[_msgSender()] = true;
    }

    function createAgreement(
        string memory _agreementCID,
        address _purchaser,
        address _paymentToken,
        uint _amount,
        uint _expiry
    ) external isWhitelisted(_msgSender()) {
        uint idToSet = idCounter;

        Agreement memory agreementObject = Agreement(
            true,
            false,
            false,
            _agreementCID,
            _paymentToken,
            _amount,
            block.timestamp,
            _expiry,
            _msgSender(),
            _purchaser
        );

        agreements[idToSet] = agreementObject;
        addressToContracts[_msgSender()].push(idToSet);
        addressToContracts[_purchaser].push(idToSet);

        ++idCounter;

        emit AgreementStatusUpdate(
            _msgSender(),
            _purchaser,
            block.timestamp,
            _expiry,
            1
        );
    }

    function getAgreement(
        uint _id
    ) external view validAgreement(_id) returns (Agreement memory) {
        return agreements[_id];
    }
}
