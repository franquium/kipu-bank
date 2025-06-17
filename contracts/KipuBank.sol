// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title KipuBank
 * @author franquium
 * @notice Smart contract for securely depositing and withdrawing ETH with restrictions
 */
contract KipuBank {

    /********************************************* 
    *               State Variables
    **********************************************/

    /** @notice Threshold for the maximum withdrawal per transaction (in wei)
    */
    uint256 public immutable withdrawalThreshold;

    /**
     * @notice Total limit of deposits
     */
    uint256 public immutable bankCap;

    /**
     * @notice Total amount currently deposited in the contract
     */
    uint256 public totalDeposited;

    /**
     * @notice Counter of the total deposits made in the contract
     */
    uint256 public depositCount;

    /**
     * @notice Counter of the total withdrawls made in the contract
     */
    uint256 public withdrawalCount;


    /******************************************** 
    *               Mappings
    *********************************************/

    /**
     * @notice Maps each user address to their ETH balance in the vault
     */
    mapping(address => uint256) private userVaults;


    /********************************************** 
    *               Events
    *********************************************/

     /**
     * @notice Emitted after a successful deposit
     * @param user The address of the user who made the deposit
     * @param amount The amount of ETH deposited (in wei)
     */
    event DepositSuccessful(address indexed user, uint256 amount);


    /**
     * @notice Emitted after a successful withdrawal
     * @param user The address of the user who made the withdrawal
     * @param amount The amount of ETH withdrawn (in wei)
     */
    event WithdrawalSuccessful(address indexed user, uint256 amount);


    /********************************************** 
    *               Custom Errors
    *********************************************/

    /// @notice Reverts if the transaction amount is zero
    error InvalidAmount();

    /// @notice Reverts if a deposit would cause the total balance to exceed the bank's max capacity
    error BankCapExceeded();

    /// @notice Reverts if a withdrawal amount exceeds the allowed threshold per transaction
    error WithdrawalThresholdExceeded();

    /// @notice Reverts if a user tries to withdraw more funds than they have in their vault
    error InsufficientBalance();

    /// @notice Reverts if the native ETH transfer fails
    error TransferFailed();

    /// @notice Reverts when invalid parameters are provided to constructor
    error InvalidConstructorParams();


    /********************************************** 
    *               Modifiers
    *********************************************/

    /**
     * @notice Validates that a given amount is non-zero
     * @param _amount Amount to validate (in wei)
     */
    modifier nonZeroAmount(uint256 _amount) {
        if (_amount == 0) {
            revert InvalidAmount();
        }
        _;
    }

    /**
     * @notice Ensures a deposit won't exceed the global bank cap
     * @param _amount Amount to check (in wei)
     */
     modifier checkBankCap(uint256 _amount) {
        if (totalDeposited + _amount > bankCap) {
            revert BankCapExceeded();
        }
        _;
     }


    /********************************************** 
    *               Constructor
    *********************************************/

    /**
     * @notice Initializes the contract with deposit and withdrawal limits
     * @dev Both parameters must be greater than zero
     * @param _bankCap The maximum ETH capacity of the contract
     * @param _withdrawalThreshold The per-transaction withdrawal limit
     */
    constructor(uint256 _bankCap, uint256 _withdrawalThreshold) {
        if (_bankCap == 0 || _withdrawalThreshold == 0) {
            revert InvalidConstructorParams();
        }

        bankCap = _bankCap;
        withdrawalThreshold = _withdrawalThreshold;
    }


    /********************************************** 
    *               External Fnuctions
    *********************************************/

    /**
     * @notice Allows a user to deposit ETH into their personal vault
     * @dev The deposit amount is the ETH value sent with the transaction (msg.value)
     * @dev Follows the Checks-Effects-Interactions pattern
     * @dev Emits a {DepositSuccessful} event.
     */
    function deposit() external payable  checkBankCap(msg.value) {
        // Checks
        // The non-zero amount is checked 
        if (msg.value == 0) {
            revert InvalidAmount();
        }


        // Effects
        userVaults[msg.sender] += msg.value;
        totalDeposited += msg.value;
        depositCount++;                     // Increase the deposit counter


        // Interactions
        emit DepositSuccessful(msg.sender, msg.value);  

    }

    /**
     * @notice Allows a user to withdraw a specific amount of ETH from their vault
     * @dev Follows checks-effects-interactions
     * @dev Emits a {WithdrawalSuccessful} event
     * @param _amount Amount of ETH to withdraw (in wei)
     */
    function withdraw(uint256 _amount) external nonZeroAmount(_amount) {
        // Checks
        // Ensure the withdrawal does not exceed the threshold
        if (_amount > withdrawalThreshold) {
            revert WithdrawalThresholdExceeded();
        }

        // Ensure the user has sufficient funds
        if (_amount > userVaults[msg.sender]) {
            revert InsufficientBalance();
        }

        // Effects
        userVaults[msg.sender] -= _amount;
        totalDeposited -= _amount;
        withdrawalCount++;                  // Increase the withdrawal counter

        // Interactions
        _safeTransfer(msg.sender, _amount);     // Transfer the currency safely
        emit WithdrawalSuccessful(msg.sender, _amount);

    }


    /********************************************** 
    *               View Functions
    *********************************************/

    /**
     * @notice Returns the ETH balance of the calling user
     * @return balance User’s current balance in the vault (in wei)
     */
    function getMyBalance() external view returns (uint256 balance) {
        return userVaults[msg.sender];
    }

    /**
     * @notice Returns statistics of the contract
     * @return Total number of deposits, withdrawals, and total deposited ETH
     */
    function getBankStats() external view returns (uint256, uint256, uint256) {
        return (depositCount, withdrawalCount, totalDeposited);
    }

    /**
     * @notice Returns the remaining capacity available for deposits
     * @return remaining Available deposit capacity in wei
     */
    function getRemainingCapacity() external view returns (uint256 remaining) {
        return bankCap - totalDeposited;
    }


    /********************************************** 
    *               Private Functions
    *********************************************/
  
    /**
     * @notice Internal function to handle the safe transfer of ETH
     * @dev Reverts if the transfer fails
     * @param _destinationAddress The destination address for the transfer.
     * @param _amount The amount (in wei) to be transferred.
     */
    function _safeTransfer(address _destinationAddress, uint256 _amount) private {
        (bool success, ) = payable(_destinationAddress).call{value: _amount}("");
        if (!success) revert TransferFailed();
    }

}