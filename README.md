## Predexyo Vault Exercise

A vault implementation providing the following functionality:

- ETH deposits and withdrawals
- ETH <-> WETH wrapping and unwrapping, via interactions with external WETH contract
- ERC20 deposits and withdrawals
- ETH, WETH, and ERC20 balance tracking

### Files

Project composition:

- `Vault.sol` - main vault implementation
- `error/Errors.sol` - error library
- `interfaces/IWETH.sol` - WETH interface
- `test/mocks` - mocks of WETH and ERC20 contracts
- `test/Vault.token.t.sol` - token-related tests
- `test/Vault.wrap.t.sol` - ETH- and WETH-related tests

## Instructions

### Prerequisites

This is a Foundry project, so requires Foundry to be installed.

See: https://book.getfoundry.sh/getting-started/installation

### Build

```shell
$ forge install
$ forge build
```

### Test

```shell
$ forge test
```

## Ideas for further improvement

- Security:
  - Re-entrancy guards (e.g. OpenZeppelin `ReentrancyGuard`)
  - Safer ERC20 calls, for better handling of tokens that aren't quite ERC20 compliant, such as USDT. (e.g. OpenZeppelin `SafeERC20`)
  - Static analysis, using something like Slither or Mythril
- Gas:
  - Proper analysis of gas costs, using Foundry's Snapshot feature
- Testing:
  - Fuzz testing, using Foundry's fuzzers
