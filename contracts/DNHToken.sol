// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DNHToken is ERC20, Ownable {

  constructor(uint256 initialSupply) ERC20("DNHToken", "DNH") Ownable(msg.sender) {
    _mint(msg.sender, initialSupply * (10**uint256(18)));
  }

  function mint(address to, uint256 amount) public onlyOwner {
    _mint(to, amount);
  }

}