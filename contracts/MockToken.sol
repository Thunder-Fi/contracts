// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function mint(address receiver) public {
        _mint(receiver, 1000000 * (10 ** uint256(decimals())));
    }

    receive() external payable {}

    fallback() external payable {}
}
