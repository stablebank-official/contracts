pragma solidity ^0.8.0;

interface IInvestment {
  function initialize(address owner, uint256 amount) external;
  function extend(uint256 amount) external returns (uint256);
  function metadata()
    external
    view
    returns (address investor, uint256 duration, address token, uint256 dueShares);
}
