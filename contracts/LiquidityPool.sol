// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LiquidityPool is Ownable {

  using Math for uint256;
  using SafeERC20 for IERC20;

  modifier safeAdd(uint256 a, uint256 b) {
    (bool success, uint256 result) = a.tryAdd(b);
    require(success, 'Addition overflow');
    _;
  }

  modifier safeSub(uint256 a, uint256 b) {
    (bool success, uint256 result) = a.trySub(b);
    require(success, 'Subtraction underflow');
    _;
  }

  modifier safeMul(uint256 a, uint256 b) {
    (bool success, uint256 result) = a.tryMul(b);
    require(success, 'Multiple error');
    _;
  }

  modifier safeDiv(uint256 a, uint256 b) {
    (bool success, uint256 result) = a.tryDiv(b);
    require(success, 'Division by 0');
    _;
  }
  
  IERC20 public dART;
  IERC20 public DNH;
  
  uint256 public totalSupply;

  mapping(address => uint256) public balances;

  event Deposit(address indexed provider, uint256 amountdART, uint256 amountDNH);
  event Withdraw(address indexed provider, uint256 amountdART, uint256 amountDNH);

  constructor(address _dART, address _DNH) Ownable(msg.sender) {
    require(_dART != address(0), 'token dART cannot be 0');
    require(_DNH != address(0), 'token DNH cannot be 0');

    dART = IERC20(_dART);
    DNH = IERC20(_DNH);
  }

  function deposit(uint256 amountdART, uint256 amountDNH) public {
    require(amountdART > 0 || amountDNH > 0, 'At least one of both tokens need to be greater than 0');

    dART.safeTransferFrom(msg.sender, address(this), amountdART);
    DNH.safeTransferFrom(msg.sender, address(this), amountDNH);
    uint256 liquidityMinted = _calculateLiquidityAmount(amountdART, amountDNH);

    totalSupply += liquidityMinted;
    balances[msg.sender] += liquidityMinted;

    emit Deposit(msg.sender, amountdART, amountDNH); // submit event deposit of sender
  }

  function withdraw(uint256 liquidity) public {
    require(liquidity > 0, 'Liquidity amount should be greater than 0');

    uint256 amountdART = sfDiv(sfMul(liquidity, dART.balanceOf(address(this))), totalSupply);

    uint256 amountDNH = sfDiv(sfMul(liquidity, DNH.balanceOf(address(this))), totalSupply);

    totalSupply = sfSub(totalSupply, liquidity);

    balances[msg.sender] = sfSub(balances[msg.sender], liquidity);

    dART.safeTransfer(msg.sender, amountdART);
    DNH.safeTransfer(msg.sender, amountDNH);

    emit Withdraw(msg.sender, amountdART, amountDNH);
  }

  function _calculateLiquidityAmount(uint256 amountdART, uint256 amountDNH) internal view returns (uint256) {
    uint256 totalLiquidity = totalSupply;

    if (totalLiquidity == 0) {
      return Math.sqrt(amountdART * amountDNH);
    }

    uint256 baseLiquidity = Math.min(
        (amountdART * totalLiquidity) / dART.balanceOf(address(this)),
        (amountDNH * totalLiquidity) / DNH.balanceOf(address(this))
    );

    return baseLiquidity;
  }

  function swap(IERC20 tokenIn, uint256 amountIn) external {
    require(amountIn > 0, 'Amount in must be greater than zero');

    tokenIn.safeTransferFrom(msg.sender, address(this), amountIn);

    IERC20 tokenOut = address(tokenIn) == address(dART) ? DNH : dART;

    uint256 amountOut = _calculateSwapAmount(tokenIn, amountIn, tokenOut);

    tokenOut.safeTransfer(msg.sender, amountOut);
  }

  function _calculateSwapAmount(IERC20 tokenIn, uint256 amountIn, IERC20 tokenOut) internal view returns (uint256) {
      // calculate ratio of pool
      uint256 poolRatio = tokenIn.balanceOf(address(this)) * 1e18 / tokenOut.balanceOf(address(this));

      // calculate amount out
      uint256 amountOut = amountIn * poolRatio / 1e18;

      return amountOut;
  }

  function sfAdd(uint256 a, uint256 b) internal pure safeAdd(a, b) returns (uint256) {
    return a + b;
  }

  function sfSub(uint256 a, uint256 b) internal pure safeSub(a, b) returns (uint256) {
    return a - b;
  }

  function sfMul(uint256 a, uint256 b) internal pure safeMul(a, b) returns (uint256) {
    return a * b;
  }

  function sfDiv(uint256 a, uint256 b) internal pure safeDiv(a, b) returns (uint256) {
    return a / b;
  }

}