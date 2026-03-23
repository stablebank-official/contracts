pragma solidity ^0.8.0;

interface ITokenizedYields {
  // +++++ Events +++++ //
  event Investment(
    address indexed investor,
    address indexed investmentIdentifier,
    uint256 indexed investedAmount,
    uint256 investmentLockTime
  );
  event Withdrawal(
    address indexed investmentIdentifier,
    uint256 indexed amountWithdrawn,
    uint256 indexed withdrawalTimestamp
  );
  event InvestmentExtension(
    address indexed investmentIdentifier,
    uint256 indexed newAmount,
    uint256 indexed extensionTimestamp
  );

  //+++++ State-mutating functions +++++ //
  function invest(
    address token,
    uint256 amount,
    uint256 investmentDuration
  ) external returns (address investmentIdentifier);
  function withdraw(address investmentIdentifier, uint256 amount, bool forceWithdrawal) external;
  function extendInvestment(address investmentIdentifier, address token, uint256 amount) external;

  // +++++ View functions +++++ //
  function investmentOwners(address) external view returns (address);
  function validInvestmentIdentifiers(address) external view returns (bool);
  function investmentMetadata(
    address investmentIdentifier
  ) external view returns (address investor, uint256 duration, address token, uint256 dueShares);
  function getProjectedShares(uint256 amount, uint256 duration) external view returns (uint256);

  // +++++ Errors +++++ //
  error OnlyInvestmentOwner();
  error InvestmentLockDuration();
}
