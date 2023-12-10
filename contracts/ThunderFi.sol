// Author : br0wnD3v
// ThunderFi : Invoicing protocol built for the Arbitrum ecosystem.

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

struct Agreement {
    uint status;
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
error ThunderFi_CallerNotTheSeller();
error ThunderFi_CallerNotThePurchaser();
error ThunderFi_InsufficientApproval();

contract ThunderFi is Context, Ownable {
    uint private idCounter = 1;
    string public baseURI = "https://gateway.lighthouse.storage/ipfs/";

    IERC20 public immutable TXN_TOKEN;
    uint public immutable PLATFORM_FEE;

    mapping(uint => Agreement) public agreements;
    // [seller, purchaser]
    mapping(uint => address[2]) private agreeementToPartiesInvolved;
    mapping(address => bool) public whitelisted;

    /// @dev STATUS -
    //  0 : Inactive
    //  1 : Created
    //  2 : Rescinded
    //  3 : Rejected
    //  4 : Settled
    event AgreementStatusUpdate(
        address indexed seller,
        address indexed purchaser,
        uint timestamp,
        uint status
    );

    constructor(address _txnToken, uint _decimals) Ownable(_msgSender()) {
        TXN_TOKEN = IERC20(_txnToken);
        // USDC, fee = 0.1 USDC
        PLATFORM_FEE = 10 ** _decimals / 10;
    }

    modifier isWhitelisted(address _user) {
        if (!whitelisted[_user]) revert ThunderFi_UserInvalid();
        _;
    }

    modifier isSeller(uint _id, address _user) {
        if (agreeementToPartiesInvolved[_id][0] != _user)
            revert ThunderFi_CallerNotTheSeller();
        _;
    }
    modifier isPurchaser(uint _id, address _user) {
        if (agreeementToPartiesInvolved[_id][1] != _user)
            revert ThunderFi_CallerNotThePurchaser();
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
        if (TXN_TOKEN.allowance(_msgSender(), address(this)) < PLATFORM_FEE)
            revert ThunderFi_InsufficientApproval();

        TXN_TOKEN.transferFrom(_msgSender(), address(this), PLATFORM_FEE);

        uint idToSet = idCounter;

        Agreement memory agreementObject = Agreement(
            1,
            _agreementCID,
            _paymentToken,
            _amount,
            block.timestamp,
            _expiry,
            _msgSender(),
            _purchaser
        );

        agreements[idToSet] = agreementObject;
        agreeementToPartiesInvolved[idToSet] = [_msgSender(), _purchaser];

        ++idCounter;

        emit AgreementStatusUpdate(
            _msgSender(),
            _purchaser,
            block.timestamp,
            1
        );
    }

    function rescindAgreement(
        uint _id
    ) external validAgreement(_id) isSeller(_id, _msgSender()) {
        Agreement storage agreementObject = agreements[_id];
        address toEmitPurchaser = agreementObject.purchaser;

        agreementObject.status = 2;
        agreementObject.agreementURL = "";
        agreementObject.paymentToken = address(0);
        agreementObject.amount = 0;
        agreementObject.expiryTimestamp = 2 ** 256 - 1;
        agreementObject.seller = address(0);
        agreementObject.purchaser = address(0);

        agreeementToPartiesInvolved[_id] = [address(0), address(0)];

        emit AgreementStatusUpdate(
            _msgSender(),
            toEmitPurchaser,
            block.timestamp,
            2
        );
    }

    function rejectAgreement(uint _id) external isPurchaser(_id, _msgSender()) {
        Agreement storage agreementObject = agreements[_id];
        address toEmitSeller = agreementObject.seller;

        agreementObject.status = 3;
        agreementObject.agreementURL = "";
        agreementObject.paymentToken = address(0);
        agreementObject.amount = 0;
        agreementObject.expiryTimestamp = 2 ** 256 - 1;
        agreementObject.seller = address(0);
        agreementObject.purchaser = address(0);

        agreeementToPartiesInvolved[_id] = [address(0), address(0)];

        emit AgreementStatusUpdate(
            toEmitSeller,
            _msgSender(),
            block.timestamp,
            3
        );
    }

    /// During settlement, a fee of 0.01% of the owed amount is deducted.
    function settleAgreement(uint _id) external isPurchaser(_id, _msgSender()) {
        Agreement storage agreementObject = agreements[_id];

        address _seller = agreementObject.seller;
        uint amount = agreementObject.amount;
        IERC20 paymentContract = IERC20(agreementObject.paymentToken);

        if (paymentContract.allowance(_msgSender(), address(this)) != amount)
            revert ThunderFi_InsufficientApproval();

        uint afterDeductionAmount = amount - amount / 10000;
        TXN_TOKEN.transfer(_seller, afterDeductionAmount);

        agreementObject.status = 4;

        emit AgreementStatusUpdate(_seller, _msgSender(), block.timestamp, 4);
    }

    // ========

    function getAgreement(
        uint _id
    ) external view validAgreement(_id) returns (Agreement memory) {
        return agreements[_id];
    }
}
