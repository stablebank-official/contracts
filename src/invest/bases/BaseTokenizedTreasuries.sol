pragma solidity ^0.8.0;

import {ERC2771Context} from '@openzeppelin/contracts/metatx/ERC2771Context.sol';
import {IInvestment} from '../interfaces/IInvestment.sol';
import {ITokenizedYields} from '../interfaces/ITokenizedYields.sol';
import {IInvestConfig} from '../interfaces/IInvestConfig.sol';
import * as Constants from '../../Constants.sol';

abstract contract BaseTokenizedTreasuries is ITokenizedYields, ERC2771Context {
  mapping(address => bool) public validInvestmentIdentifiers;
  mapping(address => address) public investmentOwners;
  mapping(address => uint256) public unlockTimes;

  IInvestConfig public immutable configuration;

  constructor(address trustedForwarder_, address configuration_) ERC2771Context(trustedForwarder_) {
    configuration = IInvestConfig(configuration_);
  }

  function _invest(
    address token,
    address investFor,
    uint256 amount,
    uint256 duration
  ) internal virtual returns (address);

  function _withdraw(address investmentId, uint256 amount) internal virtual;

  function _extendInvestment(address investmentId, address token, uint256 amount) internal virtual;

  function invest(
    address token,
    uint256 amount,
    uint256 investmentDuration
  ) external returns (address investmentIdentifier) {
    address sender = _msgSender();
    investmentIdentifier = _invest(token, sender, amount, investmentDuration);
    validInvestmentIdentifiers[investmentIdentifier] = true;
    investmentOwners[investmentIdentifier] = sender;
    IInvestment(investmentIdentifier).initialize(sender, amount);

    uint256 unlockTime = block.timestamp + investmentDuration;

    unlockTimes[investmentIdentifier] = unlockTime;

    emit Investment(sender, investmentIdentifier, amount, unlockTime);
  }

  function extendInvestment(address investmentIdentifier, address token, uint256 amount) external {
    address sender = _msgSender();

    if (investmentOwners[investmentIdentifier] != sender) revert OnlyInvestmentOwner();

    _extendInvestment(investmentIdentifier, token, amount);
    uint256 newAmount = IInvestment(investmentIdentifier).extend(amount);

    emit InvestmentExtension(investmentIdentifier, newAmount, block.timestamp);
  }

  function withdraw(address investmentIdentifier, uint256 amount, bool forceWithdrawal) external {
    address sender = _msgSender();
    uint256 withdrawableAmount = amount;

    if (investmentOwners[investmentIdentifier] != sender) revert OnlyInvestmentOwner();
    if (!forceWithdrawal && unlockTimes[investmentIdentifier] > block.timestamp)
      revert InvestmentLockDuration();
    else if (forceWithdrawal && unlockTimes[investmentIdentifier] > block.timestamp) {
      (uint256 earlyWithdrawalPenalty, ) = configuration.getConfig();
      withdrawableAmount = (earlyWithdrawalPenalty * withdrawableAmount) / Constants.DENOM_BASE;
    }

    _withdraw(investmentIdentifier, withdrawableAmount);
  }

  function investmentMetadata(
    address investmentIdentifier
  ) external view returns (address investor, uint256 duration, address token, uint256 dueShares) {
    (investor, duration, token, dueShares) = IInvestment(investmentIdentifier).metadata();
  }
}
