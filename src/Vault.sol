// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IWETH} from "./interfaces/IWETH.sol";
import {Errors} from "./errors/Errors.sol";

/// @title Vault contract.
/// @notice This contract allows the following actions:
///   - Deposit and withdraw ETH.
///   - Wrap and unwrap ETH into WETH.
///   - Deposit and withdraw ERC20 tokens.
///   - Track balances of ETH, WETH, and ERC20 tokens.

contract Vault {
    /// @dev Address of the WETH contract, set in the constructor.
    address public WETH;

    /// @dev Balances of ETH, WETH, and ERC20 tokens for each user, and total
    /// deposits for each token.
    mapping(address => uint256) public balances;
    mapping(address => uint256) public wrappedBalances;
    mapping(address => mapping(address => uint256)) public tokenBalances;
    mapping(address => uint256) public totalDeposits;

    /// @dev Events are emitted by each of the main functions.
    event DepositToken(
        address indexed user,
        address indexed token,
        uint256 amount
    );
    event WithdrawToken(
        address indexed user,
        address indexed token,
        uint256 amount
    );
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Wrap(address indexed user, uint256 amount);
    event Unwrap(address indexed user, uint256 amount);

    constructor(address _weth) {
        WETH = _weth;
    }

    /// @notice Deposits tokens into the vault.
    /// @param _token Address of the token to deposit.
    /// @param _amount Amount of tokens to deposit.
    /// @dev Reverts if the token transfer fails.
    function depositToken(address _token, uint256 _amount) public {
        tokenBalances[msg.sender][_token] += _amount;
        totalDeposits[_token] += _amount;

        if (!IERC20(_token).transferFrom(msg.sender, address(this), _amount)) {
            revert Errors.TokenTransferFailed(msg.sender, _token, _amount);
        }
        emit DepositToken(msg.sender, _token, _amount);
    }

    /// @notice Withdraws tokens from the vault.
    /// @param _token Address of the token to withdraw.
    /// @param _amount Amount of tokens to withdraw.
    /// @dev Reverts if the sender's token balance is insufficient.
    function withdrawToken(address _token, uint256 _amount) public {
        if (tokenBalances[msg.sender][_token] < _amount) {
            revert Errors.InsufficientTokenBalance(
                tokenBalances[msg.sender][_token],
                _amount
            );
        }

        tokenBalances[msg.sender][_token] -= _amount;
        totalDeposits[_token] -= _amount;
        IERC20(_token).transfer(msg.sender, _amount);
        emit WithdrawToken(msg.sender, _token, _amount);
    }

    /// @notice Deposits ETH into the vault.
    /// @dev This function is payable.
    function depositETH() public payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Withdraws ETH from the vault.
    /// @param _amount Amount of ETH to withdraw.
    /// @dev Reverts if the sender does not have enough ETH. Also reverts if
    /// the ETH transfer fails.
    function withdrawETH(uint256 _amount) external {
        if (balances[msg.sender] < _amount) {
            revert Errors.InsufficientETHBalance(balances[msg.sender], _amount);
        }

        balances[msg.sender] -= _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        if (!success) {
            revert Errors.ETHTransferFailed(msg.sender, _amount);
        }
        emit Withdraw(msg.sender, _amount);
    }

    /// @notice Wraps ETH into WETH.
    /// @param _amount Amount of ETH to wrap.
    /// @dev Reverts if the sender does not have enough ETH.
    function wrapETH(uint256 _amount) external {
        if (balances[msg.sender] < _amount) {
            revert Errors.InsufficientETHBalance(balances[msg.sender], _amount);
        }

        balances[msg.sender] -= _amount;
        wrappedBalances[msg.sender] += _amount;
        IWETH(WETH).deposit{value: _amount}();
        emit Wrap(msg.sender, _amount);
    }

    /// @notice Unwraps WETH into ETH.
    /// @param _amount Amount of WETH to unwrap.
    /// @dev Reverts if the sender does not have enough WETH.
    function unwrapETH(uint256 _amount) external {
        if (wrappedBalances[msg.sender] < _amount) {
            revert Errors.InsufficientWrappedBalance(
                wrappedBalances[msg.sender],
                _amount
            );
        }

        wrappedBalances[msg.sender] -= _amount;
        balances[msg.sender] += _amount;
        IWETH(WETH).withdraw(_amount);
        emit Unwrap(msg.sender, _amount);
    }

    /// @notice receive function to receive ETH.
    /// @dev This function is required for the unwrapping of WETH to ETH.
    receive() external payable {}
}
