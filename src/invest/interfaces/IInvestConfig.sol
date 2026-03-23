pragma solidity ^0.8.0;

interface IInvestConfig {
  function getConfig() external view returns (uint256, uint256);
}
