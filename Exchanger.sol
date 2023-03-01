//SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./SQR.sol";

contract Exchanger is Ownable, ReentrancyGuard {
  using SafeERC20 for IERC20;

  SQR public sqr;
  uint256 public counter;

  event CryptoTransferedToContract(
    uint256 indexed id,
    address indexed sender,
    address indexed receiver,
    IERC20 token,
    uint256 amount
  );
  event OfferFinished(
    uint256 indexed id,
    address indexed receiver,
    IERC20 token,
    uint256 amount
  );

  // Using nonReentrant to prevent possible errors when transferring to the owner's contract
  function transferCrypto(
    IERC20 token,
    address receiver,
    uint256 amount
  ) external onlyOwner nonReentrant {
    require(msg.sender != receiver, "Msg.sender shouldn't be receiver");
    require(amount != 0);

    uint256 beforeTransfer = token.balanceOf(address(this));
    token.safeTransferFrom(msg.sender, address(this), amount);
    uint256 afterTransfer = token.balanceOf(address(this));
    require(afterTransfer >= beforeTransfer + amount, "Transfer went wrong");

    emit CryptoTransferedToContract(
      counter,
      msg.sender,
      receiver,
      token,
      afterTransfer - beforeTransfer
    );
    counter++;
  }

  function submitFiatTransfer(
    uint256 orderId,
    IERC20 token,
    address sender,
    address receiver,
    uint256 amount
  ) external onlyOwner nonReentrant {
    token.safeTransfer(receiver, amount);
    sqr.mintBunch(
      [sender, receiver, address(this)],
      [amount / 10, amount / 10, amount / 20]
    );

    emit OfferFinished(orderId, receiver, token, amount);
  }

  function setAddressSQR(address newAddress) external onlyOwner {
    sqr = SQR(newAddress);
  }
}
