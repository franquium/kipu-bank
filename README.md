# KipuBank Smart Contract

KipuBank is a Ethereum smart contract that allows users to deposit and withdraw native ETH from a personal vault, under strict restrictions defined at deployment. 
It follows best practices in smart contract design, using custom errors, modifiers, and the Checks-Effects-Interactions pattern to ensure safety and gas efficiency.

---

## Main Features

- Users can deposit native ETH into their personal vault
- Withdrawals are limited by a **per-transaction threshold**
- Deposits are restricted by a **global vault capacity** (`bankCap`)
- The contract tracks:
  - Total amount deposited
  - Number of deposits
  - Number of withdrawals
- Emits events on successful deposit and withdrawal
- Includes secure ETH transfer logic and input validation
- All public and external elements are documented with NatSpec

---

## Deployment Instructions

You can deploy the contract using the [Remix IDE](https://remix.ethereum.org/) with MetaMask and Sepolia testnet.

### Prerequisites

- MetaMask wallet installed and connected to Sepolia testnet
- ETH in your Sepolia wallet [use a Sepolia faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)
- Contract code loaded into Remix

### Steps

1. Open [Remix IDE](https://remix.ethereum.org/)

2. Create a new file named `KipuBank.sol` and paste the full contract code.

3. Compile the Contract

    In the **Solidity Compiler** tab:
    - Select compiler version `^0.8.19`
    - Click on `Compile KipuBank.sol`

4. Deployment configure and deploy contract

    In the **Deploy & Run Transactions** tab:
   - Select `Injected Provider - MetaMask` as the environment.
   - Ensure MetaMask is set to **Sepolia testnet**.
   - Enter constructor parameters:
     - `_bankCap`: Max ETH the contract can hold (in wei), e.g.: `50000000000000000` (0.05 ETH)
     - `_withdrawalThreshold`: Max withdrawal per transaction (in wei), e.g.: `2000000000000000` (0.002 ETH)
   - Click **Transact** and confirm in MetaMask.

5.  Verify the contract

    Once deployed, copy your contract address and verify it at:  
        [`https://sepolia.etherscan.io/`](https://sepolia.etherscan.io/)

---

## How to Interact with the Contract

All interactions can be done through Remix’s UI or directly in the deployed contract tab:

### Deposit ETH

- Select the deployed contract in Remix
- Enter an amount of ETH (in the `Value` field at top)
- Click `deposit()`
- The contract will store the ETH in your personal vault
- Emits: `DepositSuccessful(address, amount)`

### Withdraw ETH

- Call `withdraw(uint256 amount)`  
  - Must not exceed `withdrawalThreshold`  
  - Must be less than or equal to your vault balance 
  - Emits: `WithdrawalSuccessful(address, amount)`


### View Functions

| Function                | Description                                             |
|-------------------------|---------------------------------------------------------|
| `getMyBalance()`        | Returns your current vault balance in wei               |
| `getBankStats()`        | Returns (depositCount, withdrawalCount, totalDeposited) |
| `getRemainingCapacity()`| Shows how much ETH can still be deposited               |

---

## Contract Address

Once deployed, your contract address will appear here:  
`https://sepolia.etherscan.io/address/<YOUR_CONTRACT_ADDRESS>`

You can verify and interact with it directly via Etherscan as well.

---

## License

This project is licensed under the [MIT License](https://github.com/franquium/kipu-bank/blob/main/LICENSE).

---

## Author

Made with by `@franquium`  

