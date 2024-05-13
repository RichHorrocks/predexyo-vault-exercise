// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

library Errors {
    /// @notice Token transfer failed.
    /// @param _from sender of the transfer.
    /// @param _token token address.
    /// @param _amount amount of token to transfer.
    error TokenTransferFailed(address _from, address _token, uint256 _amount);

    /// @notice Insufficient balance for transfer. Needed `_requested` but only
    /// `_balance` available.
    /// @param _balance balance available.
    /// @param _requested requested amount to transfer.
    error InsufficientETHBalance(uint256 _balance, uint256 _requested);

    /// Insufficient balance for transfer. Needed `_requested` but only
    /// `_balance` available.
    /// @param _balance balance available.
    /// @param _requested requested amount to transfer.
    error InsufficientTokenBalance(uint256 _balance, uint256 _requested);

    /// Insufficient balance for transfer. Needed `_requested` but only
    /// `_balance` available.
    /// @param _balance balance available.
    /// @param _requested requested amount to transfer.
    error InsufficientWrappedBalance(uint256 _balance, uint256 _requested);

    /// Transfer of ETH failed.
    /// @param _to recipient of the transfer.
    /// @param _amount amount of ETH to transfer.
    error ETHTransferFailed(address _to, uint256 _amount);
}
