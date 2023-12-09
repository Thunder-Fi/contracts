// Author : br0wnD3v
// ThunderFi : Invoicing protocol built for the Arbitrum ecosystem.

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

struct Agreement {
    bool active;
    bool accepted;
    bool settled;
    string agreementURL; //  ipfs://QmXeDSDdqSgxKZx6g62vJ4pD6AmbWWbzFNpdG9KdJXJggj
    address paymentToken; // 0x60e1773636cf5e4a227d9ac24f20feca034ee25a - wFIL
    uint amount; // 500, 50,1000 etc
    uint creationTimestamp;
    uint expiryTimestamp;
    address seller; // The one issuing the invoice.
    address purchaser; // The one receiving the invoice.
}

contract ThunderFi is Context, Ownable, ERC721URIStorage {
    uint256 private contractIds;
    string public baseURI = "https://elementalblockchain.infura-ipfs.io/ipfs/";

    mapping(uint => Agreement) public agreements;
    mapping(address => uint256[]) private addressToContracts;
    mapping(address => bool) public whitelisted;

    constructor() ERC721("ThunderFi", "THDFI") Ownable(_msgSender()) {}

    function isWhitelisted(address _address) public view returns (bool) {
        return whitelisted[_address];
    }
}
