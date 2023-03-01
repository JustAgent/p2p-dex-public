//SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SQR is ERC20, Ownable {
  address DEX;

  modifier onlyDEX() {
    require(msg.sender == DEX, "No allowance");
    _;
  }
  event DEXChanged(address indexed newDEX);

  constructor(
    string memory _name,
    string memory _symbol,
    address _DEX
  ) ERC20(_name, _symbol) {
    DEX = _DEX;
  }

  function mint(address to, uint amount) external onlyDEX {
    _mint(to, amount);
  }

  function mintBunch(
    address[3] calldata to,
    uint256[3] calldata amount
  ) external onlyDEX {
    require(to.length == amount.length, "Wrong array length");

    for (uint i = 0; i < to.length; i++) {
      _mint(to[i], amount[i]);
    }
  }

  function setDEX(address newAddress) external onlyOwner {
    DEX = newAddress;
    emit DEXChanged(newAddress);
  }
}
