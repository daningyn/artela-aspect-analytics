// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DARTToken is ERC20, Ownable {

  constructor(uint256 initialSupply) ERC20("DARTToken", "dART") Ownable(msg.sender) {
    _mint(msg.sender, initialSupply * (10**uint256(18)));
  }

  function mint(address to, uint256 amount) public onlyOwner {
    _mint(to, amount);
  }

}