pragma solidity ^0.8.0;

import {IInvestConfig} from './interfaces/IInvestConfig.sol';

struct Configuration {
  uint256 quickWithdrawalPenalty;
  uint256 investmentFee;
}

contract InvestConfig is IInvestConfig {
  uint256 QUICK_WITHDRAWAL_PENALTY = 700; // 7%
  uint256 INVESTMENT_FEE = 90; // 0.9%

  function setConfig(Configuration memory config) external {
    QUICK_WITHDRAWAL_PENALTY = config.quickWithdrawalPenalty;
    INVESTMENT_FEE = config.investmentFee;
  }

  function getConfig() external view returns (uint256, uint256) {
    return (QUICK_WITHDRAWAL_PENALTY, INVESTMENT_FEE);
  }
}
